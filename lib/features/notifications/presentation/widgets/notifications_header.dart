import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';

class NotificationsHeader extends StatelessWidget {
  final VoidCallback onBackTap;
  final VoidCallback onMarkAllReadTap;

  const NotificationsHeader({
    super.key,
    required this.onBackTap,
    required this.onMarkAllReadTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: Container(
        height: R.size(context, 72),
        padding: EdgeInsetsDirectional.fromSTEB(
          R.size(context, 6),
          R.size(context, 8),
          R.size(context, 10),
          R.size(context, 8),
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.45),
              width: 0.7,
            ),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: onBackTap,
              icon: Icon(
                Icons.arrow_back_rounded,
                size: R.size(context, 28),
                color: colorScheme.onSurface,
              ),
            ),

            Expanded(
              child: Text(
                'Notifications',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: R.sp(context, 25),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            TextButton(
              onPressed: onMarkAllReadTap,
              child: Text(
                'Read all',
                style: TextStyle(
                  color: const Color(0xFF087887),
                  fontSize: R.sp(context, 14),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
