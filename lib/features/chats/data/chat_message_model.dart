enum ChatMessageType { text, image, video, voice, file }

enum MessageStatus { sending, sent, delivered, seen }

class ChatMessageModel {
  final String id;
  final String text;
  final ChatMessageType type;
  final bool isMe;
  final String time;
  final MessageStatus status;

  final String? mediaUrl;
  final String? localPath;
  final String? fileName;
  final String? duration;

  const ChatMessageModel({
    required this.id,
    required this.text,
    required this.type,
    required this.isMe,
    required this.time,
    this.status = MessageStatus.sent,
    this.mediaUrl,
    this.localPath,
    this.fileName,
    this.duration,
  });
}
