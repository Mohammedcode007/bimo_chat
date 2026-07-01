// import 'package:flutter/material.dart';
// import 'package:flutter_html/flutter_html.dart';

// import '../../../../core/utils/responsive.dart';

// class RoomPinnedHtmlMessage extends StatelessWidget {
//   final String html;

//   const RoomPinnedHtmlMessage({super.key, required this.html});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final isDark = theme.brightness == Brightness.dark;

//     final backgroundColor = isDark
//         ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.72)
//         : const Color(0xFFDCE8EA);

//     final borderColor = isDark
//         ? colorScheme.outlineVariant.withValues(alpha: 0.28)
//         : Colors.transparent;

//     final textColor = isDark
//         ? colorScheme.onSurface.withValues(alpha: 0.92)
//         : Colors.black;

//     return Container(
//       margin: EdgeInsetsDirectional.fromSTEB(
//         R.size(context, 14),
//         0,
//         R.size(context, 14),
//         R.size(context, 14),
//       ),
//       padding: EdgeInsets.all(R.size(context, 20)),
//       constraints: BoxConstraints(minHeight: R.size(context, 175)),
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(R.size(context, 20)),
//         border: Border.all(
//           color: borderColor,
//           width: isDark ? 0.8 : 0,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
//             blurRadius: isDark ? 8 : 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Html(
//         data: html,
//         style: {
//           'body': Style(
//             textAlign: TextAlign.center,
//             fontSize: FontSize(R.sp(context, 20)),
//             fontWeight: FontWeight.w600,
//             color: textColor,
//             margin: Margins.zero,
//             padding: HtmlPaddings.zero,
//           ),
//           'h1': Style(
//             textAlign: TextAlign.center,
//             color: textColor,
//             margin: Margins.zero,
//             padding: HtmlPaddings.zero,
//           ),
//           'h2': Style(
//             textAlign: TextAlign.center,
//             color: textColor,
//             margin: Margins.zero,
//             padding: HtmlPaddings.zero,
//           ),
//           'h3': Style(
//             textAlign: TextAlign.center,
//             color: textColor,
//             margin: Margins.zero,
//             padding: HtmlPaddings.zero,
//           ),
//           'h4': Style(
//             textAlign: TextAlign.center,
//             color: textColor,
//             margin: Margins.zero,
//             padding: HtmlPaddings.zero,
//           ),
//           'h5': Style(
//             textAlign: TextAlign.center,
//             color: textColor,
//             margin: Margins.zero,
//             padding: HtmlPaddings.zero,
//           ),
//           'h6': Style(
//             textAlign: TextAlign.center,
//             fontSize: FontSize(R.sp(context, 21)),
//             fontWeight: FontWeight.w700,
//             color: textColor,
//             margin: Margins.zero,
//             padding: HtmlPaddings.zero,
//           ),
//           'p': Style(
//             textAlign: TextAlign.center,
//             color: textColor,
//             margin: Margins.zero,
//             padding: HtmlPaddings.zero,
//           ),
//           'font': Style(
//             color: textColor,
//           ),
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../core/utils/responsive.dart';

class RoomPinnedHtmlMessage extends StatelessWidget {
  final String html;

  const RoomPinnedHtmlMessage({
    super.key,
    required this.html,
  });

  Future<void> openLink(BuildContext context, String? rawUrl) async {
    if (rawUrl == null || rawUrl.trim().isEmpty) return;

    String url = rawUrl.trim();

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    try {
      bool opened = await launchUrlString(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (opened) return;

      opened = await launchUrlString(
        url,
        mode: LaunchMode.platformDefault,
      );

      if (opened) return;

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot open link: $url'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      debugPrint('[PINNED_HTML_LINK_ERROR] $error');

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot open link: $url'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

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

    const linkColor = Color(0xFF087887);

    return Container(
      width: double.infinity,
      margin: EdgeInsetsDirectional.fromSTEB(
        R.size(context, 14),
        0,
        R.size(context, 14),
        R.size(context, 14),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: R.size(context, 18),
        vertical: R.size(context, 20),
      ),
      constraints: BoxConstraints(
        minHeight: R.size(context, 145),
      ),
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          R.size(context, 20),
        ),
        border: Border.all(
          color: borderColor,
          width: isDark ? 0.8 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.18 : 0.04,
            ),
            blurRadius: isDark ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth,
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Html(
                data: html,
                shrinkWrap: true,
                onLinkTap: (
                  url,
                  attributes,
                  element,
                ) {
                  openLink(context, url);
                },
                style: {
                  '*': Style(
                    maxLines: null,
                    textAlign: TextAlign.center,
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    width: Width.auto(),
                  ),

                  'body': Style(
                    display: Display.block,
                    textAlign: TextAlign.center,
                    fontSize: FontSize(
                      R.sp(context, 20),
                    ),
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    lineHeight: const LineHeight(1.45),
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                  ),

                  'div': Style(
                    textAlign: TextAlign.center,
                    color: textColor,
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    lineHeight: const LineHeight(1.45),
                  ),

                  'p': Style(
                    textAlign: TextAlign.center,
                    color: textColor,
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    lineHeight: const LineHeight(1.45),
                  ),

                  'span': Style(
                    textAlign: TextAlign.center,
                    color: textColor,
                  ),

                  'font': Style(
                    color: textColor,
                  ),

                  'h1': Style(
                    textAlign: TextAlign.center,
                    color: textColor,
                    fontSize: FontSize(
                      R.sp(context, 24),
                    ),
                    fontWeight: FontWeight.w800,
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    lineHeight: const LineHeight(1.35),
                  ),

                  'h2': Style(
                    textAlign: TextAlign.center,
                    color: textColor,
                    fontSize: FontSize(
                      R.sp(context, 23),
                    ),
                    fontWeight: FontWeight.w800,
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    lineHeight: const LineHeight(1.35),
                  ),

                  'h3': Style(
                    textAlign: TextAlign.center,
                    color: textColor,
                    fontSize: FontSize(
                      R.sp(context, 22),
                    ),
                    fontWeight: FontWeight.w800,
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    lineHeight: const LineHeight(1.35),
                  ),

                  'h4': Style(
                    textAlign: TextAlign.center,
                    color: textColor,
                    fontSize: FontSize(
                      R.sp(context, 20),
                    ),
                    fontWeight: FontWeight.w700,
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    lineHeight: const LineHeight(1.45),
                  ),

                  'h5': Style(
                    textAlign: TextAlign.center,
                    color: textColor,
                    fontSize: FontSize(
                      R.sp(context, 19),
                    ),
                    fontWeight: FontWeight.w700,
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    lineHeight: const LineHeight(1.45),
                  ),

                  'h6': Style(
                    textAlign: TextAlign.center,
                    color: textColor,
                    fontSize: FontSize(
                      R.sp(context, 18),
                    ),
                    fontWeight: FontWeight.w700,
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    lineHeight: const LineHeight(1.45),
                  ),

                  'br': Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                  ),

                  'a': Style(
                    color: linkColor,
                    fontWeight: FontWeight.w800,
                    textDecoration: TextDecoration.underline,
                    textDecorationColor: linkColor,
                  ),

                  'img': Style(
                    width: Width(
                      R.size(context, 45),
                    ),
                    height: Height(
                      R.size(context, 45),
                    ),
                    margin: Margins.symmetric(
                      horizontal: R.size(context, 4),
                    ),
                  ),
                },
              ),
            ),
          );
        },
      ),
    );
  }
}