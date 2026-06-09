// import 'package:bimo_chat/features/rooms/presentation/room_chat_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:bimo_chat/features/settings/presentation/settings_screen.dart';
// import '../../notifications/presentation/notifications_screen.dart';
// import '../data/room_model.dart';
// import 'create_room_screen.dart';
// import 'rooms_search_screen.dart';
// import '../widgets/room_card.dart';
// import '../widgets/rooms_filter_chips.dart';
// import '../widgets/rooms_header.dart';

// class RoomsScreen extends StatefulWidget {
//   const RoomsScreen({super.key});

//   @override
//   State<RoomsScreen> createState() => _RoomsScreenState();
// }

// class _RoomsScreenState extends State<RoomsScreen> {
//   RoomFilterType selectedFilter = RoomFilterType.public;

//   final List<RoomModel> rooms = const [
//     RoomModel(
//       id: '1',
//       name: 'كوكاتو',
//       membersCount: 107,
//       rank: 1,
//       isVerified: true,
//       isActive: true,
//       avatarColor: Color(0xFF009C9A),
//     ),
//     RoomModel(
//       id: '2',
//       name: 'ملتقى 🥂 العرب',
//       membersCount: 41,
//       rank: 2,
//       isVerified: true,
//       isActive: true,
//       avatarColor: Color(0xFFA8D988),
//     ),
//     RoomModel(
//       id: '3',
//       name: 'ورق💕🤍 الورد',
//       membersCount: 6,
//       rank: 3,
//       avatarColor: Color(0xFFE55DAA),
//       avatarText: 'و',
//       showGroupIcon: true,
//     ),
//     RoomModel(
//       id: '4',
//       name: 'strangers',
//       membersCount: 34,
//       rank: 4,
//       isVerified: true,
//       isVoice: true,
//       avatarColor: Color(0xFFFF7500),
//     ),
//     RoomModel(
//       id: '5',
//       name: 'سورياالحب',
//       membersCount: 42,
//       rank: 5,
//       avatarColor: Color(0xFF65A532),
//       avatarText: 'س',
//       isFavorite: true,
//     ),
//     RoomModel(
//       id: '6',
//       name: 'عشق',
//       membersCount: 11,
//       rank: 6,
//       avatarColor: Color(0xFF65A532),
//       avatarText: 'ع',
//     ),
//     RoomModel(
//       id: '7',
//       name: 'عراقي❤️بغدادي',
//       membersCount: 47,
//       rank: 7,
//       isVerified: true,
//       isActive: true,
//       avatarColor: Color(0xFF4C93F0),
//     ),
//     RoomModel(
//       id: '8',
//       name: 'أتكيت',
//       membersCount: 19,
//       rank: 8,
//       avatarColor: Color(0xFF0EA5D8),
//       avatarText: 'ا',
//     ),
//     RoomModel(
//       id: '9',
//       name: 'Night Room',
//       membersCount: 88,
//       rank: 9,
//       isVoice: true,
//       avatarColor: Color(0xFF7C3AED),
//     ),
//     RoomModel(
//       id: '10',
//       name: 'Friends',
//       membersCount: 63,
//       rank: 10,
//       isFavorite: true,
//       avatarColor: Color(0xFFEF4444),
//     ),
//   ];

//   List<RoomModel> get filteredRooms {
//     switch (selectedFilter) {
//       case RoomFilterType.public:
//         return rooms;
//       case RoomFilterType.voice:
//         return rooms.where((room) => room.isVoice).toList();
//       case RoomFilterType.active:
//         return rooms.where((room) => room.isActive).toList();
//       case RoomFilterType.favorite:
//         return rooms.where((room) => room.isFavorite).toList();
//     }
//   }

//   void openCreateRoom() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const CreateRoomScreen()),
//     );
//   }

//   void openNotifications() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const NotificationsScreen()),
//     );
//   }

//   void openSearch() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const RoomsSearchScreen()),
//     );
//   }

//   void openRoom(RoomModel room) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => RoomChatScreen(room: room)),
//     );
//   }

//   void openSettings() {
//     Navigator.push(context, MaterialPageRoute(builder: (_) => SettingScreen()));
//   }

//   void logout() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Logout'),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final items = filteredRooms;

