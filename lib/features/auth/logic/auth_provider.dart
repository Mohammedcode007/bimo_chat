// import 'dart:async';

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:uuid/uuid.dart';

// import '../../../core/constants/ws_events.dart';
// import '../../../core/constants/ws_handlers.dart';
// import '../../../core/network/ws_client.dart';
// import '../../../core/network/ws_provider.dart';
// import 'auth_state.dart';

// final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
//   final ws = ref.watch(wsClientProvider);
//   return AuthController(ws);
// });

// class AuthController extends StateNotifier<AuthState> {
//   final WsClient ws;

//   StreamSubscription? _sub;

//   AuthController(this.ws) : super(const AuthState()) {
//     _listen();
//   }

//   void _listen() {
//     _sub = ws.stream.listen((data) {
//       final handler = data['handler']?.toString();
//       final type = data['type']?.toString();

//       /*
//         Login / Register فقط هم من يجعلوا loggedIn = true
//       */
//       if (handler == WsEvents.loginEvent || handler == WsEvents.registerEvent) {
//         if (type == 'success') {
//           final userMap = data['user'] is Map<String, dynamic>
//               ? Map<String, dynamic>.from(data['user'])
//               : <String, dynamic>{};

//           setUserFromServer(
//             userMap,
//             forceLoggedIn: true,
//           );

//           return;
//         }

//         state = state.copyWith(
//           loading: false,
//           loggedIn: false,
//           error: data['reason']?.toString() ?? 'auth_error',
//         );

//         return;
//       }

//       /*
//         تعديل بيانات البروفايل
//         وتعديل صورة البروفايل / الغلاف
//         لا يعملوا login جديد
//       */
//       if (handler == WsEvents.userProfileEvent ||
//           handler == WsEvents.userProfileImageEvent) {
//         if (type == 'success') {
//           final userMap = data['user'] is Map<String, dynamic>
//               ? Map<String, dynamic>.from(data['user'])
//               : <String, dynamic>{};

//           setUserFromServer(userMap);

//           return;
//         }

//         state = state.copyWith(
//           loading: false,
//           error: data['reason']?.toString() ?? 'update_error',
//         );

//         return;
//       }

//       /*
//         أحداث المتجر:
//         شراء / تفعيل / إضافة نقاط
//         الباك يرجع user جديد بعد العملية
//       */
//       if (handler == WsEvents.storeItemsEvent ||
//           handler == WsEvents.storeBuyEvent ||
//           handler == WsEvents.storeActivateEvent ||
//           handler == WsEvents.storePointsEvent) {
//         if (type == 'success') {
//           if (data['user'] is Map<String, dynamic>) {
//             final userMap = Map<String, dynamic>.from(data['user']);
//             setUserFromServer(userMap);
//           } else {
//             state = state.copyWith(
//               loading: false,
//               error: null,
//             );
//           }

//           return;
//         }

//         state = state.copyWith(
//           loading: false,
//           error: data['reason']?.toString() ?? 'store_error',
//         );

//         return;
//       }

//       /*
//         حذف الحساب
//       */
//       if (handler == WsEvents.userDeleteAccountEvent) {
//         if (type == 'success') {
//           state = const AuthState();
//           return;
//         }

//         state = state.copyWith(
//           loading: false,
//           error: data['reason']?.toString() ?? 'delete_account_error',
//         );

//         return;
//       }

//       /*
//         Logout من السيرفر
//       */
//       if (handler == WsEvents.logoutEvent) {
//         state = const AuthState();
//         return;
//       }

//       /*
//         Error عام
//       */
//       if (handler == WsEvents.errorEvent) {
//         state = state.copyWith(
//           loading: false,
//           error: data['reason']?.toString() ?? 'server_error',
//         );
//       }
//     });
//   }

//   void setUserFromServer(
//     Map<String, dynamic> userMap, {
//     bool forceLoggedIn = false,
//   }) {
//     final userId = userMap['userId']?.toString() ?? state.userId;
//     final username = userMap['username']?.toString() ?? state.username;
//     final photoUrl = userMap['photoUrl']?.toString() ?? state.photoUrl;

//     state = state.copyWith(
//       loading: false,
//       loggedIn: forceLoggedIn ? true : state.loggedIn,
//       userId: userId,
//       username: username,
//       photoUrl: photoUrl,
//       user: userMap,
//       error: null,
//     );
//   }

