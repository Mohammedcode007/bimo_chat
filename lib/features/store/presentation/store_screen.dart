import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/responsive.dart';
import '../../auth/logic/auth_provider.dart';
import '../../settings/presentation/settings_screen.dart';
import '../logic/store_provider.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(storeProvider.notifier).loadStore();
    });
  }

  void openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingScreen()),
    );
  }

  void showMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void logout(BuildContext context) {
    ref.read(authProvider.notifier).logout();
  }

  Color hexToColor(String value) {
    final hex = value.replaceAll('#', '').trim();

    if (hex.length != 6) {
      return const Color(0xFF2BCB00);
    }

    return Color(int.parse('FF$hex', radix: 16));
  }

  String itemPriceText(Map<String, dynamic> item) {
    final price = int.tryParse(item['price']?.toString() ?? '') ?? 0;
    return '$price pts';
  }

  String itemDurationText(Map<String, dynamic> item) {
    final days = int.tryParse(item['durationDays']?.toString() ?? '') ?? 30;
    return '$days days';
  }

  String itemTypeTitle(String type) {
    if (type == 'account_color') return 'Colors';
    if (type == 'badge') return 'Badges';
    if (type == 'verification') return 'Verification';
    return 'Items';
  }

  IconData itemIcon(String type, String value) {
    if (type == 'account_color') return Icons.color_lens_rounded;
    if (type == 'badge') return Icons.workspace_premium_rounded;

    if (type == 'verification') {
      if (value == 'gold') return Icons.workspace_premium_rounded;
      if (value == 'business') return Icons.business_center_rounded;
      return Icons.verified_rounded;
    }

    return Icons.shopping_bag_rounded;
  }

  bool hasActiveItemOfType(String type, List<Map<String, dynamic>> inventory) {
    return inventory.any((item) {
      return item['type']?.toString() == type && item['isActive'] == true;
    });
  }

  String actionText({
    required bool active,
    required bool owned,
    required bool hasActiveSameType,
  }) {
    if (active) return 'Active';
    if (owned) return 'Renew';
    if (hasActiveSameType) return 'Change';
    return 'Buy';
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(storeProvider);
    final auth = ref.watch(authProvider);
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen(storeProvider, (previous, next) {
      if (next.error != null && next.error!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            behavior: SnackBarBehavior.floating,
          ),
        );

        ref.read(storeProvider.notifier).clearError();
      }
    });

    final userPoints =
        int.tryParse(auth.user?['points']?.toString() ?? '') ?? store.points;

    final colors = store.items.where((item) {
      return item['type']?.toString() == 'account_color';
    }).toList();

    final badges = store.items.where((item) {
      return item['type']?.toString() == 'badge';
    }).toList();

    final verifications = store.items.where((item) {
      return item['type']?.toString() == 'verification';
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _StoreHeader(
            coins: userPoints.toString(),
            onAvatarTap: () => openSettings(context),
            onNotificationTap: () => showMessage(context, 'Notifications'),
            onSettingsTap: () => openSettings(context),
            onLogoutTap: () => logout(context),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.read(storeProvider.notifier).loadStore();
              },
              child: ListView(
                padding: EdgeInsets.only(bottom: R.size(context, 18)),
                children: [
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
                                '$userPoints Points',
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
                          onPressed: store.loading
                              ? null
                              : () {
                                  ref
                                      .read(storeProvider.notifier)
                                      .addPoints(1000);
                                },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.white,
                            foregroundColor: colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(R.size(context, 999)),
                            ),
                          ),
                          child: Text(
                            '+ Test',
                            style: TextStyle(
                              fontSize: R.sp(context, 14),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (store.loading && store.items.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: R.size(context, 70)),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  else if (store.items.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(R.size(context, 24)),
                      child: Center(
                        child: Text(
                          'No store items found',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: R.sp(context, 16),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else ...[
                    if (colors.isNotEmpty) ...[
                      _SectionTitle(title: 'Account Colors'),

                      SizedBox(
                        height: R.size(context, 142),
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(
                            horizontal: R.size(context, 16),
                          ),
                          itemCount: colors.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(width: R.size(context, 12)),
                          itemBuilder: (context, index) {
                            final item = colors[index];

                            final itemId = item['itemId']?.toString() ?? '';
                            final value = item['value']?.toString() ?? '';
                            final name = item['name']?.toString() ?? '';
                            final type = item['type']?.toString() ?? '';

                            final owned = store.isOwned(itemId);
                            final active = store.isActive(itemId);
                            final daysLeft = store.daysLeft(itemId);
                            final hasActiveSameType =
                                hasActiveItemOfType(type, store.inventory);

                            return _ColorStoreCard(
                              color: hexToColor(value),
                              name: name,
                              price: itemPriceText(item),
                              duration: daysLeft == null
                                  ? itemDurationText(item)
                                  : '$daysLeft days left',
                              active: active,
                              buttonText: actionText(
                                active: active,
                                owned: owned,
                                hasActiveSameType: hasActiveSameType,
                              ),
                              loading: store.loading,
                              onTap: active
                                  ? null
                                  : () {
                                      ref
                                          .read(storeProvider.notifier)
                                          .buyItem(itemId);
                                    },
                            );
                          },
                        ),
                      ),

                      SizedBox(height: R.size(context, 10)),
                    ],

                    if (badges.isNotEmpty) ...[
                      _SectionTitle(title: 'Badges'),
                      ...badges.map((item) {
                        return _StoreItemCard(
                          item: item,
                          owned: store.isOwned(
                            item['itemId']?.toString() ?? '',
                          ),
                          active: store.isActive(
                            item['itemId']?.toString() ?? '',
                          ),
                          daysLeft: store.daysLeft(
                            item['itemId']?.toString() ?? '',
                          ),
                          price: itemPriceText(item),
                          duration: itemDurationText(item),
                          icon: itemIcon(
                            item['type']?.toString() ?? '',
                            item['value']?.toString() ?? '',
                          ),
                          previewColor: colorScheme.primary,
                          hasActiveSameType: hasActiveItemOfType(
                            item['type']?.toString() ?? '',
                            store.inventory,
                          ),
                          loading: store.loading,
                          onTap: () {
                            ref.read(storeProvider.notifier).buyItem(
                                  item['itemId']?.toString() ?? '',
                                );
                          },
                        );
                      }),
                    ],

                    if (verifications.isNotEmpty) ...[
                      _SectionTitle(title: 'Verification'),
                      ...verifications.map((item) {
                        return _StoreItemCard(
                          item: item,
                          owned: store.isOwned(
                            item['itemId']?.toString() ?? '',
                          ),
                          active: store.isActive(
                            item['itemId']?.toString() ?? '',
                          ),
                          daysLeft: store.daysLeft(
                            item['itemId']?.toString() ?? '',
                          ),
                          price: itemPriceText(item),
                          duration: itemDurationText(item),
                          icon: itemIcon(
                            item['type']?.toString() ?? '',
                            item['value']?.toString() ?? '',
                          ),
                          previewColor:
                              item['value']?.toString() == 'gold'
                                  ? const Color(0xFFF59E0B)
                                  : colorScheme.primary,
                          hasActiveSameType: hasActiveItemOfType(
                            item['type']?.toString() ?? '',
                            store.inventory,
                          ),
                          loading: store.loading,
                          onTap: () {
                            ref.read(storeProvider.notifier).buyItem(
                                  item['itemId']?.toString() ?? '',
                                );
                          },
                        );
                      }),
                    ],
                  ],
                ],
              ),
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
              color: Theme.of(context).colorScheme.surface,
              elevation: 6,
              offset: Offset(0, R.size(context, 46)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(R.size(context, 8)),
              ),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: 'settings',
                    height: R.size(context, 52),
                    child: Text(
                      'Settings',
                      style: TextStyle(fontSize: R.sp(context, 20)),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    height: R.size(context, 52),
                    child: Text(
                      'Logout',
                      style: TextStyle(fontSize: R.sp(context, 20)),
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

  const _HeaderIcon({
    required this.icon,
    required this.onTap,
  });

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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        R.size(context, 18),
        R.size(context, 16),
        R.size(context, 18),
        R.size(context, 10),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: R.sp(context, 20),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ColorStoreCard extends StatelessWidget {
  final Color color;
  final String name;
  final String price;
  final String duration;
  final bool active;
  final bool loading;
  final String buttonText;
  final VoidCallback? onTap;

  const _ColorStoreCard({
    required this.color,
    required this.name,
    required this.price,
    required this.duration,
    required this.active,
    required this.loading,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: R.size(context, 132),
      padding: EdgeInsets.all(R.size(context, 12)),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(R.size(context, 20)),
        border: Border.all(
          color: active
              ? color
              : colorScheme.outlineVariant.withValues(alpha: 0.35),
          width: active ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: R.size(context, 40),
            height: R.size(context, 40),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),

          SizedBox(height: R.size(context, 8)),

          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: R.sp(context, 13),
              fontWeight: FontWeight.w800,
            ),
          ),

          SizedBox(height: R.size(context, 2)),

          Text(
            '$price • $duration',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: R.sp(context, 10),
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: R.size(context, 30),
            child: ElevatedButton(
              onPressed: active || loading ? null : onTap,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: EdgeInsets.zero,
                backgroundColor: active ? colorScheme.surfaceContainerHighest : color,
                foregroundColor: Colors.white,
                disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                disabledForegroundColor: colorScheme.onSurfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(R.size(context, 999)),
                ),
              ),
              child: Text(
                buttonText,
                style: TextStyle(
                  fontSize: R.sp(context, 11),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool owned;
  final bool active;
  final int? daysLeft;
  final String price;
  final String duration;
  final IconData icon;
  final Color previewColor;
  final bool hasActiveSameType;
  final bool loading;
  final VoidCallback onTap;

  const _StoreItemCard({
    required this.item,
    required this.owned,
    required this.active,
    required this.daysLeft,
    required this.price,
    required this.duration,
    required this.icon,
    required this.previewColor,
    required this.hasActiveSameType,
    required this.loading,
    required this.onTap,
  });

  String get title => item['name']?.toString() ?? '';
  String get type => item['type']?.toString() ?? '';
  String get value => item['value']?.toString() ?? '';

  String get subtitle {
    final typeText = type == 'badge'
        ? 'Profile badge'
        : type == 'verification'
            ? 'Account verification'
            : 'Store item';

    if (active && daysLeft != null) {
      return '$typeText • $daysLeft days left';
    }

    return '$typeText • $duration';
  }

  String get buttonText {
    if (active) return 'Active';
    if (owned) return 'Renew';
    if (hasActiveSameType) return 'Change';
    return 'Buy';
  }

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
        child: Container(
          constraints: BoxConstraints(minHeight: R.size(context, 92)),
          padding: EdgeInsets.all(R.size(context, 14)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(R.size(context, 20)),
            border: Border.all(
              color: active
                  ? previewColor.withValues(alpha: 0.75)
                  : colorScheme.outlineVariant.withValues(alpha: 0.35),
              width: active ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: R.size(context, 54),
                height: R.size(context, 54),
                decoration: BoxDecoration(
                  color: previewColor.withValues(alpha: 0.13),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: type == 'badge'
                      ? Text(
                          value,
                          style: TextStyle(fontSize: R.sp(context, 25)),
                        )
                      : Icon(
                          icon,
                          color: previewColor,
                          size: R.size(context, 27),
                        ),
                ),
              ),

              SizedBox(width: R.size(context, 13)),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
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
                      subtitle,
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

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: R.sp(context, 13),
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  SizedBox(height: R.size(context, 8)),

                  SizedBox(
                    height: R.size(context, 34),
                    child: ElevatedButton(
                      onPressed: active || loading ? null : onTap,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: R.size(context, 14),
                        ),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        disabledBackgroundColor:
                            colorScheme.surfaceContainerHighest,
                        disabledForegroundColor:
                            colorScheme.onSurfaceVariant,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(R.size(context, 999)),
                        ),
                      ),
                      child: Text(
                        buttonText,
                        style: TextStyle(
                          fontSize: R.sp(context, 12),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
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