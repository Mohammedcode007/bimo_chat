class RoomLiveMessageModel {
  final String messageId;
  final String roomId;

  final String messageKind;
  final String type;

  final String fromUserId;
  final String fromUsername;
  final String fromPhotoUrl;
  final String fromRole;

  final String text;

  final RoomLiveMedia? media;
  final RoomMention? mention;
  final RoomGift? gift;
  final RoomEntryVideo? entryVideo;
  final RoomReply? replyTo;

  final List<RoomReaction> reactions;

  final RoomSystem? system;

  final DateTime createdAt;

  const RoomLiveMessageModel({
    required this.messageId,
    required this.roomId,
    required this.messageKind,
    required this.type,
    required this.fromUserId,
    required this.fromUsername,
    required this.fromPhotoUrl,
    required this.fromRole,
    required this.text,
    required this.media,
    required this.mention,
    required this.gift,
    required this.entryVideo,
    required this.replyTo,
    required this.reactions,
    required this.system,
    required this.createdAt,
  });

  factory RoomLiveMessageModel.fromJson(Map<String, dynamic> json) {
    return RoomLiveMessageModel(
      messageId: _s(json['messageId']),
      roomId: _s(json['roomId']),
      messageKind: _s(json['messageKind']),
      type: _s(json['type']),
      fromUserId: _s(json['fromUserId']),
      fromUsername: _s(json['fromUsername']),
      fromPhotoUrl: _s(json['fromPhotoUrl']),
      fromRole: _s(json['fromRole'], fallback: 'none'),
      text: _s(json['text']),
      media: json['media'] is Map<String, dynamic>
          ? RoomLiveMedia.fromJson(json['media'])
          : null,
      mention: json['mention'] is Map<String, dynamic>
          ? RoomMention.fromJson(json['mention'])
          : null,
      gift: json['gift'] is Map<String, dynamic>
          ? RoomGift.fromJson(json['gift'])
          : null,
      entryVideo: json['entryVideo'] is Map<String, dynamic>
          ? RoomEntryVideo.fromJson(json['entryVideo'])
          : null,
      replyTo: json['replyTo'] is Map<String, dynamic>
          ? RoomReply.fromJson(json['replyTo'])
          : null,
      reactions: json['reactions'] is List
          ? (json['reactions'] as List)
              .whereType<Map<String, dynamic>>()
              .map(RoomReaction.fromJson)
              .toList()
          : const [],
      system: json['system'] is Map<String, dynamic>
          ? RoomSystem.fromJson(json['system'])
          : null,
      createdAt: DateTime.tryParse(_s(json['createdAt'])) ?? DateTime.now(),
    );
  }

  RoomLiveMessageModel copyWith({
    List<RoomReaction>? reactions,
  }) {
    return RoomLiveMessageModel(
      messageId: messageId,
      roomId: roomId,
      messageKind: messageKind,
      type: type,
      fromUserId: fromUserId,
      fromUsername: fromUsername,
      fromPhotoUrl: fromPhotoUrl,
      fromRole: fromRole,
      text: text,
      media: media,
      mention: mention,
      gift: gift,
      entryVideo: entryVideo,
      replyTo: replyTo,
      reactions: reactions ?? this.reactions,
      system: system,
      createdAt: createdAt,
    );
  }
}

class RoomLiveMedia {
  final String url;
  final String fileName;
  final String mimeType;
  final int sizeBytes;

  const RoomLiveMedia({
    required this.url,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
  });

  factory RoomLiveMedia.fromJson(Map<String, dynamic> json) {
    return RoomLiveMedia(
      url: _s(json['url']),
      fileName: _s(json['fileName']),
      mimeType: _s(json['mimeType']),
      sizeBytes: _i(json['sizeBytes']),
    );
  }
}

class RoomMention {
  final String username;
  final String userId;
  final String text;

  const RoomMention({
    required this.username,
    required this.userId,
    required this.text,
  });

  factory RoomMention.fromJson(Map<String, dynamic> json) {
    return RoomMention(
      username: _s(json['username']),
      userId: _s(json['userId']),
      text: _s(json['text']),
    );
  }
}

class RoomGift {
  final String key;
  final String name;
  final String animationType;
  final String animationUrl;
  final String thumbnailUrl;
  final int value;
  final int durationMs;

  const RoomGift({
    required this.key,
    required this.name,
    required this.animationType,
    required this.animationUrl,
    required this.thumbnailUrl,
    required this.value,
    required this.durationMs,
  });

  factory RoomGift.fromJson(Map<String, dynamic> json) {
    return RoomGift(
      key: _s(json['key']),
      name: _s(json['name']),
      animationType: _s(json['animationType'], fallback: 'gif'),
      animationUrl: _s(json['animationUrl']),
      thumbnailUrl: _s(json['thumbnailUrl']),
      value: _i(json['value']),
      durationMs: _i(json['durationMs']),
    );
  }
}

class RoomEntryVideo {
  final String videoUrl;
  final String thumbnailUrl;
  final int durationMs;

  const RoomEntryVideo({
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.durationMs,
  });

  factory RoomEntryVideo.fromJson(Map<String, dynamic> json) {
    return RoomEntryVideo(
      videoUrl: _s(json['videoUrl']),
      thumbnailUrl: _s(json['thumbnailUrl']),
      durationMs: _i(json['durationMs']),
    );
  }
}

class RoomReply {
  final String messageId;
  final String fromUserId;
  final String text;
  final String type;
  final String mediaUrl;

  const RoomReply({
    required this.messageId,
    required this.fromUserId,
    required this.text,
    required this.type,
    required this.mediaUrl,
  });

  factory RoomReply.fromJson(Map<String, dynamic> json) {
    return RoomReply(
      messageId: _s(json['messageId']),
      fromUserId: _s(json['fromUserId']),
      text: _s(json['text']),
      type: _s(json['type']),
      mediaUrl: _s(json['mediaUrl']),
    );
  }
}

class RoomReaction {
  final String userId;
  final String emoji;
  final DateTime createdAt;

  const RoomReaction({
    required this.userId,
    required this.emoji,
    required this.createdAt,
  });

  factory RoomReaction.fromJson(Map<String, dynamic> json) {
    return RoomReaction(
      userId: _s(json['userId']),
      emoji: _s(json['emoji']),
      createdAt: DateTime.tryParse(_s(json['createdAt'])) ?? DateTime.now(),
    );
  }
}

class RoomSystem {
  final String action;
  final String actorId;
  final String actorUsername;
  final String targetUserId;
  final String targetUsername;
  final String oldRole;
  final String newRole;
  final bool dc;

  const RoomSystem({
    required this.action,
    required this.actorId,
    required this.actorUsername,
    required this.targetUserId,
    required this.targetUsername,
    required this.oldRole,
    required this.newRole,
    required this.dc,
  });

  factory RoomSystem.fromJson(Map<String, dynamic> json) {
    return RoomSystem(
      action: _s(json['action']),
      actorId: _s(json['actorId']),
      actorUsername: _s(json['actorUsername']),
      targetUserId: _s(json['targetUserId']),
      targetUsername: _s(json['targetUsername']),
      oldRole: _s(json['oldRole']),
      newRole: _s(json['newRole']),
      dc: json['dc'] == true,
    );
  }
}

String _s(dynamic value, {String fallback = ''}) {
final text = (value ?? '').toString().trim();
  return text.isEmpty ? fallback : text;
}

int _i(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
return int.tryParse((value ?? '').toString()) ?? fallback;
}