import 'package:flutter/material.dart';

class SettingTileBase extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const SettingTileBase({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: theme.scaffoldBackgroundColor,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 66),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.55),
                width: 1,
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
