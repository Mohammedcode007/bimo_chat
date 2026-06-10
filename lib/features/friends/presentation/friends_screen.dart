import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/responsive.dart';
import '../../auth/logic/auth_provider.dart';
import '../../auth/presentation/login_screen.dart';
import '../../chats/data/chat_item_model.dart';
import '../../chats/presentation/chat_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../users/presentation/users_search_screen.dart';
import '../data/friend_model.dart';
import 'widgets/friend_card.dart';
import 'widgets/friends_header.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final searchController = TextEditingController();

  String query = '';

  final List<FriendModel> friends = const [
    FriendModel(
      id: '1',
      name: 'hb_bot',
      username: '@hb_bot',
      avatarUrl: '',
      isOnline: true,
      status: 'Online now',
    ),
    FriendModel(
      id: '2',
      name: '3yon_7zina',
      username: '@3yon_7zina',
      avatarUrl: '',
      isOnline: false,
      status: 'اعتزاللل',
    ),
    FriendModel(
      id: '3',
      name: 'Mostafa',
      username: '@mostafa',
      avatarUrl: '',
      isOnline: true,
      status: 'Available',
    ),
    FriendModel(
      id: '4',
      name: 'Ahmed',
      username: '@ahmed',
      avatarUrl: '',
      isOnline: false,
      status: 'Last seen recently',
    ),
  ];

  List<FriendModel> get filteredFriends {
    final text = query.trim().toLowerCase();

    List<FriendModel> result;

    if (text.isEmpty) {
      result = List<FriendModel>.from(friends);
    } else {
      result = friends.where((friend) {
        return friend.name.toLowerCase().contains(text) ||
            friend.username.toLowerCase().contains(text) ||
            friend.status.toLowerCase().contains(text);
      }).toList();
    }

    result.sort((a, b) {
      if (a.isOnline == b.isOnline) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }

      return a.isOnline ? -1 : 1;
    });

    return result;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void updateSearch(String value) {
    setState(() {
      query = value;
    });
  }

  void openAddFriend() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UsersSearchScreen(),
      ),
    );
  }

  void openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SettingScreen(),
      ),
    );
  }

  void openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SettingScreen(),
      ),
    );
  }

  void openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationsScreen(),
      ),
    );
  }

  void logout() {
    ref.read(authProvider.notifier).logout();
  }

  void openFriendChat(FriendModel friend) {
    final chat = ChatItemModel(
      id: friend.id,
      name: friend.name,
      lastMessage: '',
      time: '',
      avatarUrl: friend.avatarUrl,
      unreadCount: 0,
      isOnline: friend.isOnline,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(chat: chat),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final items = filteredFriends;

    ref.listen(authProvider, (previous, next) {
      final wasLoggedIn = previous?.loggedIn == true;
      final isLoggedOutNow = next.loggedIn == false;

      if (wasLoggedIn && isLoggedOutNow) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
          (route) => false,
        );
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          FriendsHeader(
            onAvatarTap: openProfile,
            onAddTap: openAddFriend,
            onNotificationTap: openNotifications,
            onSettingsTap: openSettings,
            onLogoutTap: logout,
          ),

          Container(
            height: R.size(context, 52),
            margin: EdgeInsetsDirectional.fromSTEB(
              R.size(context, 46),
              R.size(context, 16),
              R.size(context, 46),
              R.size(context, 18),
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(R.size(context, 30)),
            ),
            child: TextField(
              controller: searchController,
              onChanged: updateSearch,
              textAlign: TextAlign.center,
              textInputAction: TextInputAction.search,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: R.sp(context, 23),
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.75),
                  fontSize: R.sp(context, 23),
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.only(
                  bottom: R.size(context, 4),
                ),
              ),
            ),
          ),

          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      'No friends found',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: R.sp(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final friend = items[index];

                      return FriendCard(
                        friend: friend,
                        onTap: () => openFriendChat(friend),
                        onMessageTap: () => openFriendChat(friend),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}