import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/responsive.dart';
import '../../auth/logic/auth_provider.dart';
import '../../auth/presentation/login_screen.dart';
import '../../dm/data/local_chat_model.dart';
import '../../dm/presentation/dm_chat_screen.dart';
import '../../dm/logic/dm_provider.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../users/logic/users_provider.dart';
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

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(usersProvider.notifier).getFriends();
      ref.read(usersProvider.notifier).getIncomingFriendRequests();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  bool readBool(dynamic value) {
    if (value == true) return true;
    if (value?.toString() == 'true') return true;
    return false;
  }

  List<FriendModel> buildFriends(List<Map<String, dynamic>> users) {
    return users.map((user) {
      final userId = user['userId']?.toString() ?? '';
      final username = user['username']?.toString() ?? '';
      final photoUrl = user['photoUrl']?.toString() ?? '';
      final status = user['statusMessage']?.toString().trim() ?? '';
      final current = user['current']?.toString().trim() ?? '';

      final isOnline =
          current == '1' ||
          current.toLowerCase() == 'online' ||
          readBool(user['isOnline']);

      return FriendModel(
        id: userId,
        name: username,
        username: '@$username',
        avatarUrl: photoUrl,
        isOnline: isOnline,
        status: status.isNotEmpty
            ? status
            : isOnline
            ? 'Online now'
            : 'Offline',
      );
    }).toList();
  }

  List<FriendModel> filteredFriends(List<FriendModel> friends) {
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

  void updateSearch(String value) {
    setState(() {
      query = value;
    });
  }

  void openAddFriend() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UsersSearchScreen()),
    );
  }

  void openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingScreen()),
    );
  }

  void openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingScreen()),
    );
  }

  void openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  void logout() {
    ref.read(authProvider.notifier).logout();
  }

  void openFriendChat(FriendModel friend) {
    final myUserId = ref.read(authProvider).userId ?? '';

    if (myUserId.trim().isEmpty || friend.id.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open chat'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final chatId = ref
        .read(dmProvider.notifier)
        .makeChatId(myUserId, friend.id);

    final chat = LocalChatModel(
      chatId: chatId,
      peerUserId: friend.id,
      peerUsername: friend.name,
      peerPhotoUrl: friend.avatarUrl,
      lastMessageText: '',
      lastMessageType: 'text',
      lastMessageAt: DateTime.now(),
      unreadCount: 0,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DmChatScreen(myUserId: myUserId, chat: chat),
      ),
    );
  }

  void removeFriend(FriendModel friend) {
    ref.read(usersProvider.notifier).removeFriend(friend.id);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final usersState = ref.watch(usersProvider);

    final allFriends = buildFriends(usersState.friends);
    final items = filteredFriends(allFriends);

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
    });

    ref.listen(usersProvider, (previous, next) {
      if (next.error != null && next.error!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            behavior: SnackBarBehavior.floating,
          ),
        );

        ref.read(usersProvider.notifier).clearError();
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
                contentPadding: EdgeInsets.only(bottom: R.size(context, 4)),
              ),
            ),
          ),

          if (usersState.loading) const LinearProgressIndicator(),

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
                : RefreshIndicator(
                    onRefresh: () async {
                      ref.read(usersProvider.notifier).getFriends();
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final friend = items[index];

                        return Dismissible(
                          key: ValueKey(friend.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsetsDirectional.only(
                              end: R.size(context, 20),
                            ),
                            color: Colors.redAccent,
                            child: const Icon(
                              Icons.person_remove_rounded,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (_) async {
                            return await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Remove friend'),
                                      content: Text(
                                        'Remove ${friend.name} from friends?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, false);
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, true);
                                          },
                                          child: const Text('Remove'),
                                        ),
                                      ],
                                    );
                                  },
                                ) ??
                                false;
                          },
                          onDismissed: (_) {
                            removeFriend(friend);
                          },
                          child: FriendCard(
                            friend: friend,
                            onTap: () => openFriendChat(friend),
                            onMessageTap: () => openFriendChat(friend),
                          ),
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
