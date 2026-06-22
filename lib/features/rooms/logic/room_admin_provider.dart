import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/ws_background_controller.dart';
import '../../../core/network/ws_event_bus.dart';
import 'room_ws_handlers.dart';

final roomAdminProvider =
    StateNotifierProvider<RoomAdminNotifier, RoomAdminState>((ref) {
  return RoomAdminNotifier(ref);
});

class RoomAdminState {
  final bool loading;
  final String? error;

  final String activeRoomId;

  /*
    key = roomId_role
    مثال:
    room_123_owner
    room_123_admin
    room_123_member
  */
  final Map<String, List<Map<String, dynamic>>> roleUsersByRoom;

  /*
    key = roomId
  */
  final Map<String, List<Map<String, dynamic>>> logsByRoom;

  /*
    key = roomId
    value:
    {
      bannedUsers: [],
      bannedIps: []
    }
  */
  final Map<String, Map<String, dynamic>> bannedByRoom;

  const RoomAdminState({
    required this.loading,
    required this.error,
    required this.activeRoomId,
    required this.roleUsersByRoom,
    required this.logsByRoom,
    required this.bannedByRoom,
  });

  factory RoomAdminState.initial() {
    return const RoomAdminState(
      loading: false,
      error: null,
      activeRoomId: '',
      roleUsersByRoom: {},
      logsByRoom: {},
      bannedByRoom: {},
    );
  }

  RoomAdminState copyWith({
    bool? loading,
    String? error,
    String? activeRoomId,
    Map<String, List<Map<String, dynamic>>>? roleUsersByRoom,
    Map<String, List<Map<String, dynamic>>>? logsByRoom,
    Map<String, Map<String, dynamic>>? bannedByRoom,
  }) {
    return RoomAdminState(
      loading: loading ?? this.loading,
      error: error,
      activeRoomId: activeRoomId ?? this.activeRoomId,
      roleUsersByRoom: roleUsersByRoom ?? this.roleUsersByRoom,
      logsByRoom: logsByRoom ?? this.logsByRoom,
      bannedByRoom: bannedByRoom ?? this.bannedByRoom,
    );
  }
}

class RoomAdminNotifier extends StateNotifier<RoomAdminState> {
  final Ref ref;

  RoomAdminNotifier(this.ref) : super(RoomAdminState.initial());

  StreamSubscription<Map<String, dynamic>>? _subscription;

  void attachListeners() {
    _subscription?.cancel();

    _subscription = WsEventBus.instance.stream.listen((data) {
      final handler = _s(data['handler']);

      if (handler != RoomWsEvents.roomUpdate) {
        return;
      }

      _handleRoomUpdate(data);
    });
  }

  void disposeListeners() {
    _subscription?.cancel();
    _subscription = null;
  }

  /*
    جلب مستخدمين حسب الرتبة:
    owner / admin / member / creator
  */
  void listRoomRoles({required String roomId, required String role}) {
    final cleanRoomId = roomId.trim();
    final cleanRole = role.trim();

    if (cleanRoomId.isEmpty || cleanRole.isEmpty) return;

    state = state.copyWith(
      loading: true,
      error: null,
      activeRoomId: cleanRoomId,
    );

    sendBackgroundWs({
      'handler': RoomWsHandlers.roomRolesList,
      'roomId': cleanRoomId,
      'role': cleanRole,
    });
  }

  /*
    حذف أي رتبة وإرجاع المستخدم none
  */
  void removeRoomRole({
    required String roomId,
    required String targetUserId,
    String targetUsername = '',
  }) {
    final cleanRoomId = roomId.trim();
    final cleanTargetUserId = targetUserId.trim();

    if (cleanRoomId.isEmpty || cleanTargetUserId.isEmpty) return;

    state = state.copyWith(
      loading: true,
      error: null,
      activeRoomId: cleanRoomId,
    );

    sendBackgroundWs({
      'handler': RoomWsHandlers.roomRoleRemove,
      'roomId': cleanRoomId,
      'targetUserId': cleanTargetUserId,
      'targetUsername': targetUsername.trim(),
    });
  }

  /*
    جلب لوجات الغرفة
  */
  void listRoomLogs({required String roomId, int limit = 50}) {
    final cleanRoomId = roomId.trim();

    if (cleanRoomId.isEmpty) return;

    state = state.copyWith(
      loading: true,
      error: null,
      activeRoomId: cleanRoomId,
    );

    sendBackgroundWs({
      'handler': RoomWsHandlers.roomLogsList,
      'roomId': cleanRoomId,
      'limit': limit,
    });
  }

  /*
    جلب المحظورين
  */
  void listRoomBanned({required String roomId}) {
    final cleanRoomId = roomId.trim();

    if (cleanRoomId.isEmpty) return;

    state = state.copyWith(
      loading: true,
      error: null,
      activeRoomId: cleanRoomId,
    );

    sendBackgroundWs({
      'handler': RoomWsHandlers.roomBannedList,
      'roomId': cleanRoomId,
    });
  }

  void clearRoomAdminData(String roomId) {
    final cleanRoomId = roomId.trim();

    if (cleanRoomId.isEmpty) return;

    final nextRoleUsers = Map<String, List<Map<String, dynamic>>>.from(
      state.roleUsersByRoom,
    );

    nextRoleUsers.remove('${cleanRoomId}_creator');
    nextRoleUsers.remove('${cleanRoomId}_owner');
    nextRoleUsers.remove('${cleanRoomId}_admin');
    nextRoleUsers.remove('${cleanRoomId}_member');
    nextRoleUsers.remove('${cleanRoomId}_none');

    final nextLogs = Map<String, List<Map<String, dynamic>>>.from(
      state.logsByRoom,
    );

    nextLogs.remove(cleanRoomId);

    final nextBanned = Map<String, Map<String, dynamic>>.from(
      state.bannedByRoom,
    );

    nextBanned.remove(cleanRoomId);

    state = state.copyWith(
      roleUsersByRoom: nextRoleUsers,
      logsByRoom: nextLogs,
      bannedByRoom: nextBanned,
    );
  }

