class RoomModel {
  final String roomId;
  final String name;
  final String description;
  final String creatorId;

  final String role;

  final bool hasPassword;
  final bool isLockedForNone;
  final bool voiceEnabled;

  final int maxUsers;
  final int activeCount;
  final int favoriteCount;

  final int boostScore;
  final int boostCount;

  final bool isFavorite;

  final RoomPinnedMessage pinnedMessage;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RoomModel({
    required this.roomId,
    required this.name,
    required this.description,
    required this.creatorId,
    required this.role,
    required this.hasPassword,
    required this.isLockedForNone,
    required this.voiceEnabled,
    required this.maxUsers,
    required this.activeCount,
    required this.favoriteCount,
    required this.boostScore,
    required this.boostCount,
    required this.isFavorite,
    required this.pinnedMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      roomId: _s(json['roomId']),
      name: _s(json['name']),
      description: _s(json['description']),
      creatorId: _s(json['creatorId']),
      role: _s(json['role'], fallback: 'none'),
      hasPassword: json['hasPassword'] == true,
      isLockedForNone: json['isLockedForNone'] == true,
      voiceEnabled: json['voiceEnabled'] == true,
      maxUsers: _i(json['maxUsers'], fallback: 50),
      activeCount: _i(json['activeCount']),
      favoriteCount: _i(json['favoriteCount']),
      boostScore: _i(json['boostScore']),
      boostCount: _i(json['boostCount']),
      isFavorite: json['isFavorite'] == true,
      pinnedMessage: RoomPinnedMessage.fromJson(
        json['pinnedMessage'] is Map<String, dynamic>
            ? json['pinnedMessage']
            : {},
      ),
      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),
    );
  }

  RoomModel copyWith({
    String? roomId,
    String? name,
    String? description,
    String? creatorId,
    String? role,
    bool? hasPassword,
    bool? isLockedForNone,
    bool? voiceEnabled,
    int? maxUsers,
    int? activeCount,
    int? favoriteCount,
    int? boostScore,
    int? boostCount,
    bool? isFavorite,
    RoomPinnedMessage? pinnedMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoomModel(
      roomId: roomId ?? this.roomId,
      name: name ?? this.name,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      role: role ?? this.role,
      hasPassword: hasPassword ?? this.hasPassword,
      isLockedForNone: isLockedForNone ?? this.isLockedForNone,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      maxUsers: maxUsers ?? this.maxUsers,
      activeCount: activeCount ?? this.activeCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      boostScore: boostScore ?? this.boostScore,
      boostCount: boostCount ?? this.boostCount,
      isFavorite: isFavorite ?? this.isFavorite,
      pinnedMessage: pinnedMessage ?? this.pinnedMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RoomPinnedMessage {
  final String text;
  final String updatedBy;
  final DateTime? updatedAt;

  const RoomPinnedMessage({
    required this.text,
    required this.updatedBy,
    required this.updatedAt,
  });

  factory RoomPinnedMessage.fromJson(Map<String, dynamic> json) {
    return RoomPinnedMessage(
      text: _s(json['text']),
      updatedBy: _s(json['updatedBy']),
      updatedAt: _date(json['updatedAt']),
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

DateTime? _date(dynamic value) {
  if (value == null) return null;
return DateTime.tryParse((value ?? '').toString());
}