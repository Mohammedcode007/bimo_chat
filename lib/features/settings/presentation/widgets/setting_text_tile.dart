import 'package:flutter/material.dart';
import 'setting_tile_base.dart';

class SettingTextTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? trailingIcon;
  final VoidCallback? onTap;
  final Color? titleColor;

  const SettingTextTile({
    super.key,
    required this.title,
    this.subtitle,
    this.trailingIcon,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SettingTileBase(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: titleColor ?? colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (trailingIcon != null)
            Icon(
              trailingIcon,
              color: colorScheme.onSurface.withValues(alpha: 0.78),
              size: 22,
            ),
        ],
      ),
    );
  }
}
