import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/ws_client.dart';
import '../../../core/network/ws_provider.dart';
import '../models/room_model.dart';
import '../models/room_live_message_model.dart';
import 'room_ws_handlers.dart';

final roomsProvider = StateNotifierProvider<RoomsNotifier, RoomsState>((ref) {
  return RoomsNotifier(ref);
});

class RoomsState {
  final bool loading;
  final String? error;

  final String currentTab;
  final String? activeRoomId;

  final String myUserId;
  final String myUsername;

  final List<RoomModel> rooms;

  final Map<String, List<RoomLiveMessageModel>> messagesByRoom;
  final Map<String, int> activeCountByRoom;
  final Map<String, List<Map<String, dynamic>>> usersByRoom;

  const RoomsState({
    required this.loading,
    required this.error,
    required this.currentTab,
    required this.activeRoomId,
    required this.myUserId,
    required this.myUsername,
    required this.rooms,
    required this.messagesByRoom,
    required this.activeCountByRoom,
    required this.usersByRoom,
  });

  factory RoomsState.initial() {
    return const RoomsState(
      loading: false,
      error: null,
      currentTab: 'public',
      activeRoomId: null,
      myUserId: '',
      myUsername: '',
      rooms: [],
      messagesByRoom: {},
      activeCountByRoom: {},
      usersByRoom: {},
    );
  }

  RoomsState copyWith({
    bool? loading,
    String? error,
    String? currentTab,
    String? activeRoomId,
    String? myUserId,
    String? myUsername,
    List<RoomModel>? rooms,
    Map<String, List<RoomLiveMessageModel>>? messagesByRoom,
    Map<String, int>? activeCountByRoom,
    Map<String, List<Map<String, dynamic>>>? usersByRoom,
  }) {
    return RoomsState(
      loading: loading ?? this.loading,
      error: error,
      currentTab: currentTab ?? this.currentTab,
      activeRoomId: activeRoomId ?? this.activeRoomId,
      myUserId: myUserId ?? this.myUserId,
      myUsername: myUsername ?? this.myUsername,
      rooms: rooms ?? this.rooms,
      messagesByRoom: messagesByRoom ?? this.messagesByRoom,
      activeCountByRoom: activeCountByRoom ?? this.activeCountByRoom,
      usersByRoom: usersByRoom ?? this.usersByRoom,
    );
  }
}

class RoomsNotifier extends StateNotifier<RoomsState> {
  final Ref ref;

  RoomsNotifier(this.ref) : super(RoomsState.initial());

  WsClient get _ws => ref.read(wsClientProvider);

  StreamSubscription<Map<String, dynamic>>? _roomSubscription;

  void attachRoomSocketListeners() {
    _roomSubscription?.cancel();

    _roomSubscription = _ws.stream.listen((data) {
      final handler = _s(data['handler']);

      print('📥 ROOM WS EVENT: $handler => $data');
      final directType = _s(data['type']);
      final directHandler = _s(data['handler']);

      if (handler == 'room:kicked' ||
          directType == 'room:kicked' ||
          directHandler == 'room:kicked') {
        _handleRoomKicked(data);
        return;
      }

      if (handler == 'room:banned' ||
          directType == 'room:banned' ||
          directHandler == 'room:banned') {
        _handleRoomBanned(data);
        return;
      }
      if (handler == RoomWsEvents.roomList) {
        _handleRoomList(data);
        return;
      }

      if (handler == RoomWsEvents.roomCreate) {
        _handleRoomCreate(data);
        return;
      }

      if (handler == RoomWsEvents.roomJoin) {
        _handleRoomJoin(data);
        return;
      }

      if (handler == RoomWsEvents.roomLeave) {
        _handleRoomLeave(data);
        return;
      }

      if (handler == RoomWsEvents.roomMessage) {
        _handleRoomMessage(data);
        return;
      }

      if (handler == RoomWsEvents.roomReaction) {
        _handleRoomReaction(data);
        return;
      }

      if (handler == RoomWsEvents.roomUsers) {
        _handleRoomUsers(data);
        return;
      }

      if (handler == RoomWsEvents.roomUpdate) {
        _handleRoomUpdate(data);
        return;
      }

      if (handler == RoomWsEvents.roomActiveCount) {
        _handleRoomActiveCount(data);
        return;
      }

      if (handler == RoomWsEvents.roomError) {
        _handleRoomError(data);
        return;
      }
    });
  }