//   void login({
//     required String username,
//     required String password,
//   }) {
//     state = state.copyWith(
//       loading: true,
//       error: null,
//     );

//     ws.send({
//       'handler': WsHandlers.authLogin,
//       'request_id': const Uuid().v4(),
//       'username': username.trim(),
//       'password': password.trim(),
//       'session': const Uuid().v4(),
//       'sdk': '25',
//       'ver': '1',
//       'id': const Uuid().v4(),
//     });
//   }

//   void register({
//     required String username,
//     required String password,
//   }) {
//     state = state.copyWith(
//       loading: true,
//       error: null,
//     );

//     ws.send({
//       'handler': WsHandlers.authRegister,
//       'request_id': const Uuid().v4(),
//       'username': username.trim(),
//       'password': password.trim(),
//       'session': const Uuid().v4(),
//       'sdk': '25',
//       'ver': '1',
//       'id': const Uuid().v4(),
//     });
//   }

//   void updateProfile(Map<String, dynamic> data) {
//     state = state.copyWith(
//       error: null,
//     );

//     ws.send({
//       'handler': WsHandlers.usersProfileUpdate,
//       'request_id': const Uuid().v4(),
//       ...data,
//     });
//   }

//   void updateProfileImage({
//     required String imageType,
//     required String base64,
//   }) {
//     state = state.copyWith(
//       error: null,
//     );

//     ws.send({
//       'handler': WsHandlers.usersProfileImageUpdate,
//       'request_id': const Uuid().v4(),
//       'image_type': imageType,
//       'base64': base64,
//     });
//   }

//   void deleteAccount() {
//     state = state.copyWith(
//       loading: true,
//       error: null,
//     );

//     ws.send({
//       'handler': WsHandlers.usersDeleteAccount,
//       'request_id': const Uuid().v4(),
//       'confirm': 'DELETE_MY_ACCOUNT',
//     });
//   }

//   void logout() {
//     ws.send({
//       'handler': WsHandlers.authLogout,
//       'request_id': const Uuid().v4(),
//     });

//     /*
//       مهم:
//       نمسح المستخدم محليًا فورًا حتى لو السيرفر لم يرجع logout_event
//     */
//     state = const AuthState();
//   }

//   @override
//   void dispose() {
//     _sub?.cancel();
//     super.dispose();
//   }
// }
import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/ws_events.dart';
import '../../../core/constants/ws_handlers.dart';
import '../../../core/network/ws_background_controller.dart';
import '../../../core/network/ws_event_bus.dart';
import 'auth_state.dart';

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController();
});

class AuthController extends StateNotifier<AuthState> {
  StreamSubscription<Map<String, dynamic>>? _sub;

  static const String _authSessionKey = 'auth_session_user';
  static const String _authLoggedInKey = 'auth_session_logged_in';
  static const String _authTokenKey = 'auth_session_token';
  static const String _authExpiresAtKey = 'auth_session_expires_at';

  bool _resumeInProgress = false;

  AuthController()
      : super(
          const AuthState(
            initialized: false,
            loading: true,
            loggedIn: false,
          ),
        ) {
    _listen();
    unawaited(_restoreSession());
  }

