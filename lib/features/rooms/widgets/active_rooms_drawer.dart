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

    final rooms = activeRooms.isEmpty ? [currentRoom] : activeRooms;

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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Active',
                              style: TextStyle(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.82,
                                ),
                                fontSize: R.sp(context, 22),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close_rounded,
                              color: colorScheme.onSurfaceVariant,
                              size: R.size(context, 26),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: R.size(context, 8)),

                      Text(
                        '${rooms.length} active room${rooms.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: R.sp(context, 15),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: R.size(context, 24)),

                      Expanded(
                        child: rooms.isEmpty
                            ? Center(
                                child: Text(
                                  'No active rooms',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: R.sp(context, 16),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount: rooms.length,
                                separatorBuilder: (_, __) {
                                  return SizedBox(height: R.size(context, 14));
                                },
                                itemBuilder: (context, index) {
                                  final room = rooms[index];
                                  final selected = room.id == currentRoom.id;

                                  return _ActiveRoomTile(
                                    room: room,
                                    selected: selected,
                                    onTap: () {
                                      Navigator.pop(context);

                                      if (!selected) {
                                        onRoomTap(room);
                                      }
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

    final selectedColor = const Color(0xFFA8EAF5);
    final accentColor = const Color(0xFF087887);

    return Material(
      color: selected ? selectedColor : Colors.transparent,
      borderRadius: BorderRadius.circular(R.size(context, 42)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(R.size(context, 42)),
        child:  Container(
  constraints: BoxConstraints(
    minHeight: R.size(context, 76),
  ),
  padding: EdgeInsetsDirectional.symmetric(
            horizontal: R.size(context, 20),
            vertical: R.size(context, 8),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: R.size(context, 24),
                backgroundColor: selected
                    ? accentColor.withValues(alpha: 0.14)
                    : room.avatarColor.withValues(alpha: 0.18),
                child: room.isVoice
                    ? Icon(
                        Icons.mic_rounded,
                        color: selected ? accentColor : room.avatarColor,
                        size: R.size(context, 23),
                      )
                    : Text(
                        (room.avatarText ?? '').isNotEmpty
                            ? room.avatarText!
                            : _firstLetter(room.name ?? ''),
                        style: TextStyle(
                          color: selected ? accentColor : room.avatarColor,
                          fontSize: R.sp(context, 18),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),

              SizedBox(width: R.size(context, 16)),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.88),
                        fontSize: R.sp(context, 19),
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: R.size(context, 3)),
                    Text(
                      '${room.membersCount} online'
                      '${room.isVoice ? ' • Voice' : ''}'
                      '${room.isFavorite ? ' • Favorite' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected
                            ? accentColor
                            : colorScheme.onSurfaceVariant,
                        fontSize: R.sp(context, 13),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              if (selected)
                Icon(
                  Icons.check_circle_rounded,
                  color: accentColor,
                  size: R.size(context, 22),
                )
              else
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: R.size(context, 15),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static String _firstLetter(String text) {
    final value = text.trim();

    if (value.isEmpty) return '?';

    final runes = value.runes.toList();

    if (runes.isEmpty) return '?';

    return String.fromCharCode(runes.first).toUpperCase();
  }
}
