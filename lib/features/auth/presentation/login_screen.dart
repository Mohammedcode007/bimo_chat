import 'package:flutter/material.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_error_text.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../home/presentation/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? generalError;
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
      generalError = null;
      usernameError = null;
      passwordError = null;
    });

    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    bool isValid = true;

    if (username.isEmpty) {
      usernameError = 'Username is required';
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

  Future<void> login() async {
    if (!validate()) return;

    setState(() {
      isLoading = true;
      generalError = null;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 45),

              const Text(
                'Bimo Chat',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
              ),

              const SizedBox(height: 8),

              const Text(
                'Login to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 30),

              AppErrorText(message: generalError),

              if (generalError != null) const SizedBox(height: 16),

              AppTextField(
                label: 'Username',
                hint: 'Enter your username',
                controller: usernameController,
                errorText: usernameError,
                prefixIcon: Icons.person_outline,
              ),

              const SizedBox(height: 16),

              AppTextField(
                label: 'Password',
                hint: 'Enter your password',
                controller: passwordController,
                obscureText: true,
                errorText: passwordError,
                prefixIcon: Icons.lock_outline,
              ),

              const SizedBox(height: 26),

              AppButton(text: 'Login', isLoading: isLoading, onPressed: login),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Don\'t have an account?',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed: openRegister,
                    child: const Text(
                      'Create account',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
