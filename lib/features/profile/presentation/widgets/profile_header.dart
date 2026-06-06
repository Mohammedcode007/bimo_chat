import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String coverUrl;
  final String avatarUrl;
  final String username;
  final String title;
  final VoidCallback onEditCover;
  final VoidCallback onEditAvatar;

  const ProfileHeader({
    super.key,
    required this.coverUrl,
    required this.avatarUrl,
    required this.username,
    required this.title,
    required this.onEditCover,
    required this.onEditAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 245,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 155,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              image: DecorationImage(
                image: NetworkImage(coverUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.18),
                    Colors.black.withValues(alpha: 0.30),
                  ],
                ),
              ),
            ),
          ),

          PositionedDirectional(
            top: 46,
            start: 18,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          PositionedDirectional(
            top: 46,
            end: 18,
            child: InkWell(
              onTap: onEditCover,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

          Positioned(
            top: 105,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.scaffoldBackgroundColor,
                          width: 5,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundColor: colorScheme.primary.withValues(
                          alpha: 0.12,
                        ),
                        backgroundImage: NetworkImage(avatarUrl),
                      ),
                    ),
                    PositionedDirectional(
                      end: -2,
                      bottom: 4,
                      child: InkWell(
                        onTap: onEditAvatar,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.scaffoldBackgroundColor,
                              width: 2.5,
                            ),
                          ),
                          child: Icon(
                            Icons.edit_rounded,
                            color: colorScheme.surface,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 9),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Text(
                    username,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