  void disposeRoomSocketListeners() {
    _roomSubscription?.cancel();
    _roomSubscription = null;
  }

  void listRooms(String tab) {
    state = state.copyWith(loading: true, error: null, currentTab: tab);

    _ws.send({'handler': RoomWsHandlers.roomList, 'tab': tab});
  }

  void createRoom({
    required String name,
    String description = '',
    String password = '',
    bool voiceEnabled = false,
  }) {
    _ws.send({
      'handler': RoomWsHandlers.roomCreate,
      'name': name,
      'description': description,
      'password': password,
      'voiceEnabled': voiceEnabled,
    });
  }

  void joinRoom({required String roomId, String password = ''}) {
    _ws.send({
      'handler': RoomWsHandlers.roomJoin,
      'roomId': roomId,
      'password': password,
    });
  }

  void leaveRoom(String roomId) {
    _ws.send({'handler': RoomWsHandlers.roomLeave, 'roomId': roomId});
  }

  void clearRoomLocalData(String roomId) {
    final id = roomId.trim();

    if (id.isEmpty) return;

    final nextMessages = Map<String, List<RoomLiveMessageModel>>.from(
      state.messagesByRoom,
    );

    final nextUsers = Map<String, List<Map<String, dynamic>>>.from(
      state.usersByRoom,
    );

    final nextCounts = Map<String, int>.from(state.activeCountByRoom);

    nextMessages.remove(id);
    nextUsers.remove(id);
    nextCounts.remove(id);

    state = state.copyWith(
      activeRoomId: state.activeRoomId == id ? null : state.activeRoomId,
      messagesByRoom: nextMessages,
      usersByRoom: nextUsers,
      activeCountByRoom: nextCounts,
    );
  }

  void sendTextMessage({
    required String roomId,
    required String text,
    Map<String, dynamic>? replyTo,
  }) {
    final cleanText = text.trim();

    if (cleanText.isEmpty) return;

    _ws.send({
      'handler': RoomWsHandlers.roomMessageSend,
      'roomId': roomId,
      'type': 'text',
      'text': cleanText,
      'replyTo': replyTo,
    });
  }

  void sendMediaMessage({
    required String roomId,
    required String type,
    required String url,
    String fileName = '',
    String mimeType = '',
    int sizeBytes = 0,
    Map<String, dynamic>? replyTo,
  }) {
    _ws.send({
      'handler': RoomWsHandlers.roomMessageSend,
      'roomId': roomId,
      'type': type,
      'media': {
        'url': url,
        'fileName': fileName,
        'mimeType': mimeType,
        'sizeBytes': sizeBytes,
      },
      'replyTo': replyTo,
    });
  }

Future<void> sendMediaBase64Message({
  required String roomId,
  required String type,
  required String mediaBase64,
  String fileName = '',
  String mimeType = '',
  int sizeBytes = 0,
  String duration = '',
  Map<String, dynamic>? replyTo,
}) async {
  final cleanRoomId = roomId.trim();
  final cleanType = type.trim().toLowerCase();
  final cleanBase64 = mediaBase64.trim();

  if (cleanRoomId.isEmpty) return;
  if (cleanType.isEmpty) return;
  if (cleanBase64.isEmpty) return;

  _ws.send({
    'handler': RoomWsHandlers.roomMessageSend,
    'roomId': cleanRoomId,
    'type': cleanType,
    'text': cleanType == 'audio' || cleanType == 'voice'
        ? 'Voice message'
        : '',
    'mediaBase64': cleanBase64,
    'fileName': fileName,
    'mimeType': mimeType,
    'sizeBytes': sizeBytes,
    'duration': duration,
    'replyTo': replyTo,
  });
}
  void reactToMessage({
    required String roomId,
    required String messageId,
    required String emoji,
  }) {
    _ws.send({
      'handler': RoomWsHandlers.roomMessageReaction,
      'roomId': roomId,
      'messageId': messageId,
      'emoji': emoji,
    });
  }

  void setRole({
    required String roomId,
    String targetUserId = '',
    required String targetUsername,
    required String newRole,
  }) {
    _ws.send({
      'handler': RoomWsHandlers.roomRoleSet,
      'roomId': roomId,
      'targetUserId': targetUserId,
      'targetUsername': targetUsername,
      'newRole': newRole,
    });
  }

