import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
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
    final lang = AppLocalizations.of(context);

    return SafeArea(
      bottom: false,
      child: Container(
        padding: EdgeInsetsDirectional.fromSTEB(
          R.size(context, 18),
          R.size(context, 12),
          R.size(context, 14),
          R.size(context, 10),
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
                radius: R.size(context, 20),
                backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
                backgroundImage: photoUrl.trim().isEmpty
                    ? null
                    : NetworkImage(photoUrl),
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

            SizedBox(width: R.size(context, 10)),

            Expanded(
              child: Text(
                lang.t('chats'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: R.sp(context, 29),
                  height: 1.05,
                ),
              ),
            ),

            SizedBox(
              width: R.size(context, 36),
              height: R.size(context, 36),
              child: IconButton(
                tooltip: lang.t('notifications'),
                onPressed: onNotificationTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: R.size(context, 20),
                icon: Icon(
                  Icons.notifications_rounded,
                  size: R.size(context, 33),
                  color: colorScheme.onSurface,
                ),
              ),
            ),

            SizedBox(width: R.size(context, 2)),

            SizedBox(
              width: R.size(context, 34),
              height: R.size(context, 36),
              child: PopupMenuButton<String>(
                tooltip: lang.t('menu'),
                padding: EdgeInsets.zero,
                splashRadius: R.size(context, 20),
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: R.size(context, 33),
                  color: colorScheme.onSurface,
                ),
                onSelected: (value) {
                  if (value == 'settings') {
                    onSettingsTap();
                  }

                  if (value == 'logout') {
                    onLogoutTap();
                  }
                },
                itemBuilder: (_) {
                  return [
                    PopupMenuItem<String>(
                      value: 'settings',
                      child: Text(
                        lang.t('settings'),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'logout',
                      child: Text(
                        lang.t('logout'),
                      ),
                    ),
                  ];
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatsSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _ChatsSearchBar({
    required this.controller,
    required this.onChanged,
  });

  @override
  State<_ChatsSearchBar> createState() => _ChatsSearchBarState();
}

class _ChatsSearchBarState extends State<_ChatsSearchBar> {
  late final FocusNode focusNode;

  bool isFocused = false;

  @override
  void initState() {
    super.initState();

    focusNode = FocusNode();

    focusNode.addListener(_handleFocusChange);
    widget.controller.addListener(_handleTextChange);
  }

  void _handleFocusChange() {
    if (!mounted) return;

    setState(() {
      isFocused = focusNode.hasFocus;
    });
  }

  void _handleTextChange() {
    if (!mounted) return;

    setState(() {});
  }

  void clearSearch() {
    widget.controller.clear();
    widget.onChanged('');
    focusNode.requestFocus();
  }

  @override
  void dispose() {
    focusNode.removeListener(_handleFocusChange);
    widget.controller.removeListener(_handleTextChange);

    focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lang = AppLocalizations.of(context);

    final hasText = widget.controller.text.trim().isNotEmpty;

    return Container(
      color: colorScheme.surface,
      padding: EdgeInsetsDirectional.fromSTEB(
        R.size(context, 16),
        R.size(context, 8),
        R.size(context, 16),
        R.size(context, 14),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: R.size(context, 58),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(
            R.size(context, 18),
          ),
          border: Border.all(
            color: isFocused
                ? colorScheme.primary
                : colorScheme.outline.withValues(
                    alpha: 0.45,
                  ),
            width: isFocused
                ? R.size(context, 2)
                : R.size(context, 1.2),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(
                alpha: isFocused ? 0.14 : 0.08,
              ),
              blurRadius: isFocused
                  ? R.size(context, 12)
                  : R.size(context, 7),
              offset: Offset(
                0,
                R.size(context, 3),
              ),
            ),
          ],
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: focusNode,
          onChanged: widget.onChanged,
          textInputAction: TextInputAction.search,
          cursorColor: colorScheme.primary,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: R.sp(context, 18),
            fontWeight: FontWeight.w700,
            height: 1,
          ),
          decoration: InputDecoration(
            hintText: lang.t('search_chats_or_messages'),
            hintStyle: TextStyle(
              color: colorScheme.onSurface.withValues(
                alpha: 0.58,
              ),
              fontSize: R.sp(context, 17),
              fontWeight: FontWeight.w600,
              height: 1,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: R.size(context, 27),
              color: isFocused
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(
                      alpha: 0.68,
                    ),
            ),
            prefixIconConstraints: BoxConstraints(
              minWidth: R.size(context, 54),
              minHeight: R.size(context, 58),
            ),
            suffixIcon: hasText
                ? IconButton(
                    tooltip: lang.t('clear_search'),
                    onPressed: clearSearch,
                    icon: Container(
                      width: R.size(context, 28),
                      height: R.size(context, 28),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withValues(
                          alpha: 0.10,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: R.size(context, 18),
                        color: colorScheme.onSurface,
                      ),
                    ),
                  )
                : null,
            suffixIconConstraints: BoxConstraints(
              minWidth: R.size(context, 52),
              minHeight: R.size(context, 58),
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsetsDirectional.only(
              top: R.size(context, 2),
              bottom: R.size(context, 2),
              end: R.size(context, 12),
            ),
          ),
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
        child: Container(
          padding: EdgeInsetsDirectional.fromSTEB(
            R.size(context, 16),
            R.size(context, 11),
            R.size(context, 16),
            R.size(context, 11),
          ),
          decoration: BoxDecoration(
            color: hasUnread
                ? colorScheme.primary.withValues(alpha: 0.035)
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withValues(
                  alpha: 0.32,
                ),
                width: R.size(context, 0.8),
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: EdgeInsets.all(
                      R.size(context, 1.5),
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: hasUnread
                            ? colorScheme.primary.withValues(alpha: 0.45)
                            : colorScheme.outline.withValues(alpha: 0.16),
                        width: R.size(context, 1.3),
                      ),
                    ),
                    child: CircleAvatar(
                      radius: R.size(context, 34),
                      backgroundColor: colorScheme.primary.withValues(
                        alpha: 0.12,
                      ),
                      backgroundImage: chat.peerPhotoUrl.trim().isEmpty
                          ? null
                          : NetworkImage(
                              chat.peerPhotoUrl.trim(),
                            ),
                      child: chat.peerPhotoUrl.trim().isEmpty
                          ? Text(
                              chat.peerUsername.trim().isEmpty
                                  ? '?'
                                  : chat.peerUsername.characters.first
                                      .toUpperCase(),
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontSize: R.sp(context, 21),
                                fontWeight: FontWeight.w900,
                              ),
                            )
                          : null,
                    ),
                  ),

                  PositionedDirectional(
                    end: R.size(context, 1),
                    bottom: R.size(context, 2),
                    child: Container(
                      width: R.size(context, 15),
                      height: R.size(context, 15),
                      decoration: BoxDecoration(
                        color: isOnline
                            ? const Color(0xFF22C55E)
                            : colorScheme.outline.withValues(alpha: 0.65),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.surface,
                          width: R.size(context, 2.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(
                width: R.size(context, 13),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            chat.peerUsername,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: R.sp(context, 22),
                              height: 1.1,
                              fontWeight: hasUnread
                                  ? FontWeight.w900
                                  : FontWeight.w800,
                            ),
                          ),
                        ),

                        SizedBox(
                          width: R.size(context, 8),
                        ),

                        Text(
                          time,
                          maxLines: 1,
                          style: TextStyle(
                            color: hasUnread
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant.withValues(
                                    alpha: 0.62,
                                  ),
                            fontSize: R.sp(context, 14),
                            height: 1,
                            fontWeight: hasUnread
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: R.size(context, 7),
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (chat.lastMessageType != 'text') ...[
                          Icon(
                            lastMessageIcon(chat.lastMessageType),
                            size: R.size(context, 17),
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.72,
                            ),
                          ),
                          SizedBox(
                            width: R.size(context, 5),
                          ),
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
                                      ? colorScheme.onSurface.withValues(
                                          alpha: 0.88,
                                        )
                                      : colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.72),
                              fontSize: R.sp(context, 17),
                              height: 1.15,
                              fontWeight: isTyping || hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),

                        SizedBox(
                          width: R.size(context, 8),
                        ),

                        if (hasUnread)
                          Container(
                            constraints: BoxConstraints(
                              minWidth: R.size(context, 25),
                              minHeight: R.size(context, 25),
                            ),
                            padding: EdgeInsetsDirectional.symmetric(
                              horizontal: R.size(context, 7),
                            ),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(
                                R.size(context, 999),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.20,
                                  ),
                                  blurRadius: R.size(context, 5),
                                  offset: Offset(
                                    0,
                                    R.size(context, 2),
                                  ),
                                ),
                              ],
                            ),
                            child: Text(
                              chat.unreadCount > 99
                                  ? '99+'
                                  : chat.unreadCount.toString(),
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontSize: R.sp(context, 12),
                                height: 1,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          )
                        else
                          Icon(
                            Icons.chevron_right_rounded,
                            size: R.size(context, 23),
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.42,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
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
