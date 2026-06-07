class FriendModel {
  final String id;
  final String name;
  final String username;
  final String avatarUrl;
  final bool isOnline;
  final String status;

  const FriendModel({
    required this.id,
    required this.name,
    required this.username,
    this.avatarUrl = '',
    this.isOnline = false,
    this.status = '',
  });
}