  /*
    استعادة بيانات المستخدم والـ token المحفوظين.

    لا نجعل loggedIn = true مباشرة.
    نرسل auth.resume أولًا، وننتظر نجاح السيرفر.
  */
  Future<void> _restoreSession() async {
    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔐 START RESTORE AUTH SESSION');

      final prefs = await SharedPreferences.getInstance();

      final isLoggedIn =
          prefs.getBool(_authLoggedInKey) ?? false;

      final savedUser =
          prefs.getString(_authSessionKey);

      final savedToken =
          prefs.getString(_authTokenKey);

      final savedExpiresAt =
          prefs.getString(_authExpiresAtKey);

      print('saved isLoggedIn: $isLoggedIn');
      print('has saved user: ${savedUser != null}');
      print('has saved token: ${savedToken != null}');
      print('saved expiresAt: $savedExpiresAt');

      if (!isLoggedIn ||
          savedUser == null ||
          savedUser.trim().isEmpty ||
          savedToken == null ||
          savedToken.trim().isEmpty) {
        print('⚠️ NO COMPLETE SAVED AUTH SESSION');

        await _clearSavedSession();

        state = const AuthState(
          initialized: true,
          loading: false,
          loggedIn: false,
        );

        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return;
      }

      /*
        التحقق من انتهاء مدة الجلسة محليًا.
      */
      if (savedExpiresAt != null &&
          savedExpiresAt.trim().isNotEmpty) {
        final expiresAt =
            DateTime.tryParse(savedExpiresAt);

        if (expiresAt != null &&
            DateTime.now().toUtc().isAfter(
                  expiresAt.toUtc(),
                )) {
          print('❌ SAVED SESSION EXPIRED');

          await _clearSavedSession();

          state = const AuthState(
            initialized: true,
            loading: false,
            loggedIn: false,
          );

          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          return;
        }
      }

      final decoded = jsonDecode(savedUser);

      if (decoded is! Map) {
        print('❌ SAVED USER IS NOT MAP');

        await _clearSavedSession();

        state = const AuthState(
          initialized: true,
          loading: false,
          loggedIn: false,
        );

        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return;
      }

      final userMap = decoded.map<String, dynamic>(
        (key, value) => MapEntry(
          key.toString(),
          value,
        ),
      );

      final userId =
          userMap['userId']?.toString();

      final username =
          userMap['username']?.toString();

      final photoUrl =
          userMap['photoUrl']?.toString();

      print('restored userId: $userId');
      print('restored username: $username');
      print('restored photoUrl: $photoUrl');

      if ((userId == null ||
              userId.trim().isEmpty) &&
          (username == null ||
              username.trim().isEmpty)) {
        print(
          '❌ SAVED USER HAS NO USER ID OR USERNAME',
        );

        await _clearSavedSession();

        state = const AuthState(
          initialized: true,
          loading: false,
          loggedIn: false,
        );

        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return;
      }

      /*
        نحتفظ ببيانات المستخدم أثناء انتظار auth.resume،
        لكن loggedIn يظل false حتى يوافق السيرفر.
      */
      state = AuthState(
        initialized: false,
        loading: true,
        loggedIn: false,
        userId: userId,
        username: username,
        photoUrl: photoUrl,
        user: userMap,
        error: null,
      );

      _resumeInProgress = true;

      final resumeRequest = <String, dynamic>{
        'handler': 'auth.resume',
        'request_id': const Uuid().v4(),
        'token': savedToken,
        'session': const Uuid().v4(),
        'sdk': '25',
        'ver': '1',
        'id': const Uuid().v4(),
      };

      print('📤 SENDING AUTH RESUME');
      print('handler: ${resumeRequest['handler']}');
      print(
        'token exists: ${savedToken.isNotEmpty}',
      );
      print(
        'request_id: ${resumeRequest['request_id']}',
      );
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      sendBackgroundWs(resumeRequest);
    } catch (error, stackTrace) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ RESTORE AUTH SESSION ERROR');
      print('error: $error');
      print('stackTrace: $stackTrace');

      _resumeInProgress = false;

      await _clearSavedSession();

      state = const AuthState(
        initialized: true,
        loading: false,
        loggedIn: false,
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
  }

  /*
    حفظ بيانات المستخدم مع token.

    إذا token غير مرسل، نحافظ على الـtoken القديم.
    هذا مهم عند تعديل البروفايل أو المتجر.
  */
  Future<void> _saveSession(
    Map<String, dynamic> userMap, {
    String? token,
    String? sessionExpiresAt,
  }) async {
    try {
      final safeUserMap =
          Map<String, dynamic>.from(userMap);

      safeUserMap.remove('password');
      safeUserMap.remove('passwordHash');
      safeUserMap.remove('password_hash');

      final prefs =
          await SharedPreferences.getInstance();

      final finalToken =
          token?.trim().isNotEmpty == true
              ? token!.trim()
              : prefs.getString(_authTokenKey);

      final finalExpiresAt =
          sessionExpiresAt?.trim().isNotEmpty == true
              ? sessionExpiresAt!.trim()
              : prefs.getString(_authExpiresAtKey);

      if (finalToken == null ||
          finalToken.trim().isEmpty) {
        print(
          '❌ CANNOT SAVE SESSION WITHOUT TOKEN',
        );

        return;
      }

      await prefs.setBool(
        _authLoggedInKey,
        true,
      );

      await prefs.setString(
        _authSessionKey,
        jsonEncode(safeUserMap),
      );

      await prefs.setString(
        _authTokenKey,
        finalToken,
      );

      if (finalExpiresAt != null &&
          finalExpiresAt.trim().isNotEmpty) {
        await prefs.setString(
          _authExpiresAtKey,
          finalExpiresAt,
        );
      } else {
        await prefs.remove(
          _authExpiresAtKey,
        );
      }

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('✅ AUTH SESSION SAVED');
      print(
        'saved userId: ${safeUserMap['userId']}',
      );
      print(
        'saved username: ${safeUserMap['username']}',
      );
      print(
        'saved token exists: ${finalToken.isNotEmpty}',
      );
      print(
        'saved expiresAt: $finalExpiresAt',
      );
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    } catch (error, stackTrace) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ SAVE AUTH SESSION ERROR');
      print('error: $error');
      print('stackTrace: $stackTrace');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
  }

