import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class MainHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? avatarUrl;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogoutTap;

  const MainHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.avatarUrl,
    this.onProfileTap,
    this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 18,
        right: 18,
        bottom: 14,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onProfileTap,
            borderRadius: BorderRadius.circular(18),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              backgroundImage: avatarUrl != null && avatarUrl!.trim().isNotEmpty
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: avatarUrl == null || avatarUrl!.trim().isEmpty
                  ? const Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                      size: 26,
                    )
                  : null,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          InkWell(
            onTap: onLogoutTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.textPrimary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
