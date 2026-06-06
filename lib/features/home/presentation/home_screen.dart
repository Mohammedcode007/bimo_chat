import 'package:flutter/material.dart';
import '../../../core/widgets/main_header.dart';
import '../../auth/presentation/login_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../chats/presentation/chats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  String get headerTitle {
    switch (currentIndex) {
      case 0:
        return 'Bimo Chat';
      case 1:
        return 'Rooms';
      case 2:
        return 'Chats';
      case 3:
        return 'Profile';
      default:
        return 'Bimo Chat';
    }
  }

  String get headerSubtitle {
    switch (currentIndex) {
      case 0:
        return 'Welcome to your social space';
      case 1:
        return 'Join active rooms';
      case 2:
        return 'Your private conversations';
      case 3:
        return 'Manage your account';
      default:
        return '';
    }
  }

  final List<Widget> screens = const [
    _HomeTab(),
    _RoomsTab(),
    ChatsScreen(),
    ProfileScreen(),
  ];

  void goToProfile() {
    setState(() {
      currentIndex = 3;
    });
  }

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (currentIndex != 3)
            MainHeader(
              title: headerTitle,
              subtitle: headerSubtitle,
              avatarUrl: null,
              onProfileTap: goToProfile,
              onLogoutTap: logout,
            ),
          Expanded(child: screens[currentIndex]),
        ],
      ),
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
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups_rounded),
            label: 'Rooms',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
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
    return const Center(
      child: Text(
        'Home Screen',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _RoomsTab extends StatelessWidget {
  const _RoomsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Rooms Screen',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}
