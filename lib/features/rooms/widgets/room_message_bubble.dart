// import 'dart:io';

// import 'package:bimo_chat/core/utils/helpers.dart';
// import 'package:bimo_chat/features/rooms/data/room_chat_message_model.dart';
// import 'package:bimo_chat/features/rooms/data/room_role.dart';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../../../core/utils/responsive.dart';
// import 'package:flutter/gestures.dart';
// import 'package:url_launcher/url_launcher.dart';
// String cleanVisibleText(String input) {
//   return input
//       // Zero width / invisible chars
//       .replaceAll(RegExp(r'[\u200B-\u200F\u202A-\u202E\u2060-\u206F]'), '')
//       // Variation selectors
//       .replaceAll(RegExp(r'[\uFE00-\uFE0F]'), '')
//       // Combining diacritics
//       .replaceAll(RegExp(r'[\u0300-\u036F]'), '')
//       .replaceAll(RegExp(r'[\u1AB0-\u1AFF]'), '')
//       .replaceAll(RegExp(r'[\u1DC0-\u1DFF]'), '')
//       .replaceAll(RegExp(r'[\u20D0-\u20FF]'), '')
//       .replaceAll(RegExp(r'[\uFE20-\uFE2F]'), '')
//       // Khmer invisible marks
//       .replaceAll(RegExp(r'[\u17B4-\u17B5]'), '')
//       // Meetei / extra combining marks
//       .replaceAll(RegExp(r'[\uAA7B-\uAA7D]'), '')
//       .trim();
// }

// class RoomMessageBubble extends StatelessWidget {
//   final RoomChatMessageModel message;
//   final VoidCallback? onImageTap;
//   final VoidCallback? onVoicePlay;
//   final VoidCallback? onNameLongPress;
//   final VoidCallback? onAvatarTap;
//   final VoidCallback? onAvatarLongPress;

//   const RoomMessageBubble({
//     super.key,
//     required this.message,
//     this.onImageTap,
//     this.onVoicePlay,
//     this.onNameLongPress,
//     this.onAvatarTap,
//     this.onAvatarLongPress,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (message.type == RoomChatMessageType.system) {
//       return _SystemMessageBubble(message: message);
//     }

//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final isDark = theme.brightness == Brightness.dark;

//     final isMe = message.isMe;
//     final maxBubbleWidth = MediaQuery.sizeOf(context).width * 0.76;

//     final bubbleColor = isMe
//         ? Colors.white
//         : isDark
//         ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.82)
//         : Colors.white;

//     final bubbleBorderColor = isDark
//         ? colorScheme.outlineVariant.withValues(alpha: 0.35)
//         : colorScheme.outlineVariant.withValues(alpha: 0.18);

//     final bubbleTextColor = isMe
//         ? Colors.black87
//         : colorScheme.onSurface.withValues(alpha: 0.92);

//     return Padding(
//       padding: EdgeInsetsDirectional.fromSTEB(
//         R.size(context, 8),
//         R.size(context, 5),
//         R.size(context, 8),
//         R.size(context, 5),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: isMe
//             ? MainAxisAlignment.end
//             : MainAxisAlignment.start,
//         children: [
//           if (!isMe) ...[
//             _AvatarSide(
//               message: message,
//               onTap: onAvatarTap,
//               onLongPress: onAvatarLongPress,
//             ),
//             SizedBox(width: R.size(context, 6)),
//           ],

