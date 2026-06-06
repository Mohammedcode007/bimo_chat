import 'package:flutter/material.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_error_text.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../home/presentation/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  String? generalError;
  String? usernameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool validate() {
    setState(() {
      generalError = null;
      usernameError = null;
      emailError = null;
      passwordError = null;
      confirmPasswordError = null;
    });

    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    bool isValid = true;

    if (username.isEmpty) {
      usernameError = 'Username is required';
      isValid = false;
    } else if (username.length < 3) {
      usernameError = 'Username must be at least 3 characters';
      isValid = false;
    }

    if (email.isEmpty) {
      emailError = 'Email is required';
      isValid = false;
    } else if (!email.contains('@') || !email.contains('.')) {
      emailError = 'Enter a valid email address';
      isValid = false;
    }

    if (password.isEmpty) {
      passwordError = 'Password is required';
      isValid = false;
    } else if (password.length < 6) {
      passwordError = 'Password must be at least 6 characters';
      isValid = false;
    }

    if (confirmPassword.isEmpty) {
      confirmPasswordError = 'Confirm password is required';
      isValid = false;
    } else if (confirmPassword != password) {
      confirmPasswordError = 'Passwords do not match';
      isValid = false;
    }

    setState(() {});
    return isValid;
  }

  Future<void> register() async {
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

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Join Bimo Chat',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
              ),

              const SizedBox(height: 8),

              const Text(
                'Create your account to start chatting',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24),

              AppErrorText(message: generalError),

              if (generalError != null) const SizedBox(height: 16),

              AppTextField(
                label: 'Username',
                hint: 'Choose username',
                controller: usernameController,
                errorText: usernameError,
                prefixIcon: Icons.person_outline,
              ),

              const SizedBox(height: 16),

              AppTextField(
                label: 'Email',
                hint: 'Enter email address',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                errorText: emailError,
                prefixIcon: Icons.email_outlined,
              ),

              const SizedBox(height: 16),

              AppTextField(
                label: 'Password',
                hint: 'Create password',
                controller: passwordController,
                obscureText: true,
                errorText: passwordError,
                prefixIcon: Icons.lock_outline,
              ),

              const SizedBox(height: 16),

              AppTextField(
                label: 'Confirm Password',
                hint: 'Repeat password',
                controller: confirmPasswordController,
                obscureText: true,
                errorText: confirmPasswordError,
                prefixIcon: Icons.lock_reset_outlined,
              ),

              const SizedBox(height: 26),

              AppButton(
                text: 'Create Account',
                isLoading: isLoading,
                onPressed: register,
              ),

              const SizedBox(height: 14),

              Center(
                child: TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text(
                    'Already have an account? Login',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
