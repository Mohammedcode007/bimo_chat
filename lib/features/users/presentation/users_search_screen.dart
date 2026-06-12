import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/responsive.dart';
import '../logic/users_provider.dart';
import 'public_profile_screen.dart';
import '../../auth/logic/auth_provider.dart';
import '../../dm/data/local_chat_model.dart';
import '../../dm/presentation/dm_chat_screen.dart';
class UsersSearchScreen extends ConsumerStatefulWidget {
  const UsersSearchScreen({super.key});

  @override
  ConsumerState<UsersSearchScreen> createState() => _UsersSearchScreenState();
}

class _UsersSearchScreenState extends ConsumerState<UsersSearchScreen> {
  final searchController = TextEditingController();
  Timer? debounce;

  @override
  void dispose() {
    debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void onSearchChanged(String value) {
    debounce?.cancel();

    debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(usersProvider.notifier).searchUsers(value);
    });
  }

  void openProfile(String userId) {
    if (userId.trim().isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PublicProfileScreen(userId: userId)),
    );
  }
void openChat({
  required String myUserId,
  required String peerUserId,
  required String peerUsername,
  required String peerPhotoUrl,
}) {
  if (myUserId.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please login first'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  if (peerUserId.trim().isEmpty) return;
  if (myUserId == peerUserId) return;

  final ids = [myUserId, peerUserId]..sort();
  final chatId = '${ids[0]}_${ids[1]}';

  final chat = LocalChatModel(
    chatId: chatId,
    peerUserId: peerUserId,
    peerUsername: peerUsername,
    peerPhotoUrl: peerPhotoUrl,
    lastMessageText: '',
    lastMessageType: 'text',
    lastMessageAt: DateTime.now(),
    unreadCount: 0,
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DmChatScreen(
        myUserId: myUserId,
        chat: chat,
      ),
    ),
  );
}
  Color hexToColor(String value) {
    final hex = value.replaceAll('#', '').trim();

    if (hex.length != 6) {
      return const Color(0xFF2BCB00);
    }

    try {
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF2BCB00);
    }
  }

  bool readBool(dynamic value) {
    if (value == true) return true;
    if (value?.toString() == 'true') return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
  final usersState = ref.watch(usersProvider);
final authState = ref.watch(authProvider);
final colorScheme = Theme.of(context).colorScheme;

final myUserId = authState.userId ?? '';
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
      appBar: AppBar(title: const Text('Search users')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(R.size(context, 16)),
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search username',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(R.size(context, 18)),
                ),
              ),
            ),
          ),

          if (usersState.loading) const LinearProgressIndicator(),

          Expanded(
            child: usersState.searchResults.isEmpty
                ? Center(
                    child: Text(
                      'No users',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.all(R.size(context, 12)),
                    itemCount: usersState.searchResults.length,
                    separatorBuilder: (_, __) {
                      return SizedBox(height: R.size(context, 8));
                    },
                    itemBuilder: (context, index) {
                      final user = usersState.searchResults[index];

                      final userId = user['userId']?.toString() ?? '';
                      final username = user['username']?.toString() ?? '';
                      final photoUrl = user['photoUrl']?.toString() ?? '';

                      final accountColor =
                          user['accountColor']?.toString() ?? '#2BCB00';

                      final badgeValue = user['badgeValue']?.toString() ?? '';

                      final verificationType =
                          user['verificationType']?.toString() ?? 'none';

                      final isFriendFromServer = readBool(user['isFriend']);

                      final isPendingFromServer =
                          readBool(user['hasPendingFriendRequest']) ||
                          readBool(user['isPendingFriendRequest']);

                      final isBlockedFromServer =
                          readBool(user['isBlocked']) ||
                          readBool(user['blockedByMe']) ||
                          readBool(user['hasBlockedMe']);

                      final isFriend =
                          isFriendFromServer ||
                          usersState.friendUserIds.contains(userId);

                      final isPending =
                          !isFriend &&
                          (isPendingFromServer ||
                              usersState.pendingFriendUserIds.contains(userId));

                      final isBlocked =
                          isBlockedFromServer ||
                          usersState.blockedUserIds.contains(userId);

                      return _UserSearchCard(
                        username: username,
                        photoUrl: photoUrl,
                        color: hexToColor(accountColor),
                        badgeValue: badgeValue,
                        verified: verificationType != 'none',
                        isFriend: isFriend,
                        isPending: isPending,
                        isBlocked: isBlocked,
                        onTap: () => openProfile(userId),
                        onAddFriend: () {
                          if (isFriend || isPending || isBlocked) return;

                          ref
                              .read(usersProvider.notifier)
                              .sendFriendRequest(userId);
                        },
                    onChat: () {
  if (isBlocked) return;

  openChat(
    myUserId: myUserId,
    peerUserId: userId,
    peerUsername: username,
    peerPhotoUrl: photoUrl,
  );
},
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _UserSearchCard extends StatelessWidget {
  final String username;
  final String photoUrl;
  final Color color;
  final String badgeValue;
  final bool verified;
  final bool isFriend;
  final bool isPending;
  final bool isBlocked;
  final VoidCallback onTap;
  final VoidCallback onAddFriend;
  final VoidCallback onChat;

  const _UserSearchCard({
    required this.username,
    required this.photoUrl,
    required this.color,
    required this.badgeValue,
    required this.verified,
    required this.isFriend,
    required this.isPending,
    required this.isBlocked,
    required this.onTap,
    required this.onAddFriend,
    required this.onChat,
  });

  IconData get friendIcon {
    if (isBlocked) return Icons.block_rounded;
    if (isFriend) return Icons.check_circle_rounded;
    if (isPending) return Icons.hourglass_top_rounded;
    return Icons.person_add_alt_1_rounded;
  }

  Color friendIconColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isBlocked) return Colors.redAccent;
    if (isFriend) return const Color(0xFF2BCB00);
    if (isPending) return const Color(0xFFF59E0B);
    return colorScheme.onSurfaceVariant;
  }

  Color chatIconColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isBlocked) {
      return colorScheme.onSurfaceVariant.withValues(alpha: 0.45);
    }

    return colorScheme.onSurfaceVariant;
  }

  String get friendTooltip {
    if (isBlocked) return 'Blocked';
    if (isFriend) return 'Friend';
    if (isPending) return 'Pending';
    return 'Add friend';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(R.size(context, 18)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(R.size(context, 18)),
        child: Padding(
          padding: EdgeInsets.all(R.size(context, 12)),
          child: Row(
            children: [
              CircleAvatar(
                radius: R.size(context, 27),
                backgroundColor: color.withValues(alpha: 0.2),
                backgroundImage: photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : null,
                child: photoUrl.isEmpty
                    ? Icon(
                        Icons.person_rounded,
                        color: color,
                        size: R.size(context, 28),
                      )
                    : null,
              ),

              SizedBox(width: R.size(context, 12)),

              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        username,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: color,
                          fontSize: R.sp(context, 17),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    if (badgeValue.isNotEmpty) ...[
                      SizedBox(width: R.size(context, 5)),
                      Text(
                        badgeValue,
                        style: TextStyle(fontSize: R.sp(context, 17)),
                      ),
                    ],

                    if (verified) ...[
                      SizedBox(width: R.size(context, 5)),
                      Icon(
                        Icons.verified_rounded,
                        color: colorScheme.primary,
                        size: R.size(context, 18),
                      ),
                    ],
                  ],
                ),
              ),

              Tooltip(
                message: friendTooltip,
                child: IconButton(
                  onPressed: isFriend || isPending || isBlocked
                      ? null
                      : onAddFriend,
                  icon: Icon(friendIcon, color: friendIconColor(context)),
                ),
              ),

              IconButton(
                onPressed: isBlocked ? null : onChat,
                icon: Icon(
                  Icons.chat_bubble_rounded,
                  color: chatIconColor(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
