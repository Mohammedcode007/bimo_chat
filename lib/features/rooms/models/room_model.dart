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
      roomId: _s(json['roomId'] ?? json['id']),
      name: _s(json['name']),
      description: _s(json['description']),
      creatorId: _s(json['creatorId'] ?? json['creator_id']),
      role: _s(json['role'], fallback: 'none'),

      hasPassword: _b(json['hasPassword'] ?? json['has_password']),
      isLockedForNone: _b(
        json['isLockedForNone'] ??
            json['is_locked_for_none'] ??
            json['membersOnly'] ??
            json['members_only'],
      ),
      voiceEnabled: _b(json['voiceEnabled'] ?? json['voice_enabled']),

      maxUsers: _i(json['maxUsers'] ?? json['max_users'], fallback: 50),
      activeCount: _i(
        json['activeCount'] ??
            json['active_count'] ??
            json['usersCount'] ??
            json['users_count'],
      ),
      favoriteCount: _i(json['favoriteCount'] ?? json['favorite_count']),

      boostScore: _i(json['boostScore'] ?? json['boost_score']),
      boostCount: _i(json['boostCount'] ?? json['boost_count']),

      isFavorite: _b(json['isFavorite'] ?? json['is_favorite']),

      pinnedMessage: RoomPinnedMessage.fromJson(
        json['pinnedMessage'] is Map<String, dynamic>
            ? json['pinnedMessage'] as Map<String, dynamic>
            : json['pinned_message'] is Map<String, dynamic>
            ? json['pinned_message'] as Map<String, dynamic>
            : {},
      ),

      createdAt: _date(json['createdAt'] ?? json['created_at']),
      updatedAt: _date(json['updatedAt'] ?? json['updated_at']),
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
      updatedBy: _s(json['updatedBy'] ?? json['updated_by']),
      updatedAt: _date(json['updatedAt'] ?? json['updated_at']),
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

  final text = (value ?? '').toString().trim();
  if (text.isEmpty) return fallback;

  return int.tryParse(text) ?? fallback;
}

bool _b(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value == 1;

  final text = (value ?? '').toString().trim().toLowerCase();

  if (text.isEmpty) return fallback;

  return text == 'true' ||
      text == '1' ||
      text == 'yes' ||
      text == 'y' ||
      text == 'on';
}

DateTime? _date(dynamic value) {
  if (value == null) return null;

  final text = value.toString().trim();
  if (text.isEmpty) return null;

  return DateTime.tryParse(text);
}
