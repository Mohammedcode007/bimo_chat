// import 'package:flutter/material.dart';

// import '../../../core/utils/responsive.dart';

// enum RoomFilterType {
//   public,
//   voice,
//   active,
//   favorite,
// }

// class RoomsFilterChips extends StatelessWidget {
//   final RoomFilterType selectedFilter;
//   final ValueChanged<RoomFilterType> onChanged;
//   final int activeCount;

//   const RoomsFilterChips({
//     super.key,
//     required this.selectedFilter,
//     required this.onChanged,
//     this.activeCount = 1,
//   });
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: R.size(context, 56),
//       child: ListView(
//         scrollDirection: Axis.horizontal,
//         padding: EdgeInsets.symmetric(horizontal: R.size(context, 14)),
//         children: [
//           _FilterChipButton(
//             label: 'Public',
//             icon: Icons.public_rounded,
//             isSelected: selectedFilter == RoomFilterType.public,
//             onTap: () => onChanged(RoomFilterType.public),
//           ),
//           _FilterChipButton(
//             label: 'Voice',
//             icon: Icons.volume_up_rounded,
//             isSelected: selectedFilter == RoomFilterType.voice,
//             onTap: () => onChanged(RoomFilterType.voice),
//           ),
//           _FilterChipButton(
//             label: 'Active',
//             icon: Icons.check_circle_outline_rounded,
//             isSelected: selectedFilter == RoomFilterType.active,
//             badge: activeCount,
//             onTap: () => onChanged(RoomFilterType.active),
//           ),
//           _FilterChipButton(
//             label: 'Favorite',
//             icon: Icons.favorite_border_rounded,
//             isSelected: selectedFilter == RoomFilterType.favorite,
//             onTap: () => onChanged(RoomFilterType.favorite),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _FilterChipButton extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final bool isSelected;
//   final VoidCallback onTap;
//   final int? badge;

//   const _FilterChipButton({
//     required this.label,
//     required this.icon,
//     required this.isSelected,
//     required this.onTap,
//     this.badge,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return Padding(
//       padding: EdgeInsetsDirectional.only(end: R.size(context, 10)),
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           InkWell(
//             onTap: onTap,
//             borderRadius: BorderRadius.circular(R.size(context, 12)),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 180),
//               height: R.size(context, 46),
//               padding: EdgeInsets.symmetric(horizontal: R.size(context, 13)),
//               decoration: BoxDecoration(
//                 color: isSelected
//                     ? const Color(0xFFCDEEF5)
//                     : Colors.transparent,
//                 borderRadius: BorderRadius.circular(R.size(context, 12)),
//                 border: Border.all(
//                   color: isSelected
//                       ? Colors.transparent
//                       : colorScheme.onSurface.withValues(alpha: 0.65),
//                   width: R.size(context, 1.3),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     icon,
//                     size: R.size(context, 23),
//                     color: colorScheme.onSurface.withValues(alpha: 0.82),
//                   ),
//                   SizedBox(width: R.size(context, 7)),
//                   Text(
//                     label,
//                     style: TextStyle(
//                       color: colorScheme.onSurface.withValues(alpha: 0.88),
//                       fontSize: R.sp(context, 21),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (badge != null && badge! > 0)
//             PositionedDirectional(
//               top: R.size(context, -8),
//               end: R.size(context, -2),
//               child: Container(
//                 width: R.size(context, 28),
//                 height: R.size(context, 28),
//                 decoration: const BoxDecoration(
//                   color: Color(0xFFE64B3C),
//                   shape: BoxShape.circle,
//                 ),
//                 alignment: Alignment.center,
//                 child: Text(
//                   badge.toString(),
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: R.sp(context, 15),
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

import '../../../core/utils/responsive.dart';
import '../../../core/localization/app_localizations.dart';

enum RoomFilterType {
  public,
  voice,
  active,
  favorite,
}

class RoomsFilterChips extends StatelessWidget {
  final RoomFilterType selectedFilter;
  final ValueChanged<RoomFilterType> onChanged;
  final int activeCount;

  const RoomsFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
    this.activeCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return SizedBox(
      height: R.size(context, 60),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.size(context, 14),
        ),
        child: Row(
          children: [
            Expanded(
              child: _FilterChipButton(
                label: localizations.t('public_rooms'),
                icon: Icons.public_rounded,
                isSelected:
                    selectedFilter == RoomFilterType.public,
                onTap: () {
                  onChanged(RoomFilterType.public);
                },
              ),
            ),
            Expanded(
              child: _FilterChipButton(
                label: localizations.t('voice_rooms'),
                icon: Icons.volume_up_rounded,
                isSelected:
                    selectedFilter == RoomFilterType.voice,
                onTap: () {
                  onChanged(RoomFilterType.voice);
                },
              ),
            ),
            Expanded(
              child: _FilterChipButton(
                label: localizations.t('active_rooms'),
                icon: Icons.check_circle_outline_rounded,
                isSelected:
                    selectedFilter == RoomFilterType.active,
                badge: activeCount,
                onTap: () {
                  onChanged(RoomFilterType.active);
                },
              ),
            ),
            Expanded(
              child: _FilterChipButton(
                label: localizations.t('favorite_rooms'),
                icon: Icons.favorite_border_rounded,
                isSelected:
                    selectedFilter == RoomFilterType.favorite,
                onTap: () {
                  onChanged(RoomFilterType.favorite);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badge;

  const _FilterChipButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        end: R.size(context, 4),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(
              R.size(context, 13),
            ),
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 180,
              ),
              width: double.infinity,
              height: R.size(context, 50),
              padding: EdgeInsets.symmetric(
                horizontal: R.size(context, 10),
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFCDEEF5)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(
                  R.size(context, 13),
                ),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : colorScheme.onSurface.withValues(
                          alpha: 0.65,
                        ),
                  width: R.size(context, 1.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: R.size(context, 22),
                    color:
                        colorScheme.onSurface.withValues(
                      alpha: 0.82,
                    ),
                  ),
                  SizedBox(
                    width: R.size(context, 5),
                  ),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            colorScheme.onSurface.withValues(
                          alpha: 0.88,
                        ),
                        fontSize: R.sp(context, 18),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (badge != null && badge! > 0)
            PositionedDirectional(
              top: R.size(context, -8),
              end: R.size(context, -2),
              child: Container(
                width: R.size(context, 26),
                height: R.size(context, 26),
                decoration: const BoxDecoration(
                  color: Color(0xFFE64B3C),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  badge.toString(),
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: R.sp(context, 14),
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}