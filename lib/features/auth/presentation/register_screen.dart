import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/responsive.dart';
import '../../home/presentation/home_screen.dart';
import '../logic/auth_provider.dart';
import 'login_screen.dart';
import 'widgets/auth_input_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  String? usernameError;
  String? passwordError;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool validate() {
    setState(() {
      usernameError = null;
      passwordError = null;
    });

    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    bool isValid = true;

    if (username.isEmpty) {
      usernameError = 'Username is required';
      isValid = false;
    } else if (username.length < 3) {
      usernameError = 'Username must be at least 3 characters';
      isValid = false;
    }

    if (password.isEmpty) {
      passwordError = 'Password is required';
      isValid = false;
    } else if (password.length < 6) {
      passwordError = 'Password must be at least 6 characters';
      isValid = false;
    }

    setState(() {});
    return isValid;
  }

  void register() {
    if (!validate()) return;

    ref
        .read(authProvider.notifier)
        .register(
          username: usernameController.text.trim(),
          password: passwordController.text.trim(),
        );
  }

  void openLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void signInWithGoogle() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        content: Text(
          'Google sign in clicked',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void openTerms() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        content: Text(
          'Terms clicked',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void openPrivacy() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        content: Text(
          'Privacy Policy clicked',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      if (next.loggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }

      if (next.error != null && next.error!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.inverseSurface,
            content: Text(
              next.error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }
    });

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final primary = colorScheme.primary;
    final textColor = colorScheme.onSurface;

    final googleButtonColor = theme.brightness == Brightness.dark
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.55)
        : const Color(0xFFE1E2E4);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(horizontal: R.size(context, 28)),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      SizedBox(height: R.size(context, 34)),

                      Text(
                        'New account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColor,
                          fontSize: R.sp(context, 34),
                          fontWeight: FontWeight.w500,
                          height: 1.1,
                        ),
                      ),

                      SizedBox(height: R.size(context, 30)),

                      const _RegisterLogo(),

                      SizedBox(height: R.size(context, 42)),

                      AuthInputField(
                        controller: usernameController,
                        hintText: 'Username',
                        prefixIcon: Icons.person_outline_rounded,
                        errorText: usernameError,
                      ),

                      SizedBox(height: R.size(context, 24)),

                      AuthInputField(
                        controller: passwordController,
                        hintText: 'Password',
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        errorText: passwordError,
                      ),

                      SizedBox(height: R.size(context, 72)),

                      InkWell(
                        onTap: auth.loading ? null : signInWithGoogle,
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: double.infinity,
                          height: R.size(context, 68),
                          decoration: BoxDecoration(
                            color: googleButtonColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const _GoogleIcon(),

                              SizedBox(width: R.size(context, 14)),

                              Text(
                                'Sign in with Google',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: R.sp(context, 18),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: R.size(context, 22)),

                      SizedBox(
                        width: double.infinity,
                        height: R.size(context, 58),
                        child: ElevatedButton(
                          onPressed: auth.loading ? null : register,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: auth.loading
                              ? SizedBox(
                                  width: R.size(context, 24),
                                  height: R.size(context, 24),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: colorScheme.onPrimary,
                                  ),
                                )
                              : Text(
                                  'Create account',
                                  style: TextStyle(
                                    fontSize: R.sp(context, 19),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: R.size(context, 28)),

                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'You have an account? ',
                            style: TextStyle(
                              color: textColor,
                              fontSize: R.sp(context, 18),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: openLogin,
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: primary,
                                fontSize: R.sp(context, 18),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      Padding(
                        padding: EdgeInsets.only(
                          bottom: R.size(context, 22),
                          top: R.size(context, 35),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'By creating an account,  you agree to our',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textColor,
                                fontSize: R.sp(context, 18),
                                fontWeight: FontWeight.w500,
                                height: 1.35,
                              ),
                            ),

                            SizedBox(height: R.size(context, 4)),

                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: openTerms,
                                  child: Text(
                                    'Terms',
                                    style: TextStyle(
                                      color: primary,
                                      fontSize: R.sp(context, 18),
                                      fontWeight: FontWeight.w700,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                                Text(
                                  ' and ',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: R.sp(context, 18),
                                    fontWeight: FontWeight.w500,
                                    height: 1.35,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: openPrivacy,
                                  child: Text(
                                    'Privacy Policy',
                                    style: TextStyle(
                                      color: primary,
                                      fontSize: R.sp(context, 18),
                                      fontWeight: FontWeight.w700,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RegisterLogo extends StatelessWidget {
  const _RegisterLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: R.size(context, 138),
      height: R.size(context, 138),
      decoration: const BoxDecoration(
        color: Color(0xFF2BCB00),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        width: R.size(context, 76),
        height: R.size(context, 76),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          'T',
          style: TextStyle(
            color: const Color(0xFF2BCB00),
            fontSize: R.sp(context, 56),
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: R.size(context, 36),
      height: R.size(context, 36),
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.16;
    final rect = Rect.fromLTWH(
      strokeWidth,
      strokeWidth,
      size.width - strokeWidth * 2,
      size.height - strokeWidth * 2,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.05, 1.45, false, paint);

    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 1.40, 1.30, false, paint);

    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.70, 1.15, false, paint);

    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 3.85, 1.35, false, paint);

    final linePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.55, size.height * 0.52),
      Offset(size.width * 0.88, size.height * 0.52),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
