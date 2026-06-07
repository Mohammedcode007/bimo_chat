import '../data/room_role.dart';

enum RoomUserAction {
  sendGift,
  message,
  kick,
  ban,
  setMember,
  setAdmin,
  setOwner,
  removeRole,
  copy,
}

extension RoomUserActionX on RoomUserAction {
  String get label {
    switch (this) {
      case RoomUserAction.sendGift:
        return 'Send Gift';
      case RoomUserAction.message:
        return 'Message';
      case RoomUserAction.kick:
        return 'Kick';
      case RoomUserAction.ban:
        return 'Ban';
      case RoomUserAction.setMember:
        return 'Set Member';
      case RoomUserAction.setAdmin:
        return 'Set Admin';
      case RoomUserAction.setOwner:
        return 'Set Owner';
      case RoomUserAction.removeRole:
        return 'Remove Role';
      case RoomUserAction.copy:
        return 'Copy';
    }
  }
}

List<RoomUserAction> allowedRoomUserActions(RoomRole myRole) {
  if (myRole == RoomRole.owner) {
    return const [
      RoomUserAction.sendGift,
      RoomUserAction.message,
      RoomUserAction.kick,
      RoomUserAction.ban,
      RoomUserAction.setMember,
      RoomUserAction.setAdmin,
      RoomUserAction.setOwner,
      RoomUserAction.removeRole,
      RoomUserAction.copy,
    ];
  }

  if (myRole == RoomRole.admin) {
    return const [
      RoomUserAction.sendGift,
      RoomUserAction.message,
      RoomUserAction.kick,
      RoomUserAction.ban,
      RoomUserAction.setMember,
      RoomUserAction.setAdmin,
      RoomUserAction.copy,
    ];
  }

  return const [
    RoomUserAction.message,
    RoomUserAction.copy,
  ];
}