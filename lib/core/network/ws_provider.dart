import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ws_client.dart';

final wsClientProvider = Provider<WsClient>((ref) {
  /*
    هذا Provider مؤقت للتوافق مع الملفات القديمة فقط.

    بعد توحيد WebSocket:
    - الاتصال يتم من startBackgroundWs(url)
    - الإرسال يتم من sendBackgroundWs(data)
    - الاستقبال يتم من WsEventBus.instance.stream

    لذلك لا نعمل client.connect هنا.
    ولا نعمل client.dispose هنا حتى لا يحصل فصل غير مقصود.
  */
  final client = WsClient();

  return client;
});