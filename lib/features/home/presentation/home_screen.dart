import 'package:flutter/material.dart';

import '../../chats/presentation/chats_screen.dart';
import '../../rooms/presentation/rooms_screen.dart';
import '../../store/presentation/store_screen.dart';
import '../../friends/presentation/friends_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    _HomeTab(),
    RoomsScreen(),
    ChatsScreen(),
    FriendsScreen(),
    StoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bubble_chart_outlined),
            selectedIcon: Icon(Icons.bubble_chart_rounded),
            label: 'Rooms',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group_rounded),
            label: 'Friends',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'Store',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Text(
            'Home',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _FriendsTab extends StatelessWidget {
  const _FriendsTab();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Text(
            'Friends',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