  void kickUser({
    required String roomId,
    required String targetUserId,
    String targetUsername = '',
  }) {
    _ws.send({
      'handler': RoomWsHandlers.roomKick,
      'roomId': roomId,
      'targetUserId': targetUserId,
      'targetUsername': targetUsername,
    });
  }

  void banUser({
    required String roomId,
    String targetUserId = '',
    required String targetUsername,
    bool banIp = false,
  }) {
    _ws.send({
      'handler': RoomWsHandlers.roomBan,
      'roomId': roomId,
      'targetUserId': targetUserId,
      'targetUsername': targetUsername,
      'banIp': banIp,
    });
  }

  void setPassword({required String roomId, required String password}) {
    _ws.send({
      'handler': RoomWsHandlers.roomPasswordSet,
      'roomId': roomId,
      'password': password,
    });
  }

  void removePassword(String roomId) {
    _ws.send({
      'handler': RoomWsHandlers.roomPasswordSet,
      'roomId': roomId,
      'password': '',
    });
  }

  void setRoomLock({required String roomId, required bool locked}) {
    _ws.send({
      'handler': RoomWsHandlers.roomLockSet,
      'roomId': roomId,
      'locked': locked,
    });
  }

  void setPinnedMessage({required String roomId, required String text}) {
    _ws.send({
      'handler': RoomWsHandlers.roomPinSet,
      'roomId': roomId,
      'text': text,
    });
  }

  void toggleFavorite(String roomId) {
    _ws.send({'handler': RoomWsHandlers.roomFavoriteToggle, 'roomId': roomId});
  }

  void boostRoom({required String roomId, int value = 1}) {
    _ws.send({
      'handler': RoomWsHandlers.roomBoost,
      'roomId': roomId,
      'value': value,
    });
  }

  void _handleRoomKicked(dynamic data) {
    final map = _asMap(data);
    final roomId = _s(map['roomId']);
    final message = _s(map['message'], fallback: 'تم طردك من الغرفة');

    if (roomId.isEmpty) return;

    clearRoomLocalData(roomId);

    state = state.copyWith(error: message);
  }

  void _handleRoomBanned(dynamic data) {
    final map = _asMap(data);
    final roomId = _s(map['roomId']);
    final message = _s(map['message'], fallback: 'أنت محظور من هذه الغرفة');

    if (roomId.isEmpty) return;

    clearRoomLocalData(roomId);

    state = state.copyWith(error: message);
  }

  void _handleRoomList(dynamic data) {
    final map = _asMap(data);
    final list = map['rooms'];

    final rooms = list is List
        ? list
              .whereType<Map<String, dynamic>>()
              .map(RoomModel.fromJson)
              .toList()
        : <RoomModel>[];

    final nextCounts = Map<String, int>.from(state.activeCountByRoom);

    for (final room in rooms) {
      nextCounts[room.roomId] = room.activeCount;
    }

    state = state.copyWith(
      loading: false,
      error: null,
      rooms: rooms,
      activeCountByRoom: nextCounts,
    );
  }

  void _handleRoomCreate(dynamic data) {
    final map = _asMap(data);
    final roomJson = map['room'];

    if (roomJson is! Map<String, dynamic>) return;

    final room = RoomModel.fromJson(roomJson);

    final exists = state.rooms.any((item) => item.roomId == room.roomId);

    state = state.copyWith(
      rooms: exists
          ? state.rooms
                .map((item) => item.roomId == room.roomId ? room : item)
                .toList()
          : [room, ...state.rooms],
    );
  }

