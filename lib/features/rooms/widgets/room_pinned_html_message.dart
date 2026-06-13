import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../../core/utils/responsive.dart';

class RoomPinnedHtmlMessage extends StatelessWidget {
  final String html;

  const RoomPinnedHtmlMessage({super.key, required this.html});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.72)
        : const Color(0xFFDCE8EA);

    final borderColor = isDark
        ? colorScheme.outlineVariant.withValues(alpha: 0.28)
        : Colors.transparent;

    final textColor = isDark
        ? colorScheme.onSurface.withValues(alpha: 0.92)
        : Colors.black;

    return Container(
      margin: EdgeInsetsDirectional.fromSTEB(
        R.size(context, 14),
        0,
        R.size(context, 14),
        R.size(context, 14),
      ),
      padding: EdgeInsets.all(R.size(context, 20)),
      constraints: BoxConstraints(minHeight: R.size(context, 175)),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(R.size(context, 20)),
        border: Border.all(
          color: borderColor,
          width: isDark ? 0.8 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
            blurRadius: isDark ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Html(
        data: html,
        style: {
          'body': Style(
            textAlign: TextAlign.center,
            fontSize: FontSize(R.sp(context, 20)),
            fontWeight: FontWeight.w600,
            color: textColor,
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
          ),
          'h1': Style(
            textAlign: TextAlign.center,
            color: textColor,
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
          ),
          'h2': Style(
            textAlign: TextAlign.center,
            color: textColor,
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
          ),
          'h3': Style(
            textAlign: TextAlign.center,
            color: textColor,
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
          ),
          'h4': Style(
            textAlign: TextAlign.center,
            color: textColor,
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
          ),
          'h5': Style(
            textAlign: TextAlign.center,
            color: textColor,
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
          ),
          'h6': Style(
            textAlign: TextAlign.center,
            fontSize: FontSize(R.sp(context, 21)),
            fontWeight: FontWeight.w700,
            color: textColor,
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
          ),
          'p': Style(
            textAlign: TextAlign.center,
            color: textColor,
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
          ),
          'font': Style(
            color: textColor,
          ),
        },
      ),
    );
  }
}