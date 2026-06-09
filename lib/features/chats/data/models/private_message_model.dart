class PrivateMessageModel {
  final String messageId;
  final String? localMessageId;
  final String senderId;
  final String receiverId;
  final String body;
  final String messageType;
  final String status;
  final DateTime createdAt;

  PrivateMessageModel({
    required this.messageId,
    this.localMessageId,
    required this.senderId,
    required this.receiverId,
    required this.body,
    required this.messageType,
    required this.status,
    required this.createdAt,
  });

  factory PrivateMessageModel.fromJson(Map<String, dynamic> json) {
    return PrivateMessageModel(
      messageId: json['message_id']?.toString() ?? '',
      localMessageId: json['local_message_id']?.toString(),
      senderId: json['sender_id']?.toString() ?? '',
      receiverId: json['receiver_id']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      messageType: json['message_type']?.toString() ?? 'text',
      status:
          json['status']?.toString() ??
          json['delivery']?.toString() ??
          'received',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'local_message_id': localMessageId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'body': body,
      'message_type': messageType,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