//           Flexible(
//             child: IntrinsicWidth(
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(
//                   minWidth: R.size(context, 78),
//                   maxWidth: maxBubbleWidth,
//                 ),
//                 child: Container(
//                   padding: EdgeInsetsDirectional.fromSTEB(
//                     R.size(context, 12),
//                     R.size(context, 8),
//                     R.size(context, 12),
//                     R.size(context, 9),
//                   ),
//                   decoration: BoxDecoration(
//                     color: bubbleColor,
//                     border: Border.all(
//                       color: bubbleBorderColor,
//                       width: isDark ? 0.8 : 0.6,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withValues(
//                           alpha: isDark ? 0.14 : 0.035,
//                         ),
//                         blurRadius: isDark ? 6 : 4,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                     borderRadius: BorderRadiusDirectional.only(
//                       topStart: Radius.circular(
//                         isMe ? R.size(context, 15) : R.size(context, 4),
//                       ),
//                       topEnd: Radius.circular(
//                         isMe ? R.size(context, 4) : R.size(context, 15),
//                       ),
//                       bottomStart: Radius.circular(R.size(context, 15)),
//                       bottomEnd: Radius.circular(R.size(context, 15)),
//                     ),
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: isMe
//                         ? CrossAxisAlignment.end
//                         : CrossAxisAlignment.start,
//                     children: [
//                       _SenderNameInside(
//                         message: message,
//                         colorScheme: colorScheme,
//                         onLongPress: onNameLongPress,
//                         alignEnd: isMe,
//                       ),
//                       SizedBox(height: R.size(context, 5)),
//                       _MessageContent(
//                         message: message,
//                         colorScheme: colorScheme,
//                         textColor: bubbleTextColor,
//                         onImageTap: onImageTap,
//                         onVoicePlay: onVoicePlay,
//                         alignEnd: isMe,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           if (isMe) ...[
//             SizedBox(width: R.size(context, 6)),
//             _AvatarSide(
//               message: message,
//               isMe: true,
//               onTap: onAvatarTap,
//               onLongPress: onAvatarLongPress,
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

// class _SenderNameInside extends StatelessWidget {
//   final RoomChatMessageModel message;
//   final ColorScheme colorScheme;
//   final VoidCallback? onLongPress;
//   final bool alignEnd;

//   const _SenderNameInside({
//     required this.message,
//     required this.colorScheme,
//     required this.onLongPress,
//     required this.alignEnd,
//   });

//   bool get hasBadge {
//     final badge = message.sender.badge;
//     return badge != null && badge.trim().isNotEmpty;
//   }

//   String roleStar() {
//     final role = message.sender.role;

//     if (role == RoomRole.owner) return '★';
//     if (role == RoomRole.admin) return '★';

//     return '';
//   }

//   Color roleStarColor() {
//     final role = message.sender.role;

//     if (role == RoomRole.owner) return Colors.red;
//     if (role == RoomRole.admin) return Colors.blue;

//     return Colors.transparent;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final fallbackNameColor = colorScheme.onSurface.withValues(alpha: 0.92);
//     final star = roleStar();
//     final starColor = roleStarColor();
//     final badge = hasBadge ? message.sender.badge!.trim() : '';

// final nameStyle = TextStyle(
//   color: message.sender.nameColor ?? fallbackNameColor,
//   fontSize: R.sp(context, 20),
//   fontWeight: FontWeight.w700,
//   height: 1.08,
//   letterSpacing: -0.2,
//   fontFamily: null,
//   fontFamilyFallback: const [
//     'Roboto',
//     'Noto Sans',
//     'Noto Sans Symbols',
//     'Noto Sans Symbols 2',
//     'Noto Color Emoji',
//     'Segoe UI Emoji',
//   ],
// );

//     return GestureDetector(
//       onLongPress: onLongPress,
//       child: Align(
//         alignment: alignEnd
//             ? AlignmentDirectional.centerEnd
//             : AlignmentDirectional.centerStart,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: alignEnd
//               ? CrossAxisAlignment.end
//               : CrossAxisAlignment.start,
//           children: [
//             Text.rich(
//               TextSpan(
//                 children: [
//                   TextSpan(
//                     text: cleanVisibleText(message.sender.name),
//                     style: nameStyle,
//                   ),
//                   if (badge.isNotEmpty)
//                     WidgetSpan(
//                       alignment: PlaceholderAlignment.middle,
//                       child: Padding(
//                         padding: EdgeInsetsDirectional.only(
//                           start: R.size(context, 5),
//                         ),
//                         child: Text(
//                           badge,
//                           softWrap: false,
//                           overflow: TextOverflow.visible,
//                           style: TextStyle(
//                             fontSize: R.sp(context, 15),
//                             height: 1,
//                             fontWeight: FontWeight.w800,
//                           ),
//                         ),
//                       ),
//                     ),
//                   if (star.isNotEmpty)
//                     WidgetSpan(
//                       alignment: PlaceholderAlignment.middle,
//                       child: Padding(
//                         padding: EdgeInsetsDirectional.only(
//                           start: R.size(context, 5),
//                         ),
//                         child: Text(
//                           star,
//                           style: TextStyle(
//                             color: starColor,
//                             fontSize: R.sp(context, 15),
//                             height: 1,
//                             fontWeight: FontWeight.w900,
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               textAlign: alignEnd ? TextAlign.end : TextAlign.start,
//               softWrap: true,
//               overflow: TextOverflow.visible,
//               maxLines: null,
//             ),

//             SizedBox(height: R.size(context, 4)),

//             Container(
//               height: R.size(context, 1),
//               width: double.infinity,
//               color: colorScheme.onSurface.withValues(alpha: 0.13),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _MessageContent extends StatelessWidget {
//   final RoomChatMessageModel message;
//   final ColorScheme colorScheme;
//   final Color textColor;
//   final VoidCallback? onImageTap;
//   final VoidCallback? onVoicePlay;
//   final bool alignEnd;

//   const _MessageContent({
//     required this.message,
//     required this.colorScheme,
//     required this.textColor,
//     required this.onImageTap,
//     required this.onVoicePlay,
//     required this.alignEnd,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (message.type == RoomChatMessageType.image &&
//         message.localPath != null &&
//         message.localPath!.trim().isNotEmpty) {
//       return GestureDetector(
//         onTap: onImageTap,
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(R.size(context, 12)),
//           child:_ChatImage(
//   path: message.localPath!,
//   width: MediaQuery.sizeOf(context).width * 0.62,
//   height: R.size(context, 220),
// ),
//         ),
//       );
//     }

//     if (message.type == RoomChatMessageType.voice) {
//       return InkWell(
//         onTap: onVoicePlay,
//         borderRadius: BorderRadius.circular(R.size(context, 16)),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: alignEnd
//               ? MainAxisAlignment.end
//               : MainAxisAlignment.start,
//           children: [
//             Icon(
//               Icons.play_circle_fill_rounded,
//               size: R.size(context, 30),
//               color: const Color(0xFF087887),
//             ),
//             SizedBox(width: R.size(context, 7)),
//             Flexible(
//               child: Text(
//                 'Voice message',
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   color: textColor,
//                   fontSize: R.sp(context, 17),
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//             if (message.duration != null &&
//                 message.duration!.trim().isNotEmpty) ...[
//               SizedBox(width: R.size(context, 7)),
//               Text(
//                 message.duration!,
//                 style: TextStyle(
//                   fontSize: R.sp(context, 13),
//                   color: colorScheme.onSurfaceVariant,
//                 ),
//               ),
//             ],
//           ],
//         ),
//       );
//     }
// return _LinkedMessageText(
//   text: cleanVisibleText(message.text),
//   textColor: textColor,
//   alignEnd: alignEnd,
// );
//   }
// }
// class _LinkedMessageText extends StatelessWidget {
//   final String text;
//   final Color textColor;
//   final bool alignEnd;

//   const _LinkedMessageText({
//     required this.text,
//     required this.textColor,
//     required this.alignEnd,
//   });

//   static final RegExp _urlRegex = RegExp(
//     r'((https?:\/\/)?(www\.)?[a-zA-Z0-9\-]+(\.[a-zA-Z]{2,})([^\s]*)?)',
//     caseSensitive: false,
//   );

//   bool _looksLikeUrl(String value) {
//     final text = value.trim().toLowerCase();

//     if (text.isEmpty) return false;

//     return text.startsWith('http://') ||
//         text.startsWith('https://') ||
//         text.startsWith('www.') ||
//         RegExp(r'^[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}([\/?#][^\s]*)?$')
//             .hasMatch(text);
//   }

//   String _normalizeUrl(String value) {
//     final url = value.trim();

//     if (url.startsWith('http://') || url.startsWith('https://')) {
//       return url;
//     }

//     return 'https://$url';
//   }

//   Future<void> _openUrl(BuildContext context, String rawUrl) async {
//     final finalUrl = _normalizeUrl(rawUrl);
//     final uri = Uri.tryParse(finalUrl);

//     if (uri == null) return;

//     try {
//       await launchUrl(
//         uri,
//         mode: LaunchMode.externalApplication,
//       );
//     } catch (_) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Could not open link'),
//         ),
//       );
//     }
//   }

//   List<InlineSpan> _buildSpans(BuildContext context, TextStyle normalStyle) {
//     final spans = <InlineSpan>[];
//     int currentIndex = 0;

//     final matches = _urlRegex.allMatches(text).toList();

//     for (final match in matches) {
//       final value = match.group(0) ?? '';

//       if (!_looksLikeUrl(value)) {
//         continue;
//       }

//       if (match.start > currentIndex) {
//         spans.add(
//           TextSpan(
//             text: text.substring(currentIndex, match.start),
//             style: normalStyle,
//           ),
//         );
//       }

//       spans.add(
//         WidgetSpan(
//           alignment: PlaceholderAlignment.baseline,
//           baseline: TextBaseline.alphabetic,
//           child: InkWell(
//             onTap: () => _openUrl(context, value),
//             child: Text(
//               value,
//               style: normalStyle.copyWith(
//                 color: const Color(0xFF087887),
//                 fontWeight: FontWeight.w800,
//                 decoration: TextDecoration.underline,
//                 decorationColor: const Color(0xFF087887),
//               ),
//             ),
//           ),
//         ),
//       );

//       currentIndex = match.end;
//     }

//     if (currentIndex < text.length) {
//       spans.add(
//         TextSpan(
//           text: text.substring(currentIndex),
//           style: normalStyle,
//         ),
//       );
//     }

//     if (spans.isEmpty) {
//       spans.add(
//         TextSpan(
//           text: text,
//           style: normalStyle,
//         ),
//       );
//     }

//     return spans;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final normalStyle = TextStyle(
//       color: textColor,
//       fontSize: R.sp(context, 25),
//       height: 1.35,
//       fontFamily: null,
//       fontFamilyFallback: const [
//         'Roboto',
//         'Noto Sans',
//         'Noto Sans Symbols',
//         'Noto Sans Symbols 2',
//         'Noto Color Emoji',
//         'Segoe UI Emoji',
//       ],
//     );

//     return RichText(
//       textAlign: alignEnd ? TextAlign.end : TextAlign.start,
//       softWrap: true,
//       text: TextSpan(
//         children: _buildSpans(context, normalStyle),
//       ),
//     );
//   }
// }
// class _ChatImage extends StatelessWidget {
//   final String path;
//   final double width;
//   final double height;

//   const _ChatImage({
//     required this.path,
//     required this.width,
//     required this.height,
//   });

//   bool get isNetwork {
//     final value = path.trim().toLowerCase();
//     return value.startsWith('http://') || value.startsWith('https://');
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isNetwork) {
//        return Image.network(
//   path,
//   width: width,
//   height: height,
//   fit: BoxFit.cover,
//   gaplessPlayback: true,
//   filterQuality: FilterQuality.medium,
//   loadingBuilder: (context, child, progress) {
//     if (progress == null) return child;

//     return SizedBox(
//       width: width,
//       height: height,
//       child: const Center(
//         child: CircularProgressIndicator(strokeWidth: 2),
//       ),
//     );
//   },
//   errorBuilder: (_, __, ___) {
//     return _ImageErrorBox(width: width, height: height);
//   },
// );
//     }

//     return Image.file(
//       File(path),
//       width: width,
//       height: height,
//       fit: BoxFit.cover,
//       errorBuilder: (_, __, ___) {
//         return _ImageErrorBox(width: width, height: height);
//       },
//     );
//   }
// }

// class _ImageErrorBox extends StatelessWidget {
//   final double width;
//   final double height;

//   const _ImageErrorBox({required this.width, required this.height});

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return Container(
//       width: width,
//       height: height,
//       alignment: Alignment.center,
//       color: colorScheme.surfaceContainerHighest,
//       child: Icon(
//         Icons.broken_image_rounded,
//         color: colorScheme.onSurfaceVariant,
//         size: R.size(context, 32),
//       ),
//     );
//   }
// }

// class _AvatarSide extends StatelessWidget {
//   final RoomChatMessageModel message;
//   final bool isMe;
//   final VoidCallback? onTap;
//   final VoidCallback? onLongPress;

//   const _AvatarSide({
//     required this.message,
//     this.isMe = false,
//     this.onTap,
//     this.onLongPress,
//   });

//   String roleStar() {
//     final role = message.sender.role;

//     if (role == RoomRole.owner) return '★';
//     if (role == RoomRole.admin) return '★';

//     return '';
//   }

//   Color roleStarColor() {
//     final role = message.sender.role;

//     if (role == RoomRole.owner) return Colors.red;
//     if (role == RoomRole.admin) return Colors.blue;

//     return Colors.transparent;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final star = roleStar();
//     final starColor = roleStarColor();

//     return SizedBox(
//       width: R.size(context, 78),
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           Align(
//             alignment: AlignmentDirectional.topCenter,
//             child: GestureDetector(
//               onTap: onTap,
//               onLongPress: onLongPress,
//               child: _AvatarWithFrame(message: message),
//             ),
//           ),
//           if (star.isNotEmpty)
//             PositionedDirectional(
//               top: R.size(context, -5),
//               end: R.size(context, -1),
//               child: IgnorePointer(
//                 child: Text(
//                   star,
//                   style: TextStyle(
//                     color: starColor,
//                     fontSize: R.sp(context, 15),
//                     height: 1,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class _AvatarWithFrame extends StatelessWidget {
//   final RoomChatMessageModel message;

//   const _AvatarWithFrame({required this.message});

//   bool get hasAvatar {
//     return message.sender.avatarUrl.trim().isNotEmpty;
//   }

//   bool get hasFrame {
//     final frame = message.sender.frame;
//     return frame != null && frame.trim().isNotEmpty;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     final frameColor = message.sender.frame == 'gold'
//         ? const Color(0xFFFFC107)
//         : message.sender.frame == 'blue'
//         ? const Color(0xFF3B82F6)
//         : message.sender.frame == 'purple'
//         ? const Color(0xFF7C3AED)
//         : colorScheme.error;

//     return Container(
//       padding: EdgeInsets.all(hasFrame ? R.size(context, 2.2) : 0),
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         border: hasFrame
//             ? Border.all(color: frameColor, width: R.size(context, 1.5))
//             : null,
//       ),
//       child: CircleAvatar(
//         radius: R.size(context, 36),
//         backgroundColor: colorScheme.primary.withValues(alpha: 0.95),
//         backgroundImage: hasAvatar
//             ? NetworkImage(message.sender.avatarUrl.trim())
//             : null,
//         onBackgroundImageError: hasAvatar
//             ? (_, __) {
//                 debugPrint('Avatar image failed: ${message.sender.avatarUrl}');
//               }
//             : null,
//         child: hasAvatar
//             ? null
//             : Text(
//                 message.sender.avatarText,
//                 style: TextStyle(
//                   color: colorScheme.onPrimary,
//                   fontSize: R.sp(context, 14),
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//       ),
//     );
//   }
// }

// class _SystemMessageBubble extends StatelessWidget {
//   final RoomChatMessageModel message;

//   const _SystemMessageBubble({
//     required this.message,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     final isJoin = message.text.contains('__JOIN__');
//     final isLeave = message.text.contains('__LEAVE__');

//     final text = message.text
//         .replaceAll('__JOIN__', '')
//         .replaceAll('__LEAVE__', '')
//         .trim();

//     return Padding(
//       padding: EdgeInsets.symmetric(
//         horizontal: R.size(context, 24),
//         vertical: R.size(context, 6),
//       ),
//       child: Center(
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               text,
//               style: TextStyle(
//                 color: colorScheme.onSurfaceVariant,
//                 fontSize: R.sp(context, 15),
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             if (isJoin || isLeave) ...[
//               SizedBox(width: R.size(context, 5)),
//               Icon(
//                 isJoin
//                     ? Icons.login_rounded
//                     : Icons.logout_rounded,
//                 size: R.size(context, 16),
//                 color: colorScheme.onSurfaceVariant,
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';

import 'package:bimo_chat/core/utils/helpers.dart';
import 'package:bimo_chat/features/rooms/data/room_chat_message_model.dart';
import 'package:bimo_chat/features/rooms/data/room_role.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../../core/utils/responsive.dart';

String cleanVisibleText(String input) {
  return input
      // Zero width / invisible chars
      .replaceAll(RegExp(r'[\u200B-\u200F\u202A-\u202E\u2060-\u206F]'), '')
      // Variation selectors
      .replaceAll(RegExp(r'[\uFE00-\uFE0F]'), '')
      // Combining diacritics
      .replaceAll(RegExp(r'[\u0300-\u036F]'), '')
      .replaceAll(RegExp(r'[\u1AB0-\u1AFF]'), '')
      .replaceAll(RegExp(r'[\u1DC0-\u1DFF]'), '')
      .replaceAll(RegExp(r'[\u20D0-\u20FF]'), '')
      .replaceAll(RegExp(r'[\uFE20-\uFE2F]'), '')
      // Khmer invisible marks
      .replaceAll(RegExp(r'[\u17B4-\u17B5]'), '')
      // Meetei / extra combining marks
      .replaceAll(RegExp(r'[\uAA7B-\uAA7D]'), '')
      .trim();
}

class RoomMessageBubble extends StatelessWidget {
  final RoomChatMessageModel message;
  final VoidCallback? onImageTap;
  final VoidCallback? onVoicePlay;
  final VoidCallback? onNameLongPress;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onAvatarLongPress;

  const RoomMessageBubble({
    super.key,
    required this.message,
    this.onImageTap,
    this.onVoicePlay,
    this.onNameLongPress,
    this.onAvatarTap,
    this.onAvatarLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (message.type == RoomChatMessageType.system) {
      return _SystemMessageBubble(message: message);
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final isMe = message.isMe;
    final maxBubbleWidth = MediaQuery.sizeOf(context).width * 0.76;

    final bubbleColor = isMe
        ? Colors.white
        : isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.82)
            : Colors.white;

    final bubbleBorderColor = isDark
        ? colorScheme.outlineVariant.withValues(alpha: 0.35)
        : colorScheme.outlineVariant.withValues(alpha: 0.18);

    final bubbleTextColor = isMe
        ? Colors.black87
        : colorScheme.onSurface.withValues(alpha: 0.92);

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        R.size(context, 8),
        R.size(context, 5),
        R.size(context, 8),
        R.size(context, 5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            _AvatarSide(
              message: message,
              onTap: onAvatarTap,
              onLongPress: onAvatarLongPress,
            ),
            SizedBox(width: R.size(context, 6)),
          ],
          Flexible(
            child: IntrinsicWidth(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: R.size(context, 78),
                  maxWidth: maxBubbleWidth,
                ),
                child: Container(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    R.size(context, 12),
                    R.size(context, 8),
                    R.size(context, 12),
                    R.size(context, 9),
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    border: Border.all(
                      color: bubbleBorderColor,
                      width: isDark ? 0.8 : 0.6,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.14 : 0.035,
                        ),
                        blurRadius: isDark ? 6 : 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    borderRadius: BorderRadiusDirectional.only(
                      topStart: Radius.circular(
                        isMe ? R.size(context, 15) : R.size(context, 4),
                      ),
                      topEnd: Radius.circular(
                        isMe ? R.size(context, 4) : R.size(context, 15),
                      ),
                      bottomStart: Radius.circular(R.size(context, 15)),
                      bottomEnd: Radius.circular(R.size(context, 15)),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      _SenderNameInside(
                        message: message,
                        colorScheme: colorScheme,
                        onLongPress: onNameLongPress,
                        alignEnd: isMe,
                      ),
                      SizedBox(height: R.size(context, 5)),
                      _MessageContent(
                        message: message,
                        colorScheme: colorScheme,
                        textColor: bubbleTextColor,
                        onImageTap: onImageTap,
                        onVoicePlay: onVoicePlay,
                        alignEnd: isMe,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isMe) ...[
            SizedBox(width: R.size(context, 6)),
            _AvatarSide(
              message: message,
              isMe: true,
              onTap: onAvatarTap,
              onLongPress: onAvatarLongPress,
            ),
          ],
        ],
      ),
    );
  }
}

class _SenderNameInside extends StatelessWidget {
  final RoomChatMessageModel message;
  final ColorScheme colorScheme;
  final VoidCallback? onLongPress;
  final bool alignEnd;

  const _SenderNameInside({
    required this.message,
    required this.colorScheme,
    required this.onLongPress,
    required this.alignEnd,
  });

  bool get hasBadge {
    final badge = message.sender.badge;
    return badge != null && badge.trim().isNotEmpty;
  }

  String roleStar() {
    final role = message.sender.role;

    if (role == RoomRole.owner) return '★';
    if (role == RoomRole.admin) return '★';

    return '';
  }

  Color roleStarColor() {
    final role = message.sender.role;

    if (role == RoomRole.owner) return Colors.red;
    if (role == RoomRole.admin) return Colors.blue;

    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final fallbackNameColor = colorScheme.onSurface.withValues(alpha: 0.92);
    final star = roleStar();
    final starColor = roleStarColor();
    final badge = hasBadge ? message.sender.badge!.trim() : '';

    final nameStyle = TextStyle(
      color: message.sender.nameColor ?? fallbackNameColor,
      fontSize: R.sp(context, 21),
      fontWeight: FontWeight.w700,
      height: 1.08,
      letterSpacing: -0.2,
      fontFamily: null,
      fontFamilyFallback: const [
        'Roboto',
        'Noto Sans',
        'Noto Sans Symbols',
        'Noto Sans Symbols 2',
        'Noto Color Emoji',
        'Segoe UI Emoji',
      ],
    );

    return Align(
      alignment:
          alignEnd ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
         Padding(
  padding: EdgeInsets.only(
    top: R.size(context, 4),
    bottom: R.size(context, 6),
  ),
  child: SelectableText.rich(
    TextSpan(
      children: [
        TextSpan(
          text: cleanVisibleText(message.sender.name),
          style: nameStyle,
        ),
                if (badge.isNotEmpty)
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: R.size(context, 5),
                      ),
                      child: Text(
                        badge,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          fontSize: R.sp(context, 15),
                          height: 1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                if (star.isNotEmpty)
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: R.size(context, 5),
                      ),
                      child: Text(
                        star,
                        style: TextStyle(
                          color: starColor,
                          fontSize: R.sp(context, 15),
                          height: 1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            textAlign: alignEnd ? TextAlign.end : TextAlign.start,
            maxLines: null,
              ),

          ),
          SizedBox(height: R.size(context, 4)),
          Container(
            height: R.size(context, 1),
            width: double.infinity,
            color: colorScheme.onSurface.withValues(alpha: 0.13),
          ),
        ],
      ),
    );
  }
}

class _MessageContent extends StatelessWidget {
  final RoomChatMessageModel message;
  final ColorScheme colorScheme;
  final Color textColor;
  final VoidCallback? onImageTap;
  final VoidCallback? onVoicePlay;
  final bool alignEnd;

  const _MessageContent({
    required this.message,
    required this.colorScheme,
    required this.textColor,
    required this.onImageTap,
    required this.onVoicePlay,
    required this.alignEnd,
  });

  @override
  Widget build(BuildContext context) {
    if (message.type == RoomChatMessageType.image &&
        message.localPath != null &&
        message.localPath!.trim().isNotEmpty) {
      return GestureDetector(
        onTap: onImageTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(R.size(context, 12)),
          child: _ChatImage(
            path: message.localPath!,
            width: MediaQuery.sizeOf(context).width * 0.62,
            height: R.size(context, 220),
          ),
        ),
      );
    }

    if (message.type == RoomChatMessageType.voice) {
      return InkWell(
        onTap: onVoicePlay,
        borderRadius: BorderRadius.circular(R.size(context, 16)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment:
              alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Icon(
              Icons.play_circle_fill_rounded,
              size: R.size(context, 30),
              color: const Color(0xFF087887),
            ),
            SizedBox(width: R.size(context, 7)),
            Flexible(
              child: Text(
                'Voice message',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: R.sp(context, 17),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (message.duration != null &&
                message.duration!.trim().isNotEmpty) ...[
              SizedBox(width: R.size(context, 7)),
              Text(
                message.duration!,
                style: TextStyle(
                  fontSize: R.sp(context, 13),
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return _SelectableLinkedMessageText(
      text: cleanVisibleText(message.text),
      textColor: textColor,
      alignEnd: alignEnd,
    );
  }
}

class _SelectableLinkedMessageText extends StatelessWidget {
  final String text;
  final Color textColor;
  final bool alignEnd;

  const _SelectableLinkedMessageText({
    required this.text,
    required this.textColor,
    required this.alignEnd,
  });

  static final RegExp _urlRegex = RegExp(
    r'((https?:\/\/)?(www\.)?[a-zA-Z0-9\-]+(\.[a-zA-Z]{2,})([^\s]*)?)',
    caseSensitive: false,
  );

  bool _looksLikeUrl(String value) {
    final currentText = value.trim().toLowerCase();

    if (currentText.isEmpty) return false;

    return currentText.startsWith('http://') ||
        currentText.startsWith('https://') ||
        currentText.startsWith('www.') ||
        RegExp(r'^[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}([\/?#][^\s]*)?$')
            .hasMatch(currentText);
  }

String _cleanRawUrl(String value) {
  var url = value.trim();

  // إزالة رموز قد تأتي بعد الرابط داخل الرسالة
  url = url.replaceAll(RegExp(r'^[<({\[]+'), '');
  url = url.replaceAll(RegExp(r'[>)}\].,،؛:!؟]+$'), '');

  // إزالة مسافات أو أسطر غير ظاهرة
  url = url.replaceAll('\n', '');
  url = url.replaceAll('\r', '');
  url = url.replaceAll('\t', '');

  return url.trim();
}

String _normalizeUrl(String value) {
  final url = _cleanRawUrl(value);

  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url;
  }

  if (url.startsWith('www.')) {
    return 'https://$url';
  }

  return 'https://$url';
}

Future<void> _openUrl(BuildContext context, String rawUrl) async {
  final finalUrl = _normalizeUrl(rawUrl);

  final uri = Uri.tryParse(finalUrl);

  if (uri == null || uri.scheme.isEmpty || uri.host.isEmpty) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invalid URL: $finalUrl'),
      ),
    );
    return;
  }

  try {
    bool opened = false;

    opened = await launchUrlString(
      finalUrl,
      mode: LaunchMode.externalApplication,
    );

    if (!opened) {
      opened = await launchUrlString(
        finalUrl,
        mode: LaunchMode.platformDefault,
      );
    }

    if (!opened) {
      opened = await launchUrlString(
        finalUrl,
        mode: LaunchMode.inAppBrowserView,
      );
    }

    if (opened) return;

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cannot open URL: $finalUrl'),
      ),
    );
  } catch (error) {
    debugPrint('[OPEN_LINK_ERROR] $error');
    debugPrint('[OPEN_LINK_URL] $finalUrl');

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cannot open URL: $finalUrl'),
      ),
    );
  }
}
  List<InlineSpan> _buildSpans(
    BuildContext context,
    TextStyle normalStyle,
    TextStyle linkStyle,
  ) {
    final spans = <InlineSpan>[];
    int currentIndex = 0;

    final matches = _urlRegex.allMatches(text).toList();

    for (final match in matches) {
final value = _cleanRawUrl(match.group(0) ?? '');
      if (!_looksLikeUrl(value)) {
        continue;
      }

      if (match.start > currentIndex) {
        spans.add(
          TextSpan(
            text: text.substring(currentIndex, match.start),
            style: normalStyle,
          ),
        );
      }

      spans.add(
        TextSpan(
          text: value,
          style: linkStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              _openUrl(context, value);
            },
        ),
      );

      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(currentIndex),
          style: normalStyle,
        ),
      );
    }

    if (spans.isEmpty) {
      spans.add(
        TextSpan(
          text: text,
          style: normalStyle,
        ),
      );
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final normalStyle = TextStyle(
      color: textColor,
      fontSize: R.sp(context, 25),
      height: 1.35,
      fontFamily: null,
      fontFamilyFallback: const [
        'Roboto',
        'Noto Sans',
        'Noto Sans Symbols',
        'Noto Sans Symbols 2',
        'Noto Color Emoji',
        'Segoe UI Emoji',
      ],
    );

    final linkStyle = normalStyle.copyWith(
      color: const Color(0xFF087887),
      fontWeight: FontWeight.w800,
      decoration: TextDecoration.underline,
      decorationColor: const Color(0xFF087887),
    );

    return SelectableText.rich(
      TextSpan(
        children: _buildSpans(
          context,
          normalStyle,
          linkStyle,
        ),
      ),
      textAlign: alignEnd ? TextAlign.end : TextAlign.start,
      maxLines: null,
    );
  }
}

class _ChatImage extends StatelessWidget {
  final String path;
  final double width;
  final double height;

  const _ChatImage({
    required this.path,
    required this.width,
    required this.height,
  });

  bool get isNetwork {
    final value = path.trim().toLowerCase();
    return value.startsWith('http://') || value.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    if (isNetwork) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;

          return SizedBox(
            width: width,
            height: height,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (_, __, ___) {
          return _ImageErrorBox(width: width, height: height);
        },
      );
    }

    return Image.file(
      File(path),
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return _ImageErrorBox(width: width, height: height);
      },
    );
  }
}

class _ImageErrorBox extends StatelessWidget {
  final double width;
  final double height;

  const _ImageErrorBox({
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.broken_image_rounded,
        color: colorScheme.onSurfaceVariant,
        size: R.size(context, 32),
      ),
    );
  }
}

