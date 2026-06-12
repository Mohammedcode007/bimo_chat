import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/responsive.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../users/logic/users_provider.dart';
import '../data/local_chat_model.dart';
import '../logic/dm_provider.dart';
import 'dm_chat_screen.dart';
import '../../auth/logic/auth_provider.dart';
import '../../auth/presentation/login_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
class DmChatListScreen extends ConsumerStatefulWidget {
  final String myUserId;

  const DmChatListScreen({super.key, required this.myUserId});

  @override
  ConsumerState<DmChatListScreen> createState() => _DmChatListScreenState();
}

class _DmChatListScreenState extends ConsumerState<DmChatListScreen> {
  final searchController = TextEditingController();

  String query = '';

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(dmProvider.notifier).loadChats();
      ref.read(usersProvider.notifier).getFriends();
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

  bool isUserOnlineFromMap(Map<String, dynamic> user) {
    final current = user['current']?.toString().trim() ?? '';

    return current == '1' ||
        current.toLowerCase() == 'online' ||
        readBool(user['isOnline']);
  }

  bool isChatPeerOnline(String peerUserId, List<Map<String, dynamic>> friends) {
    for (final user in friends) {
      final userId = user['userId']?.toString() ?? '';

      if (userId == peerUserId) {
        return isUserOnlineFromMap(user);
      }
    }

    return false;
  }

  List<LocalChatModel> filterChats(List<LocalChatModel> chats) {
    final text = query.trim().toLowerCase();

    if (text.isEmpty) return chats;

    return chats.where((chat) {
      return chat.peerUsername.toLowerCase().contains(text) ||
          chat.lastMessageText.toLowerCase().contains(text);
    }).toList();
  }

  void updateSearch(String value) {
    setState(() {
      query = value;
    });
  }

  void openChat(LocalChatModel chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DmChatScreen(myUserId: widget.myUserId, chat: chat),
      ),
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

  Future<void> deleteChat(LocalChatModel chat) async {
    await ref.read(dmProvider.notifier).deleteChat(chat.chatId);
    showMessage('Chat deleted');
  }

  Future<void> clearChatMessages(LocalChatModel chat) async {
    await ref.read(dmProvider.notifier).clearChatMessages(chat.chatId);
    showMessage('Messages cleared');
  }

  void showChatActions(LocalChatModel chat) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(R.size(context, 24)),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              top: R.size(context, 8),
              bottom: R.size(context, 10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: R.size(context, 48),
                  height: R.size(context, 5),
                  margin: EdgeInsets.only(bottom: R.size(context, 8)),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),

                _ActionTile(
                  icon: Icons.chat_rounded,
                  title: 'Open chat',
                  onTap: () {
                    Navigator.pop(context);
                    openChat(chat);
                  },
                ),

                _ActionTile(
                  icon: Icons.cleaning_services_rounded,
                  title: 'Clear messages',
                  onTap: () {
                    Navigator.pop(context);
                    clearChatMessages(chat);
                  },
                ),

