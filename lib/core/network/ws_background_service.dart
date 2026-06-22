// import 'dart:async';
// import 'dart:convert';
// import 'dart:ui';

// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

// const String wsBackgroundChannelId = 'bimo_ws_background';
// const int wsBackgroundNotificationId = 9001;

// Future<void> initializeWsBackgroundService() async {
//   final service = FlutterBackgroundService();

//   const androidChannel = AndroidNotificationChannel(
//     wsBackgroundChannelId,
//     'Bimo Chat Connection',
//     description: 'Keeps chat connection active in background',
//     importance: Importance.low,
//   );

//   final notifications = FlutterLocalNotificationsPlugin();

//   await notifications
//       .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(androidChannel);

//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       onStart: onWsBackgroundStart,
//       autoStart: false,
//       isForegroundMode: true,
//       notificationChannelId: wsBackgroundChannelId,
//       initialNotificationTitle: 'Bimo Chat',
//       initialNotificationContent: 'Chat connection is running',
//       foregroundServiceNotificationId: wsBackgroundNotificationId,
//     ),
//     iosConfiguration: IosConfiguration(
//       autoStart: false,
//       onForeground: onWsBackgroundStart,
//       onBackground: onIosBackground,
//     ),
//   );
// }

// @pragma('vm:entry-point')
// Future<bool> onIosBackground(ServiceInstance service) async {
//   DartPluginRegistrant.ensureInitialized();
//   return true;
// }

// @pragma('vm:entry-point')
// void onWsBackgroundStart(ServiceInstance service) async {
//   DartPluginRegistrant.ensureInitialized();

//   WebSocketChannel? channel;
//   StreamSubscription? socketSub;
//   StreamSubscription<List<ConnectivityResult>>? connectivitySub;
//   Timer? pingTimer;
//   Timer? reconnectTimer;

//   String? wsUrl;

//   bool connected = false;
//   bool connecting = false;
//   bool manualStop = false;
//   bool hasInternet = true;

//   Future<void> clearSocket() async {
//     connected = false;
//     connecting = false;

//     pingTimer?.cancel();
//     pingTimer = null;

//     await socketSub?.cancel();
//     socketSub = null;

//     try {
//       await channel?.sink.close();
//     } catch (_) {}

//     channel = null;
//   }

//   late void Function() scheduleReconnect;
//   late Future<void> Function() openSocket;

//   void send(Map<String, dynamic> data) {
//     if (manualStop) return;

//     if (channel == null) {
//       connected = false;
//       scheduleReconnect();
//       return;
//     }

//     try {
//       channel!.sink.add(jsonEncode(data));
//     } catch (error) {
//       connected = false;
//       connecting = false;

//       service.invoke('ws_status', {
//         'connected': false,
//         'reason': error.toString(),
//       });

//       scheduleReconnect();
//     }
//   }

//   void startPing() {
//     pingTimer?.cancel();

//     pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
//       if (manualStop) return;
//       if (!hasInternet) return;

//       send({
//         'handler': 'ping',
//         'type': 'ping',
//         'time': DateTime.now().toIso8601String(),
//       });
//     });
//   }

//   openSocket = () async {
//     if (manualStop) return;
//     if (!hasInternet) return;
//     if (connected || connecting) return;

//     final url = wsUrl?.trim();

//     if (url == null || url.isEmpty) return;

//     connecting = true;

//     try {
//       await clearSocket();

//       channel = WebSocketChannel.connect(Uri.parse(url));

//       socketSub = channel!.stream.listen(
//         (event) {
//           connected = true;
//           connecting = false;

//           service.invoke('ws_status', {
//             'connected': true,
//             'reason': 'message_received',
//           });

//           try {
//             final decoded = jsonDecode(event.toString());

//             service.invoke('ws_event', {
//               'data': decoded,
//             });
//           } catch (_) {
//             service.invoke('ws_event', {
//               'data': {
//                 'handler': 'error_event',
//                 'type': 'error',
//                 'reason': 'invalid_server_message',
//               },
//             });
//           }
//         },
//         onError: (error) {
//           connected = false;
//           connecting = false;

//           service.invoke('ws_status', {
//             'connected': false,
//             'reason': error.toString(),
//           });

//           scheduleReconnect();
//         },
//         onDone: () {
//           connected = false;
//           connecting = false;

//           service.invoke('ws_status', {
//             'connected': false,
//             'reason': 'connection_closed',
//           });

//           scheduleReconnect();
//         },
//         cancelOnError: true,
//       );

//       connecting = false;

//       startPing();

//       service.invoke('ws_status', {
//         'connected': true,
//         'reason': 'connected',
//       });
//     } catch (error) {
//       connected = false;
//       connecting = false;