class _AvatarSide extends StatelessWidget {
  final RoomChatMessageModel message;
  final bool isMe;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _AvatarSide({
    required this.message,
    this.isMe = false,
    this.onTap,
    this.onLongPress,
  });

  String roleStar() {
    final role = message.sender.role;

    if (role == RoomRole.owner) return '★';
    if (role == RoomRole.admin) return '★';

    return '';
  }

  Color roleStarColor() {
    final role = message.sender.role;

    if (role == RoomRole.owner) return Colors.red;
    if (role == RoomRole.admin) return Colors.blue;

    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final star = roleStar();
    final starColor = roleStarColor();

    return SizedBox(
      width: R.size(context, 78),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: AlignmentDirectional.topCenter,
            child: GestureDetector(
              onTap: onTap,
              onLongPress: onLongPress,
              child: _AvatarWithFrame(message: message),
            ),
          ),
          if (star.isNotEmpty)
            PositionedDirectional(
              top: R.size(context, -5),
              end: R.size(context, -1),
              child: IgnorePointer(
                child: Text(
                  star,
                  style: TextStyle(
                    color: starColor,
                    fontSize: R.sp(context, 15),
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AvatarWithFrame extends StatelessWidget {
  final RoomChatMessageModel message;

  const _AvatarWithFrame({
    required this.message,
  });

  bool get hasAvatar {
    return message.sender.avatarUrl.trim().isNotEmpty;
  }

  bool get hasFrame {
    final frame = message.sender.frame;
    return frame != null && frame.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final frameColor = message.sender.frame == 'gold'
        ? const Color(0xFFFFC107)
        : message.sender.frame == 'blue'
            ? const Color(0xFF3B82F6)
            : message.sender.frame == 'purple'
                ? const Color(0xFF7C3AED)
                : colorScheme.error;

    return Container(
      padding: EdgeInsets.all(hasFrame ? R.size(context, 2.2) : 0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: hasFrame
            ? Border.all(
                color: frameColor,
                width: R.size(context, 1.5),
              )
            : null,
      ),
      child: CircleAvatar(
        radius: R.size(context, 36),
        backgroundColor: colorScheme.primary.withValues(alpha: 0.95),
        backgroundImage:
            hasAvatar ? NetworkImage(message.sender.avatarUrl.trim()) : null,
        onBackgroundImageError: hasAvatar
            ? (_, __) {
                debugPrint('Avatar image failed: ${message.sender.avatarUrl}');
              }
            : null,
        child: hasAvatar
            ? null
            : Text(
                message.sender.avatarText,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: R.sp(context, 14),
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

class _SystemMessageBubble extends StatelessWidget {
  final RoomChatMessageModel message;

  const _SystemMessageBubble({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final isJoin = message.text.contains('__JOIN__');
    final isLeave = message.text.contains('__LEAVE__');

    final text = message.text
        .replaceAll('__JOIN__', '')
        .replaceAll('__LEAVE__', '')
        .trim();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: R.size(context, 24),
        vertical: R.size(context, 6),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText(
              text,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: R.sp(context, 15),
                fontWeight: FontWeight.w700,
              ),
            ),
            if (isJoin || isLeave) ...[
              SizedBox(width: R.size(context, 5)),
              Icon(
                isJoin ? Icons.login_rounded : Icons.logout_rounded,
                size: R.size(context, 16),
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }
}