import 'package:uuid/uuid.dart';

import '../../../core/constants/ws_handlers.dart';
import '../../../core/network/ws_client.dart';

class AuthRepository {
  final WsClient wsClient;

  AuthRepository(this.wsClient);

  void connect(String url) {
    wsClient.connect(url);
  }

  void login({required String username, required String password}) {
    wsClient.send({
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

  void logout() {
    wsClient.send({
      'handler': WsHandlers.authLogout,
      'request_id': const Uuid().v4(),
    });
  }
}
