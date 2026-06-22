import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import '../constants/api_constants.dart';

String _currentWsUrl = ApiConstants.wsUrl;

Future<void>? _startingFuture;

bool _startCommandSent = false;

Future<void> startBackgroundWs([
  String? url,
]) async {
  if (kIsWeb) {
    debugPrint(
      '❌ startBackgroundWs ignored on Web',
    );
    return;
  }

  final requestedUrl =
      (url ?? ApiConstants.wsUrl).trim();

  debugPrint(
    '🟢 startBackgroundWs called url=$requestedUrl',
  );

  if (requestedUrl.isEmpty) {
    debugPrint(
      '❌ startBackgroundWs failed: missing_ws_url',
    );
    return;
  }

  if (!requestedUrl.startsWith('ws://') &&
      !requestedUrl.startsWith('wss://')) {
    debugPrint(
      '❌ Invalid WebSocket URL: $requestedUrl',
    );
    return;
  }

  _currentWsUrl = requestedUrl;

  /*
    لو توجد عملية تشغيل حالية،
    ننتظرها بدل إنشاء عملية أخرى.
  */
  final currentStartingFuture =
      _startingFuture;

  if (currentStartingFuture != null) {
    debugPrint(
      '⏳ WebSocket start already in progress',
    );

    await currentStartingFuture;
    return;
  }

  final completer =
      Completer<void>();

  _startingFuture =
      completer.future;

  try {
    final service =
        FlutterBackgroundService();

    final isRunning =
        await service.isRunning();

    debugPrint(
      '🟢 background service isRunning=$isRunning',
    );

    if (!isRunning) {
      final started =
          await service.startService();

      debugPrint(
        '🟢 background service startService result=$started',
      );

      /*
        انتظار تشغيل isolate الخلفية
        وتركيب service.on('start_ws').
      */
      await Future<void>.delayed(
        const Duration(
          milliseconds: 1000,
        ),
      );
    }

    debugPrint(
      '🟢 invoking start_ws url=$_currentWsUrl',
    );

    service.invoke(
      'start_ws',
      {
        'url': _currentWsUrl,
      },
    );

    _startCommandSent = true;

    /*
      إعطاء أمر start_ws فرصة للوصول
      قبل إرسال auth.login أو أي رسالة أخرى.
    */
    await Future<void>.delayed(
      const Duration(
        milliseconds: 250,
      ),
    );

    if (!completer.isCompleted) {
      completer.complete();
    }
  } catch (error, stackTrace) {
    debugPrint(
      '❌ startBackgroundWs error: $error',
    );

    debugPrint(
      stackTrace.toString(),
    );

    _startCommandSent = false;

    if (!completer.isCompleted) {
      completer.completeError(
        error,
        stackTrace,
      );
    }
  } finally {
    _startingFuture = null;
  }
}

void sendBackgroundWs(
  Map<String, dynamic> data,
) {
  debugPrint(
    '📤 sendBackgroundWs called => $data',
  );

  if (kIsWeb) {
    debugPrint(
      '❌ sendBackgroundWs ignored on Web',
    );
    return;
  }

  /*
    نضمن تشغيل خدمة WebSocket وإرسال الرابط
    قبل إرسال الرسالة.
  */
  unawaited(
    _ensureStartedThenSend(
      Map<String, dynamic>.from(
        data,
      ),
    ),
  );
}

Future<void> _ensureStartedThenSend(
  Map<String, dynamic> data,
) async {
  try {
    final startingFuture =
        _startingFuture;

    if (startingFuture != null) {
      debugPrint(
        '⏳ Waiting for WebSocket start...',
      );

      await startingFuture;
    }

    if (!_startCommandSent) {
      debugPrint(
        '⚠️ WebSocket has not started yet',
      );

      await startBackgroundWs(
        ApiConstants.wsUrl,
      );
    }

    if (!_startCommandSent) {
      debugPrint(
        '❌ Message not sent because WebSocket start failed',
      );
      return;
    }

    final service =
        FlutterBackgroundService();

    service.invoke(
      'send_ws',
      {
        'data': data,
      },
    );

    debugPrint(
      '📤 send_ws invoked to background service',
    );
  } catch (error, stackTrace) {
    debugPrint(
      '❌ sendBackgroundWs error: $error',
    );

    debugPrint(
      stackTrace.toString(),
    );
  }
}

Future<void> restartBackgroundWs([
  String? url,
]) async {
  if (kIsWeb) {
    debugPrint(
      '❌ restartBackgroundWs ignored on Web',
    );
    return;
  }

  final requestedUrl =
      (url ?? ApiConstants.wsUrl).trim();

  if (requestedUrl.isNotEmpty) {
    _currentWsUrl =
        requestedUrl;
  }

  debugPrint(
    '🔄 restartBackgroundWs called url=$_currentWsUrl',
  );

  final service =
      FlutterBackgroundService();

  service.invoke(
    'stop_ws',
  );

  _startCommandSent = false;
  _startingFuture = null;

  await Future<void>.delayed(
    const Duration(
      milliseconds: 400,
    ),
  );

  await startBackgroundWs(
    _currentWsUrl,
  );
}

Future<void> stopBackgroundWs({
  bool stopService = false,
}) async {
  debugPrint(
    '🛑 stopBackgroundWs called',
  );

  if (kIsWeb) {
    debugPrint(
      '❌ stopBackgroundWs ignored on Web',
    );
    return;
  }

  final service =
      FlutterBackgroundService();

  /*
    إيقاف اتصال WebSocket الحالي.
  */
  service.invoke(
    'stop_ws',
  );

  _startCommandSent = false;
  _startingFuture = null;

  /*
    لا توقف الخدمة بالكامل افتراضيًا،
    لأن شاشة تسجيل الدخول تحتاجها مرة أخرى.
  */
  if (stopService) {
    await Future<void>.delayed(
      const Duration(
        milliseconds: 200,
      ),
    );

    service.invoke(
      'stop_service',
    );
  }
}

Future<void> ensureBackgroundWsStarted() async {
  if (kIsWeb) {
    return;
  }

  final startingFuture =
      _startingFuture;

  if (startingFuture != null) {
    await startingFuture;
    return;
  }

  if (_startCommandSent) {
    return;
  }

  await startBackgroundWs(
    ApiConstants.wsUrl,
  );
}