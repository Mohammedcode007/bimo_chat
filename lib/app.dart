import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app/app_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/network/ws_event_bus.dart';
import 'features/splash/presentation/splash_screen.dart';

class BimoChatApp extends StatefulWidget {
  final AppStateController controller;

  const BimoChatApp({
    super.key,
    required this.controller,
  });

  @override
  State<BimoChatApp> createState() => _BimoChatAppState();
}

class _BimoChatAppState extends State<BimoChatApp> {
  AppStateController get controller => widget.controller;

  @override
  void initState() {
    super.initState();

    WsEventBus.instance.start();
  }

  @override
  void dispose() {
    /*
      لا تستدعِ controller.dispose() هنا،
      لأن الكنترولر تم إنشاؤه في main.dart.
    */

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppController(
      controller: controller,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return MaterialApp(
            title: 'Bimo Chat',
            debugShowCheckedModeBanner: false,

            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: controller.themeMode,

            /*
              اللغة التي تم تحميلها من SharedPreferences.
            */
            locale: controller.locale,

            supportedLocales: const [
              Locale('ar'),
              Locale('en'),
            ],

            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            /*
              تغيير النصوص فقط،
              مع إبقاء اتجاه التطبيق بالكامل LTR.
            */
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.ltr,
                child: child ?? const SizedBox.shrink(),
              );
            },

            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}