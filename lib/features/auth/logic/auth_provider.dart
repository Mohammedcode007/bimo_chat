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

          setUserFromServer(
            userMap,
            forceLoggedIn: true,
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
        تعديل بيانات البروفايل
        وتعديل صورة البروفايل / الغلاف
        لا يعملوا login جديد
      */
      if (handler == WsEvents.userProfileEvent ||
          handler == WsEvents.userProfileImageEvent) {
        if (type == 'success') {
          final userMap = data['user'] is Map<String, dynamic>
              ? Map<String, dynamic>.from(data['user'])
              : <String, dynamic>{};

          setUserFromServer(userMap);

          return;
        }

        state = state.copyWith(
          loading: false,
          error: data['reason']?.toString() ?? 'update_error',
        );

        return;
      }

      /*
        أحداث المتجر:
        شراء / تفعيل / إضافة نقاط
        الباك يرجع user جديد بعد العملية
      */
      if (handler == WsEvents.storeItemsEvent ||
          handler == WsEvents.storeBuyEvent ||
          handler == WsEvents.storeActivateEvent ||
          handler == WsEvents.storePointsEvent) {
        if (type == 'success') {
          if (data['user'] is Map<String, dynamic>) {
            final userMap = Map<String, dynamic>.from(data['user']);
            setUserFromServer(userMap);
          } else {
            state = state.copyWith(
              loading: false,
              error: null,
            );
          }

          return;
        }

        state = state.copyWith(
          loading: false,
          error: data['reason']?.toString() ?? 'store_error',
        );

        return;
      }

      /*
        حذف الحساب
      */
      if (handler == WsEvents.userDeleteAccountEvent) {
        if (type == 'success') {
          state = const AuthState();
          return;
        }

        state = state.copyWith(
          loading: false,
          error: data['reason']?.toString() ?? 'delete_account_error',
        );

        return;
      }

      /*
        Logout من السيرفر
      */
      if (handler == WsEvents.logoutEvent) {
        state = const AuthState();
        return;
      }

      /*
        Error عام
      */
      if (handler == WsEvents.errorEvent) {
        state = state.copyWith(
          loading: false,
          error: data['reason']?.toString() ?? 'server_error',
        );
      }
    });
  }

  void setUserFromServer(
    Map<String, dynamic> userMap, {
    bool forceLoggedIn = false,
  }) {
    final userId = userMap['userId']?.toString() ?? state.userId;
    final username = userMap['username']?.toString() ?? state.username;
    final photoUrl = userMap['photoUrl']?.toString() ?? state.photoUrl;

    state = state.copyWith(
      loading: false,
      loggedIn: forceLoggedIn ? true : state.loggedIn,
      userId: userId,
      username: username,
      photoUrl: photoUrl,
      user: userMap,
      error: null,
    );
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
      error: null,
    );

    ws.send({
      'handler': WsHandlers.usersProfileUpdate,
      'request_id': const Uuid().v4(),
      ...data,
    });
  }

  void updateProfileImage({
    required String imageType,
    required String base64,
  }) {
    state = state.copyWith(
      error: null,
    );

    ws.send({
      'handler': WsHandlers.usersProfileImageUpdate,
      'request_id': const Uuid().v4(),
      'image_type': imageType,
      'base64': base64,
    });
  }

  void deleteAccount() {
    state = state.copyWith(
      loading: true,
      error: null,
    );

    ws.send({
      'handler': WsHandlers.usersDeleteAccount,
      'request_id': const Uuid().v4(),
      'confirm': 'DELETE_MY_ACCOUNT',
    });
  }

  void logout() {
    ws.send({
      'handler': WsHandlers.authLogout,
      'request_id': const Uuid().v4(),
    });

    /*
      مهم:
      نمسح المستخدم محليًا فورًا حتى لو السيرفر لم يرجع logout_event
    */
    state = const AuthState();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}