class RoomWsHandlers {
  static const roomCreate = 'room.create';
  static const roomJoin = 'room.join';
  static const roomLeave = 'room.leave';
  static const roomList = 'room.list';

  static const roomMessageSend = 'room.message.send';
  static const roomMessageReaction = 'room.message.reaction';

  static const roomRoleSet = 'room.role.set';

  static const roomBanUser = 'room.ban.user';

  static const roomPasswordSet = 'room.password.set';
  static const roomLockSet = 'room.lock.set';

  static const roomPinSet = 'room.pin.set';

  static const roomFavoriteToggle = 'room.favorite.toggle';

  static const roomBoost = 'room.boost';
}

class RoomWsEvents {
  static const roomCreate = 'room.create';
  static const roomJoin = 'room.join';
  static const roomLeave = 'room.leave';
  static const roomList = 'room.list';

  static const roomMessage = 'room.message';
  static const roomMessageSend = 'room.message.send';
  static const roomReaction = 'room.message.reaction';

  static const roomUsers = 'room.users';
  static const roomUpdate = 'room.update';
  static const roomActiveCount = 'room.active_count.update';

  static const roomError = 'room.error';
}