  List<Map<String, dynamic>> getRoleUsers({
    required String roomId,
    required String role,
  }) {
    final key = '${roomId.trim()}_${role.trim()}';

    return state.roleUsersByRoom[key] ?? <Map<String, dynamic>>[];
  }

  List<Map<String, dynamic>> getLogs(String roomId) {
    return state.logsByRoom[roomId.trim()] ?? <Map<String, dynamic>>[];
  }

  List<Map<String, dynamic>> getBannedUsers(String roomId) {
    final banned = state.bannedByRoom[roomId.trim()] ?? {};

    final users = banned['bannedUsers'];

    if (users is List<Map<String, dynamic>>) {
      return users;
    }

    if (users is List) {
      return _readAnyMapList(users);
    }

    return <Map<String, dynamic>>[];
  }

  List<String> getBannedIps(String roomId) {
    final banned = state.bannedByRoom[roomId.trim()] ?? {};

    final ips = banned['bannedIps'];

    if (ips is List<String>) {
      return ips;
    }

    if (ips is List) {
      return ips.map((item) => item.toString()).toList();
    }

    return <String>[];
  }

  void _handleRoomUpdate(dynamic data) {
    final map = _asMap(data);

    final type = _s(map['type']);
    final roomId = _s(map['roomId']);

    if (roomId.isEmpty) return;

    if (type == 'roles_list') {
      _handleRolesList(map);
      return;
    }

    if (type == 'logs') {
      _handleLogs(map);
      return;
    }

    if (type == 'banned_list') {
      _handleBannedList(map);
      return;
    }

    if (type == 'role_remove') {
      _handleRoleRemove(map);
      return;
    }
  }

  void _handleRolesList(Map<String, dynamic> map) {
    final roomId = _s(map['roomId']);
    final role = _s(map['role'], fallback: 'none');

    final users = _readAnyMapList(map['users']);

    final key = '${roomId}_$role';

    final next = Map<String, List<Map<String, dynamic>>>.from(
      state.roleUsersByRoom,
    );

    next[key] = users;

    state = state.copyWith(
      loading: false,
      error: null,
      activeRoomId: roomId,
      roleUsersByRoom: next,
    );
  }

  void _handleLogs(Map<String, dynamic> map) {
    final roomId = _s(map['roomId']);
    final logs = _readAnyMapList(map['logs']);

    final next = Map<String, List<Map<String, dynamic>>>.from(state.logsByRoom);

    next[roomId] = logs;

    state = state.copyWith(
      loading: false,
      error: null,
      activeRoomId: roomId,
      logsByRoom: next,
    );
  }

  void _handleBannedList(Map<String, dynamic> map) {
    final roomId = _s(map['roomId']);

    final bannedUsers = _readAnyMapList(map['bannedUsers']);

    final bannedIpsRaw = map['bannedIps'];

    final bannedIps = bannedIpsRaw is List
        ? bannedIpsRaw.map((item) => item.toString()).toList()
        : <String>[];

    final next = Map<String, Map<String, dynamic>>.from(state.bannedByRoom);

    next[roomId] = {
      'bannedUsers': bannedUsers,
      'bannedIps': bannedIps,
    };

    state = state.copyWith(
      loading: false,
      error: null,
      activeRoomId: roomId,
      bannedByRoom: next,
    );
  }

  void _handleRoleRemove(Map<String, dynamic> map) {
    final roomId = _s(map['roomId']);
    final targetUserId = _s(map['targetUserId'] ?? map['target_user_id']);
    final oldRole = _s(map['oldRole'] ?? map['old_role']);

    if (roomId.isEmpty || targetUserId.isEmpty) {
      state = state.copyWith(loading: false);
      return;
    }

    /*
      لو عندك قائمة role محملة، احذف المستخدم منها مباشرة
      حتى تختفي من شاشة Owners/Admins/Members بدون إعادة تحميل.
    */
    final next = Map<String, List<Map<String, dynamic>>>.from(
      state.roleUsersByRoom,
    );

    final roles = <String>[
      'creator',
      'owner',
      'admin',
      'member',
      'none',
      oldRole,
    ];

    for (final role in roles) {
      final cleanRole = role.trim();

      if (cleanRole.isEmpty) continue;

      final key = '${roomId}_$cleanRole';
      final oldList = next[key];

      if (oldList == null) continue;

      next[key] = oldList.where((user) {
        return _s(user['userId']) != targetUserId;
      }).toList();
    }

    state = state.copyWith(
      loading: false,
      error: null,
      activeRoomId: roomId,
      roleUsersByRoom: next,
    );
  }

  void setError(String message) {
    state = state.copyWith(loading: false, error: message);
  }

  @override
  void dispose() {
    disposeListeners();
    super.dispose();
  }
}

List<Map<String, dynamic>> _readAnyMapList(dynamic value) {
  if (value is! List) {
    return <Map<String, dynamic>>[];
  }

  return value
      .whereType<Map>()
      .map((item) {
        return item.map((key, value) => MapEntry(key.toString(), value));
      })
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

Map<String, dynamic> _asMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;

  if (data is Map) {
    return data.map((key, value) => MapEntry(key.toString(), value));
  }

  return {};
}

String _s(dynamic value, {String fallback = ''}) {
  final text = (value ?? '').toString().trim();
  return text.isEmpty ? fallback : text;
}