//       service.invoke('ws_status', {
//         'connected': false,
//         'reason': error.toString(),
//       });

//       scheduleReconnect();
//     }
//   };

//   scheduleReconnect = () {
//     if (manualStop) return;
//     if (!hasInternet) return;

//     reconnectTimer?.cancel();

//     reconnectTimer = Timer(const Duration(seconds: 2), () {
//       openSocket();
//     });
//   };

//   connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
//     hasInternet = results.any((result) {
//       return result == ConnectivityResult.wifi ||
//           result == ConnectivityResult.mobile ||
//           result == ConnectivityResult.ethernet ||
//           result == ConnectivityResult.vpn;
//     });

//     service.invoke('ws_internet', {
//       'hasInternet': hasInternet,
//     });

//     if (!hasInternet) {
//       connected = false;
//       connecting = false;

//       reconnectTimer?.cancel();
//       reconnectTimer = null;

//       return;
//     }

//     scheduleReconnect();
//   });

//   service.on('start_ws').listen((event) {
//     final url = event?['url']?.toString().trim();

//     if (url == null || url.isEmpty) {
//       service.invoke('ws_status', {
//         'connected': false,
//         'reason': 'missing_ws_url',
//       });
//       return;
//     }

//     wsUrl = url;
//     manualStop = false;

//     openSocket();
//   });

//   service.on('send_ws').listen((event) {
//     final data = event?['data'];

//     if (data is Map) {
//       send(Map<String, dynamic>.from(data));
//     }
//   });

//   service.on('stop_ws').listen((event) async {
//     manualStop = true;

//     reconnectTimer?.cancel();
//     reconnectTimer = null;

//     await clearSocket();

//     service.invoke('ws_status', {
//       'connected': false,
//       'reason': 'manual_stop_ws',
//     });
//   });

//   service.on('stop_service').listen((event) async {
//     manualStop = true;

//     reconnectTimer?.cancel();
//     reconnectTimer = null;

//     await connectivitySub?.cancel();
//     connectivitySub = null;

//     await clearSocket();

//     service.stopSelf();
//   });

//   if (service is AndroidServiceInstance) {
//     service.setAsForegroundService();

//     service.setForegroundNotificationInfo(
//       title: 'Bimo Chat',
//       content: 'Chat connection is running',
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String wsBackgroundChannelId = 'bimo_ws_background';
const int wsBackgroundNotificationId = 9001;

