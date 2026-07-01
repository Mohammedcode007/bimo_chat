import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import 'package:bimo_chat/features/rooms/presentation/room_chat_screen.dart';
import 'package:bimo_chat/features/settings/presentation/settings_screen.dart';

import '../../auth/logic/auth_provider.dart';
import '../../auth/logic/auth_state.dart';
import '../../auth/presentation/login_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';

import '../data/room_model.dart' as ui;
import '../logic/rooms_provider.dart';

import 'create_room_screen.dart';
import 'rooms_search_screen.dart';

import '../widgets/room_card.dart';
import '../widgets/rooms_filter_chips.dart';
import '../widgets/rooms_header.dart';

class RoomsScreen extends ConsumerStatefulWidget {
  const RoomsScreen({super.key});

  @override
  ConsumerState<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends ConsumerState<RoomsScreen> {
  late final RoomsNotifier _roomsNotifier;

  RoomFilterType selectedFilter = RoomFilterType.public;

  ui.RoomModel? pendingOpenRoom;
  bool isOpeningRoom = false;

  @override
  void initState() {
    super.initState();

    /*
      نحفظ الـNotifier هنا أثناء أن ref ما زال صالحًا،
      حتى لا نستخدم ref داخل dispose.
    */
    _roomsNotifier = ref.read(roomsProvider.notifier);

    Future.microtask(() {
      if (!mounted) return;

      print('🏠 ROOMS SCREEN INIT');
      print('🎧 ATTACH ROOM SOCKET LISTENERS');

      _roomsNotifier.attachRoomSocketListeners();

      final tab = _tabFromFilter(selectedFilter);

      print('📤 REQUEST ROOMS: $tab');

      _roomsNotifier.listRooms(tab);
    });
  }

  @override
  void dispose() {
    /*
      ممنوع استخدام ref.read داخل dispose.
    */
    _roomsNotifier.disposeRoomSocketListeners();

    super.dispose();
  }

  String _tabFromFilter(RoomFilterType filter) {
    switch (filter) {
      case RoomFilterType.public:
        return 'public';

      case RoomFilterType.voice:
        return 'voice';

      case RoomFilterType.active:
        return 'active';

      case RoomFilterType.favorite:
        return 'favorite';
    }
  }

  Color _avatarColor(String roomId) {
    final colors = <Color>[
      const Color(0xFF009C9A),
      const Color(0xFFA8D988),
      const Color(0xFFE55DAA),
      const Color(0xFFFF7500),
      const Color(0xFF65A532),
      const Color(0xFF4C93F0),
      const Color(0xFF0EA5D8),
      const Color(0xFF7C3AED),
      const Color(0xFFEF4444),
    ];

    final hash = roomId.codeUnits.fold<int>(
      0,
      (previous, element) => previous + element,
    );

    return colors[hash % colors.length];
  }

  ui.RoomModel _toUiRoom(dynamic room, int index, Map<String, int> counts) {
    final activeCount = counts[room.roomId] ?? room.activeCount;

    final name = room.name.toString().trim();

    final avatarText = name.isNotEmpty ? name.characters.first : 'غ';

    final roleText = room.role.toString().trim();

    return ui.RoomModel(
      id: room.roomId,
      name: name,
      membersCount: activeCount,
      rank: index + 1,

      role: roleText.isEmpty ? 'none' : roleText,

      isVerified: room.boostScore > 0,
      isActive: activeCount > 0,
      isVoice: room.voiceEnabled == true,
      isFavorite: room.isFavorite == true,

      hasPassword: room.hasPassword == true,
      isLockedForNone: room.isLockedForNone == true,

      avatarColor: _avatarColor(room.roomId),
      avatarText: avatarText,
      showGroupIcon: false,
    );
  }

  void openCreateRoom() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateRoomScreen()),
    ).then((_) {
      if (!mounted) return;

      _roomsNotifier.listRooms(_tabFromFilter(selectedFilter));
    });
  }

  void openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  void openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RoomsSearchScreen()),
    );
  }

  String roomErrorText(BuildContext context, String error) {
    final localizations = AppLocalizations.of(context);

    final value = error.trim();
    final lower = value.toLowerCase();

    if (lower == 'room_banned' ||
        lower == 'banned' ||
        lower == 'you_are_banned' ||
        lower == 'user_banned' ||
        value == 'ROOM_BANNED' ||
        value == 'BANNED') {
      return localizations.t('room_banned');
    }

    if (lower == 'room_not_found') {
      return localizations.t('room_not_found');
    }

    if (lower == 'room_password_required' || lower == 'password_required') {
      return localizations.t('room_password_required');
    }

    if (lower == 'wrong_room_password' ||
        lower == 'invalid_room_password' ||
        lower == 'wrong_password' ||
        lower == 'invalid_password') {
      return localizations.t('wrong_room_password');
    }

    if (lower == 'room_locked_for_none' ||
        lower == 'room_locked_for_members_only' ||
        lower == 'members_only' ||
        lower == 'members_only_room') {
      return localizations.t('room_members_only');
    }

    if (lower == 'room_join_failed') {
      return localizations.t('room_join_failed');
    }

    if (lower == 'room_not_joined') {
      return localizations.t('room_not_joined');
    }

    if (value.isEmpty || lower == 'null' || lower == 'undefined') {
      return localizations.t('error_occurred');
    }

    return value;
  }

  bool isRealRoomError(String? error) {
    final value = (error ?? '').trim();

    if (value.isEmpty) return false;

    final lower = value.toLowerCase();

    if (lower == 'null') return false;
    if (lower == 'undefined') return false;
    if (lower == 'none') return false;

    return true;
  }

