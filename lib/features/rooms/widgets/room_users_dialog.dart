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

  static String _safeString(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final sortedUsers = [...users]..sort((a, b) {
        final rankA = _roleRank(a.role);
        final rankB = _roleRank(b.role);

        if (rankA != rankB) return rankB.compareTo(rankA);

        final nameA = _safeString(a.name).toLowerCase();
        final nameB = _safeString(b.name).toLowerCase();

        return nameA.compareTo(nameB);
      });

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: R.size(context, 24),
        vertical: R.size(context, 30),
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
                R.size(context, 24),
                R.size(context, 18),
                R.size(context, 12),
                R.size(context, 8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Users',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: R.sp(context, 31),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${sortedUsers.length}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: R.sp(context, 18),
                      fontWeight: FontWeight.w700,
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
            ),

            Divider(
              height: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.45),
            ),

            Expanded(
              child: sortedUsers.isEmpty
                  ? Center(
                      child: Text(
                        'No users online',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: R.sp(context, 16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: sortedUsers.length,
                      itemBuilder: (context, index) {
                        final user = sortedUsers[index];

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

  static int _roleRank(RoomRole role) {
    switch (role) {
      case RoomRole.owner:
        return 4;

      case RoomRole.admin:
        return 3;

      case RoomRole.member:
        return 2;

      case RoomRole.none:
        return 1;

      case RoomRole.banned:
        return 0;
    }
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

  static String _safeString(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  static String _firstLetter(dynamic value) {
    final text = _safeString(value);

    if (text.isEmpty) return '?';

    final runes = text.runes.toList();

    if (runes.isEmpty) return '?';

    return String.fromCharCode(runes.first).toUpperCase();
  }

  bool get canModerate {
    return myRole == RoomRole.owner || myRole == RoomRole.admin;
  }

  bool get isMe {
    return _safeString(user.id) == 'me';
  }

  Color roleColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (user.role) {
      case RoomRole.owner:
        return const Color(0xFFF59E0B);

      case RoomRole.admin:
        return const Color(0xFF3B82F6);

      case RoomRole.member:
        return const Color(0xFF087887);

      case RoomRole.banned:
        return colorScheme.error;

      case RoomRole.none:
        return colorScheme.onSurface;
    }
  }

  Color avatarBgColor(BuildContext context) {
    final color = roleColor(context);
    return color.withValues(alpha: 0.14);
  }

  List<RoomUserAction> buildActions() {
    final base = <RoomUserAction>[
      RoomUserAction.copy,
      RoomUserAction.message,
      RoomUserAction.sendGift,
    ];

    if (isMe) return base;

    if (!canModerate) return base;

    final actions = <RoomUserAction>[
      ...base,
      RoomUserAction.kick,
      RoomUserAction.ban,
      RoomUserAction.setMember,
    ];

    if (myRole == RoomRole.owner) {
      actions.add(RoomUserAction.setAdmin);
      actions.add(RoomUserAction.setOwner);
      actions.add(RoomUserAction.removeRole);
    }

    if (myRole == RoomRole.admin) {
      actions.add(RoomUserAction.removeRole);
    }

    return actions;
  }

  Future<void> openActions(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final actions = buildActions();

    final userName = _safeString(user.name);
    final avatarText = _safeString(user.avatarText);
    final displayAvatar =
        avatarText.isNotEmpty ? avatarText : _firstLetter(userName);

    final action = await showMenu<RoomUserAction>(
      context: context,
      color: colorScheme.surface,
      position: RelativeRect.fromLTRB(
        R.size(context, 120),
        R.size(context, 160),
        R.size(context, 30),
        0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(R.size(context, 10)),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
          width: 0.8,
        ),
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          height: R.size(context, 50),
          child: Row(
            children: [
              CircleAvatar(
                radius: R.size(context, 17),
                backgroundColor: avatarBgColor(context),
                child: Text(
                  displayAvatar,
                  style: TextStyle(
                    color: roleColor(context),
                    fontSize: R.sp(context, 13),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(width: R.size(context, 10)),
              Expanded(
                child: Text(
                  userName.isEmpty ? 'User' : userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: R.sp(context, 18),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        ...actions.map((action) {
          return PopupMenuItem(
            value: action,
            height: R.size(context, 56),
            child: Text(
              action.label,
              style: TextStyle(
                color: _actionColor(context, action),
                fontSize: R.sp(context, 21),
                fontWeight: FontWeight.w500,
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

  Color _actionColor(BuildContext context, RoomUserAction action) {
    final colorScheme = Theme.of(context).colorScheme;

    if (action == RoomUserAction.ban ||
        action == RoomUserAction.kick ||
        action == RoomUserAction.removeRole) {
      return colorScheme.error;
    }

    return colorScheme.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final userName = _safeString(user.name);
    final avatarText = _safeString(user.avatarText);
    final avatarUrl = _safeString(user.avatarUrl);
    final badge = _safeString(user.badge);

    final displayName = userName.isEmpty ? 'User' : userName;
    final displayAvatar =
        avatarText.isNotEmpty ? avatarText : _firstLetter(displayName);

    return InkWell(
      onTap: () => openActions(context),
      onLongPress: () => openActions(context),
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: R.size(context, 18),
          end: R.size(context, 12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: R.size(context, 31),
              backgroundColor: avatarBgColor(context),
              backgroundImage:
                  avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
              child: avatarUrl.isEmpty
                  ? Text(
                      displayAvatar,
                      style: TextStyle(
                        color: roleColor(context),
                        fontSize: R.sp(context, 18),
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  : null,
            ),

            SizedBox(width: R.size(context, 12)),

            Expanded(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: R.size(context, 76),
                ),
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
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: R.size(context, 9),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          user.nameColor ?? roleColor(context),
                                      fontSize: R.sp(context, 21),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                if (badge.isNotEmpty) ...[
                                  SizedBox(width: R.size(context, 5)),
                                  Text(
                                    badge,
                                    style: TextStyle(
                                      fontSize: R.sp(context, 15),
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            SizedBox(height: R.size(context, 3)),

                            Row(
                              children: [
                                Container(
                                  width: R.size(context, 7),
                                  height: R.size(context, 7),
                                  decoration: BoxDecoration(
                                    color: user.isOnline
                                        ? const Color(0xFF22C55E)
                                        : colorScheme.onSurfaceVariant,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: R.size(context, 6)),
                                Text(
                                  user.role.label,
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: R.sp(context, 14),
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: onGiftTap,
                      tooltip: 'Gift',
                      icon: Icon(
                        Icons.card_giftcard_rounded,
                        size: R.size(context, 29),
                        color: colorScheme.onSurface.withValues(alpha: 0.70),
                      ),
                    ),

                    IconButton(
                      onPressed: onMessageTap,
                      tooltip: 'Message',
                      icon: Icon(
                        Icons.message_rounded,
                        size: R.size(context, 29),
                        color: colorScheme.onSurface.withValues(alpha: 0.70),
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