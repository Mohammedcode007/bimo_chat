import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';

class RoomAvatar extends StatelessWidget {
  final Color color;
  final String? text;
  final bool isVerified;
  final double baseSize;

  const RoomAvatar({
    super.key,
    required this.color,
    this.text,
    this.isVerified = false,
    this.baseSize = 72,
  });

  @override
  Widget build(BuildContext context) {
    final size = R.size(context, baseSize);

    final firstLetter = text != null && text!.trim().isNotEmpty
        ? text!.trim().characters.first
        : '';

    return SizedBox(
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isVerified ? const Color(0xFF4CAF50) : color,
            width: R.size(context, 3),
          ),
        ),
        alignment: Alignment.center,
        child: isVerified
            ? Container(
                width: size * 0.42,
                height: size * 0.42,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: size * 0.30,
                ),
              )
            : Text(
                firstLetter,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
