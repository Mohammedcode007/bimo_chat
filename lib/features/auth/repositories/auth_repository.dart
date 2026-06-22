import 'package:uuid/uuid.dart';

import '../../../core/constants/ws_handlers.dart';
import '../../../core/network/ws_client.dart';
import '../../../core/network/ws_background_controller.dart';

class AuthRepository {
  final WsClient wsClient;

  AuthRepository(this.wsClient);

  Future<void> connect(String url) async {
    /*
      نستخدم خدمة الخلفية كمصدر WebSocket الوحيد.
      لا نشغل wsClient.connect هنا حتى لا يصبح عندنا اتصالان.
    */
    await startBackgroundWs(url);
  }

  void login({required String username, required String password}) {
    sendBackgroundWs({
      'handler': WsHandlers.authLogin,
      'request_id': const Uuid().v4(),
      'username': username,
      'password': password,
      'session': const Uuid().v4(),
      'sdk': '25',
      'ver': '1',
      'id': const Uuid().v4(),
    });
  }

  Future<void> logout() async {
    sendBackgroundWs({
      'handler': WsHandlers.authLogout,
      'request_id': const Uuid().v4(),
    });

    await stopBackgroundWs();
  }
}