//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: Column(
//         children: [
//           RoomsHeader(
//             onAddTap: openCreateRoom,
//             onSearchTap: openSearch,
//             onNotificationTap: openNotifications,
//             onSettingsTap: openSettings,
//             onLogoutTap: logout,
//           ),

//           RoomsFilterChips(
//             selectedFilter: selectedFilter,
//             activeCount: rooms.where((room) => room.isActive).length,
//             onChanged: (filter) {
//               setState(() {
//                 selectedFilter = filter;
//               });
//             },
//           ),

//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.only(bottom: 12),
//               itemCount: items.length,
//               itemBuilder: (context, index) {
//                 final room = items[index];

//                 return RoomCard(room: room, onTap: () => openRoom(room));
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:bimo_chat/features/rooms/presentation/room_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bimo_chat/features/settings/presentation/settings_screen.dart';
import '../../auth/logic/auth_provider.dart';
import '../../auth/presentation/login_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../data/room_model.dart';
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

  final List<RoomModel> rooms = const [
    RoomModel(
      id: '1',
      name: 'كوكاتو',
      membersCount: 107,
      rank: 1,
      isVerified: true,
      isActive: true,
      avatarColor: Color(0xFF009C9A),
    ),
    RoomModel(
      id: '2',
      name: 'ملتقى 🥂 العرب',
      membersCount: 41,
      rank: 2,
      isVerified: true,
      isActive: true,
      avatarColor: Color(0xFFA8D988),
    ),
    RoomModel(
      id: '3',
      name: 'ورق💕🤍 الورد',
      membersCount: 6,
      rank: 3,
      avatarColor: Color(0xFFE55DAA),
      avatarText: 'و',
      showGroupIcon: true,
    ),
    RoomModel(
      id: '4',
      name: 'strangers',
      membersCount: 34,
      rank: 4,
      isVerified: true,
      isVoice: true,
      avatarColor: Color(0xFFFF7500),
    ),
    RoomModel(
      id: '5',
      name: 'سورياالحب',
      membersCount: 42,
      rank: 5,
      avatarColor: Color(0xFF65A532),
      avatarText: 'س',
      isFavorite: true,
    ),
    RoomModel(
      id: '6',
      name: 'عشق',
      membersCount: 11,
      rank: 6,
      avatarColor: Color(0xFF65A532),
      avatarText: 'ع',
    ),
    RoomModel(
      id: '7',
      name: 'عراقي❤️بغدادي',
      membersCount: 47,
      rank: 7,
      isVerified: true,
      isActive: true,
      avatarColor: Color(0xFF4C93F0),
    ),
    RoomModel(
      id: '8',
      name: 'أتكيت',
      membersCount: 19,
      rank: 8,
      avatarColor: Color(0xFF0EA5D8),
      avatarText: 'ا',
    ),
    RoomModel(
      id: '9',
      name: 'Night Room',
      membersCount: 88,
      rank: 9,
      isVoice: true,
      avatarColor: Color(0xFF7C3AED),
    ),
    RoomModel(
      id: '10',
      name: 'Friends',
      membersCount: 63,
      rank: 10,
      isFavorite: true,
      avatarColor: Color(0xFFEF4444),
    ),
  ];

  List<RoomModel> get filteredRooms {
    switch (selectedFilter) {
      case RoomFilterType.public:
        return rooms;
      case RoomFilterType.voice:
        return rooms.where((room) => room.isVoice).toList();
      case RoomFilterType.active:
        return rooms.where((room) => room.isActive).toList();
      case RoomFilterType.favorite:
        return rooms.where((room) => room.isFavorite).toList();
    }
  }

  void openCreateRoom() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateRoomScreen()),
    );
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

  void openRoom(RoomModel room) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RoomChatScreen(room: room)),
    );
  }

  void openSettings() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => SettingScreen()));
  }

  void logout() {
    ref.read(authProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final items = filteredRooms;

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
            activeCount: rooms.where((room) => room.isActive).length,
            onChanged: (filter) {
              setState(() {
                selectedFilter = filter;
              });
            },
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final room = items[index];

                return RoomCard(room: room, onTap: () => openRoom(room));
              },
            ),
          ),
        ],
      ),
    );
  }
}
