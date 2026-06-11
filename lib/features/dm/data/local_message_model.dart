class LocalMessageModel {
  final String messageId;
  final String? tempId;

  final String chatId;

  final String fromUserId;
  final String toUserId;

  final String type; // text, image, video, audio, file

  final String text;

  final Map<String, dynamic>? media;
  final Map<String, dynamic>? replyTo;
  final Map<String, dynamic>? shared;

  final String status;
  // sending, sent, delivered, seen, failed, deleted

  final bool isMine;
  final bool isEdited;
  final bool isDeleted;

  final DateTime createdAt;
  final DateTime updatedAt;

  const LocalMessageModel({
    required this.messageId,
    this.tempId,
    required this.chatId,
    required this.fromUserId,
    required this.toUserId,
    required this.type,
    required this.text,
    this.media,
    this.replyTo,
    this.shared,
    required this.status,
    required this.isMine,
    required this.isEdited,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  LocalMessageModel copyWith({
    String? messageId,
    String? tempId,
    String? chatId,
    String? fromUserId,
    String? toUserId,
    String? type,
    String? text,
    Map<String, dynamic>? media,
    Map<String, dynamic>? replyTo,
    Map<String, dynamic>? shared,
    String? status,
    bool? isMine,
    bool? isEdited,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LocalMessageModel(
      messageId: messageId ?? this.messageId,
      tempId: tempId ?? this.tempId,
      chatId: chatId ?? this.chatId,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      type: type ?? this.type,
      text: text ?? this.text,
      media: media ?? this.media,
      replyTo: replyTo ?? this.replyTo,
      shared: shared ?? this.shared,
      status: status ?? this.status,
      isMine: isMine ?? this.isMine,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'tempId': tempId,
      'chatId': chatId,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'type': type,
      'text': text,
      'media': media,
      'replyTo': replyTo,
      'shared': shared,
      'status': status,
      'isMine': isMine,
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory LocalMessageModel.fromMap(Map<String, dynamic> map) {
    return LocalMessageModel(
      messageId: map['messageId']?.toString() ?? '',
      tempId: map['tempId']?.toString(),
      chatId: map['chatId']?.toString() ?? '',
      fromUserId: map['fromUserId']?.toString() ?? '',
      toUserId: map['toUserId']?.toString() ?? '',
      type: map['type']?.toString() ?? 'text',
      text: map['text']?.toString() ?? '',
      media: map['media'] is Map
          ? Map<String, dynamic>.from(map['media'] as Map)
          : null,
      replyTo: map['replyTo'] is Map
          ? Map<String, dynamic>.from(map['replyTo'] as Map)
          : null,
      shared: map['shared'] is Map
          ? Map<String, dynamic>.from(map['shared'] as Map)
          : null,
      status: map['status']?.toString() ?? 'sent',
      isMine: map['isMine'] == true || map['isMine']?.toString() == 'true',
      isEdited:
          map['isEdited'] == true || map['isEdited']?.toString() == 'true',
      isDeleted:
          map['isDeleted'] == true || map['isDeleted']?.toString() == 'true',
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
