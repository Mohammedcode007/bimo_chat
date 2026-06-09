import 'package:flutter/material.dart';

import '../../../core/utils/responsive.dart';
import '../data/room_chat_user_model.dart';
import '../data/room_role.dart';
import 'room_user_action_menu.dart';

class RoomUsersDialog extends StatelessWidget {
  final List<RoomChatUserModel> users;
  final RoomRole myRole;
  final void Function(RoomChatUserModel user, RoomUserAction action)
  onUserAction;
  final void Function(RoomChatUserModel user) onMessageTap;

  const RoomUsersDialog({
    super.key,
    required this.users,
    required this.myRole,
    required this.onUserAction,
    required this.onMessageTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: R.size(context, 38),
        vertical: R.size(context, 34),
      ),
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(R.size(context, 18)),
      ),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.82,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                R.size(context, 28),
                R.size(context, 22),
                R.size(context, 16),
                R.size(context, 4),
              ),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'Users',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: R.sp(context, 34),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];

                  return _UserTile(
                    user: user,
                    myRole: myRole,
                    onMessageTap: () => onMessageTap(user),
                    onGiftTap: () {
                      onUserAction(user, RoomUserAction.sendGift);
                    },
                    onAction: (action) {
                      onUserAction(user, action);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final RoomChatUserModel user;
  final RoomRole myRole;
  final VoidCallback onMessageTap;
  final VoidCallback onGiftTap;
  final ValueChanged<RoomUserAction> onAction;

  const _UserTile({
    required this.user,
    required this.myRole,
    required this.onMessageTap,
    required this.onGiftTap,
    required this.onAction,
  });

  Color roleColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (user.role) {
      case RoomRole.owner:
        return const Color(0xFFC04A28);

      case RoomRole.admin:
        return const Color(0xFF4A90E2);

      case RoomRole.banned:
        return colorScheme.error;

      case RoomRole.none:
        return colorScheme.onSurface;

      case RoomRole.member:
        return colorScheme.onSurface;
    }
  }

  Future<void> openActions(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final actions = allowedRoomUserActions(myRole);

    final action = await showMenu<RoomUserAction>(
      context: context,
      color: colorScheme.surface,
      position: RelativeRect.fromLTRB(
        R.size(context, 120),
        R.size(context, 160),
        R.size(context, 30),
        0,
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          height: R.size(context, 46),
          child: Text(
            user.name,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: R.sp(context, 18),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        ...actions.map((action) {
          return PopupMenuItem(
            value: action,
            height: R.size(context, 58),
            child: Text(
              action.label,
              style: TextStyle(
                color: action == RoomUserAction.ban
                    ? colorScheme.error
                    : colorScheme.onSurface,
                fontSize: R.sp(context, 22),
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }),
      ],
    );

    if (action != null) {
      onAction(action);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => openActions(context),
      onLongPress: () => openActions(context),
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: R.size(context, 18),
          end: R.size(context, 14),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: R.size(context, 31),
              backgroundColor: colorScheme.surfaceContainerHighest,
              child: Text(
                user.avatarText,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: R.sp(context, 18),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            SizedBox(width: R.size(context, 12)),

            Expanded(
              child: Container(
                height: R.size(context, 72),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: user.nameColor ?? roleColor(context),
                              fontSize: R.sp(context, 22),
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          SizedBox(height: R.size(context, 2)),

                          Text(
                            user.role.label,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: R.sp(context, 15),
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: onGiftTap,
                      icon: Icon(
                        Icons.card_giftcard_rounded,
                        size: R.size(context, 31),
                        color: colorScheme.onSurface.withValues(alpha: 0.72),
                      ),
                    ),

                    IconButton(
                      onPressed: onMessageTap,
                      icon: Icon(
                        Icons.message_rounded,
                        size: R.size(context, 31),
                        color: colorScheme.onSurface.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
