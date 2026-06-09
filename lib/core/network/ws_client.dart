import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class WsClient {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  final StreamController<Map<String, dynamic>> _controller =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  bool _connected = false;

  bool get isConnected => _connected;

  void connect(String url) {
    if (_connected) return;

    _channel = WebSocketChannel.connect(Uri.parse(url));
    _connected = true;

    _subscription = _channel!.stream.listen(
      (event) {
        try {
          final decoded = jsonDecode(event.toString());

          if (decoded is Map<String, dynamic>) {
            _controller.add(decoded);
          }
        } catch (_) {
          _controller.add({
            'handler': 'error_event',
            'type': 'error',
            'reason': 'invalid_server_message',
          });
        }
      },
      onError: (error) {
        _connected = false;
        _controller.add({
          'handler': 'socket_error',
          'type': 'error',
          'reason': error.toString(),
        });
      },
      onDone: () {
        _connected = false;
        _controller.add({
          'handler': 'socket_closed',
          'type': 'error',
          'reason': 'connection_closed',
        });
      },
    );
  }

  void send(Map<String, dynamic> data) {
    if (!_connected || _channel == null) {
      _controller.add({
        'handler': 'error_event',
        'type': 'error',
        'reason': 'socket_not_connected',
      });
      return;
    }

    _channel!.sink.add(jsonEncode(data));
  }

  Future<void> disconnect() async {
    _connected = false;

    await _subscription?.cancel();
    _subscription = null;

    await _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _controller.close();
  }
}
