import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class WsEventBus {
  WsEventBus._();

  static final WsEventBus instance = WsEventBus._();

  final StreamController<Map<String, dynamic>> _controller =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  StreamSubscription? _wsEventSub;
  StreamSubscription? _wsStatusSub;
  StreamSubscription? _wsInternetSub;

  bool _listening = false;

  void start() {
    /*
      flutter_background_service لا يعمل على Web.
      لذلك نمنع تشغيله على Chrome حتى لا يحدث crash.
    */
    if (kIsWeb) {
      print('[WS_EVENT_BUS] skipped on Web');
      return;
    }

    if (_listening) return;

    _listening = true;

    _wsEventSub = FlutterBackgroundService().on('ws_event').listen((event) {
      final data = event?['data'];

      if (data is Map) {
        final message = Map<String, dynamic>.from(data);

        print('[WS_EVENT_BUS_EVENT] $message');

        _safeAdd(message);
      }
    });

    _wsStatusSub = FlutterBackgroundService().on('ws_status').listen((event) {
      final data = event == null
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(event);

      print('[WS_EVENT_BUS_STATUS] $data');

      _safeAdd({
        'handler': 'ws.status',
        'type': 'status',
        ...data,
      });
    });

    _wsInternetSub =
        FlutterBackgroundService().on('ws_internet').listen((event) {
      final data = event == null
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(event);

      print('[WS_EVENT_BUS_INTERNET] $data');

      _safeAdd({
        'handler': 'ws.internet',
        'type': 'internet',
        ...data,
      });
    });
  }

  void _safeAdd(Map<String, dynamic> data) {
    if (_controller.isClosed) return;

    _controller.add(data);
  }

  Future<void> dispose() async {
    await _wsEventSub?.cancel();
    await _wsStatusSub?.cancel();
    await _wsInternetSub?.cancel();

    _wsEventSub = null;
    _wsStatusSub = null;
    _wsInternetSub = null;

    _listening = false;

    await _controller.close();
  }
}