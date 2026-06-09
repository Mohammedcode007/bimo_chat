class WsEvents {
  static const connectionEvent = 'connection_event';

  static const loginEvent = 'login_event';
  static const registerEvent = 'register_event';
  static const logoutEvent = 'logout_event';
static const userProfileEvent = 'user_profile_event';
  static const userSettingsEvent = 'user_settings_event';
  static const userBlockEvent = 'user_block_event';

  static const friendsListEvent = 'friends_list_event';
  static const friendRequestEvent = 'friend_request_event';

  static const chatsListEvent = 'chats_list_event';
  static const chatMessageEvent = 'chat_message_event';
  static const chatTypingEvent = 'chat_typing_event';

  static const roomsListEvent = 'rooms_list_event';
  static const roomJoinEvent = 'room_join_event';
  static const roomLeaveEvent = 'room_leave_event';
  static const roomMessageEvent = 'room_message_event';

  static const tweetsListEvent = 'tweets_list_event';
  static const tweetCreateEvent = 'tweet_create_event';
  static const tweetLikeEvent = 'tweet_like_event';
  static const tweetCommentEvent = 'tweet_comment_event';
  static const tweetRetweetEvent = 'tweet_retweet_event';

  static const notificationEvent = 'notification_event';
  static const errorEvent = 'error_event';
}