Future<String?> openRoomPasswordDialog(
  ui.RoomModel room,
) async {
  final controller = TextEditingController();
  final localizations = AppLocalizations.of(context);

  final result = await showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      final colorScheme = theme.colorScheme;

      return Directionality(
        textDirection:
            AppLocalizations.textDirectionOf(dialogContext),
        child: AlertDialog(
          title: Text(
            localizations.t('room_password'),
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: TextField(
            controller: controller,
            obscureText: true,
            autofocus: true,
            decoration: InputDecoration(
              hintText: localizations.t('enter_password'),
              prefixIcon: const Icon(
                Icons.lock_outline,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (value) {
              Navigator.pop(
                dialogContext,
                value.trim(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                localizations.t('cancel'),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  controller.text.trim(),
                );
              },
              child: Text(
                localizations.t('enter'),
              ),
            ),
          ],
        ),
      );
    },
  );

  controller.dispose();

  final password = result?.trim();

  if (password == null || password.isEmpty) {
    return null;
  }

  return password;
}
Future<void> openMembersOnlyDialog() async {
  if (!mounted) return;

  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final localizations = AppLocalizations.of(context);

  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return Directionality(
        textDirection:
            AppLocalizations.textDirectionOf(dialogContext),
        child: AlertDialog(
          title: Text(
            localizations.t('members_only_title'),
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            localizations.t('members_only_message'),
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                localizations.t('ok'),
              ),
            ),
          ],
        ),
      );
    },
  );
}
Future<void> openRoom(ui.RoomModel room) async {
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('🚪 [ROOMS_SCREEN_OPEN_ROOM_START]');
  print('room.id: ${room.id}');
  print('room.name: ${room.name}');
  print('room.role: ${room.role}');
  print('room.hasPassword: ${room.hasPassword}');
  print('room.isLockedForNone: ${room.isLockedForNone}');
  print('isOpeningRoom before: $isOpeningRoom');
  print('pendingOpenRoom before: ${pendingOpenRoom?.id}');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  if (isOpeningRoom) {
    print('⚠️ [ROOMS_SCREEN_OPEN_ROOM_ABORT]');
    print('reason: isOpeningRoom already true');
    print('pendingOpenRoom: ${pendingOpenRoom?.id}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    return;
  }

  final roomsState = ref.read(roomsProvider);

  final usersInRoom = roomsState.usersByRoom[room.id] ?? [];

  final myUserId = roomsState.myUserId.trim();

final isAlreadyActiveRoom = roomsState.activeRoomId == room.id;

final isMyUserInRoom = usersInRoom.any((user) {
  final userId = (
    user['userId'] ??
    user['id'] ??
    user['_id'] ??
    ''
  ).toString().trim();

  return myUserId.isNotEmpty && userId == myUserId;
});

/*
  مهم:
  لا نعتمد على activeRoomId وحده.
  لأن activeRoomId قد يظل قديمًا بعد الخروج.
*/
final isAlreadyInRoom = isMyUserInRoom;

  print('🔎 [ROOMS_SCREEN_OPEN_ROOM_STATE_CHECK]');
  print('room.id: ${room.id}');
  print('state.activeRoomId: ${roomsState.activeRoomId}');
  print('state.myUserId: ${roomsState.myUserId}');
  print('state.myUsername: ${roomsState.myUsername}');
  print('usersInRoom.length: ${usersInRoom.length}');
  print('isAlreadyActiveRoom: $isAlreadyActiveRoom');
  print('isMyUserInRoom: $isMyUserInRoom');
  print('isAlreadyInRoom: $isAlreadyInRoom');

  for (final user in usersInRoom) {
    print('👤 [ROOMS_SCREEN_USER_IN_ROOM]');
    print('rawUser: $user');
    print('userId: ${user['userId'] ?? user['id'] ?? user['_id']}');
    print('username: ${user['username'] ?? user['name']}');
  }

  if (isAlreadyInRoom) {
    print('✅ [ROOMS_SCREEN_OPEN_WITHOUT_JOIN]');
    print('reason: current user already active/in users list');
    print('roomId: ${room.id}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RoomChatScreen(room: room)),
    );

    return;
  }

  String password = '';

  final isCreator = room.role == 'creator';

  final isRankedUser =
      room.role == 'creator' ||
      room.role == 'owner' ||
      room.role == 'admin' ||
      room.role == 'member';

  print('🔐 [ROOMS_SCREEN_ROOM_ACCESS_CHECK]');
  print('isCreator: $isCreator');
  print('isRankedUser: $isRankedUser');
  print('hasPassword: ${room.hasPassword}');
  print('isLockedForNone: ${room.isLockedForNone}');

  if (room.isLockedForNone && !isRankedUser) {
    print('⛔ [ROOMS_SCREEN_MEMBERS_ONLY]');
    print('roomId: ${room.id}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    await openMembersOnlyDialog();
    return;
  }

  if (room.hasPassword && !isCreator) {
    print('🔑 [ROOMS_SCREEN_PASSWORD_REQUIRED]');
    print('roomId: ${room.id}');

    final result = await openRoomPasswordDialog(room);

    if (!mounted) return;

    if (result == null || result.isEmpty) {
      print('⚠️ [ROOMS_SCREEN_PASSWORD_CANCELLED]');
      print('roomId: ${room.id}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return;
    }

    password = result;

    print('✅ [ROOMS_SCREEN_PASSWORD_ENTERED]');
    print('passwordEmpty: ${password.trim().isEmpty}');
  }

  pendingOpenRoom = room;
  isOpeningRoom = true;

  print('📤 [ROOMS_SCREEN_JOIN_REQUEST]');
  print('roomId: ${room.id}');
  print('passwordEmpty: ${password.trim().isEmpty}');
  print('pendingOpenRoom after: ${pendingOpenRoom?.id}');
  print('isOpeningRoom after: $isOpeningRoom');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  _roomsNotifier.joinRoom(roomId: room.id, password: password);
}
  void openSettings() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => SettingScreen()));
  }

  void logout() {
    ref.read(authProvider.notifier).logout();
  }

  void onFilterChanged(RoomFilterType filter) {
    setState(() {
      selectedFilter = filter;
    });

    _roomsNotifier.listRooms(_tabFromFilter(filter));
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    final roomsState = ref.watch(roomsProvider);

    final rooms = roomsState.rooms
        .asMap()
        .entries
        .map(
          (entry) =>
              _toUiRoom(entry.value, entry.key, roomsState.activeCountByRoom),
        )
        .toList();

    final activeCount = rooms.where((room) => room.isActive).length;

    /*
      الاستماع إلى تسجيل الخروج.
    */
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (!mounted) return;

      /*
          previous يمكن أن يكون null،
          لذلك نستخدم ?. وليس .
        */
      final wasLoggedIn = previous?.loggedIn == true;

      final isLoggedOutNow = next.loggedIn == false;

      if (wasLoggedIn && isLoggedOutNow) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );

        return;
      }

      final error = next.error?.trim() ?? '';

      if (error.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), behavior: SnackBarBehavior.floating),
        );
      }
    });

    /*
      الاستماع إلى نتائج دخول الغرف والأخطاء.
    */
 ref.listen<RoomsState>(roomsProvider, (previous, next) {
  if (!mounted) return;

  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('👂 [ROOMS_SCREEN_PROVIDER_LISTEN]');
  print('previous.activeRoomId: ${previous?.activeRoomId}');
  print('next.activeRoomId: ${next.activeRoomId}');
  print('next.error: ${next.error}');
  print('pendingOpenRoom: ${pendingOpenRoom?.id}');
  print('isOpeningRoom: $isOpeningRoom');
  print('next.myUserId: ${next.myUserId}');
  print('next.myUsername: ${next.myUsername}');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  final error = next.error;

  if (isRealRoomError(error)) {
    print('❌ [ROOMS_SCREEN_JOIN_ERROR]');
    print('error: $error');
    print('pendingOpenRoom before clear: ${pendingOpenRoom?.id}');
    print('isOpeningRoom before clear: $isOpeningRoom');

    isOpeningRoom = false;
    pendingOpenRoom = null;

    final message = roomErrorText(context, error!);
    final lower = error.trim().toLowerCase();

    if (lower == 'room_locked_for_none' ||
        lower == 'room_locked_for_members_only' ||
        lower == 'members_only' ||
        lower == 'members_only_room') {
      openMembersOnlyDialog();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        behavior: SnackBarBehavior.floating,
      ),
    );

    return;
  }

  final roomToOpen = pendingOpenRoom;

  if (roomToOpen == null) {
    print('ℹ️ [ROOMS_SCREEN_LISTEN_NO_PENDING_ROOM]');
    return;
  }

  final joinedByActiveRoom = next.activeRoomId == roomToOpen.id;

  final usersInRoom = next.usersByRoom[roomToOpen.id] ?? [];

  final myUserId = next.myUserId.trim();

  final joinedByMyUserInUsersList = usersInRoom.any((user) {
    final userId = (
      user['userId'] ??
      user['id'] ??
      user['_id'] ??
      ''
    ).toString().trim();

    return myUserId.isNotEmpty && userId == myUserId;
  });

  print('🔎 [ROOMS_SCREEN_JOIN_RESULT_CHECK]');
  print('roomToOpen.id: ${roomToOpen.id}');
  print('joinedByActiveRoom: $joinedByActiveRoom');
  print('usersInRoom.length: ${usersInRoom.length}');
  print('joinedByMyUserInUsersList: $joinedByMyUserInUsersList');

  for (final user in usersInRoom) {
    print('👤 [ROOMS_SCREEN_JOIN_RESULT_USER]');
    print('rawUser: $user');
    print('userId: ${user['userId'] ?? user['id'] ?? user['_id']}');
    print('username: ${user['username'] ?? user['name']}');
  }

  if (!joinedByActiveRoom && !joinedByMyUserInUsersList) {
    print('⏳ [ROOMS_SCREEN_WAITING_FOR_JOIN_CONFIRMATION]');
    print('reason: activeRoomId not matched and my user not in users list');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    return;
  }

  pendingOpenRoom = null;
  isOpeningRoom = false;

  print('✅ [ROOMS_SCREEN_NAVIGATE_TO_ROOM]');
  print('roomId: ${roomToOpen.id}');
  print('roomName: ${roomToOpen.name}');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => RoomChatScreen(room: roomToOpen)),
  );
});
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          RoomsHeader(
            onAddTap: openCreateRoom,
            onSearchTap: openSearch,
            onNotificationTap: openNotifications,
            onSettingsTap: openSettings,
            onLogoutTap: logout,
          ),
          RoomsFilterChips(
            selectedFilter: selectedFilter,
            activeCount: activeCount,
            onChanged: onFilterChanged,
          ),
          Expanded(
            child: roomsState.loading
                ? const Center(child: CircularProgressIndicator())
                : rooms.isEmpty
                ? Center(
                    child: Text(
                      localizations.t('no_rooms_now'),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 15,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      _roomsNotifier.listRooms(_tabFromFilter(selectedFilter));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 12),
                      itemCount: rooms.length,
                      itemBuilder: (context, index) {
                        final room = rooms[index];

                        return RoomCard(
                          room: room,
                          onTap: () => openRoom(room),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
