import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';
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
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: R.size(context, 38),
        vertical: R.size(context, 34),
      ),
      backgroundColor: Colors.white,
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

  Color get roleColor {
    switch (user.role) {
      case RoomRole.owner:
        return const Color(0xFFC04A28);

      case RoomRole.admin:
        return const Color(0xFF4A90E2);

      case RoomRole.banned:
        return Colors.red;

      case RoomRole.none:
      case RoomRole.member:
        return Colors.black;
    }
  }

  Future<void> openActions(BuildContext context) async {
    final actions = allowedRoomUserActions(myRole);

    final action = await showMenu<RoomUserAction>(
      context: context,
      color: const Color(0xFFF4EDF8),
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
              fontSize: R.sp(context, 18),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        ...actions.map(
          (action) => PopupMenuItem(
            value: action,
            height: R.size(context, 58),
            child: Text(
              action.label,
              style: TextStyle(
                fontSize: R.sp(context, 22),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );

    if (action != null) {
      onAction(action);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              backgroundColor: Colors.grey.shade300,
              child: Text(
                user.avatarText,
                style: TextStyle(
                  color: Colors.white,
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
                      color: Colors.grey.withValues(alpha: 0.25),
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
                              color: user.nameColor ?? roleColor,
                              fontSize: R.sp(context, 22),
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          SizedBox(height: R.size(context, 2)),

                          Text(
                            user.role.label,
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: 0.65),
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
                        color: Colors.black.withValues(alpha: 0.72),
                      ),
                    ),

                    IconButton(
                      onPressed: onMessageTap,
                      icon: Icon(
                        Icons.message_rounded,
                        size: R.size(context, 31),
                        color: Colors.black.withValues(alpha: 0.72),
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
