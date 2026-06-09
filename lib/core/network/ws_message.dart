class WsMessage {
  final String handler;
  final String type;
  final String? reason;
  final String? requestId;
  final Map<String, dynamic> raw;

  WsMessage({
    required this.handler,
    required this.type,
    this.reason,
    this.requestId,
    required this.raw,
  });

  factory WsMessage.fromJson(Map<String, dynamic> json) {
    return WsMessage(
      handler: json['handler']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      reason: json['reason']?.toString(),
      requestId: json['request_id']?.toString(),
      raw: json,
    );
  }

  bool get isSuccess => type == 'success';

  bool get isError => type == 'error';
}
