import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bimo_chat/features/rooms/presentation/room_chat_screen.dart';
import 'package:bimo_chat/features/settings/presentation/settings_screen.dart';

import '../../auth/logic/auth_provider.dart';
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
  RoomFilterType selectedFilter = RoomFilterType.public;

  ui.RoomModel? pendingOpenRoom;
  bool isOpeningRoom = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(roomsProvider.notifier).attachRoomSocketListeners();
      ref
          .read(roomsProvider.notifier)
          .listRooms(_tabFromFilter(selectedFilter));
    });
  }

  @override
  void dispose() {
    ref.read(roomsProvider.notifier).disposeRoomSocketListeners();
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

      // مهم حتى نعرف هل هو creator أم لا
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
      ref
          .read(roomsProvider.notifier)
          .listRooms(_tabFromFilter(selectedFilter));
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

  String roomErrorText(String error) {
    final value = error.trim();
    final lower = value.toLowerCase();

    if (lower == 'room_banned' ||
        lower == 'banned' ||
        lower == 'you_are_banned' ||
        lower == 'user_banned' ||
        value == 'ROOM_BANNED' ||
        value == 'BANNED') {
      return 'أنت محظور من هذه الغرفة';
    }

    if (lower == 'room_not_found') {
      return 'الغرفة غير موجودة';
    }

    if (lower == 'room_password_required' || lower == 'password_required') {
      return 'هذه الغرفة تحتاج كلمة مرور';
    }

    if (lower == 'wrong_room_password' ||
        lower == 'invalid_room_password' ||
        lower == 'wrong_password' ||
        lower == 'invalid_password') {
      return 'كلمة مرور الغرفة غير صحيحة';
    }

    if (lower == 'room_locked_for_none' ||
        lower == 'room_locked_for_members_only' ||
        lower == 'members_only' ||
        lower == 'members_only_room') {
      return 'هذه الغرفة للأعضاء فقط';
    }

    if (lower == 'room_join_failed') {
      return 'تعذر دخول الغرفة';
    }

    if (lower == 'room_not_joined') {
      return 'يجب دخول الغرفة أولًا';
    }

    if (value.isEmpty || lower == 'null' || lower == 'undefined') {
      return 'حدث خطأ';
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

  Future<String?> openRoomPasswordDialog(ui.RoomModel room) async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          title: Text(
            'كلمة مرور الغرفة',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: TextField(
            controller: controller,
            obscureText: true,
            autofocus: true,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              hintText: 'اكتب كلمة المرور',
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (value) {
              Navigator.pop(context, value.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text('دخول'),
            ),
          ],
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

  Future<void> openRoom(ui.RoomModel room) async {
    if (isOpeningRoom) return;

    String password = '';

    final isCreator = room.role == 'creator';

    /*
    Creator يدخل مباشرة حتى لو الغرفة عليها باسورد.
    باقي الرتب تظهر لهم نافذة الباسورد لو الغرفة hasPassword.
  */
    if (room.hasPassword && !isCreator) {
      final result = await openRoomPasswordDialog(room);

      if (result == null || result.isEmpty) {
        return;
      }

      password = result;
    }

    pendingOpenRoom = room;
    isOpeningRoom = true;

    ref
        .read(roomsProvider.notifier)
        .joinRoom(roomId: room.id, password: password);
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

    ref.read(roomsProvider.notifier).listRooms(_tabFromFilter(filter));
  }

  @override
  Widget build(BuildContext context) {
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

    ref.listen(authProvider, (previous, next) {
      final wasLoggedIn = previous?.loggedIn == true;
      final isLoggedOutNow = next.loggedIn == false;

      if (wasLoggedIn && isLoggedOutNow) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }

      if (next.error != null && next.error!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    ref.listen<RoomsState>(roomsProvider, (previous, next) {
      final error = next.error;

      if (isRealRoomError(error)) {
        isOpeningRoom = false;
        pendingOpenRoom = null;

        final message = roomErrorText(error!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message, textDirection: TextDirection.rtl),
            behavior: SnackBarBehavior.floating,
          ),
        );

        return;
      }

      final roomToOpen = pendingOpenRoom;

      if (roomToOpen == null) return;

      final joinedByActiveRoom = next.activeRoomId == roomToOpen.id;

      final usersInRoom = next.usersByRoom[roomToOpen.id] ?? [];
      final joinedByUsersList = usersInRoom.isNotEmpty;

      if (!joinedByActiveRoom && !joinedByUsersList) return;

      pendingOpenRoom = null;
      isOpeningRoom = false;

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
                      'لا توجد غرف الآن',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 15,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      ref
                          .read(roomsProvider.notifier)
                          .listRooms(_tabFromFilter(selectedFilter));
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
