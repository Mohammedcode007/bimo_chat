import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppErrorText extends StatelessWidget {
  final String? message;

  const AppErrorText({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Text(
        message!,
        style: const TextStyle(
          color: AppColors.error,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