  void _handleRoomJoin(dynamic data) {
    final map = _asMap(data);

    final finalRoomId = _s(map['roomId']).isNotEmpty
        ? _s(map['roomId'])
        : _s(map['room'] is Map ? map['room']['roomId'] : null);

    if (finalRoomId.isEmpty) return;

    final currentUserId = _s(map['currentUserId']);
    final currentUsername = _s(map['currentUsername']);

    final pinned = map['pinnedMessage'];

    final messages = Map<String, List<RoomLiveMessageModel>>.from(
      state.messagesByRoom,
    );

    messages.putIfAbsent(finalRoomId, () => []);

    if (pinned is Map<String, dynamic>) {
      final text = _s(pinned['text']);

      if (text.isNotEmpty) {
        final alreadyPinned = messages[finalRoomId]!.any(
          (item) => item.messageId == 'pinned_$finalRoomId',
        );

        if (!alreadyPinned) {
          messages[finalRoomId] = [
            RoomLiveMessageModel.fromJson({
              'messageId': 'pinned_$finalRoomId',
              'roomId': finalRoomId,
              'messageKind': 'system',
              'type': 'none',
              'fromUserId': '',
              'fromUsername': '',
              'fromPhotoUrl': '',
              'fromRole': 'none',
              'text': text,
              'media': null,
              'mention': null,
              'gift': null,
              'entryVideo': null,
              'replyTo': null,
              'reactions': [],
              'system': {
                'action': 'pinned_changed',
                'actorId': '',
                'actorUsername': '',
                'targetUserId': '',
                'targetUsername': '',
              },
              'createdAt': DateTime.now().toIso8601String(),
            }),
            ...messages[finalRoomId]!,
          ];
        }
      }
    }

    final activeUsers = _readUsersList(map['activeUsers'] ?? map['users']);
    final activeCount = _i(
      map['activeCount'],
      fallback: activeUsers.isNotEmpty ? activeUsers.length : 0,
    );

    final nextCounts = Map<String, int>.from(state.activeCountByRoom);
    if (activeCount > 0) {
      nextCounts[finalRoomId] = activeCount;
    }

    final nextUsers = Map<String, List<Map<String, dynamic>>>.from(
      state.usersByRoom,
    );

    if (activeUsers.isNotEmpty) {
      nextUsers[finalRoomId] = activeUsers;
    }

    state = state.copyWith(
      activeRoomId: finalRoomId,
      myUserId: currentUserId.isNotEmpty ? currentUserId : state.myUserId,
      myUsername: currentUsername.isNotEmpty
          ? currentUsername
          : state.myUsername,
      messagesByRoom: messages,
      activeCountByRoom: nextCounts,
      usersByRoom: nextUsers,
    );
  }

  void _handleRoomLeave(dynamic data) {
    final map = _asMap(data);
    final roomId = _s(map['roomId']);

    if (roomId.isEmpty) return;

    final activeUsers = _readUsersList(map['activeUsers'] ?? map['users']);
    final activeCount = _i(
      map['activeCount'],
      fallback: activeUsers.isNotEmpty ? activeUsers.length : 0,
    );

    final nextCounts = Map<String, int>.from(state.activeCountByRoom);
    nextCounts[roomId] = activeCount;

    final nextUsers = Map<String, List<Map<String, dynamic>>>.from(
      state.usersByRoom,
    );

    nextUsers[roomId] = activeUsers;

    final updatedRooms = state.rooms.map((room) {
      if (room.roomId != roomId) return room;
      return room.copyWith(activeCount: activeCount);
    }).toList();

    state = state.copyWith(
      activeRoomId: state.activeRoomId == roomId ? null : state.activeRoomId,
      activeCountByRoom: nextCounts,
      usersByRoom: nextUsers,
      rooms: updatedRooms,
    );
  }

  void _handleRoomMessage(dynamic data) {
    final map = _asMap(data);
    final messageJson = map['message'];

    if (messageJson is! Map<String, dynamic>) return;

    final message = RoomLiveMessageModel.fromJson(messageJson);
    final roomId = message.roomId;

    if (roomId.isEmpty) return;

    final messages = Map<String, List<RoomLiveMessageModel>>.from(
      state.messagesByRoom,
    );

    final old = messages[roomId] ?? [];

    final exists = old.any((item) {
      if (item.messageId == message.messageId) return true;

      final isSystemLikeMessage =
          message.messageKind == 'join' ||
          message.messageKind == 'leave' ||
          message.messageKind == 'role' ||
          message.messageKind == 'system';
      if (!isSystemLikeMessage) return false;
      final sameUser = item.fromUserId == message.fromUserId;
      final sameKind = item.messageKind == message.messageKind;

      if (!sameUser || !sameKind) return false;

      final diff = message.createdAt.difference(item.createdAt).inSeconds.abs();

      return diff <= 2;
    });

    messages[roomId] = exists ? old : [...old, message];

    state = state.copyWith(messagesByRoom: messages);
  }

