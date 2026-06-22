

import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsClient {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  final StreamController<Map<String, dynamic>> _controller =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  bool _connected = false;
  bool _connecting = false;
  bool _manualDisconnect = false;
  bool _disposed = false;

  String? _url;
  Timer? _reconnectTimer;
  Timer? _pingTimer;

  bool get isConnected => _connected;

  void connect(String url) {
    _url = url;
    _manualDisconnect = false;
    _disposed = false;

    if (_connected || _connecting) return;

    _listenInternetChanges();
    _openSocket();
  }

  void _openSocket() {
    final url = _url;

    if (url == null || url.trim().isEmpty) return;
    if (_disposed) return;
    if (_connected || _connecting) return;

    _connecting = true;

    try {
      print('[WS_CONNECT_START] $url');

      _channel = WebSocketChannel.connect(Uri.parse(url));

      _subscription = _channel!.stream.listen(
        (event) {
          _connected = true;
          _connecting = false;

          try {
            final decoded = jsonDecode(event.toString());

            if (decoded is Map<String, dynamic>) {
              _safeAdd(decoded);
            }
          } catch (_) {
            _safeAdd({
              'handler': 'error_event',
              'type': 'error',
              'reason': 'invalid_server_message',
            });
          }
        },
        onError: (error) {
          print('[WS_ERROR] $error');

          _connected = false;
          _connecting = false;

          _safeAdd({
            'handler': 'socket_error',
            'type': 'error',
            'reason': error.toString(),
          });

          _scheduleReconnect();
        },
        onDone: () {
          print('[WS_CLOSED]');

          _connected = false;
          _connecting = false;

          _safeAdd({
            'handler': 'socket_closed',
            'type': 'error',
            'reason': 'connection_closed',
          });

          _scheduleReconnect();
        },
        cancelOnError: true,
      );

      _connected = true;
      _connecting = false;

      _startPing();

      print('[WS_CONNECTED]');
    } catch (error) {
      print('[WS_CONNECT_FAILED] $error');

      _connected = false;
      _connecting = false;

      _safeAdd({
        'handler': 'socket_error',
        'type': 'error',
        'reason': error.toString(),
      });

      _scheduleReconnect();
    }
  }

  void _listenInternetChanges() {
    _connectivitySubscription ??=
        Connectivity().onConnectivityChanged.listen((results) {
      final hasInternet = results.any((result) {
        return result == ConnectivityResult.wifi ||
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.ethernet ||
            result == ConnectivityResult.vpn;
      });

      print('[WS_INTERNET_CHANGED] hasInternet=$hasInternet');

      if (hasInternet) {
        reconnect();
      }
    });
  }

  void reconnect() {
    if (_disposed) return;
    if (_manualDisconnect) return;
    if (_connected || _connecting) return;

    print('[WS_RECONNECT_NOW]');

    _clearSocketOnly();
    _openSocket();
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    if (_manualDisconnect) return;

    _reconnectTimer?.cancel();

    _reconnectTimer = Timer(const Duration(seconds: 2), () {
      reconnect();
    });
  }

  void _startPing() {
    _pingTimer?.cancel();

    _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (!_connected || _channel == null) return;

      send({
        'handler': 'ping',
        'type': 'ping',
        'time': DateTime.now().toIso8601String(),
      });
    });
  }

  void send(Map<String, dynamic> data) {
    if (!_connected || _channel == null) {
      _safeAdd({
        'handler': 'error_event',
        'type': 'error',
        'reason': 'socket_not_connected',
      });

      _scheduleReconnect();
      return;
    }

    try {
      _channel!.sink.add(jsonEncode(data));
    } catch (error) {
      print('[WS_SEND_FAILED] $error');

      _connected = false;

      _safeAdd({
        'handler': 'socket_error',
        'type': 'error',
        'reason': error.toString(),
      });

      _scheduleReconnect();
    }
  }

  Future<void> disconnect() async {
    _manualDisconnect = true;
    _connected = false;
    _connecting = false;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _pingTimer?.cancel();
    _pingTimer = null;

    await _subscription?.cancel();
    _subscription = null;

    await _channel?.sink.close();
    _channel = null;

    print('[WS_DISCONNECTED_MANUAL]');
  }

  Future<void> _clearSocketOnly() async {
    _connected = false;
    _connecting = false;

    _pingTimer?.cancel();
    _pingTimer = null;

    await _subscription?.cancel();
    _subscription = null;

    try {
      await _channel?.sink.close();
    } catch (_) {}

    _channel = null;
  }

  void _safeAdd(Map<String, dynamic> data) {
    if (_disposed) return;
    if (_controller.isClosed) return;

    _controller.add(data);
  }

  Future<void> dispose() async {
    _disposed = true;
    _manualDisconnect = true;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _pingTimer?.cancel();
    _pingTimer = null;

    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;

    await _subscription?.cancel();
    _subscription = null;

    await _channel?.sink.close();
    _channel = null;

    _connected = false;
    _connecting = false;

    await _controller.close();

    print('[WS_DISPOSED]');
  }
}