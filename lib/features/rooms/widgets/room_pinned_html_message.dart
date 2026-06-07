import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../../core/utils/responsive.dart';

class RoomPinnedHtmlMessage extends StatelessWidget {
  final String html;

  const RoomPinnedHtmlMessage({super.key, required this.html});

  @override
  Widget build(BuildContext context) {
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
        color: const Color(0xFFDCE8EA),
        borderRadius: BorderRadius.circular(R.size(context, 20)),
      ),
      child: Html(
        data: html,
        style: {
          'body': Style(
            textAlign: TextAlign.center,
            fontSize: FontSize(R.sp(context, 20)),
            fontWeight: FontWeight.w600,
            color: Colors.black,
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
          ),
          'h6': Style(
            textAlign: TextAlign.center,
            fontSize: FontSize(R.sp(context, 21)),
            fontWeight: FontWeight.w700,
            color: Colors.black,
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
          ),
        },
      ),
    );
  }
}
