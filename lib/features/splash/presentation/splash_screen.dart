// import 'package:flutter/material.dart';
// import '../../auth/presentation/login_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();

//     Future.delayed(const Duration(seconds: 2), () {
//       if (!mounted) return;

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginScreen()),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//         child: Text(
//           'Bimo Chat',
//           style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/logic/auth_provider.dart';
import '../../auth/presentation/login_screen.dart';
import '../../home/presentation/home_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    /*
      نفس الانتظار القديم حتى تعمل خدمة WebSocket أولًا.
    */
    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;

      await _openNextScreen();
    });
  }

  Future<void> _openNextScreen() async {
    if (!mounted || _navigated) return;

    /*
      هنا فقط يتم إنشاء authProvider بعد انتهاء الثانيتين،
      وليس فور تشغيل التطبيق.
    */
    ref.read(authProvider.notifier);

    /*
      انتظار انتهاء استعادة الجلسة من SharedPreferences.
    */
    while (mounted) {
      final authState = ref.read(authProvider);

      if (authState.initialized) {
        _navigated = true;

        final Widget destination = authState.loggedIn
            ? const HomeScreen()
            : const LoginScreen();

        if (!mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => destination,
          ),
          (route) => false,
        );

        return;
      }

      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  Widget build(BuildContext context) {
    /*
      لا تستخدم ref.watch أو ref.listen هنا،
      حتى لا يتم تشغيل AuthController مبكرًا.
    */
    return const Scaffold(
      body: Center(
        child: Text(
          'Bimo Chat',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}