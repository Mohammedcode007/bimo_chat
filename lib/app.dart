import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app/app_controller.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/splash_screen.dart';

class BimoChatApp extends StatefulWidget {
  const BimoChatApp({super.key});

  @override
  State<BimoChatApp> createState() => _BimoChatAppState();
}

class _BimoChatAppState extends State<BimoChatApp> {
  final AppStateController controller = AppStateController();

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

            locale: controller.locale,
            supportedLocales: const [Locale('en'), Locale('ar')],

            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            builder: (context, child) {
              return Directionality(
                textDirection: AppLocalizations.textDirectionOf(context),
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
