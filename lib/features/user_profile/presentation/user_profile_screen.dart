import 'package:flutter/material.dart';

import '../../../core/utils/responsive.dart';
import '../data/user_profile_model.dart';

class UserProfileScreen extends StatelessWidget {
  final UserProfileModel user;

  const UserProfileScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _ProfileTopName(user: user),

            _CoverAvatarSection(user: user),

            _UserIdText(user: user),

            SizedBox(height: R.size(context, 22)),

            Divider(
              height: 1,
              thickness: 1,
              color: Colors.black.withValues(alpha: 0.08),
            ),

            _StatsRow(user: user),

            _InfoRow(user: user),

            _BioBox(user: user),

            SizedBox(height: R.size(context, 24)),
          ],
        ),
      ),
    );
  }
}

class _ProfileTopName extends StatelessWidget {
  final UserProfileModel user;

  const _ProfileTopName({
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: R.size(context, 122),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: R.size(context, 18)),
      child: Text(
        user.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          color: user.nameColor ?? const Color(0xFF202124),
          fontSize: R.sp(context, 24),
          fontWeight: FontWeight.w500,
          height: 1.1,
        ),
      ),
    );
  }
}

class _CoverAvatarSection extends StatelessWidget {
  final UserProfileModel user;

  const _CoverAvatarSection({
    required this.user,
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
            child: _CoverImage(user: user),
          ),

          Positioned(
            bottom: R.size(context, 0),
            child: _Avatar(user: user),
          ),
        ],
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  final UserProfileModel user;

  const _CoverImage({
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    if (user.coverUrl.trim().isEmpty) {
      return Container(
        color: const Color(0xFFF7F8FA),
      );
    }

    return Image.network(
      user.coverUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          color: const Color(0xFFF7F8FA),
        );
      },
    );
  }
}

class _Avatar extends StatelessWidget {
  final UserProfileModel user;

  const _Avatar({
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: R.size(context, 150),
      height: R.size(context, 150),
      padding: EdgeInsets.all(R.size(context, 4)),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFF7F8FA),
          width: R.size(context, 4),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(user.frame != null ? R.size(context, 3) : 0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: user.frame != null
              ? Border.all(
                  color: user.frame == 'gold'
                      ? const Color(0xFFFFC107)
                      : Colors.red,
                  width: R.size(context, 3),
                )
              : null,
        ),
        child: ClipOval(
          child: user.avatarUrl.trim().isNotEmpty
              ? Image.network(
                  user.avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return _AvatarText(user: user);
                  },
                )
              : _AvatarText(user: user),
        ),
      ),
    );
  }
}

class _AvatarText extends StatelessWidget {
  final UserProfileModel user;

  const _AvatarText({
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0C3A3F),
      alignment: Alignment.center,
      child: Text(
        user.avatarText,
        style: TextStyle(
          color: Colors.white,
          fontSize: R.sp(context, 42),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _UserIdText extends StatelessWidget {
  final UserProfileModel user;

  const _UserIdText({
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: R.size(context, 10)),
      child: Center(
        child: Text(
          'ID: ${user.id}',
          style: TextStyle(
            color: const Color(0xFF4A4D55),
            fontSize: R.sp(context, 22),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final UserProfileModel user;

  const _StatsRow({
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: R.size(context, 12)),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              value: '${user.receivedGifts}',
              label: 'Gifts',
              icon: Icons.south_west_rounded,
            ),
          ),
          Expanded(
            child: _StatItem(
              value: '${user.sentGifts}',
              label: 'Gifts',
              icon: Icons.north_east_rounded,
            ),
          ),
          Expanded(
            child: _StatItem(
              value: '${user.views}',
              label: 'Views',
            ),
          ),
          Expanded(
            child: _StatItem(
              value: '${user.friends}',
              label: 'Friends',
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final UserProfileModel user;

  const _InfoRow({
    required this.user,
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
              value: user.since,
              label: 'Since',
            ),
          ),
          Expanded(
            child: _InfoItem(
              value: user.country,
              label: 'Country',
            ),
          ),
          Expanded(
            child: _InfoItem(
              value: user.gender,
              label: 'Gender',
            ),
          ),
          Expanded(
            child: _InfoItem(
              value: user.age,
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
    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: const Color(0xFF6B8790),
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
                color: const Color(0xFF444850),
                fontSize: R.sp(context, 20),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (icon != null) ...[
              SizedBox(width: R.size(context, 3)),
              Icon(
                icon,
                color: const Color(0xFF444850),
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
    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: const Color(0xFF6B8790),
            fontSize: R.sp(context, 20),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: R.size(context, 4)),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF444850),
            fontSize: R.sp(context, 20),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _BioBox extends StatelessWidget {
  final UserProfileModel user;

  const _BioBox({
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final text = user.bio.trim().isEmpty
        ? 'فقدت حماسي في كل شيء رغباتي كلها تهجرني حتى أني لا أرى أحلامًا ذات شأن لا أرى سوى أحلام عادية.'
        : user.bio;

    return Container(
      width: double.infinity,
      color: const Color(0xFFE9EEF1),
      padding: EdgeInsets.symmetric(
        horizontal: R.size(context, 24),
        vertical: R.size(context, 12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          color: const Color(0xFF3E4248),
          fontSize: R.sp(context, 20),
          fontWeight: FontWeight.w400,
          height: 1.55,
        ),
      ),
    );
  }
}