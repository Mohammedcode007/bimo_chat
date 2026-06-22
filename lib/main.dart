import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/app/app_controller.dart';
import 'core/constants/api_constants.dart';
import 'core/network/ws_background_controller.dart';
import 'core/network/ws_background_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /*
    إنشاء كنترولر التطبيق قبل تشغيل الواجهة.
  */
  final appController = AppStateController();

  /*
    تحميل اللغة المحفوظة من SharedPreferences.

    إذا لم توجد لغة محفوظة،
    ستكون العربية هي اللغة الافتراضية.
  */
  await appController.loadSavedLanguage();

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    await initializeWsBackgroundService();

    await startBackgroundWs(
      ApiConstants.wsUrl,
    );
  }

  runApp(
    ProviderScope(
      child: BimoChatApp(
        controller: appController,
      ),
    ),
  );
}