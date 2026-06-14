import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';
import '../data/room_model.dart';
import 'room_avatar.dart';

class RoomCard extends StatelessWidget {
  final RoomModel room;
  final VoidCallback onTap;

  const RoomCard({super.key, required this.room, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: R.size(context, 14),
        vertical: R.size(context, 5),
      ),
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(R.size(context, 22)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(R.size(context, 22)),
          child: Container(
            constraints: BoxConstraints(minHeight: R.size(context, 104)),
            padding: EdgeInsetsDirectional.fromSTEB(
              R.size(context, 16),
              R.size(context, 8),
              R.size(context, 16),
              R.size(context, 8),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(R.size(context, 22)),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                RoomAvatar(
                  color: room.avatarColor,
                  text: room.avatarText ?? room.name,
                  isVerified: room.isVerified,
                  baseSize: 76,
                ),

                SizedBox(width: R.size(context, 16)),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              room.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: R.sp(context, 21),
                                fontWeight: FontWeight.w700,
                                height: 1.15,
                              ),
                            ),
                          ),

                          if (room.isLockedForNone) ...[
                            SizedBox(width: R.size(context, 6)),
                            Tooltip(
                              message: 'Members Only',
                              child: Icon(
                                Icons.group_off_outlined,
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.75,
                                ),
                                size: R.size(context, 22),
                              ),
                            ),
                          ],

                          if (room.hasPassword) ...[
                            SizedBox(width: R.size(context, 6)),
                            Tooltip(
                              message: 'Password Required',
                              child: Icon(
                                Icons.lock_outline_rounded,
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.75,
                                ),
                                size: R.size(context, 22),
                              ),
                            ),
                          ],
                        ],
                      ),

                      SizedBox(height: R.size(context, 14)),

                      Row(
                        children: [
                          Icon(
                            Icons.people_alt_outlined,
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.55,
                            ),
                            size: R.size(context, 20),
                          ),
                          SizedBox(width: R.size(context, 5)),
                          Text(
                            room.membersCount.toString(),
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.65,
                              ),
                              fontSize: R.sp(context, 20),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(width: R.size(context, 8)),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: R.size(context, 48),
                      height: R.size(context, 48),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9EA0A1).withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        room.rank.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: R.sp(context, 18),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    if (room.showGroupIcon) ...[
                      SizedBox(height: R.size(context, 12)),
                      Icon(
                        Icons.groups_rounded,
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.55,
                        ),
                        size: R.size(context, 30),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
