class WsHandlers {
  static const authLogin = 'auth.login';
  static const authRegister = 'auth.register';
  static const authLogout = 'auth.logout';

  static const usersProfileUpdate = 'users.profile.update';
  static const usersProfileImageUpdate = 'users.profile.image.update';
  static const usersDeleteAccount = 'users.account.delete';

  static const usersSettingsUpdate = 'users.settings.update';
  static const usersBlock = 'users.block';
  static const usersUnblock = 'users.unblock';

  static const friendRequestRespond = 'friend.request.respond';

  static const storeItemsList = 'store.items.list';
  static const storeItemBuy = 'store.item.buy';
  static const storeItemActivate = 'store.item.activate';
  static const storePointsAdd = 'store.points.add';

  static const friendsList = 'friends.list';
  static const friendsRequest = 'friends.request';
  static const friendsAccept = 'friends.accept';
  static const friendsReject = 'friends.reject';
  static const friendsRemove = 'friends.remove';
  static const usersSearch = 'users.search';
  static const usersProfileGet = 'users.profile.get';

  static const friendRequestSend = 'friend.request.send';

  static const incomingFriendRequestsGet = 'friend.requests.incoming.list';

  static const friendsGet = 'friends.list';

  static const friendRemove = 'friends.remove';
  static const chatsList = 'chats.list';
  static const chatsMessageSend = 'chats.message.send';
  static const chatsTypingStart = 'chats.typing.start';
  static const chatsTypingStop = 'chats.typing.stop';
  static const usersBlockedList = 'users.blocked.list';
  static const roomsList = 'rooms.list';
  static const roomsJoin = 'rooms.join';
  static const roomsLeave = 'rooms.leave';
  static const roomsMessageSend = 'rooms.message.send';
  static const dmSend = 'dm.send';
  static const dmTyping = 'dm.typing';
  static const dmSeen = 'dm.seen';
  static const dmEdit = 'dm.edit';
  static const dmDelete = 'dm.delete';
  static const dmClear = 'dm.clear';
  static const dmShare = 'dm.share';
  static const dmPendingDeliver = 'dm.pending.deliver';
  static const tweetsCreate = 'tweets.create';
  static const tweetsList = 'tweets.list';
  static const tweetsLike = 'tweets.like';
  static const tweetsComment = 'tweets.comment';
  static const tweetsRetweet = 'tweets.retweet';
}
