enum ChatMessageType { text, image, voice, video, file }

enum MessageStatus { sending, sent, delivered, seen }

class ChatMessageModel {
  final String id;
  final String text;
  final ChatMessageType type;
  final bool isMe;
  final String time;
  final MessageStatus status;
  final String? duration;
  final String? localPath;
  final String? fileName;

  final ChatMessageModel? replyTo;
  final String? reaction;
  final bool isEdited;
  final bool isDeleted;

  const ChatMessageModel({
    required this.id,
    required this.text,
    required this.type,
    required this.isMe,
    required this.time,
    this.status = MessageStatus.sent,
    this.duration,
    this.localPath,
    this.fileName,
    this.replyTo,
    this.reaction,
    this.isEdited = false,
    this.isDeleted = false,
  });

  ChatMessageModel copyWith({
    String? id,
    String? text,
    ChatMessageType? type,
    bool? isMe,
    String? time,
    MessageStatus? status,
    String? duration,
    String? localPath,
    String? fileName,
    ChatMessageModel? replyTo,
    String? reaction,
    bool? isEdited,
    bool? isDeleted,
    bool clearReply = false,
    bool clearReaction = false,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      isMe: isMe ?? this.isMe,
      time: time ?? this.time,
      status: status ?? this.status,
      duration: duration ?? this.duration,
      localPath: localPath ?? this.localPath,
      fileName: fileName ?? this.fileName,
      replyTo: clearReply ? null : replyTo ?? this.replyTo,
      reaction: clearReaction ? null : reaction ?? this.reaction,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
