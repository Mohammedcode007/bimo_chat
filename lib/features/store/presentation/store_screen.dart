import 'package:flutter/material.dart';

import '../../../core/utils/responsive.dart';
import '../../settings/presentation/settings_screen.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  void openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingScreen()),
    );
  }

  void showMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  void logout(BuildContext context) {
    showMessage(context, 'Logout');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final items = const [
      StoreItem(
        title: 'VIP',
        subtitle: 'Special profile style and premium look',
        icon: Icons.workspace_premium_rounded,
        price: '500 Coins',
      ),
      StoreItem(
        title: 'Name Color',
        subtitle: 'Change your username color',
        icon: Icons.color_lens_rounded,
        price: '200 Coins',
      ),
      StoreItem(
        title: 'Badge',
        subtitle: 'Add a special badge beside your name',
        icon: Icons.verified_rounded,
        price: '350 Coins',
      ),
      StoreItem(
        title: 'Avatar Frame',
        subtitle: 'Decorate your profile avatar',
        icon: Icons.account_circle_rounded,
        price: '250 Coins',
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _StoreHeader(
            coins: '1,250',
            onAvatarTap: () => openSettings(context),
            onNotificationTap: () => showMessage(context, 'Notifications'),
            onSettingsTap: () => openSettings(context),
            onLogoutTap: () => logout(context),
          ),

          Container(
            width: double.infinity,
            margin: EdgeInsetsDirectional.fromSTEB(
              R.size(context, 16),
              R.size(context, 8),
              R.size(context, 16),
              R.size(context, 14),
            ),
            padding: EdgeInsets.all(R.size(context, 18)),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(R.size(context, 24)),
            ),
            child: Row(
              children: [
                Container(
                  width: R.size(context, 52),
                  height: R.size(context, 52),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.monetization_on_rounded,
                    color: Colors.white,
                    size: R.size(context, 30),
                  ),
                ),

                SizedBox(width: R.size(context, 14)),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Balance',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: R.sp(context, 14),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: R.size(context, 4)),
                      Text(
                        '1,250 Coins',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: R.sp(context, 27),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),

                ElevatedButton(
                  onPressed: () => showMessage(context, 'Buy coins'),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.white,
                    foregroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.size(context, 999)),
                    ),
                  ),
                  child: Text(
                    'Buy',
                    style: TextStyle(
                      fontSize: R.sp(context, 14),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              R.size(context, 18),
              0,
              R.size(context, 18),
              R.size(context, 8),
            ),
            child: Row(
              children: [
                Text(
                  'Store Items',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: R.sp(context, 20),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: R.size(context, 12)),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return _StoreItemCard(
                  item: item,
                  onTap: () => showMessage(context, '${item.title} selected'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreHeader extends StatelessWidget {
  final String coins;
  final VoidCallback onAvatarTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;

  const _StoreHeader({
    required this.coins,
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
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          R.size(context, 22),
          R.size(context, 14),
          R.size(context, 10),
          R.size(context, 12),
        ),
        child: Row(
          children: [
            InkWell(
              onTap: onAvatarTap,
              borderRadius: BorderRadius.circular(999),
              child: CircleAvatar(
                radius: R.size(context, 31),
                backgroundColor: const Color(0xFFDDE7FF),
                child: Icon(
                  Icons.person_rounded,
                  size: R.size(context, 33),
                  color: colorScheme.primary,
                ),
              ),
            ),

            SizedBox(width: R.size(context, 16)),

            Expanded(
              child: Text(
                'Store',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: R.sp(context, 36),
                  fontWeight: FontWeight.w400,
                  height: 1,
                ),
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(
                horizontal: R.size(context, 10),
                vertical: R.size(context, 6),
              ),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(R.size(context, 999)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.monetization_on_rounded,
                    color: colorScheme.primary,
                    size: R.size(context, 17),
                  ),
                  SizedBox(width: R.size(context, 4)),
                  Text(
                    coins,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: R.sp(context, 13),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: R.size(context, 4)),

            _HeaderIcon(
              icon: Icons.notifications_rounded,
              onTap: onNotificationTap,
            ),

            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'settings') {
                  onSettingsTap();
                } else if (value == 'logout') {
                  onLogoutTap();
                }
              },
              color: const Color(0xFFF4EDF8),
              elevation: 6,
              offset: Offset(0, R.size(context, 46)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(R.size(context, 8)),
              ),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: 'settings',
                    height: R.size(context, 56),
                    child: Text(
                      'Settings',
                      style: TextStyle(fontSize: R.sp(context, 24)),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    height: R.size(context, 56),
                    child: Text(
                      'Logout',
                      style: TextStyle(fontSize: R.sp(context, 24)),
                    ),
                  ),
                ];
              },
              child: Padding(
                padding: EdgeInsets.all(R.size(context, 8)),
                child: Icon(
                  Icons.more_vert_rounded,
                  size: R.size(context, 33),
                  color: colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: EdgeInsets.all(R.size(context, 8)),
        child: Icon(
          icon,
          size: R.size(context, 33),
          color: colorScheme.onSurface.withValues(alpha: 0.72),
        ),
      ),
    );
  }
}

class StoreItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String price;

  const StoreItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.price,
  });
}

class _StoreItemCard extends StatelessWidget {
  final StoreItem item;
  final VoidCallback onTap;

  const _StoreItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        R.size(context, 14),
        R.size(context, 5),
        R.size(context, 14),
        R.size(context, 5),
      ),
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(R.size(context, 20)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(R.size(context, 20)),
          child: Container(
            constraints: BoxConstraints(minHeight: R.size(context, 84)),
            padding: EdgeInsets.all(R.size(context, 14)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(R.size(context, 20)),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: R.size(context, 52),
                  height: R.size(context, 52),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.icon,
                    color: colorScheme.primary,
                    size: R.size(context, 26),
                  ),
                ),

                SizedBox(width: R.size(context, 13)),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: R.sp(context, 17),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: R.size(context, 4)),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: R.sp(context, 13),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: R.size(context, 10)),

                Text(
                  item.price,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: R.sp(context, 13),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