  /*
    مسح المستخدم والـtoken بالكامل.
  */
  Future<void> _clearSavedSession() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      await prefs.remove(_authSessionKey);
      await prefs.remove(_authLoggedInKey);
      await prefs.remove(_authTokenKey);
      await prefs.remove(_authExpiresAtKey);

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🗑️ AUTH SESSION CLEARED');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    } catch (error, stackTrace) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ CLEAR AUTH SESSION ERROR');
      print('error: $error');
      print('stackTrace: $stackTrace');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
  }

  void _listen() {
    _sub?.cancel();

    print('🎧 AUTH LISTENER ATTACHED');

    _sub = WsEventBus.instance.stream.listen(
      (data) {
        final handler =
            data['handler']?.toString();

        final type =
            data['type']?.toString();

        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('📥 AUTH WS EVENT');
        print('handler: $handler');
        print('type: $type');
        print('reason: ${data['reason']}');
        print('message: ${data['message']}');
        print('keys: ${data.keys.toList()}');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        /*
          Login / Register / Resume.

          auth.resume من الباك يرجع login_event.
        */
        if (handler == WsEvents.loginEvent ||
            handler == WsEvents.registerEvent) {
          if (type == 'success') {
            final userMap =
                data['user'] is Map
                    ? Map<String, dynamic>.from(
                        data['user'],
                      )
                    : <String, dynamic>{};

            final token =
                data['token']?.toString();

            final sessionExpiresAt =
                data['session_expires_at']
                    ?.toString();

            print('✅ AUTH SUCCESS');
            print(
              'resume in progress: $_resumeInProgress',
            );
            print(
              'token exists: ${token != null && token.isNotEmpty}',
            );
            print(
              'session expires at: $sessionExpiresAt',
            );
            print(
              'userId: ${userMap['userId']}',
            );
            print(
              'username: ${userMap['username']}',
            );

            if (token == null ||
                token.trim().isEmpty) {
              print(
                '❌ AUTH SUCCESS WITHOUT TOKEN',
              );

              _resumeInProgress = false;

              unawaited(
                _clearSavedSession(),
              );

              state = const AuthState(
                initialized: true,
                loading: false,
                loggedIn: false,
                error: 'missing_session_token',
              );

              return;
            }

            _resumeInProgress = false;

            setUserFromServer(
              userMap,
              forceLoggedIn: true,
              token: token,
              sessionExpiresAt:
                  sessionExpiresAt,
            );

            return;
          }

          final reason =
              data['reason']?.toString() ??
                  data['message']?.toString() ??
                  'auth_error';

          print('❌ AUTH FAILED');
          print(
            'resume in progress: $_resumeInProgress',
          );
          print('reason: $reason');

          final wasResume =
              _resumeInProgress;

          _resumeInProgress = false;

          if (wasResume) {
            /*
              إذا فشلت استعادة الجلسة،
              نمسح البيانات القديمة ونعود لتسجيل الدخول.
            */
            unawaited(
              _clearSavedSession(),
            );
          }

          state = AuthState(
            initialized: true,
            loading: false,
            loggedIn: false,
            error: reason,
          );

          return;
        }

        /*
          تعديل بيانات البروفايل.
        */
        if (handler ==
                WsEvents.userProfileEvent ||
            handler ==
                WsEvents.userProfileImageEvent) {
          if (type == 'success') {
            final userMap =
                data['user'] is Map
                    ? Map<String, dynamic>.from(
                        data['user'],
                      )
                    : <String, dynamic>{};

            setUserFromServer(userMap);

            return;
          }

          state = state.copyWith(
            initialized: true,
            loading: false,
            error:
                data['reason']?.toString() ??
                    data['message']
                        ?.toString() ??
                    'update_error',
          );

          return;
        }

        /*
          أحداث المتجر.
        */
        if (handler ==
                WsEvents.storeItemsEvent ||
            handler ==
                WsEvents.storeBuyEvent ||
            handler ==
                WsEvents.storeActivateEvent ||
            handler ==
                WsEvents.storePointsEvent) {
          if (type == 'success') {
            if (data['user'] is Map) {
              final userMap =
                  Map<String, dynamic>.from(
                    data['user'],
                  );

              setUserFromServer(userMap);
            } else {
              state = state.copyWith(
                initialized: true,
                loading: false,
                error: null,
              );
            }

            return;
          }

          state = state.copyWith(
            initialized: true,
            loading: false,
            error:
                data['reason']?.toString() ??
                    data['message']
                        ?.toString() ??
                    'store_error',
          );

          return;
        }

        /*
          حذف الحساب.
        */
        if (handler ==
            WsEvents.userDeleteAccountEvent) {
          if (type == 'success') {
            _resumeInProgress = false;

            unawaited(
              _clearSavedSession(),
            );

            state = const AuthState(
              initialized: true,
              loading: false,
              loggedIn: false,
            );

            return;
          }

          state = state.copyWith(
            initialized: true,
            loading: false,
            error:
                data['reason']?.toString() ??
                    data['message']
                        ?.toString() ??
                    'delete_account_error',
          );

          return;
        }

        /*
          Logout.
        */
        if (handler ==
            WsEvents.logoutEvent) {
          _resumeInProgress = false;

          unawaited(
            _clearSavedSession(),
          );

          state = const AuthState(
            initialized: true,
            loading: false,
            loggedIn: false,
          );

          return;
        }

        /*
          حالة WebSocket.
        */
        if (handler == 'ws.status') {
          final connected =
              data['connected'] == true;

          final connecting =
              data['connecting'] == true;

          final reason =
              data['reason']?.toString() ??
                  '';

          print('🔌 WS STATUS');
          print('connected: $connected');
          print('connecting: $connecting');
          print('reason: $reason');

          /*
            لا نفشل auth.resume عند:
            - connecting
            - الرسالة في قائمة الانتظار
          */
          if (!connected &&
              state.loading &&
              !_resumeInProgress &&
              reason !=
                  'message_queued_socket_not_connected' &&
              reason != 'connecting') {
            state = state.copyWith(
              loading: false,
              error: reason.isNotEmpty
                  ? reason
                  : 'socket_not_connected',
            );
          }

          return;
        }

        /*
          حالة الإنترنت.
          لا نمسح الجلسة عند انقطاع الإنترنت.
        */
        if (handler == 'ws.internet') {
          final hasInternet =
              data['hasInternet'] == true;

          print(
            '🌐 INTERNET STATUS: $hasInternet',
          );

          if (!hasInternet &&
              !_resumeInProgress) {
            state = state.copyWith(
              loading: false,
              error: 'no_internet',
            );
          }

          return;
        }

        /*
          خطأ عام.
        */
        if (handler ==
            WsEvents.errorEvent) {
          final reason =
              data['reason']?.toString() ??
                  data['message']?.toString() ??
                  'server_error';

          print('❌ GENERAL AUTH ERROR');
          print('reason: $reason');

          state = state.copyWith(
            initialized: true,
            loading: false,
            error: reason,
          );
        }
      },
      onError: (error, stackTrace) {
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('❌ AUTH EVENT BUS ERROR');
        print('error: $error');
        print('stackTrace: $stackTrace');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        state = state.copyWith(
          initialized: true,
          loading: false,
          error: error.toString(),
        );
      },
      onDone: () {
        print('⚠️ AUTH EVENT BUS CLOSED');
      },
    );
  }

  /*
    تحديث بيانات المستخدم القادمة من السيرفر.

    token يتم تمريره بعد login/register/resume.
    وعند تحديث البروفايل يتم الحفاظ على token القديم.
  */
  void setUserFromServer(
    Map<String, dynamic> userMap, {
    bool forceLoggedIn = false,
    String? token,
    String? sessionExpiresAt,
  }) {
    final mergedUser =
        <String, dynamic>{
      if (state.user != null)
        ...state.user!,
      ...userMap,
    };

    mergedUser.remove('password');
    mergedUser.remove('passwordHash');
    mergedUser.remove('password_hash');

    final userId =
        mergedUser['userId']?.toString() ??
            mergedUser['id']?.toString() ??
            state.userId;

    final username =
        mergedUser['username']?.toString() ??
            mergedUser['name']?.toString() ??
            state.username;

    final photoUrl =
        mergedUser['photoUrl']?.toString() ??
            mergedUser['avatarUrl']
                ?.toString() ??
            mergedUser['avatar']?.toString() ??
            state.photoUrl;

    final loggedIn =
        forceLoggedIn || state.loggedIn;

    state = state.copyWith(
      initialized: true,
      loading: false,
      loggedIn: loggedIn,
      userId: userId,
      username: username,
      photoUrl: photoUrl,
      user: mergedUser,
      error: null,
    );

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ AUTH STATE UPDATED');
    print('loggedIn: ${state.loggedIn}');
    print('userId: ${state.userId}');
    print('username: ${state.username}');
    print('photoUrl: ${state.photoUrl}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (loggedIn) {
      unawaited(
        _saveSession(
          mergedUser,
          token: token,
          sessionExpiresAt:
              sessionExpiresAt,
        ),
      );
    }
  }

  void login({
    required String username,
    required String password,
  }) {
    final cleanUsername =
        username.trim();

    final cleanPassword =
        password.trim();

    if (cleanUsername.isEmpty ||
        cleanPassword.isEmpty) {
      state = state.copyWith(
        initialized: true,
        loading: false,
        error:
            'username_and_password_required',
      );

      return;
    }

    _resumeInProgress = false;

    final request =
        <String, dynamic>{
      'handler': WsHandlers.authLogin,
      'request_id': const Uuid().v4(),
      'username': cleanUsername,
      'password': cleanPassword,
      'session': const Uuid().v4(),
      'sdk': '25',
      'ver': '1',
      'id': const Uuid().v4(),
    };

    state = state.copyWith(
      initialized: true,
      loading: true,
      error: null,
    );

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔐 LOGIN REQUEST');
    print('username: $cleanUsername');
    print(
      'request_id: ${request['request_id']}',
    );
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    sendBackgroundWs(request);
  }

  void register({
    required String username,
    required String password,
  }) {
    final cleanUsername =
        username.trim();

    final cleanPassword =
        password.trim();

    if (cleanUsername.isEmpty ||
        cleanPassword.isEmpty) {
      state = state.copyWith(
        initialized: true,
        loading: false,
        error:
            'username_and_password_required',
      );

      return;
    }

    _resumeInProgress = false;

    final request =
        <String, dynamic>{
      'handler':
          WsHandlers.authRegister,
      'request_id': const Uuid().v4(),
      'username': cleanUsername,
      'password': cleanPassword,
      'session': const Uuid().v4(),
      'sdk': '25',
      'ver': '1',
      'id': const Uuid().v4(),
    };

    state = state.copyWith(
      initialized: true,
      loading: true,
      error: null,
    );

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📝 REGISTER REQUEST');
    print('username: $cleanUsername');
    print(
      'request_id: ${request['request_id']}',
    );
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    sendBackgroundWs(request);
  }

  void updateProfile(
    Map<String, dynamic> data,
  ) {
    state = state.copyWith(
      error: null,
    );

    sendBackgroundWs({
      'handler':
          WsHandlers.usersProfileUpdate,
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

    sendBackgroundWs({
      'handler':
          WsHandlers.usersProfileImageUpdate,
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

    sendBackgroundWs({
      'handler':
          WsHandlers.usersDeleteAccount,
      'request_id': const Uuid().v4(),
      'confirm': 'DELETE_MY_ACCOUNT',
    });
  }

  Future<void> logout() async {
    _resumeInProgress = false;

    sendBackgroundWs({
      'handler': WsHandlers.authLogout,
      'request_id': const Uuid().v4(),
    });

    await _clearSavedSession();

    state = const AuthState(
      initialized: true,
      loading: false,
      loggedIn: false,
    );

    print('✅ LOCAL LOGOUT COMPLETED');
  }

  @override
  void dispose() {
    _sub?.cancel();
    _sub = null;

    super.dispose();
  }
}