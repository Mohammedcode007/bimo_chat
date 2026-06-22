import 'package:uuid/uuid.dart';

import '../../../../core/constants/ws_handlers.dart';
import '../../../../core/network/ws_client.dart';
import '../../../../core/network/ws_background_controller.dart';

class ChatsRepository {
  final WsClient wsClient;

  ChatsRepository(this.wsClient);

  String sendPrivateMessage({
    required String receiverId,
    required String body,
  }) {
    final localMessageId = const Uuid().v4();

    sendBackgroundWs({
      'handler': WsHandlers.chatsMessageSend,
      'request_id': const Uuid().v4(),
      'receiver_id': receiverId,
      'local_message_id': localMessageId,
      'body': body,
      'message_type': 'text',
    });

    return localMessageId;
  }

  void startTyping(String receiverId) {
    sendBackgroundWs({
      'handler': WsHandlers.chatsTypingStart,
      'receiver_id': receiverId,
    });
  }

  void stopTyping(String receiverId) {
    sendBackgroundWs({
      'handler': WsHandlers.chatsTypingStop,
      'receiver_id': receiverId,
    });
  }
}