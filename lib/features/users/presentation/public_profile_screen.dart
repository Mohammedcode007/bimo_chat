import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/responsive.dart';
import '../logic/users_provider.dart';

class PublicProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const PublicProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<PublicProfileScreen> createState() =>
      _PublicProfileScreenState();
}

class _PublicProfileScreenState extends ConsumerState<PublicProfileScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(usersProvider.notifier).getUserProfile(widget.userId);
    });
  }

  Color hexToColor(String value) {
    final hex = value.replaceAll('#', '').trim();

    if (hex.length != 6) {
      return const Color(0xFF2BCB00);
    }

    return Color(int.parse('FF$hex', radix: 16));
  }

  String textValue(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? '-' : text;
  }

  String dateOnly(dynamic value) {
    final text = value?.toString().trim() ?? '';

    if (text.isEmpty) return '-';

    if (text.contains('T')) {
      return text.split('T').first;
    }

    return text;
  }

  bool readBool(dynamic value) {
    if (value == true) return true;
    if (value?.toString() == 'true') return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usersProvider);
    final profile = state.profile;

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

    if (state.loading && profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (profile == null) {
      return const Scaffold(
        body: Center(child: Text('Profile not found')),
      );
    }

    final stats = profile['stats'] is Map
        ? Map<String, dynamic>.from(profile['stats'])
        : <String, dynamic>{};

    final username = textValue(profile['username']);
    final userId = textValue(profile['userId']);
    final photoUrl = profile['photoUrl']?.toString() ?? '';
    final coverUrl = profile['coverUrl']?.toString() ?? '';
    final accountColor = profile['accountColor']?.toString() ?? '#2BCB00';
    final statusMessage = profile['statusMessage']?.toString().trim() ?? '';

    final receivedGifts = textValue(stats['giftsReceivedCount']);
    final sentGifts = textValue(stats['giftsSentCount']);
    final views = textValue(stats['profileViewsCount']);
    final friends = textValue(stats['friendsCount']);

    final since = dateOnly(profile['createdAt']);
    final country = textValue(profile['country']);
    final gender = textValue(profile['gender']);
    final age = textValue(profile['age']);

    final nameColor = hexToColor(accountColor);
    final avatarText = username.isNotEmpty && username != '-'
        ? username.characters.first.toUpperCase()
        : '?';

    final isSelf = readBool(profile['isSelf']);

    final isFriendFromServer = readBool(profile['isFriend']);

    final isPendingFromServer =
        readBool(profile['hasPendingFriendRequest']) ||
        readBool(profile['isPendingFriendRequest']);

    final isFriend =
        isFriendFromServer || state.friendUserIds.contains(userId);

    final isPending =
        !isFriend &&
        (isPendingFromServer || state.pendingFriendUserIds.contains(userId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _ProfileTopName(
              name: username,
              color: nameColor,
            ),

            _CoverAvatarSection(
              coverUrl: coverUrl,
              avatarUrl: photoUrl,
              avatarText: avatarText,
            ),

            _UserIdText(userId: userId),

            if (!isSelf) ...[
              SizedBox(height: R.size(context, 14)),

              _ProfileActionsRow(
                isFriend: isFriend,
                isPending: isPending,
                onFriendTap: () {
                  if (isFriend || isPending) return;

                  ref.read(usersProvider.notifier).sendFriendRequest(userId);
                },
                onChatTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Chat will be added later'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],

            SizedBox(height: R.size(context, 22)),

            Divider(
              height: 1,
              thickness: 1,
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.45),
            ),

            _StatsRow(
              receivedGifts: receivedGifts,
              sentGifts: sentGifts,
              views: views,
              friends: friends,
            ),

            _InfoRow(
              since: since,
              country: country,
              gender: gender,
              age: age,
            ),

            if (statusMessage.isNotEmpty) _BioBox(text: statusMessage),

            SizedBox(height: R.size(context, 24)),
          ],
        ),
      ),
    );
  }
}

class _ProfileTopName extends StatelessWidget {
  final String name;
  final Color color;

  const _ProfileTopName({
    required this.name,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: R.size(context, 122),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: R.size(context, 18)),
      child: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          color: color,
          fontSize: R.sp(context, 24),
          fontWeight: FontWeight.w600,
          height: 1.1,
        ),
      ),
    );
  }
}

class _CoverAvatarSection extends StatelessWidget {
  final String coverUrl;
  final String avatarUrl;
  final String avatarText;

  const _CoverAvatarSection({
    required this.coverUrl,
    required this.avatarUrl,
    required this.avatarText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: R.size(context, 190),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            top: 0,
            bottom: R.size(context, 44),
            child: _CoverImage(coverUrl: coverUrl),
          ),

          Positioned(
            bottom: 0,
            child: _Avatar(
              avatarUrl: avatarUrl,
              avatarText: avatarText,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String coverUrl;

  const _CoverImage({required this.coverUrl});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (coverUrl.trim().isEmpty) {
      return Container(color: colorScheme.surfaceContainerHighest);
    }

    return Image.network(
      coverUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(color: colorScheme.surfaceContainerHighest);
      },
    );
  }
}

class _Avatar extends StatelessWidget {
  final String avatarUrl;
  final String avatarText;