  void _handleRoomReaction(dynamic data) {
    final map = _asMap(data);

    final reactionMap = map['reaction'] is Map<String, dynamic>
        ? map['reaction'] as Map<String, dynamic>
        : map;

    final roomId = _s(reactionMap['roomId']);
    final messageId = _s(reactionMap['messageId']);

    if (roomId.isEmpty || messageId.isEmpty) return;

    final reaction = RoomReaction.fromJson(reactionMap);

    final messages = Map<String, List<RoomLiveMessageModel>>.from(
      state.messagesByRoom,
    );

    final old = messages[roomId] ?? [];

    messages[roomId] = old.map((message) {
      if (message.messageId != messageId) return message;

      final filtered = message.reactions
          .where((item) => item.userId != reaction.userId)
          .toList();

      return message.copyWith(reactions: [...filtered, reaction]);
    }).toList();

    state = state.copyWith(messagesByRoom: messages);
  }

  void _handleRoomUsers(dynamic data) {
    final map = _asMap(data);
    final roomId = _s(map['roomId']);

    if (roomId.isEmpty) return;

    final users = _readUsersList(map['users'] ?? map['activeUsers']);
    final count = _i(map['activeCount'], fallback: users.length);

    final nextUsers = Map<String, List<Map<String, dynamic>>>.from(
      state.usersByRoom,
    );

    nextUsers[roomId] = users;

    final nextCounts = Map<String, int>.from(state.activeCountByRoom);
    nextCounts[roomId] = count;

    final updatedRooms = state.rooms.map((room) {
      if (room.roomId != roomId) return room;
      return room.copyWith(activeCount: count);
    }).toList();

    state = state.copyWith(
      usersByRoom: nextUsers,
      activeCountByRoom: nextCounts,
      rooms: updatedRooms,
    );
  }

  void _handleRoomUpdate(dynamic data) {
    final map = _asMap(data);

    final roomId = _s(map['roomId']);
    final type = _s(map['type']);

    if (roomId.isEmpty && map['room'] is! Map<String, dynamic>) {
      return;
    }

    if (type == 'favorite') {
      final isFavorite = map['isFavorite'] == true;
      final favoriteCount = _i(map['favoriteCount']);

      state = state.copyWith(
        rooms: state.rooms.map((room) {
          if (room.roomId != roomId) return room;

          return room.copyWith(
            isFavorite: isFavorite,
            favoriteCount: favoriteCount,
          );
        }).toList(),
      );
      return;
    }

    if (type == 'active_count') {
      _handleRoomActiveCount(data);
      return;
    }
    if (type == 'pin') {
      final pinned = map['pinnedMessage'];
      final pinText = pinned is Map ? _s(pinned['text']) : '';

      final nextMessages = Map<String, List<RoomLiveMessageModel>>.from(
        state.messagesByRoom,
      );

      final oldMessages = nextMessages[roomId] ?? <RoomLiveMessageModel>[];

      /*
    حذف أي رسالة مثبتة قديمة.
  */
      final withoutOldPinned = oldMessages.where((message) {
        return message.messageId != 'pinned_$roomId';
      }).toList();

      /*
    لو النص فارغ يبقى إلغاء الرسالة المثبتة.
    نحذف مكانها من شاشة الشات.
  */
      if (pinText.isEmpty) {
        nextMessages[roomId] = withoutOldPinned;

        final roomJson = map['room'];

        state = state.copyWith(
          messagesByRoom: nextMessages,
          rooms: roomJson is Map<String, dynamic>
              ? state.rooms.map((room) {
                  if (room.roomId != roomId) return room;
                  return RoomModel.fromJson(roomJson);
                }).toList()
              : state.rooms,
        );

        return;
      }

      /*
    لو فيه نص جديد، نضيف الرسالة المثبتة أعلى الشات.
  */
      nextMessages[roomId] = [
        RoomLiveMessageModel.fromJson({
          'messageId': 'pinned_$roomId',
          'roomId': roomId,
          'messageKind': 'system',
          'type': 'none',
          'fromUserId': '',
          'fromUsername': '',
          'fromPhotoUrl': '',
          'fromRole': 'none',
          'text': pinText,
          'media': null,
          'mention': null,
          'gift': null,
          'entryVideo': null,
          'replyTo': null,
          'reactions': [],
          'system': {
            'action': 'pinned_changed',
            'actorId': '',
            'actorUsername': '',
            'targetUserId': '',
            'targetUsername': '',
          },
          'createdAt': DateTime.now().toIso8601String(),
        }),
        ...withoutOldPinned,
      ];

      final roomJson = map['room'];

      state = state.copyWith(
        messagesByRoom: nextMessages,
        rooms: roomJson is Map<String, dynamic>
            ? state.rooms.map((room) {
                if (room.roomId != roomId) return room;
                return RoomModel.fromJson(roomJson);
              }).toList()
            : state.rooms,
      );

      return;
    }
    /*
    مهم:
    room.update type role لا يعرض رسالة في الشات.
    هو فقط يحدّث role داخل usersByRoom حتى تظهر النجمة فورًا.
    رسالة الرول نفسها تأتي من room.message.
  */
    if (type == 'role') {
      final targetUserId = _s(map['targetUserId'] ?? map['target_user_id']);
      final newRole = _s(map['newRole'] ?? map['new_role'], fallback: 'none');

      if (roomId.isEmpty || targetUserId.isEmpty) return;

      final nextUsers = Map<String, List<Map<String, dynamic>>>.from(
        state.usersByRoom,
      );

      final oldUsers = nextUsers[roomId] ?? <Map<String, dynamic>>[];

      nextUsers[roomId] = oldUsers.map((user) {
        if (_s(user['userId']) != targetUserId) return user;

        return {...user, 'role': newRole};
      }).toList();

      state = state.copyWith(usersByRoom: nextUsers);

      return;
    }

    final roomJson = map['room'];

    if (roomJson is Map<String, dynamic>) {
      final updatedRoom = RoomModel.fromJson(roomJson);

      state = state.copyWith(
        rooms: state.rooms.map((room) {
          if (room.roomId != updatedRoom.roomId) return room;
          return updatedRoom;
        }).toList(),
      );
    }
  }

