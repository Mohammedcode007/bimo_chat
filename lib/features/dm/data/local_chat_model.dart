class LocalChatModel {
  final String chatId;

  final String peerUserId;
  final String peerUsername;
  final String peerPhotoUrl;

  final String lastMessageText;
  final String lastMessageType;

  final DateTime lastMessageAt;

  final int unreadCount;

  final bool isPinned;
  final bool isMuted;

  const LocalChatModel({
    required this.chatId,
    required this.peerUserId,
    required this.peerUsername,
    required this.peerPhotoUrl,
    required this.lastMessageText,
    required this.lastMessageType,
    required this.lastMessageAt,
    required this.unreadCount,
    this.isPinned = false,
    this.isMuted = false,
  });

  LocalChatModel copyWith({
    String? chatId,
    String? peerUserId,
    String? peerUsername,
    String? peerPhotoUrl,
    String? lastMessageText,
    String? lastMessageType,
    DateTime? lastMessageAt,
    int? unreadCount,
    bool? isPinned,
    bool? isMuted,
  }) {
    return LocalChatModel(
      chatId: chatId ?? this.chatId,
      peerUserId: peerUserId ?? this.peerUserId,
      peerUsername: peerUsername ?? this.peerUsername,
      peerPhotoUrl: peerPhotoUrl ?? this.peerPhotoUrl,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageType: lastMessageType ?? this.lastMessageType,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'peerUserId': peerUserId,
      'peerUsername': peerUsername,
      'peerPhotoUrl': peerPhotoUrl,
      'lastMessageText': lastMessageText,
      'lastMessageType': lastMessageType,
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'unreadCount': unreadCount,
      'isPinned': isPinned,
      'isMuted': isMuted,
    };
  }

  factory LocalChatModel.fromMap(Map<String, dynamic> map) {
    return LocalChatModel(
      chatId: map['chatId']?.toString() ?? '',
      peerUserId: map['peerUserId']?.toString() ?? '',
      peerUsername: map['peerUsername']?.toString() ?? '',
      peerPhotoUrl: map['peerPhotoUrl']?.toString() ?? '',
      lastMessageText: map['lastMessageText']?.toString() ?? '',
      lastMessageType: map['lastMessageType']?.toString() ?? 'text',
      lastMessageAt:
          DateTime.tryParse(map['lastMessageAt']?.toString() ?? '') ??
          DateTime.now(),
      unreadCount: int.tryParse(map['unreadCount']?.toString() ?? '') ?? 0,
      isPinned:
          map['isPinned'] == true || map['isPinned']?.toString() == 'true',
      isMuted: map['isMuted'] == true || map['isMuted']?.toString() == 'true',
    );
  }
}
