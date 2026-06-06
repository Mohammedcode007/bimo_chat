enum ChatLastMessageType { text, image, video, voice, file }

class ChatItemModel {
  final String id;
  final String name;
  final String lastMessage;
  final ChatLastMessageType lastMessageType;
  final String time;
  final String avatarUrl;
  final int unreadCount;
  final bool isOnline;
  final bool isTyping;

  const ChatItemModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.lastMessageType = ChatLastMessageType.text,
    this.avatarUrl = '',
    this.unreadCount = 0,
    this.isOnline = false,
    this.isTyping = false,
  });
}
