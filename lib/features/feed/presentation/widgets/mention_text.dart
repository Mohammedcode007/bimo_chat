import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';

class MentionText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final Color mentionColor;
  final Color hashtagColor;
  final TextAlign textAlign;

  const MentionText({
    super.key,
    required this.text,
    this.fontSize = 17,
    this.fontWeight = FontWeight.w400,
    this.color = Colors.black,
    this.mentionColor = const Color(0xFF1D9BF0),
    this.hashtagColor = const Color(0xFF1D9BF0),
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];

    /*
      يلتقط أي نص يبدأ بـ @ أو #
      ويستمر حتى أول مسافة أو سطر جديد.

      أمثلة:
      @user
      @محمود
      @𓆩〭〬🌸⃝ʀɛʍǟռ🥂𓆪
      @محمد_أحمد
      #موضوع_مزخرف
    */
    final regex = RegExp(
      r'(@[^\s]+|#[^\s]+)',
      unicode: true,
    );

    final matches = regex.allMatches(text);

    var currentIndex = 0;

    for (final match in matches) {
      if (match.start > currentIndex) {
        spans.add(
          TextSpan(
            text: text.substring(
              currentIndex,
              match.start,
            ),
            style: _normalStyle(context),
          ),
        );
      }

      final matchedText =
          match.group(0) ?? '';

      final isMention =
          matchedText.startsWith('@');

      spans.add(
        TextSpan(
          text: matchedText,
          style: TextStyle(
            color: isMention
                ? mentionColor
                : hashtagColor,
            fontSize: R.sp(
              context,
              fontSize,
            ),
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
      );

      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(
            currentIndex,
          ),
          style: _normalStyle(context),
        ),
      );
    }

    return RichText(
      textAlign: textAlign,
      textDirection: _isArabic(text)
          ? TextDirection.rtl
          : TextDirection.ltr,
      text: TextSpan(
        children: spans,
      ),
    );
  }

  TextStyle _normalStyle(
    BuildContext context,
  ) {
    return TextStyle(
      color: color,
      fontSize: R.sp(
        context,
        fontSize,
      ),
      fontWeight: fontWeight,
      height: 1.35,
    );
  }

  bool _isArabic(
    String value,
  ) {
    return RegExp(
      r'[\u0600-\u06FF]',
    ).hasMatch(value);
  }
}