  const _Avatar({
    required this.avatarUrl,
    required this.avatarText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pageBackground = theme.scaffoldBackgroundColor;

    return Container(
      width: R.size(context, 150),
      height: R.size(context, 150),
      padding: EdgeInsets.all(R.size(context, 4)),
      decoration: BoxDecoration(
        color: pageBackground,
        shape: BoxShape.circle,
        border: Border.all(
          color: pageBackground,
          width: R.size(context, 4),
        ),
      ),
      child: ClipOval(
        child: avatarUrl.trim().isNotEmpty
            ? Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return _AvatarText(text: avatarText);
                },
              )
            : _AvatarText(text: avatarText),
      ),
    );
  }
}

class _AvatarText extends StatelessWidget {
  final String text;

  const _AvatarText({required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.primary,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: colorScheme.onPrimary,
          fontSize: R.sp(context, 42),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _UserIdText extends StatelessWidget {
  final String userId;

  const _UserIdText({required this.userId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(top: R.size(context, 10)),
      child: Center(
        child: Text(
          'ID: $userId',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: R.sp(context, 22),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ProfileActionsRow extends StatelessWidget {
  final bool isFriend;
  final bool isPending;
  final VoidCallback onFriendTap;
  final VoidCallback onChatTap;

  const _ProfileActionsRow({
    required this.isFriend,
    required this.isPending,
    required this.onFriendTap,
    required this.onChatTap,
  });

  IconData get friendIcon {
    if (isFriend) return Icons.check_circle_rounded;
    if (isPending) return Icons.hourglass_top_rounded;
    return Icons.person_add_alt_1_rounded;
  }

  Color friendIconColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isFriend) return const Color(0xFF2BCB00);
    if (isPending) return const Color(0xFFF59E0B);
    return colorScheme.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CircleActionButton(
          icon: friendIcon,
          color: friendIconColor(context),
          onTap: isFriend || isPending ? null : onFriendTap,
        ),

        SizedBox(width: R.size(context, 18)),

        _CircleActionButton(
          icon: Icons.chat_bubble_rounded,
          color: Theme.of(context).colorScheme.onSurface,
          onTap: onChatTap,
        ),
      ],
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _CircleActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: R.size(context, 48),
        height: R.size(context, 48),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: onTap == null ? color.withValues(alpha: 0.7) : color,
          size: R.size(context, 25),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final String receivedGifts;
  final String sentGifts;
  final String views;
  final String friends;

  const _StatsRow({
    required this.receivedGifts,
    required this.sentGifts,
    required this.views,
    required this.friends,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: R.size(context, 12)),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              value: receivedGifts,
              label: 'Gifts',
              icon: Icons.south_west_rounded,
            ),
          ),
          Expanded(
            child: _StatItem(
              value: sentGifts,
              label: 'Gifts',
              icon: Icons.north_east_rounded,
            ),
          ),
          Expanded(
            child: _StatItem(
              value: views,
              label: 'Views',
            ),
          ),
          Expanded(
            child: _StatItem(
              value: friends,
              label: 'Friends',
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String since;
  final String country;
  final String gender;
  final String age;

  const _InfoRow({
    required this.since,
    required this.country,
    required this.gender,
    required this.age,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: R.size(context, 6),
        bottom: R.size(context, 14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _InfoItem(
              value: since,
              label: 'Since',
            ),
          ),
          Expanded(
            child: _InfoItem(
              value: country,
              label: 'Country',
            ),
          ),
          Expanded(
            child: _InfoItem(
              value: gender,
              label: 'Gender',
            ),
          ),
          Expanded(
            child: _InfoItem(
              value: age,
              label: 'Age',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;

  const _StatItem({
    required this.value,
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: R.sp(context, 22),
            fontWeight: FontWeight.w500,
          ),
        ),

        SizedBox(height: R.size(context, 3)),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: R.sp(context, 20),
                fontWeight: FontWeight.w500,
              ),
            ),

            if (icon != null) ...[
              SizedBox(width: R.size(context, 3)),
              Icon(
                icon,
                color: colorScheme.onSurface,
                size: R.size(context, 25),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String value;
  final String label;

  const _InfoItem({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: R.sp(context, 20),
            fontWeight: FontWeight.w500,
          ),
        ),

        SizedBox(height: R.size(context, 4)),

        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: R.sp(context, 20),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _BioBox extends StatelessWidget {
  final String text;

  const _BioBox({required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
      padding: EdgeInsets.symmetric(
        horizontal: R.size(context, 24),
        vertical: R.size(context, 12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: R.sp(context, 20),
          fontWeight: FontWeight.w400,
          height: 1.55,
        ),
      ),
    );
  }
}