                _ActionTile(
                  icon: Icons.delete_rounded,
                  title: 'Delete chat',
                  color: colorScheme.error,
                  onTap: () {
                    Navigator.pop(context);
                    deleteChat(chat);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showMessage(String text) {
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        content: Text(
          text,
          style: TextStyle(
            color: colorScheme.onInverseSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String formatTime(DateTime time) {
    final now = DateTime.now();

    final sameDay =
        now.year == time.year && now.month == time.month && now.day == time.day;

    final yesterday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 1));

    final isYesterday =
        yesterday.year == time.year &&
        yesterday.month == time.month &&
        yesterday.day == time.day;

    if (sameDay) {
      final hour = time.hour > 12
          ? time.hour - 12
          : time.hour == 0
          ? 12
          : time.hour;
      final minute = time.minute.toString().padLeft(2, '0');
      final amPm = time.hour >= 12 ? 'PM' : 'AM';

      return '$hour:$minute $amPm';
    }

    if (isYesterday) return 'Yesterday';

    return '${time.day}/${time.month}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

   final dmState = ref.watch(dmProvider);
final usersState = ref.watch(usersProvider);
final authState = ref.watch(authProvider);

final myUsername = authState.username ?? '';
final myPhotoUrl = authState.photoUrl ?? '';

    final chats = filterChats(dmState.chats);
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
    _ChatsHeader(
  username: myUsername,
  photoUrl: myPhotoUrl,
  onAvatarTap: openProfile,
  onNotificationTap: openNotifications,
  onSettingsTap: openSettings,
  onLogoutTap: logout,
),
          _ChatsSearchBar(
            controller: searchController,
            onChanged: updateSearch,
          ),

          Expanded(
            child: dmState.loading
                ? const Center(child: CircularProgressIndicator())
                : chats.isEmpty
                ? _EmptyChats(hasSearch: query.trim().isNotEmpty)
                : RefreshIndicator(
                    onRefresh: () async {
                      ref.read(usersProvider.notifier).getFriends();
                      await ref.read(dmProvider.notifier).loadChats();
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.only(
                        top: R.size(context, 2),
                        bottom: R.size(context, 8),
                      ),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final chat = chats[index];

                        final isTyping = dmState.typingUserIds.contains(
                          chat.peerUserId,
                        );

                        final isOnline = isChatPeerOnline(
                          chat.peerUserId,
                          usersState.friends,
                        );

                        return Dismissible(
                          key: ValueKey(chat.chatId),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: AlignmentDirectional.centerEnd,
                            padding: EdgeInsetsDirectional.only(
                              end: R.size(context, 24),
                            ),
                            color: colorScheme.error,
                            child: Icon(
                              Icons.delete_rounded,
                              color: colorScheme.onError,
                            ),
                          ),
                          confirmDismiss: (_) async {
                            return await showDialog<bool>(
                                  context: context,
                                  builder: (_) {
                                    return AlertDialog(
                                      title: const Text('Delete chat?'),
                                      content: Text(
                                        'Delete chat with ${chat.peerUsername} from this device only?',
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
                                          child: Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: colorScheme.error,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ) ??
                                false;
                          },
                          onDismissed: (_) {
                            deleteChat(chat);
                          },
                          child: _DmChatTile(
                            chat: chat,
                            time: formatTime(chat.lastMessageAt),
                            isTyping: isTyping,
                            isOnline: isOnline,
                            onTap: () => openChat(chat),
                            onLongPress: () => showChatActions(chat),
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

class _ChatsHeader extends StatelessWidget {
  final String username;
  final String photoUrl;
  final VoidCallback onAvatarTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;

  const _ChatsHeader({
    required this.username,
    required this.photoUrl,
    required this.onAvatarTap,
    required this.onNotificationTap,
    required this.onSettingsTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: Container(
        padding: EdgeInsetsDirectional.fromSTEB(
          R.size(context, 18),
          R.size(context, 14),
          R.size(context, 12),
          R.size(context, 12),
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.10),
            ),
          ),
        ),
        child: Row(
          children: [
          GestureDetector(
  onTap: onAvatarTap,
  child: CircleAvatar(
    radius: R.size(context, 22),
    backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
    backgroundImage: photoUrl.trim().isEmpty ? null : NetworkImage(photoUrl),
    child: photoUrl.trim().isEmpty
        ? Text(
            username.trim().isEmpty
                ? '?'
                : username.characters.first.toUpperCase(),
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w900,
              fontSize: R.sp(context, 16),
            ),
          )
        : null,
  ),
),

            SizedBox(width: R.size(context, 12)),

            Expanded(
              child: Text(
                'Chats',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: R.sp(context, 28),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            IconButton(
              onPressed: onNotificationTap,
              icon: const Icon(Icons.notifications_none_rounded),
            ),

            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'settings') onSettingsTap();
                if (value == 'logout') onLogoutTap();
              },
              itemBuilder: (_) {
                return const [
                  PopupMenuItem(value: 'settings', child: Text('Settings')),
                  PopupMenuItem(value: 'logout', child: Text('Logout')),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatsSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _ChatsSearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      padding: EdgeInsetsDirectional.fromSTEB(
        R.size(context, 18),
        R.size(context, 6),
        R.size(context, 18),
        R.size(context, 12),
      ),
      child: Container(
        height: R.size(context, 46),
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: R.size(context, 14),
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(R.size(context, 18)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.55),
            ),
            SizedBox(width: R.size(context, 8)),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search chats',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DmChatTile extends StatelessWidget {
  final LocalChatModel chat;
  final String time;
  final bool isTyping;
  final bool isOnline;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _DmChatTile({
    required this.chat,
    required this.time,
    required this.isTyping,
    required this.isOnline,
    required this.onTap,
    required this.onLongPress,
  });

  IconData lastMessageIcon(String type) {
    if (type == 'image') return Icons.image_rounded;
    if (type == 'video') return Icons.videocam_rounded;
    if (type == 'audio') return Icons.mic_rounded;
    if (type == 'file') return Icons.insert_drive_file_rounded;

    return Icons.chat_bubble_rounded;
  }

  String lastText() {
    if (isTyping) return 'Typing...';

    if (chat.lastMessageText.trim().isEmpty) {
      if (chat.lastMessageType == 'image') return 'Photo';
      if (chat.lastMessageType == 'video') return 'Video';
      if (chat.lastMessageType == 'audio') return 'Voice message';
      if (chat.lastMessageType == 'file') return 'File';
      return 'No messages yet';
    }

    return chat.lastMessageText;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final hasUnread = chat.unreadCount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            R.size(context, 18),
            R.size(context, 8),
            R.size(context, 18),
            R.size(context, 8),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: R.size(context, 28),
                    backgroundColor: colorScheme.primary.withValues(
                      alpha: 0.12,
                    ),
                    backgroundImage: chat.peerPhotoUrl.trim().isEmpty
                        ? null
                        : NetworkImage(chat.peerPhotoUrl),
                    child: chat.peerPhotoUrl.trim().isEmpty
                        ? Text(
                            chat.peerUsername.isEmpty
                                ? '?'
                                : chat.peerUsername.characters.first
                                      .toUpperCase(),
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: R.sp(context, 18),
                              fontWeight: FontWeight.w800,
                            ),
                          )
                        : null,
                  ),

                  PositionedDirectional(
                    end: R.size(context, 2),
                    bottom: R.size(context, 2),
                    child: Container(
                      width: R.size(context, 12),
                      height: R.size(context, 12),
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.green : colorScheme.outline,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.surface,
                          width: R.size(context, 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(width: R.size(context, 12)),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.peerUsername,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: R.sp(context, 16),
                        fontWeight: hasUnread
                            ? FontWeight.w800
                            : FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: R.size(context, 5)),

                    Row(
                      children: [
                        if (chat.lastMessageType != 'text') ...[
                          Icon(
                            lastMessageIcon(chat.lastMessageType),
                            size: R.size(context, 15),
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.55,
                            ),
                          ),
                          SizedBox(width: R.size(context, 4)),
                        ],

                        Expanded(
                          child: Text(
                            lastText(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isTyping
                                  ? colorScheme.primary
                                  : hasUnread
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurface.withValues(
                                      alpha: 0.58,
                                    ),
                              fontSize: R.sp(context, 13),
                              fontWeight: hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: R.size(context, 10)),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      color: hasUnread
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.48),
                      fontSize: R.sp(context, 11),
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: R.size(context, 8)),

                  if (hasUnread)
                    Container(
                      constraints: BoxConstraints(
                        minWidth: R.size(context, 22),
                        minHeight: R.size(context, 22),
                      ),
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: R.size(context, 7),
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        chat.unreadCount > 99
                            ? '99+'
                            : chat.unreadCount.toString(),
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: R.sp(context, 11),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurface.withValues(alpha: 0.35),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyChats extends StatelessWidget {
  final bool hasSearch;

  const _EmptyChats({required this.hasSearch});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(R.size(context, 24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasSearch
                  ? Icons.search_off_rounded
                  : Icons.chat_bubble_outline_rounded,
              size: R.size(context, 48),
              color: colorScheme.primary,
            ),

            SizedBox(height: R.size(context, 12)),

            Text(
              hasSearch ? 'No chats found' : 'No chats yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: R.sp(context, 17),
                fontWeight: FontWeight.w800,
              ),
            ),

            SizedBox(height: R.size(context, 6)),

            Text(
              hasSearch
                  ? 'Try another username or message.'
                  : 'Start a conversation from any user profile.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.58),
                fontSize: R.sp(context, 13),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final itemColor = color ?? colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: itemColor),
      title: Text(
        title,
        style: TextStyle(color: itemColor, fontWeight: FontWeight.w700),
      ),
      onTap: onTap,
    );
  }
}