Future<void> initializeWsBackgroundService() async {
  final service = FlutterBackgroundService();

  const androidChannel = AndroidNotificationChannel(
    wsBackgroundChannelId,
    'Bimo Chat Connection',
    description: 'Keeps chat connection active in background',
    importance: Importance.low,
  );

  final notifications = FlutterLocalNotificationsPlugin();

  await notifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidChannel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onWsBackgroundStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: wsBackgroundChannelId,
      initialNotificationTitle: 'Bimo Chat',
      initialNotificationContent: 'Chat connection is running',
      foregroundServiceNotificationId: wsBackgroundNotificationId,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onWsBackgroundStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onWsBackgroundStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  WebSocketChannel? channel;

  StreamSubscription? socketSub;
  StreamSubscription<List<ConnectivityResult>>? connectivitySub;

  Timer? pingTimer;
  Timer? reconnectTimer;

  String? wsUrl;

  bool connected = false;
  bool connecting = false;
  bool manualStop = false;
  bool hasInternet = true;

  /*
    الرسائل التي تصل قبل اكتمال اتصال السوكيت.
  */
  final List<Map<String, dynamic>> pendingMessages = [];

  /*
    إبلاغ التطبيق بحالة الاتصال.
  */
  void emitStatus({
    required bool isConnected,
    required String reason,
  }) {
    service.invoke('ws_status', {
      'connected': isConnected,
      'connecting': connecting,
      'reason': reason,
    });
  }

  /*
    تنظيف السوكيت الحالي.
  */
  Future<void> clearSocket() async {
    connected = false;

    pingTimer?.cancel();
    pingTimer = null;

    await socketSub?.cancel();
    socketSub = null;

    try {
      await channel?.sink.close();
    } catch (error) {
      print('[BG_WS_CLOSE_ERROR] $error');
    }

    channel = null;
  }

  late void Function() scheduleReconnect;
  late Future<void> Function() openSocket;

  /*
    إرسال الرسائل الموجودة في الانتظار بعد الاتصال.
  */
  void flushPendingMessages() {
    if (!connected || channel == null) {
      return;
    }

    if (pendingMessages.isEmpty) {
      return;
    }

    print(
      '[BG_WS_FLUSH_PENDING] count=${pendingMessages.length}',
    );

    final messages = List<Map<String, dynamic>>.from(
      pendingMessages,
    );

    pendingMessages.clear();

    for (final message in messages) {
      try {
        final encoded = jsonEncode(message);

        channel!.sink.add(encoded);

        print('[BG_WS_PENDING_SENT] $encoded');
      } catch (error) {
        print('[BG_WS_PENDING_SEND_ERROR] $error');

        /*
          إعادة الرسالة إلى الانتظار إذا فشل إرسالها.
        */
        pendingMessages.insert(0, message);

        connected = false;
        connecting = false;

        emitStatus(
          isConnected: false,
          reason: error.toString(),
        );

        scheduleReconnect();
        break;
      }
    }
  }

  /*
    إرسال رسالة إلى السيرفر.
    إذا لم يكتمل الاتصال، يتم الاحتفاظ بها مؤقتًا.
  */
  void send(Map<String, dynamic> data) {
    if (manualStop) {
      print('[BG_WS_SEND_CANCELLED] manualStop=true');
      return;
    }

    if (!connected || channel == null) {
      print('[BG_WS_SEND_QUEUED] socket not connected => $data');

      pendingMessages.add(
        Map<String, dynamic>.from(data),
      );

      emitStatus(
        isConnected: false,
        reason: 'message_queued_socket_not_connected',
      );

      scheduleReconnect();
      return;
    }

    try {
      final encoded = jsonEncode(data);

      channel!.sink.add(encoded);

      print('[BG_WS_SENT] $encoded');
    } catch (error) {
      print('[BG_WS_SEND_ERROR] $error');

      connected = false;
      connecting = false;

      /*
        عدم فقد الرسالة عند حدوث خطأ أثناء الإرسال.
      */
      pendingMessages.add(
        Map<String, dynamic>.from(data),
      );

      emitStatus(
        isConnected: false,
        reason: error.toString(),
      );

      scheduleReconnect();
    }
  }

  /*
    تشغيل Ping للحفاظ على الاتصال.
  */
  void startPing() {
    pingTimer?.cancel();

    pingTimer = Timer.periodic(
      const Duration(seconds: 25),
      (_) {
        if (manualStop) return;
        if (!hasInternet) return;
        if (!connected || channel == null) return;

        send({
          'handler': 'ping',
          'type': 'ping',
          'time': DateTime.now().toIso8601String(),
        });
      },
    );
  }

  /*
    فتح اتصال WebSocket.
  */
  openSocket = () async {
    if (manualStop) {
      print('[BG_WS_CONNECT_CANCELLED] manualStop=true');
      return;
    }

    if (!hasInternet) {
      print('[BG_WS_CONNECT_CANCELLED] no internet');
      return;
    }

    if (connected || connecting) {
      print(
        '[BG_WS_CONNECT_SKIPPED] connected=$connected connecting=$connecting',
      );
      return;
    }

    final url = wsUrl?.trim();

    if (url == null || url.isEmpty) {
      print('[BG_WS_CONNECT_FAILED] missing ws url');

      emitStatus(
        isConnected: false,
        reason: 'missing_ws_url',
      );

      return;
    }

    connecting = true;

    emitStatus(
      isConnected: false,
      reason: 'connecting',
    );

    try {
      /*
        تنظيف الاتصال السابق قبل إنشاء اتصال جديد.
      */
      await clearSocket();

      connecting = true;

      print('[BG_WS_CONNECT_START] $url');

      final newChannel = WebSocketChannel.connect(
        Uri.parse(url),
      );

      channel = newChannel;

      /*
        انتظار اكتمال المصافحة مع السيرفر.
      */
      await newChannel.ready.timeout(
        const Duration(seconds: 15),
      );

      if (manualStop) {
        await newChannel.sink.close();
        channel = null;
        connecting = false;
        return;
      }

      connected = true;
      connecting = false;

      print('[BG_WS_CONNECTED] $url');

      emitStatus(
        isConnected: true,
        reason: 'connected',
      );

      /*
        يجب تركيب المستمع بعد نجاح الاتصال.
      */
      socketSub = newChannel.stream.listen(
        (event) {
          connected = true;
          connecting = false;

          print('[BG_WS_RECEIVED] $event');

          emitStatus(
            isConnected: true,
            reason: 'message_received',
          );

          try {
            final decoded = jsonDecode(event.toString());

            if (decoded is Map) {
              service.invoke('ws_event', {
                'data': Map<String, dynamic>.from(decoded),
              });
            } else {
              service.invoke('ws_event', {
                'data': {
                  'handler': 'error_event',
                  'type': 'error',
                  'reason': 'invalid_server_message_type',
                },
              });
            }
          } catch (error) {
            print('[BG_WS_DECODE_ERROR] $error');

            service.invoke('ws_event', {
              'data': {
                'handler': 'error_event',
                'type': 'error',
                'reason': 'invalid_server_message',
              },
            });
          }
        },
        onError: (error) {
          print('[BG_WS_ERROR] $error');

          connected = false;
          connecting = false;

          emitStatus(
            isConnected: false,
            reason: error.toString(),
          );

          scheduleReconnect();
        },
        onDone: () {
          print('[BG_WS_CLOSED]');

          connected = false;
          connecting = false;

          emitStatus(
            isConnected: false,
            reason: 'connection_closed',
          );

          scheduleReconnect();
        },
        cancelOnError: true,
      );

      startPing();

      /*
        إرسال طلب تسجيل الدخول أو الرسائل التي وصلت قبل الاتصال.
      */
      flushPendingMessages();
    } on TimeoutException {
      print('[BG_WS_CONNECT_TIMEOUT]');

      connected = false;
      connecting = false;

      await clearSocket();

      emitStatus(
        isConnected: false,
        reason: 'connection_timeout',
      );

      scheduleReconnect();
    } catch (error, stackTrace) {
      print('[BG_WS_CONNECT_ERROR] $error');
      print(stackTrace);

      connected = false;
      connecting = false;

      await clearSocket();

      emitStatus(
        isConnected: false,
        reason: error.toString(),
      );

      scheduleReconnect();
    }
  };

  /*
    إعادة الاتصال بعد ثانيتين.
  */
  scheduleReconnect = () {
    if (manualStop) return;
    if (!hasInternet) return;
    if (connected || connecting) return;

    reconnectTimer?.cancel();

    print('[BG_WS_RECONNECT_SCHEDULED]');

    reconnectTimer = Timer(
      const Duration(seconds: 2),
      () {
        openSocket();
      },
    );
  };

  /*
    مراقبة الإنترنت.
  */
  connectivitySub = Connectivity().onConnectivityChanged.listen(
    (results) {
      hasInternet = results.any((result) {
        return result == ConnectivityResult.wifi ||
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.ethernet ||
            result == ConnectivityResult.vpn;
      });

      print('[BG_WS_INTERNET] hasInternet=$hasInternet');

      service.invoke('ws_internet', {
        'hasInternet': hasInternet,
      });

      if (!hasInternet) {
        connected = false;
        connecting = false;

        reconnectTimer?.cancel();
        reconnectTimer = null;

        emitStatus(
          isConnected: false,
          reason: 'no_internet',
        );

        return;
      }

      scheduleReconnect();
    },
  );

  /*
    استقبال أمر تشغيل السوكيت من التطبيق.
  */
  service.on('start_ws').listen((event) {
    final url = event?['url']?.toString().trim();

    print('[BG_WS_START_COMMAND] url=$url');

    if (url == null || url.isEmpty) {
      emitStatus(
        isConnected: false,
        reason: 'missing_ws_url',
      );

      return;
    }

    wsUrl = url;
    manualStop = false;

    openSocket();
  });

  /*
    استقبال أمر إرسال رسالة من التطبيق.
  */
  service.on('send_ws').listen((event) {
    final data = event?['data'];

    print('[BG_WS_SEND_COMMAND] $data');

    if (data is Map) {
      send(
        Map<String, dynamic>.from(data),
      );
    }
  });

  /*
    إيقاف السوكيت فقط.
  */
  service.on('stop_ws').listen((event) async {
    print('[BG_WS_STOP_COMMAND]');

    manualStop = true;

    reconnectTimer?.cancel();
    reconnectTimer = null;

    pendingMessages.clear();

    await clearSocket();

    connecting = false;

    emitStatus(
      isConnected: false,
      reason: 'manual_stop_ws',
    );
  });

  /*
    إيقاف الخدمة بالكامل.
  */
  service.on('stop_service').listen((event) async {
    print('[BG_WS_STOP_SERVICE_COMMAND]');

    manualStop = true;

    reconnectTimer?.cancel();
    reconnectTimer = null;

    pendingMessages.clear();

    await connectivitySub?.cancel();
    connectivitySub = null;

    await clearSocket();

    connecting = false;

    service.stopSelf();
  });

  /*
    تشغيل Android Foreground Service.
  */
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();

    service.setForegroundNotificationInfo(
      title: 'Bimo Chat',
      content: 'Chat connection is running',
    );
  }

  print('[BG_WS_SERVICE_READY]');
}