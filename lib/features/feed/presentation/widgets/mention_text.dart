import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';

class MentionText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final TextAlign textAlign;

  const MentionText({
    super.key,
    required this.text,
    this.fontSize = 17,
    this.fontWeight = FontWeight.w400,
    this.color = Colors.black,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'(@[a-zA-Z0-9_]+|#[^\s#@]+)');
    final matches = regex.allMatches(text);

    int currentIndex = 0;

    for (final match in matches) {
      if (match.start > currentIndex) {
        spans.add(
          TextSpan(
            text: text.substring(currentIndex, match.start),
            style: TextStyle(
              color: color,
              fontSize: R.sp(context, fontSize),
              fontWeight: fontWeight,
              height: 1.35,
            ),
          ),
        );
      }

      spans.add(
        TextSpan(
          text: match.group(0),
          style: TextStyle(
            color: const Color(0xFF1D9BF0),
            fontSize: R.sp(context, fontSize),
            fontWeight: fontWeight,
            height: 1.35,
          ),
        ),
      );

      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(currentIndex),
          style: TextStyle(
            color: color,
            fontSize: R.sp(context, fontSize),
            fontWeight: fontWeight,
            height: 1.35,
          ),
        ),
      );
    }

    return RichText(
      textAlign: textAlign,
      textDirection: _isArabic(text) ? TextDirection.rtl : TextDirection.ltr,
      text: TextSpan(children: spans),
    );
  }

  bool _isArabic(String value) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(value);
  }
}
