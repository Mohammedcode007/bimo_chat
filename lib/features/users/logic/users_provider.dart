import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/ws_events.dart';
import '../../../core/constants/ws_handlers.dart';
import '../../../core/network/ws_client.dart';
import '../../../core/network/ws_provider.dart';
import 'users_state.dart';

final usersProvider = StateNotifierProvider<UsersController, UsersState>((ref) {
  final ws = ref.watch(wsClientProvider);
  return UsersController(ws);
});

class UsersController extends StateNotifier<UsersState> {
  final WsClient ws;

  StreamSubscription? _sub;

  UsersController(this.ws) : super(const UsersState()) {
    _listen();
  }

  void _listen() {
    _sub = ws.stream.listen((data) {
      final handler = data['handler']?.toString();
      final type = data['type']?.toString();

      if (handler == WsEvents.usersSearchEvent) {
        if (type == 'success') {
          final users = data['users'] is List
              ? List<Map<String, dynamic>>.from(
                  (data['users'] as List).map(
                    (item) => Map<String, dynamic>.from(item as Map),
                  ),
                )
              : <Map<String, dynamic>>[];

          state = state.copyWith(
            loading: false,
            error: null,
            searchResults: users,
          );
          return;
        }

        state = state.copyWith(
          loading: false,
          error: data['reason']?.toString() ?? 'search_error',
        );
        return;
      }

      if (handler == WsEvents.userProfileGetEvent) {
        if (type == 'success') {
          final profile = data['profile'] is Map<String, dynamic>
              ? Map<String, dynamic>.from(data['profile'])
              : <String, dynamic>{};

          state = state.copyWith(
            loading: false,
            error: null,
            profile: profile,
          );
          return;
        }

        state = state.copyWith(
          loading: false,
          error: data['reason']?.toString() ?? 'profile_error',
        );
        return;
      }

   if (handler == WsEvents.friendRequestSendEvent) {
  if (type == 'incoming') {
    final request = data['request'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(data['request'])
        : <String, dynamic>{};

    final fromUser = data['fromUser'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(data['fromUser'])
        : <String, dynamic>{};

    final item = {
      ...request,
      'fromUser': fromUser,
    };

    state = state.copyWith(
      incomingFriendRequests: [
        item,
        ...state.incomingFriendRequests,
      ],
    );

    return;
  }

  if (type == 'success') {
    final toUser = data['toUser'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(data['toUser'])
        : <String, dynamic>{};

    final toUserId = toUser['userId']?.toString() ?? '';

    final pending = Set<String>.from(state.pendingFriendUserIds);

    if (toUserId.isNotEmpty) {
      pending.add(toUserId);
    }

    state = state.copyWith(
      loading: false,
      error: null,
      pendingFriendUserIds: pending,
    );
    return;
  }

  state = state.copyWith(
    loading: false,
    error: data['reason']?.toString() ?? 'friend_request_error',
  );
  return;
}
    if (handler == WsEvents.friendRequestRespondEvent) {
  if (type == 'success' || type == 'friend_request_updated') {
    final action = data['action']?.toString() ?? '';

    final request = data['request'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(data['request'])
        : <String, dynamic>{};

    final fromUser = data['fromUser'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(data['fromUser'])
        : <String, dynamic>{};

    final toUser = data['toUser'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(data['toUser'])
        : <String, dynamic>{};

    final requestId = request['requestId']?.toString() ?? '';

    final fromUserId = fromUser['userId']?.toString() ??
        request['fromUserId']?.toString() ??
        '';

    final toUserId = toUser['userId']?.toString() ??
        request['toUserId']?.toString() ??
        '';

    final pending = Set<String>.from(state.pendingFriendUserIds);
    final friends = Set<String>.from(state.friendUserIds);

    pending.remove(fromUserId);
    pending.remove(toUserId);

    if (action == 'accept') {
      if (fromUserId.isNotEmpty) friends.add(fromUserId);
      if (toUserId.isNotEmpty) friends.add(toUserId);
    }

    state = state.copyWith(
      loading: false,
      error: null,
      pendingFriendUserIds: pending,
      friendUserIds: friends,
      incomingFriendRequests: state.incomingFriendRequests.where((item) {
        return item['requestId']?.toString() != requestId;
      }).toList(),
    );

    return;
  }

  state = state.copyWith(
    loading: false,
    error: data['reason']?.toString() ?? 'friend_respond_error',
  );
}
    });
  }

  void searchUsers(String query) {
    final q = query.trim();

    if (q.isEmpty) {
      state = state.copyWith(
        loading: false,
        error: null,
        searchResults: [],
      );
      return;
    }

    state = state.copyWith(
      loading: true,
      error: null,
    );

    ws.send({
      'handler': WsHandlers.usersSearch,
      'request_id': const Uuid().v4(),
      'query': q,
      'limit': 30,
    });
  }

  void getUserProfile(String targetUserId) {
    if (targetUserId.trim().isEmpty) return;

    state = state.copyWith(
      loading: true,
      error: null,
      profile: null,
    );

    ws.send({
      'handler': WsHandlers.usersProfileGet,
      'request_id': const Uuid().v4(),
      'target_user_id': targetUserId.trim(),
    });
  }

  void sendFriendRequest(String toUserId) {
    if (toUserId.trim().isEmpty) return;

    state = state.copyWith(
      loading: true,
      error: null,
    );

    ws.send({
      'handler': WsHandlers.friendRequestSend,
      'request_id': const Uuid().v4(),
      'to_user_id': toUserId.trim(),
    });
  }

  void respondFriendRequest({
    required String requestId,
    required String action,
  }) {
    if (requestId.trim().isEmpty) return;
    if (action != 'accept' && action != 'reject') return;

    state = state.copyWith(
      loading: true,
      error: null,
    );

    ws.send({
      'handler': WsHandlers.friendRequestRespond,
      'request_id': const Uuid().v4(),
      'request_id_value': requestId.trim(),
      'action': action,
    });
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}