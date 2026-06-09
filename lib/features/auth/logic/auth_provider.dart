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

  void _listen() {
    _sub = ws.stream.listen((data) {
      final handler = data['handler']?.toString();
      final type = data['type']?.toString();

      /*
        Login / Register فقط هم من يجعلوا loggedIn = true
      */
      if (handler == WsEvents.loginEvent || handler == WsEvents.registerEvent) {
        if (type == 'success') {
          final userMap = data['user'] is Map<String, dynamic>
              ? Map<String, dynamic>.from(data['user'])
              : <String, dynamic>{};

          final userId =
              userMap['userId']?.toString() ?? data['user_id']?.toString();

          final username =
              userMap['username']?.toString() ?? data['username']?.toString();

          final photoUrl =
              userMap['photoUrl']?.toString() ??
              data['photo_url']?.toString() ??
              '';

          state = state.copyWith(
            loading: false,
            loggedIn: true,
            userId: userId,
            username: username,
            photoUrl: photoUrl,
            user: userMap,
            error: null,
          );

          return;
        }

        state = state.copyWith(
          loading: false,
          loggedIn: false,
          error: data['reason']?.toString() ?? 'auth_error',
        );

        return;
      }

      /*
        تعديل البروفايل فقط يحدث user
        لا يعمل loggedIn: true من جديد
      */
      if (handler == WsEvents.userProfileEvent) {
        if (type == 'success') {
          final userMap = data['user'] is Map<String, dynamic>
              ? Map<String, dynamic>.from(data['user'])
              : <String, dynamic>{};

          final userId =
              userMap['userId']?.toString() ??
              data['user_id']?.toString() ??
              state.userId;

          final username =
              userMap['username']?.toString() ??
              data['username']?.toString() ??
              state.username;

          final photoUrl =
              userMap['photoUrl']?.toString() ??
              data['photo_url']?.toString() ??
              state.photoUrl;

          state = state.copyWith(
            loading: false,

            // مهم جدًا: لا تغير حالة الدخول بعد تعديل البيانات
            loggedIn: state.loggedIn,

            userId: userId,
            username: username,
            photoUrl: photoUrl,
            user: userMap,
            error: null,
          );

          return;
        }

        state = state.copyWith(
          loading: false,
          error: data['reason']?.toString() ?? 'update_error',
        );

        return;
      }

      if (handler == WsEvents.logoutEvent) {
        state = const AuthState();
        return;
      }

      if (handler == WsEvents.errorEvent) {
        state = state.copyWith(
          loading: false,
          error: data['reason']?.toString() ?? 'server_error',
        );
      }
    });
  }

  void login({
    required String username,
    required String password,
  }) {
    state = state.copyWith(
      loading: true,
      error: null,
    );

    ws.send({
      'handler': WsHandlers.authLogin,
      'request_id': const Uuid().v4(),
      'username': username.trim(),
      'password': password.trim(),
      'session': const Uuid().v4(),
      'sdk': '25',
      'ver': '1',
      'id': const Uuid().v4(),
    });
  }

  void register({
    required String username,
    required String password,
  }) {
    state = state.copyWith(
      loading: true,
      error: null,
    );

    ws.send({
      'handler': WsHandlers.authRegister,
      'request_id': const Uuid().v4(),
      'username': username.trim(),
      'password': password.trim(),
      'session': const Uuid().v4(),
      'sdk': '25',
      'ver': '1',
      'id': const Uuid().v4(),
    });
  }

  void updateProfile(Map<String, dynamic> data) {
    state = state.copyWith(
      loading: true,
      error: null,
    );

    ws.send({
      'handler': WsHandlers.usersProfileUpdate,
      'request_id': const Uuid().v4(),
      ...data,
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