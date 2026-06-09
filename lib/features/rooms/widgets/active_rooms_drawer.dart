import 'package:flutter/material.dart';

import '../../../core/utils/responsive.dart';
import '../data/room_model.dart';

class ActiveRoomsDrawer extends StatelessWidget {
  final RoomModel currentRoom;
  final List<RoomModel> activeRooms;
  final void Function(RoomModel room) onRoomTap;

  const ActiveRoomsDrawer({
    super.key,
    required this.currentRoom,
    required this.activeRooms,
    required this.onRoomTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.black.withValues(alpha: 0.18)),
            ),
          ),

          PositionedDirectional(
            end: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: MediaQuery.sizeOf(context).width * 0.94,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadiusDirectional.only(
                  topStart: Radius.circular(R.size(context, 28)),
                  bottomStart: Radius.circular(R.size(context, 28)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(-4, 0),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    R.size(context, 24),
                    R.size(context, 28),
                    R.size(context, 20),
                    R.size(context, 20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active',
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.82),
                          fontSize: R.sp(context, 22),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: R.size(context, 26)),

                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: activeRooms.length,
                          separatorBuilder: (_, __) {
                            return SizedBox(height: R.size(context, 14));
                          },
                          itemBuilder: (context, index) {
                            final room = activeRooms[index];
                            final selected = room.id == currentRoom.id;

                            return _ActiveRoomTile(
                              room: room,
                              selected: selected,
                              onTap: () {
                                Navigator.pop(context);
                                onRoomTap(room);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveRoomTile extends StatelessWidget {
  final RoomModel room;
  final bool selected;
  final VoidCallback onTap;

  const _ActiveRoomTile({
    required this.room,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: selected ? const Color(0xFFA8EAF5) : Colors.transparent,
      borderRadius: BorderRadius.circular(R.size(context, 42)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(R.size(context, 42)),
        child: Container(
          height: R.size(context, 76),
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: R.size(context, 26),
          ),
          child: Row(
            children: [
              Icon(
                Icons.bubble_chart_rounded,
                color: selected
                    ? const Color(0xFF087887)
                    : colorScheme.onSurface.withValues(alpha: 0.72),
                size: R.size(context, 36),
              ),

              SizedBox(width: R.size(context, 22)),

              Expanded(
                child: Text(
                  room.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.85),
                    fontSize: R.sp(context, 19),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
