class LocalChatModel {
  final String chatId;
  final String peerUserId;
  final String peerUsername;
  final String peerPhotoUrl;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;

  LocalChatModel({
    required this.chatId,
    required this.peerUserId,
    required this.peerUsername,
    required this.peerPhotoUrl,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'chat_id': chatId,
      'peer_user_id': peerUserId,
      'peer_username': peerUsername,
      'peer_photo_url': peerPhotoUrl,
      'last_message': lastMessage,
      'last_message_at': lastMessageAt.toIso8601String(),
      'unread_count': unreadCount,
    };
  }

  factory LocalChatModel.fromJson(Map<String, dynamic> json) {
    return LocalChatModel(
      chatId: json['chat_id']?.toString() ?? '',
      peerUserId: json['peer_user_id']?.toString() ?? '',
      peerUsername: json['peer_username']?.toString() ?? '',
      peerPhotoUrl: json['peer_photo_url']?.toString() ?? '',
      lastMessage: json['last_message']?.toString() ?? '',
      lastMessageAt:
          DateTime.tryParse(json['last_message_at']?.toString() ?? '') ??
          DateTime.now(),
      unreadCount: int.tryParse(json['unread_count']?.toString() ?? '0') ?? 0,
    );
  }
}
