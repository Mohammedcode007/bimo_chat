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

          final pending = Set<String>.from(state.pendingFriendUserIds);
          final friends = Set<String>.from(state.friendUserIds);
          final blocked = Set<String>.from(state.blockedUserIds);

          for (final user in users) {
            final userId = user['userId']?.toString() ?? '';
            if (userId.isEmpty) continue;

            if (_readBool(user['hasPendingFriendRequest']) ||
                _readBool(user['isPendingFriendRequest'])) {
              pending.add(userId);
            }

            if (_readBool(user['isFriend'])) {
              friends.add(userId);
            }

            if (_readBool(user['isBlocked']) ||
                _readBool(user['blockedByMe']) ||
                _readBool(user['hasBlockedMe'])) {
              blocked.add(userId);
            }
          }

          state = state.copyWith(
            loading: false,
            error: null,
            searchResults: users,
            pendingFriendUserIds: pending,
            friendUserIds: friends,
            blockedUserIds: blocked,
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

          final userId = profile['userId']?.toString() ?? '';

          final pending = Set<String>.from(state.pendingFriendUserIds);
          final friends = Set<String>.from(state.friendUserIds);
          final blocked = Set<String>.from(state.blockedUserIds);

          if (userId.isNotEmpty) {
            if (_readBool(profile['hasPendingFriendRequest']) ||
                _readBool(profile['isPendingFriendRequest'])) {
              pending.add(userId);
            }

            if (_readBool(profile['isFriend'])) {
              friends.add(userId);
            }

            if (_readBool(profile['isBlocked']) ||
                _readBool(profile['blockedByMe']) ||
                _readBool(profile['hasBlockedMe'])) {
              blocked.add(userId);
            }
          }

          state = state.copyWith(
            loading: false,
            error: null,
            profile: profile,
            pendingFriendUserIds: pending,
            friendUserIds: friends,
            blockedUserIds: blocked,
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

          final requestId = request['requestId']?.toString() ?? '';

          final exists = state.incomingFriendRequests.any((item) {
            return item['requestId']?.toString() == requestId;
          });

          final item = {...request, 'fromUser': fromUser};

          state = state.copyWith(
            incomingFriendRequests: exists
                ? state.incomingFriendRequests
                : [item, ...state.incomingFriendRequests],
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
            searchResults: state.searchResults.map((item) {
              if (item['userId']?.toString() == toUserId) {
                return {
                  ...item,
                  'hasPendingFriendRequest': true,
                  'isPendingFriendRequest': true,
                };
              }

              return item;
            }).toList(),
            profile:
                state.profile != null &&
                    state.profile!['userId']?.toString() == toUserId
                ? {
                    ...state.profile!,
                    'hasPendingFriendRequest': true,
                    'isPendingFriendRequest': true,
                  }
                : state.profile,
          );
          return;
        }

        state = state.copyWith(
          loading: false,
          error: data['reason']?.toString() ?? 'friend_request_error',
        );
        return;
      }

      if (handler == WsEvents.incomingFriendRequestsGetEvent) {
        if (type == 'success') {
          final requests = data['requests'] is List
              ? List<Map<String, dynamic>>.from(
                  (data['requests'] as List).map(
                    (item) => Map<String, dynamic>.from(item as Map),
                  ),
                )
              : <Map<String, dynamic>>[];

          state = state.copyWith(
            loading: false,
            error: null,
            incomingFriendRequests: requests,
          );
          return;
        }

        state = state.copyWith(
          loading: false,
          error: data['reason']?.toString() ?? 'incoming_requests_error',
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

          final fromUserId =
              fromUser['userId']?.toString() ??
              request['fromUserId']?.toString() ??
              '';

          final toUserId =
              toUser['userId']?.toString() ??
              request['toUserId']?.toString() ??
              '';

          final pending = Set<String>.from(state.pendingFriendUserIds);
          final friends = Set<String>.from(state.friendUserIds);

          pending.remove(fromUserId);
          pending.remove(toUserId);

          var friendsList = List<Map<String, dynamic>>.from(state.friends);

          if (action == 'accept') {
            if (fromUserId.isNotEmpty) friends.add(fromUserId);
            if (toUserId.isNotEmpty) friends.add(toUserId);

            final candidates = [fromUser, toUser];

            for (final candidate in candidates) {
              final id = candidate['userId']?.toString() ?? '';
              if (id.isEmpty) continue;

              final alreadyExists = friendsList.any((item) {
                return item['userId']?.toString() == id;
              });

              if (!alreadyExists) {
                friendsList.insert(0, {
                  ...candidate,
                  'isFriend': true,
                  'hasPendingFriendRequest': false,
                });
              }
            }
          }

          state = state.copyWith(
            loading: false,
            error: null,
            pendingFriendUserIds: pending,
            friendUserIds: friends,
            friends: friendsList,
            incomingFriendRequests: state.incomingFriendRequests.where((item) {
              return item['requestId']?.toString() != requestId;
            }).toList(),
            searchResults: state.searchResults.map((item) {
              final id = item['userId']?.toString() ?? '';

              if (id == fromUserId || id == toUserId) {
                return {
                  ...item,
                  'isFriend': action == 'accept',
                  'hasPendingFriendRequest': false,
                  'isPendingFriendRequest': false,
                };
              }

              return item;
            }).toList(),
            profile:
                state.profile != null &&
                    (state.profile!['userId']?.toString() == fromUserId ||
                        state.profile!['userId']?.toString() == toUserId)
                ? {
                    ...state.profile!,
                    'isFriend': action == 'accept',
                    'hasPendingFriendRequest': false,
                    'isPendingFriendRequest': false,
                  }
                : state.profile,
          );

          return;
        }

        state = state.copyWith(
          loading: false,
          error: data['reason']?.toString() ?? 'friend_respond_error',
        );
        return;
      }

    if (handler == WsEvents.friendsGetEvent) {
  if (type == 'success') {
    final friendsList = data['friends'] is List
        ? List<Map<String, dynamic>>.from(
            (data['friends'] as List).map(
              (item) => Map<String, dynamic>.from(item as Map),
            ),
          )
        : <Map<String, dynamic>>[];

    final friendIds = <String>{};
    final blockedIds = Set<String>.from(state.blockedUserIds);
    final pendingIds = Set<String>.from(state.pendingFriendUserIds);

    for (final friend in friendsList) {
      final userId = friend['userId']?.toString() ?? '';

      if (userId.isEmpty) continue;

      friendIds.add(userId);

      if (_readBool(friend['isBlocked']) ||
          _readBool(friend['blockedByMe']) ||
          _readBool(friend['hasBlockedMe'])) {
        blockedIds.add(userId);
      }

      if (_readBool(friend['hasPendingFriendRequest']) ||
          _readBool(friend['isPendingFriendRequest'])) {
        pendingIds.add(userId);
      }
    }

    state = state.copyWith(
      loading: false,
      error: null,
      friends: friendsList,
      friendUserIds: friendIds,
      blockedUserIds: blockedIds,
      pendingFriendUserIds: pendingIds,
    );
    return;
  }

  state = state.copyWith(
    loading: false,
    error: data['reason']?.toString() ?? 'friends_get_error',
  );
  return;
}
      if (handler == WsEvents.friendRemoveEvent) {
        if (type == 'success' || type == 'friend_removed') {
          final removedUserId = data['removedUserId']?.toString() ?? '';

          final friends = Set<String>.from(state.friendUserIds);
          final pending = Set<String>.from(state.pendingFriendUserIds);

          friends.remove(removedUserId);
          pending.remove(removedUserId);

          state = state.copyWith(
            loading: false,
            error: null,
            friendUserIds: friends,
            pendingFriendUserIds: pending,
            friends: state.friends.where((item) {
              return item['userId']?.toString() != removedUserId;
            }).toList(),
            searchResults: state.searchResults.map((item) {
              if (item['userId']?.toString() == removedUserId) {
                return {
                  ...item,
                  'isFriend': false,
                  'hasPendingFriendRequest': false,
                  'isPendingFriendRequest': false,
                };
              }

              return item;
            }).toList(),
            profile:
                state.profile != null &&
                    state.profile!['userId']?.toString() == removedUserId
                ? {
                    ...state.profile!,
                    'isFriend': false,
                    'hasPendingFriendRequest': false,
                    'isPendingFriendRequest': false,
                  }
                : state.profile,
          );

          return;
        }

        state = state.copyWith(
          loading: false,
          error: data['reason']?.toString() ?? 'friend_remove_error',
        );
        return;
      }

      if (handler == WsEvents.usersBlockedListEvent) {
        if (type == 'success') {
          final blockedUsers = data['blockedUsers'] is List
              ? List<Map<String, dynamic>>.from(
                  (data['blockedUsers'] as List).map(
                    (item) => Map<String, dynamic>.from(item as Map),
                  ),
                )
              : <Map<String, dynamic>>[];

          final blockedIds = blockedUsers
              .map((item) => item['userId']?.toString() ?? '')
              .where((id) => id.isNotEmpty)
              .toSet();

          state = state.copyWith(
            loading: false,
            error: null,
            blockedUsers: blockedUsers,
            blockedUserIds: blockedIds,
          );
          return;
        }

        state = state.copyWith(
          loading: false,
          error: data['reason']?.toString() ?? 'blocked_users_error',
        );
        return;
      }

      if (handler == WsEvents.userBlockEvent) {
        if (type == 'success') {
          final targetUserId =
              data['target_user_id']?.toString() ??
              data['targetUserId']?.toString() ??
              '';

          final blocked = _readBool(data['blocked']);

          final blockedIds = Set<String>.from(state.blockedUserIds);

          if (targetUserId.isNotEmpty) {
            if (blocked) {
              blockedIds.add(targetUserId);
            } else {
              blockedIds.remove(targetUserId);
            }
          }

          state = state.copyWith(
            loading: false,
            error: null,
            blockedUserIds: blockedIds,
            blockedUsers: blocked
                ? state.blockedUsers
                : state.blockedUsers.where((item) {
                    return item['userId']?.toString() != targetUserId;
                  }).toList(),
            searchResults: state.searchResults.map((item) {
              if (item['userId']?.toString() == targetUserId) {
                return {...item, 'isBlocked': blocked, 'blockedByMe': blocked};
              }

              return item;
            }).toList(),
            profile:
                state.profile != null &&
                    state.profile!['userId']?.toString() == targetUserId
                ? {
                    ...state.profile!,
                    'isBlocked': blocked,
                    'blockedByMe': blocked,
                  }
                : state.profile,
          );
          return;
        }

        state = state.copyWith(
          loading: false,
          error: data['reason']?.toString() ?? 'block_error',
        );
        return;
      }
      if (handler == WsEvents.userProfileLiveUpdateEvent) {
        final user = data['user'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(data['user'])
            : data['user'] is Map
            ? Map<String, dynamic>.from(data['user'] as Map)
            : <String, dynamic>{};

        final userId =
            data['userId']?.toString() ?? user['userId']?.toString() ?? '';

        if (userId.isEmpty) return;

        final isBlocked =
            _readBool(user['isBlocked']) ||
            _readBool(user['blockedByMe']) ||
            _readBool(user['hasBlockedMe']);

        final blockedIds = Set<String>.from(state.blockedUserIds);

        if (isBlocked) {
          blockedIds.add(userId);
        }

        state = state.copyWith(
          loading: false,
          error: null,
          blockedUserIds: blockedIds,
          friends: state.friends.map((item) {
            if (item['userId']?.toString() == userId) {
              return {...item, ...user};
            }

            return item;
          }).toList(),
          searchResults: state.searchResults.map((item) {
            if (item['userId']?.toString() == userId) {
              return {...item, ...user};
            }

            return item;
          }).toList(),
          blockedUsers: state.blockedUsers.map((item) {
            if (item['userId']?.toString() == userId) {
              return {...item, ...user};
            }

            return item;
          }).toList(),
          profile:
              state.profile != null &&
                  state.profile!['userId']?.toString() == userId
              ? {...state.profile!, ...user}
              : state.profile,
        );

        return;
      }
    });
  }

  static bool _readBool(dynamic value) {
    if (value == true) return true;
    if (value?.toString() == 'true') return true;
    return false;
  }

  void searchUsers(String query) {
    final q = query.trim();

    if (q.isEmpty) {
      state = state.copyWith(loading: false, error: null, searchResults: []);
      return;
    }

    state = state.copyWith(loading: true, error: null);

    ws.send({
      'handler': WsHandlers.usersSearch,
      'request_id': const Uuid().v4(),
      'query': q,
      'limit': 30,
    });
  }

  void getUserProfile(String targetUserId) {
    if (targetUserId.trim().isEmpty) return;

    state = state.copyWith(loading: true, error: null, profile: null);

    ws.send({
      'handler': WsHandlers.usersProfileGet,
      'request_id': const Uuid().v4(),
      'target_user_id': targetUserId.trim(),
    });
  }

  void sendFriendRequest(String toUserId) {
    if (toUserId.trim().isEmpty) return;

    state = state.copyWith(loading: true, error: null);

    ws.send({
      'handler': WsHandlers.friendRequestSend,
      'request_id': const Uuid().v4(),
      'to_user_id': toUserId.trim(),
    });
  }

  void getIncomingFriendRequests() {
    state = state.copyWith(loading: true, error: null);

    ws.send({
      'handler': WsHandlers.incomingFriendRequestsGet,
      'request_id': const Uuid().v4(),
    });
  }

  void getFriends() {
    state = state.copyWith(loading: true, error: null);

    ws.send({
      'handler': WsHandlers.friendsGet,
      'request_id': const Uuid().v4(),
    });
  }

  void removeFriend(String friendUserId) {
    if (friendUserId.trim().isEmpty) return;

    state = state.copyWith(loading: true, error: null);

    ws.send({
      'handler': WsHandlers.friendRemove,
      'request_id': const Uuid().v4(),
      'friend_user_id': friendUserId.trim(),
    });
  }

  void blockUser(String targetUserId) {
    if (targetUserId.trim().isEmpty) return;

    state = state.copyWith(loading: true, error: null);

    ws.send({
      'handler': WsHandlers.usersBlock,
      'request_id': const Uuid().v4(),
      'target_user_id': targetUserId.trim(),
    });
  }

  void unblockUser(String targetUserId) {
    if (targetUserId.trim().isEmpty) return;

    state = state.copyWith(loading: true, error: null);

    ws.send({
      'handler': WsHandlers.usersUnblock,
      'request_id': const Uuid().v4(),
      'target_user_id': targetUserId.trim(),
    });
  }

  void getBlockedUsers() {
    state = state.copyWith(loading: true, error: null);

    ws.send({
      'handler': WsHandlers.usersBlockedList,
      'request_id': const Uuid().v4(),
    });
  }

  void respondFriendRequest({
    required String requestId,
    required String action,
  }) {
    if (requestId.trim().isEmpty) return;
    if (action != 'accept' && action != 'reject') return;

    state = state.copyWith(loading: true, error: null);

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
