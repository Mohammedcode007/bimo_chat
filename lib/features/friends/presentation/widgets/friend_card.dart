import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/friend_model.dart';

class FriendCard extends StatelessWidget {
  final FriendModel friend;
  final VoidCallback onTap;
  final VoidCallback onMessageTap;

  const FriendCard({
    super.key,
    required this.friend,
    required this.onTap,
    required this.onMessageTap,
  });

  bool get hasAvatar => friend.avatarUrl.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          R.size(context, 22),
          R.size(context, 8),
          R.size(context, 14),
          0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: R.size(context, 34),
                  backgroundColor: const Color(0xFFB8C4C9),
                  child: ClipOval(
                    child: hasAvatar
                        ? Image.network(
                            friend.avatarUrl,
                            width: R.size(context, 68),
                            height: R.size(context, 68),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return _AvatarFallback(name: friend.name);
                            },
                          )
                        : _AvatarFallback(name: friend.name),
                  ),
                ),

                if (friend.isOnline)
                  PositionedDirectional(
                    end: R.size(context, 2),
                    bottom: R.size(context, 2),
                    child: Container(
                      width: R.size(context, 15),
                      height: R.size(context, 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: R.size(context, 2.5),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(width: R.size(context, 18)),

            Expanded(
              child: Container(
                constraints: BoxConstraints(minHeight: R.size(context, 82)),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.75),
                      width: 1,
                    ),
                  ),
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.86),
                          fontSize: R.sp(context, 24),
                          fontWeight: FontWeight.w500,
                          height: 1.1,
                        ),
                      ),

                      SizedBox(height: R.size(context, 7)),

                      Text(
                        friend.status.trim().isEmpty
                            ? (friend.isOnline ? 'Online' : 'Offline')
                            : friend.status,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.65,
                          ),
                          fontSize: R.sp(context, 18),
                          fontWeight: FontWeight.w400,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String name;

  const _AvatarFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    final letter = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return Container(
      width: R.size(context, 68),
      height: R.size(context, 68),
      alignment: Alignment.center,
      color: const Color(0xFF0C9AA5),
      child: Text(
        letter,
        style: TextStyle(
          color: Colors.white,
          fontSize: R.sp(context, 29),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
