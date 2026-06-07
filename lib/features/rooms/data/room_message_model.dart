class RoomMessageModel {
  final String id;
  final String senderName;
  final String text;
  final String time;
  final bool isMe;
  final bool isOnline;

  const RoomMessageModel({
    required this.id,
    required this.senderName,
    required this.text,
    required this.time,
    this.isMe = false,
    this.isOnline = false,
  });
}
