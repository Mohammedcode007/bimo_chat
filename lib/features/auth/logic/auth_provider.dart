import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/ws_events.dart';
import '../../../core/constants/ws_handlers.dart';
import '../../../core/network/ws_client.dart';
import '../../../core/network/ws_provider.dart';
import 'auth_state.dart';

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final ws = ref.watch(wsClientProvider);
  return AuthController(ws);
});

class AuthController extends StateNotifier<AuthState> {
  final WsClient ws;

  StreamSubscription? _sub;

  AuthController(this.ws) : super(const AuthState()) {
    _listen();
  }

  void connect(String url) {
    ws.connect(url);
  }

  void _listen() {
    _sub = ws.stream.listen((data) {
      final handler = data['handler']?.toString();
      final type = data['type']?.toString();

      if (handler == WsEvents.loginEvent || handler == WsEvents.registerEvent) {
        if (type == 'success') {
          state = state.copyWith(
            loading: false,
            loggedIn: true,
            userId: data['user_id']?.toString(),
            username: data['username']?.toString(),
            photoUrl: data['photo_url']?.toString(),
            error: null,
          );
        } else {
          state = state.copyWith(
            loading: false,
            loggedIn: false,
            error: data['reason']?.toString() ?? 'auth_error',
          );
        }
      }

      if (handler == WsEvents.logoutEvent) {
        state = const AuthState();
      }
    });
  }

  void login({required String username, required String password}) {
    state = state.copyWith(loading: true, error: null);

    ws.send({
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

  void register({required String username, required String password}) {
    state = state.copyWith(loading: true, error: null);

    ws.send({
      'handler': WsHandlers.authRegister,
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
    ws.send({
      'handler': WsHandlers.authLogout,
      'request_id': const Uuid().v4(),
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
