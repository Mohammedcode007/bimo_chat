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

  static const friendsList = 'friends.list';
  static const friendsRequest = 'friends.request';
  static const friendsAccept = 'friends.accept';
  static const friendsReject = 'friends.reject';
  static const friendsRemove = 'friends.remove';

  static const chatsList = 'chats.list';
  static const chatsMessageSend = 'chats.message.send';
  static const chatsTypingStart = 'chats.typing.start';
  static const chatsTypingStop = 'chats.typing.stop';

  static const roomsList = 'rooms.list';
  static const roomsJoin = 'rooms.join';
  static const roomsLeave = 'rooms.leave';
  static const roomsMessageSend = 'rooms.message.send';

  static const tweetsCreate = 'tweets.create';
  static const tweetsList = 'tweets.list';
  static const tweetsLike = 'tweets.like';
  static const tweetsComment = 'tweets.comment';
  static const tweetsRetweet = 'tweets.retweet';
}