  void _handleRoomActiveCount(dynamic data) {
    final map = _asMap(data);

    final roomId = _s(map['roomId']);

    if (roomId.isEmpty) return;

    final activeUsers = _readUsersList(map['activeUsers'] ?? map['users']);

    final activeCount = _i(
      map['activeCount'],
      fallback: activeUsers.isNotEmpty ? activeUsers.length : 0,
    );

    final nextCounts = Map<String, int>.from(state.activeCountByRoom);
    nextCounts[roomId] = activeCount;

    final updatedRooms = state.rooms.map((room) {
      if (room.roomId != roomId) return room;
      return room.copyWith(activeCount: activeCount);
    }).toList();

    final nextUsers = Map<String, List<Map<String, dynamic>>>.from(
      state.usersByRoom,
    );

    if (activeUsers.isNotEmpty || map.containsKey('activeUsers')) {
      nextUsers[roomId] = activeUsers;
    }

    state = state.copyWith(
      activeCountByRoom: nextCounts,
      rooms: updatedRooms,
      usersByRoom: nextUsers,
    );
  }

  void _handleRoomError(dynamic data) {
    final map = _asMap(data);

    state = state.copyWith(
      loading: false,
      error: _s(map['reason'], fallback: 'room_error'),
    );
  }

  @override
  void dispose() {
    disposeRoomSocketListeners();
    super.dispose();
  }
}

List<Map<String, dynamic>> _readUsersList(dynamic value) {
  if (value is! List) {
    return <Map<String, dynamic>>[];
  }

  return value
      .whereType<Map>()
      .map((item) {
        final map = item.map((key, value) => MapEntry(key.toString(), value));

        return <String, dynamic>{
          'userId': _s(map['userId'] ?? map['id']),
          'username': _s(map['username'] ?? map['name'], fallback: 'User'),
          'photoUrl': _s(map['photoUrl'] ?? map['avatarUrl']),
          'socketId': _s(map['socketId']),
          'joinedAt': _s(map['joinedAt']),
          'dc': map['dc'] == true,

          'role': _s(map['role'], fallback: 'none'),

          'accountColor': _s(
            map['accountColor'] ?? map['nameColor'] ?? map['color'],
          ),

          'badgeKey': _s(map['badgeKey']),
          'badgeName': _s(map['badgeName']),
          'badgeValue': _s(map['badgeValue']),

          'verificationType': _s(map['verificationType'], fallback: 'none'),
        };
      })
      .where((user) => _s(user['userId']).isNotEmpty)
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

int _i(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();

  return int.tryParse((value ?? '').toString()) ?? fallback;
}
