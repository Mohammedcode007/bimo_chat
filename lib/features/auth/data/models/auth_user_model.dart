class AuthUserModel {
  final String userId;
  final String username;
  final String photoUrl;
  final bool isManualOffline;
  final Map<String, dynamic> privacy;
  final Map<String, dynamic> features;

  AuthUserModel({
    required this.userId,
    required this.username,
    required this.photoUrl,
    required this.isManualOffline,
    required this.privacy,
    required this.features,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      userId: json['user_id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      photoUrl: json['photo_url']?.toString() ?? '',
      isManualOffline: json['is_manual_offline'] == true,
      privacy: Map<String, dynamic>.from(json['privacy'] ?? {}),
      features: Map<String, dynamic>.from(json['features'] ?? {}),
    );
  }
}
