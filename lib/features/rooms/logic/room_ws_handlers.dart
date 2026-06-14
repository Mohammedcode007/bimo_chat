class RoomWsHandlers {
  static const roomCreate = 'room.create';
  static const roomJoin = 'room.join';
  static const roomLeave = 'room.leave';
  static const roomList = 'room.list';

  static const roomMessageSend = 'room.message.send';
  static const roomMessageReaction = 'room.message.reaction';

  static const roomRoleSet = 'room.role.set';

  /*
    الجديد:
    جلب كل المستخدمين حسب الرتبة.
    role = owner / admin / member / creator
  */
  static const roomRolesList = 'room.roles.list';

  /*
    الجديد:
    حذف أي رتبة من المستخدم وإرجاعه none.
  */
  static const roomRoleRemove = 'room.role.remove';

  /*
    الجديد:
    جلب لوجات الغرفة.
  */
  static const roomLogsList = 'room.logs.list';

  /*
    الجديد:
    جلب المحظورين من الغرفة.
  */
  static const roomBannedList = 'room.banned.list';

  /*
    يستخدم مع الباك الجديد.
  */
  static const roomKick = 'room.kick';
  static const roomBan = 'room.ban';

  /*
    القديم:
    اتركه مؤقتًا لو أي شاشة قديمة ما زالت تستخدمه.
    لاحقًا بعد التأكد ممكن تحذفه.
  */
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

  /*
    أحداث مباشرة من الباك للمستخدم المطرود أو المحظور.
    هذه ليست handlers يرسلها الفرونت.
    الفرونت فقط يستقبلها.
  */
  static const roomKicked = 'room:kicked';
  static const roomBanned = 'room:banned';
}
