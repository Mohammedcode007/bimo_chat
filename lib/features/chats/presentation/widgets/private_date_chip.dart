import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';

class PrivateDateChip extends StatelessWidget {
  final String text;

  const PrivateDateChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        margin: EdgeInsets.only(bottom: R.size(context, 18)),
        padding: EdgeInsets.symmetric(
          horizontal: R.size(context, 18),
          vertical: R.size(context, 8),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFDDE7E8),
          borderRadius: BorderRadius.circular(R.size(context, 5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.48),
            fontSize: R.sp(context, 18),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
