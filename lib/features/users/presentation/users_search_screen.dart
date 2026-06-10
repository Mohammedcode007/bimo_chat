import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/responsive.dart';
import '../logic/users_provider.dart';
import 'public_profile_screen.dart';

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublicProfileScreen(userId: userId),
      ),
    );
  }

  Color hexToColor(String value) {
    final hex = value.replaceAll('#', '').trim();

    if (hex.length != 6) {
      return const Color(0xFF2BCB00);
    }

    return Color(int.parse('FF$hex', radix: 16));
  }

  bool readBool(dynamic value) {
    if (value == true) return true;
    if (value?.toString() == 'true') return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(usersProvider);
    final colorScheme = Theme.of(context).colorScheme;

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
      appBar: AppBar(
        title: const Text('Search users'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(R.size(context, 16)),
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
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
                    separatorBuilder: (_, __) =>
                        SizedBox(height: R.size(context, 8)),
                    itemBuilder: (context, index) {
                      final user = usersState.searchResults[index];

                      final userId = user['userId']?.toString() ?? '';
                      final username = user['username']?.toString() ?? '';
                      final photoUrl = user['photoUrl']?.toString() ?? '';
                      final accountColor =
                          user['accountColor']?.toString() ?? '#2BCB00';

                      final badgeValue =
                          user['badgeValue']?.toString() ?? '';

                      final verificationType =
                          user['verificationType']?.toString() ?? 'none';

                      final isFriendFromServer =
                          readBool(user['isFriend']);

                      final isPendingFromServer =
                          readBool(user['hasPendingFriendRequest']) ||
                              readBool(user['isPendingFriendRequest']);

                      final isFriend = isFriendFromServer ||
                          usersState.friendUserIds.contains(userId);

                      final isPending = !isFriend &&
                          (isPendingFromServer ||
                              usersState.pendingFriendUserIds
                                  .contains(userId));

                      return _UserSearchCard(
                        username: username,
                        photoUrl: photoUrl,
                        color: hexToColor(accountColor),
                        badgeValue: badgeValue,
                        verified: verificationType != 'none',
                        isFriend: isFriend,
                        isPending: isPending,
                        onTap: () => openProfile(userId),
                        onAddFriend: () {
                          if (isFriend || isPending) return;

                          ref
                              .read(usersProvider.notifier)
                              .sendFriendRequest(userId);
                        },
                        onChat: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Chat will be added later'),
                              behavior: SnackBarBehavior.floating,
                            ),
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
    required this.onTap,
    required this.onAddFriend,
    required this.onChat,
  });

  IconData get friendIcon {
    if (isFriend) return Icons.check_circle_rounded;
    if (isPending) return Icons.hourglass_top_rounded;
    return Icons.person_add_alt_1_rounded;
  }

  Color iconColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isFriend) return const Color(0xFF2BCB00);
    if (isPending) return const Color(0xFFF59E0B);
    return colorScheme.onSurfaceVariant;
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
                backgroundImage:
                    photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
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

              IconButton(
                onPressed: isFriend || isPending ? null : onAddFriend,
                icon: Icon(
                  friendIcon,
                  color: iconColor(context),
                ),
              ),

              IconButton(
                onPressed: onChat,
                icon: const Icon(Icons.chat_bubble_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}