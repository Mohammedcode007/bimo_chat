// import 'package:flutter/material.dart';

// import '../../../../core/utils/responsive.dart';
// import '../../data/tweet_models.dart';
// import 'mention_text.dart';
// import 'tweet_actions_bar.dart';
// import 'tweet_media_preview.dart';

// class TweetCard extends StatelessWidget {
//   final TweetModel tweet;

//   final VoidCallback onTap;
//   final VoidCallback onCommentTap;
//   final VoidCallback onRetweetTap;
//   final VoidCallback onLikeTap;
//   final VoidCallback onDeleteTap;
//   final VoidCallback onShareTap;

//   const TweetCard({
//     super.key,
//     required this.tweet,
//     required this.onTap,
//     required this.onCommentTap,
//     required this.onRetweetTap,
//     required this.onLikeTap,
//     required this.onDeleteTap,
//     required this.onShareTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme =
//         Theme.of(context);

//     final colorScheme =
//         theme.colorScheme;

//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding:
//             EdgeInsetsDirectional.fromSTEB(
//           R.size(context, 14),
//           R.size(context, 11),
//           R.size(context, 12),
//           R.size(context, 10),
//         ),
//         decoration: BoxDecoration(
//           color:
//               theme.scaffoldBackgroundColor,
//           border: Border(
//             bottom: BorderSide(
//               color: colorScheme
//                   .outlineVariant
//                   .withValues(
//                 alpha: 0.45,
//               ),
//               width: 0.7,
//             ),
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment:
//               CrossAxisAlignment.start,
//           children: [
//             /*
//               عنوان إعادة النشر يظهر فوق التويتة.

//               تمت إضافة مسافة من البداية حتى يكون
//               العنوان بمحاذاة محتوى التويتة وليس الأفاتار.
//             */
//             if (tweet.retweetBy != null) ...[
//               Padding(
//                 padding:
//                     EdgeInsetsDirectional.only(
//                   start: R.size(
//                     context,
//                     59,
//                   ),
//                   bottom: R.size(
//                     context,
//                     7,
//                   ),
//                 ),
//                 child: _RetweetHeader(
//                   username:
//                       tweet.retweetBy!.username,
//                 ),
//               ),
//             ],

//             Row(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,
//               children: [
//                 _Avatar(
//                   tweet: tweet,
//                 ),

//                 SizedBox(
//                   width: R.size(
//                     context,
//                     11,
//                   ),
//                 ),

//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment:
//                         CrossAxisAlignment.start,
//                     children: [
//                       /*
//                         الاسم يبدأ مباشرة من أعلى الأفاتار.
//                         لا يوجد Padding علوي هنا.
//                       */
//                       _TweetHeader(
//                         tweet: tweet,
//                         onDeleteTap:
//                             onDeleteTap,
//                       ),

//                       if (tweet.text
//                           .trim()
//                           .isNotEmpty) ...[
//                         SizedBox(
//                           height: R.size(
//                             context,
//                             6,
//                           ),
//                         ),

//                         MentionText(
//                           text:
//                               tweet.text,
//                           fontSize: 18,
//                           color:
//                               colorScheme.onSurface,
//                           fontWeight:
//                               FontWeight.w400,
//                         ),
//                       ],

//                       TweetMediaPreview(
//                         tweet: tweet,
//                       ),

//                       TweetActionsBar(
//                         tweet: tweet,
//                         onCommentTap:
//                             onCommentTap,
//                         onRetweetTap:
//                             onRetweetTap,
//                         onLikeTap:
//                             onLikeTap,
//                         onShareTap:
//                             onShareTap,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _Avatar extends StatelessWidget {
//   final TweetModel tweet;

//   const _Avatar({
//     required this.tweet,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme =
//         Theme.of(context).colorScheme;

//     final avatarUrl =
//         tweet.author?.photoUrl.trim() ??
//         '';

//     return CircleAvatar(
//       radius: R.size(
//         context,
//         24,
//       ),
//       backgroundColor:
//           colorScheme
//               .surfaceContainerHighest,
//       child: avatarUrl.isNotEmpty
//           ? ClipOval(
//               child: Image.network(
//                 avatarUrl,
//                 width: R.size(
//                   context,
//                   48,
//                 ),
//                 height: R.size(
//                   context,
//                   48,
//                 ),
//                 fit: BoxFit.cover,
//                 errorBuilder: (
//                   context,
//                   error,
//                   stackTrace,
//                 ) {
//                   return _AvatarFallback(
//                     tweet: tweet,
//                   );
//                 },
//               ),
//             )
//           : _AvatarFallback(
//               tweet: tweet,
//             ),
//     );
//   }
// }

// class _AvatarFallback
//     extends StatelessWidget {
//   final TweetModel tweet;

//   const _AvatarFallback({
//     required this.tweet,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme =
//         Theme.of(context).colorScheme;

//     final username =
//         tweet.author?.username.trim() ??
//         '';

//     final firstCharacter =
//         username.isNotEmpty
//             ? username.characters
//                 .first
//                 .toUpperCase()
//             : '?';

//     return Text(
//       firstCharacter,
//       style: TextStyle(
//         color: colorScheme.onSurface
//             .withValues(
//           alpha: 0.75,
//         ),
//         fontSize:
//             R.sp(context, 18),
//         fontWeight:
//             FontWeight.w900,
//       ),
//     );
//   }
// }

// class _TweetHeader extends StatelessWidget {
//   final TweetModel tweet;
//   final VoidCallback onDeleteTap;

//   const _TweetHeader({
//     required this.tweet,
//     required this.onDeleteTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     final username = tweet.author?.username.trim() ?? '';

//     final time = _formatTweetTime(
//       tweet.createdAt,
//     );

//     return SizedBox(
//       height: R.size(context, 30),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           /*
//             هذا الجزء يأخذ كل المساحة المتاحة،
//             بدون تحديد عرض ثابت للاسم.
//           */
//           Expanded(
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 /*
//                   الاسم يأخذ أكبر مساحة ممكنة،
//                   وعند امتلاء السطر يظهر ...
//                 */
//                 Flexible(
//                   child: Text(
//                     username.isEmpty
//                         ? 'Unknown user'
//                         : username,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       color: colorScheme.onSurface,
//                       fontSize: R.sp(context, 20),
//                       fontWeight: FontWeight.w700,
//                       height: 1,
//                     ),
//                   ),
//                 ),

//                 if (_isVerified(tweet)) ...[
//                   SizedBox(
//                     width: R.size(context, 4),
//                   ),
//                   Icon(
//                     Icons.verified_rounded,
//                     size: R.size(context, 16),
//                     color: const Color(0xFF1D9BF0),
//                   ),
//                 ],

//                 if (time.isNotEmpty) ...[
//                   SizedBox(
//                     width: R.size(context, 6),
//                   ),
//                   Text(
//                     '·',
//                     style: TextStyle(
//                       color: colorScheme.onSurfaceVariant,
//                       fontSize: R.sp(context, 15),
//                       height: 1,
//                     ),
//                   ),
//                   SizedBox(
//                     width: R.size(context, 6),
//                   ),
//                   Text(
//                     time,
//                     maxLines: 1,
//                     style: TextStyle(
//                       color: colorScheme.onSurfaceVariant,
//                       fontSize: R.sp(context, 14),
//                       fontWeight: FontWeight.w400,
//                       height: 1,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),

//           /*
//             أيقونة الثلاث نقاط خارج Expanded،
//             لذلك تظل دائمًا في أقصى نهاية السطر.
//           */
//           SizedBox(
//             width: R.size(context, 30),
//             height: R.size(context, 30),
//             child: PopupMenuButton<String>(
//               padding: EdgeInsets.zero,
//               constraints: const BoxConstraints(),
//               color: colorScheme.surface,
//               tooltip: '',
//               position: PopupMenuPosition.under,
//               icon: Icon(
//                 Icons.more_horiz_rounded,
//                 size: R.size(context, 21),
//                 color: colorScheme.onSurfaceVariant,
//               ),
//               onSelected: (value) {
//                 if (value == 'delete') {
//                   onDeleteTap();
//                 }
//               },
//               itemBuilder: (context) {
//                 if (tweet.canDelete) {
//                   return const [
//                     PopupMenuItem<String>(
//                       value: 'delete',
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.delete_outline_rounded,
//                             color: Colors.red,
//                           ),
//                           SizedBox(width: 10),
//                           Text(
//                             'Delete Tweet',
//                             style: TextStyle(
//                               color: Colors.red,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ];
//                 }

//                 return const [
//                   PopupMenuItem<String>(
//                     value: 'report',
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.flag_outlined,
//                         ),
//                         SizedBox(width: 10),
//                         Text('Report'),
//                       ],
//                     ),
//                   ),
//                 ];
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   bool _isVerified(TweetModel tweet) {
//     final verificationType =
//         tweet.author?.verificationType.trim().toLowerCase() ?? '';

//     return verificationType.isNotEmpty &&
//         verificationType != 'none' &&
//         verificationType != 'false' &&
//         verificationType != '0';
//   }
// }
// class _RetweetHeader
//     extends StatelessWidget {
//   final String username;

//   const _RetweetHeader({
//     required this.username,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme =
//         Theme.of(context).colorScheme;

//     final cleanUsername =
//         username.trim();

//     return Row(
//       mainAxisSize:
//           MainAxisSize.min,
//       children: [
//         Icon(
//           Icons.repeat_rounded,
//           size: R.size(
//             context,
//             16,
//           ),
//           color: const Color(
//             0xFF00BA7C,
//           ),
//         ),

//         SizedBox(
//           width: R.size(
//             context,
//             5,
//           ),
//         ),

//         Flexible(
//           child: Text(
//             cleanUsername.isEmpty
//                 ? 'Reposted'
//                 : '$cleanUsername reposted',
//             maxLines: 1,
//             overflow:
//                 TextOverflow.ellipsis,
//             style: TextStyle(
//               color: colorScheme
//                   .onSurfaceVariant,
//               fontSize:
//                   R.sp(context, 13),
//               fontWeight:
//                   FontWeight.w700,
//               height: 1,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// String _formatTweetTime(
//   DateTime? createdAt,
// ) {
//   if (createdAt == null) {
//     return '';
//   }

//   final now =
//       DateTime.now();

//   final localCreatedAt =
//       createdAt.toLocal();

//   final difference =
//       now.difference(
//     localCreatedAt,
//   );

//   if (difference.isNegative ||
//       difference.inSeconds < 60) {
//     return 'now';
//   }

//   if (difference.inMinutes < 60) {
//     return '${difference.inMinutes}m';
//   }

//   if (difference.inHours < 24) {
//     return '${difference.inHours}h';
//   }

//   if (difference.inDays < 7) {
//     return '${difference.inDays}d';
//   }

//   final day =
//       localCreatedAt.day
//           .toString()
//           .padLeft(
//             2,
//             '0',
//           );

//   final month =
//       localCreatedAt.month
//           .toString()
//           .padLeft(
//             2,
//             '0',
//           );

//   if (localCreatedAt.year ==
//       now.year) {
//     return '$day/$month';
//   }

//   return '$day/$month/${localCreatedAt.year}';
// }
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';

import '../../../users/presentation/public_profile_screen.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/tweet_models.dart';
import 'mention_text.dart';
import 'tweet_actions_bar.dart';
import 'tweet_media_preview.dart';

class TweetCard extends StatelessWidget {
  final TweetModel tweet;

  final VoidCallback onTap;
  final VoidCallback onCommentTap;
  final VoidCallback onRetweetTap;
  final VoidCallback onLikeTap;
  final VoidCallback onDeleteTap;
  final VoidCallback onShareTap;

  const TweetCard({
    super.key,
    required this.tweet,
    required this.onTap,
    required this.onCommentTap,
    required this.onRetweetTap,
    required this.onLikeTap,
    required this.onDeleteTap,
    required this.onShareTap,
  });

  void openAuthorProfile(BuildContext context) {
    final userId = tweet.author?.userId.trim() ?? '';

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User profile not available'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublicProfileScreen(
          userId: userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsetsDirectional.fromSTEB(
          R.size(context, 14),
          R.size(context, 11),
          R.size(context, 12),
          R.size(context, 10),
        ),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.45),
              width: 0.7,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tweet.retweetBy != null) ...[
              Padding(
                padding: EdgeInsetsDirectional.only(
                  start: R.size(context, 59),
                  bottom: R.size(context, 7),
                ),
                child: _RetweetHeader(
                  username: tweet.retweetBy!.username,
                ),
              ),
            ],

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(
                  tweet: tweet,
                  onTap: () => openAuthorProfile(context),
                ),

                SizedBox(
                  width: R.size(context, 11),
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TweetHeader(
                        tweet: tweet,
                        onDeleteTap: onDeleteTap,
                        onAuthorTap: () => openAuthorProfile(context),
                      ),

                      if (tweet.text.trim().isNotEmpty) ...[
                        SizedBox(
                          height: R.size(context, 6),
                        ),

                        // لا يتم تغيير المنشن
                        MentionText(
                          text: tweet.text,
                          fontSize: 18,
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w400,
                        ),
                      ],

                      TweetMediaPreview(
                        tweet: tweet,
                      ),

                      _TweetLinkPreview(
                        text: tweet.text,
                      ),

                      TweetActionsBar(
                        tweet: tweet,
                        onCommentTap: onCommentTap,
                        onRetweetTap: onRetweetTap,
                        onLikeTap: onLikeTap,
                        onShareTap: onShareTap,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final TweetModel tweet;
  final VoidCallback onTap;

  const _Avatar({
    required this.tweet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final avatarUrl = tweet.author?.photoUrl.trim() ?? '';

    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: R.size(context, 24),
        backgroundColor: colorScheme.surfaceContainerHighest,
        child: avatarUrl.isNotEmpty
            ? ClipOval(
                child: Image.network(
                  avatarUrl,
                  width: R.size(context, 48),
                  height: R.size(context, 48),
                  fit: BoxFit.cover,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return _AvatarFallback(
                      tweet: tweet,
                    );
                  },
                ),
              )
            : _AvatarFallback(
                tweet: tweet,
              ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final TweetModel tweet;

  const _AvatarFallback({
    required this.tweet,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final username = tweet.author?.username.trim() ?? '';

    final firstCharacter =
        username.isNotEmpty ? username.characters.first.toUpperCase() : '?';

    return Text(
      firstCharacter,
      style: TextStyle(
        color: colorScheme.onSurface.withValues(alpha: 0.75),
        fontSize: R.sp(context, 18),
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _TweetHeader extends StatelessWidget {
  final TweetModel tweet;
  final VoidCallback onDeleteTap;
  final VoidCallback onAuthorTap;

  const _TweetHeader({
    required this.tweet,
    required this.onDeleteTap,
    required this.onAuthorTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final username = tweet.author?.username.trim() ?? '';

    final time = _formatTweetTime(
      tweet.createdAt,
    );

    return SizedBox(
      height: R.size(context, 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: InkWell(
                    onTap: onAuthorTap,
                    borderRadius: BorderRadius.circular(
                      R.size(context, 8),
                    ),
                    child: Text(
                      username.isEmpty ? 'Unknown user' : username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: R.sp(context, 20),
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
                ),

                if (_isVerified(tweet)) ...[
                  SizedBox(
                    width: R.size(context, 4),
                  ),
                  Icon(
                    Icons.verified_rounded,
                    size: R.size(context, 16),
                    color: const Color(0xFF1D9BF0),
                  ),
                ],

                if (time.isNotEmpty) ...[
                  SizedBox(
                    width: R.size(context, 6),
                  ),
                  Text(
                    '·',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: R.sp(context, 15),
                      height: 1,
                    ),
                  ),
                  SizedBox(
                    width: R.size(context, 6),
                  ),
                  Text(
                    time,
                    maxLines: 1,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: R.sp(context, 14),
                      fontWeight: FontWeight.w400,
                      height: 1,
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(
            width: R.size(context, 30),
            height: R.size(context, 30),
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              color: colorScheme.surface,
              tooltip: '',
              position: PopupMenuPosition.under,
              icon: Icon(
                Icons.more_horiz_rounded,
                size: R.size(context, 21),
                color: colorScheme.onSurfaceVariant,
              ),
              onSelected: (value) {
                if (value == 'delete') {
                  onDeleteTap();
                }
              },
              itemBuilder: (context) {
                if (tweet.canDelete) {
                  return const [
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Delete Tweet',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ];
                }

                return const [
                  PopupMenuItem<String>(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(
                          Icons.flag_outlined,
                        ),
                        SizedBox(width: 10),
                        Text('Report'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isVerified(TweetModel tweet) {
    final verificationType =
        tweet.author?.verificationType.trim().toLowerCase() ?? '';

    return verificationType.isNotEmpty &&
        verificationType != 'none' &&
        verificationType != 'false' &&
        verificationType != '0';
  }
}

class _RetweetHeader extends StatelessWidget {
  final String username;

  const _RetweetHeader({
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final cleanUsername = username.trim();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.repeat_rounded,
          size: R.size(context, 16),
          color: const Color(0xFF00BA7C),
        ),

        SizedBox(
          width: R.size(context, 5),
        ),

        Flexible(
          child: Text(
            cleanUsername.isEmpty ? 'Reposted' : '$cleanUsername reposted',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: R.sp(context, 13),
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _TweetLinkPreview extends StatefulWidget {
  final String text;

  const _TweetLinkPreview({
    required this.text,
  });

  @override
  State<_TweetLinkPreview> createState() => _TweetLinkPreviewState();
}

class _TweetLinkPreviewState extends State<_TweetLinkPreview> {
  String? url;
  _LinkPreviewData? data;

  bool loading = false;
  bool failed = false;

  static final RegExp _urlRegex = RegExp(
    r'((https?:\/\/)?(www\.)?[a-zA-Z0-9\-]+(\.[a-zA-Z]{2,})([^\s]*)?)',
    caseSensitive: false,
  );

  @override
  void initState() {
    super.initState();

    url = _extractFirstUrl(widget.text);

    if (url != null) {
      _loadPreview(url!);
    }
  }

  @override
  void didUpdateWidget(covariant _TweetLinkPreview oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.text != widget.text) {
      final newUrl = _extractFirstUrl(widget.text);

      if (newUrl == url) return;

      setState(() {
        url = newUrl;
        data = null;
        loading = false;
        failed = false;
      });

      if (newUrl != null) {
        _loadPreview(newUrl);
      }
    }
  }

  String _cleanUrl(String value) {
    var url = value.trim();

    url = url.replaceAll(RegExp(r'^[<({\[]+'), '');
    url = url.replaceAll(RegExp(r'[>)}\].,،؛:!؟]+$'), '');

    return url.trim();
  }

  bool _looksLikeUrl(String value) {
    final url = _cleanUrl(value).toLowerCase();

    if (url.isEmpty) return false;

    return url.startsWith('http://') ||
        url.startsWith('https://') ||
        url.startsWith('www.') ||
        RegExp(
          r'^[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}([\/?#][^\s]*)?$',
        ).hasMatch(url);
  }

  String _normalizeUrl(String value) {
    final url = _cleanUrl(value);

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    return 'https://$url';
  }

  String? _extractFirstUrl(String text) {
    for (final match in _urlRegex.allMatches(text)) {
      final value = _cleanUrl(match.group(0) ?? '');

      if (_looksLikeUrl(value)) {
        return _normalizeUrl(value);
      }
    }

    return null;
  }

  Future<void> _openUrl(String rawUrl) async {
    final link = _normalizeUrl(rawUrl);

    try {
      bool opened = await launchUrlString(
        link,
        mode: LaunchMode.externalApplication,
      );

      if (opened) return;

      opened = await launchUrlString(
        link,
        mode: LaunchMode.platformDefault,
      );

      if (opened) return;
    } catch (error) {
      debugPrint('[TWEET_OPEN_LINK_ERROR] $error');
    }
  }

  Future<void> _loadPreview(String link) async {
    if (loading) return;

    setState(() {
      loading = true;
      failed = false;
    });

    try {
      final uri = Uri.parse(link);

      final response = await http
          .get(
            uri,
            headers: const {
              'User-Agent':
                  'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Chrome/120 Mobile Safari/537.36',
            },
          )
          .timeout(
            const Duration(seconds: 7),
          );

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw Exception('Invalid status code ${response.statusCode}');
      }

      final html = response.body;

      final title = _readMeta(html, 'og:title') ?? _readTitle(html) ?? uri.host;

      final description = _readMeta(html, 'og:description') ??
          _readMeta(html, 'description') ??
          '';

      String image = _readMeta(html, 'og:image') ?? '';

      if (image.isNotEmpty && image.startsWith('//')) {
        image = '${uri.scheme}:$image';
      } else if (image.isNotEmpty && image.startsWith('/')) {
        image = '${uri.scheme}://${uri.host}$image';
      }

      if (!mounted) return;

      setState(() {
        data = _LinkPreviewData(
          url: link,
          host: uri.host.replaceFirst('www.', ''),
          title: title.trim(),
          description: description.trim(),
          image: image.trim(),
        );

        loading = false;
      });
    } catch (error) {
      debugPrint('[TWEET_LINK_PREVIEW_ERROR] $error');

      if (!mounted) return;

      setState(() {
        failed = true;
        loading = false;
      });
    }
  }

  String? _readMeta(String html, String name) {
    final patterns = [
      RegExp(
        '<meta[^>]+property=["\\\']$name["\\\'][^>]+content=["\\\']([^"\\\']*)["\\\'][^>]*>',
        caseSensitive: false,
      ),
      RegExp(
        '<meta[^>]+name=["\\\']$name["\\\'][^>]+content=["\\\']([^"\\\']*)["\\\'][^>]*>',
        caseSensitive: false,
      ),
      RegExp(
        '<meta[^>]+content=["\\\']([^"\\\']*)["\\\'][^>]+property=["\\\']$name["\\\'][^>]*>',
        caseSensitive: false,
      ),
      RegExp(
        '<meta[^>]+content=["\\\']([^"\\\']*)["\\\'][^>]+name=["\\\']$name["\\\'][^>]*>',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(html);

      if (match != null) {
        return _decodeHtml(match.group(1) ?? '');
      }
    }

    return null;
  }

  String? _readTitle(String html) {
    final match = RegExp(
      r'<title[^>]*>(.*?)<\/title>',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(html);

    if (match == null) return null;

    return _decodeHtml(
      (match.group(1) ?? '').replaceAll(RegExp(r'\s+'), ' ').trim(),
    );
  }

  String _decodeHtml(String value) {
    return value
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return const SizedBox.shrink();
    }

    if (loading) {
      return Padding(
        padding: EdgeInsets.only(
          top: R.size(context, 10),
        ),
        child: _LinkPreviewLoadingBox(
          url: url!,
        ),
      );
    }

    if (failed || data == null) {
      return Padding(
        padding: EdgeInsets.only(
          top: R.size(context, 10),
        ),
        child: _SimpleLinkBox(
          url: url!,
          onTap: () => _openUrl(url!),
        ),
      );
    }

    final preview = data!;

    return Padding(
      padding: EdgeInsets.only(
        top: R.size(context, 10),
      ),
      child: InkWell(
        onTap: () => _openUrl(preview.url),
        borderRadius: BorderRadius.circular(
          R.size(context, 15),
        ),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              R.size(context, 15),
            ),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withValues(
                    alpha: 0.65,
                  ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (preview.image.isNotEmpty)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    preview.image,
                    fit: BoxFit.cover,
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return const SizedBox.shrink();
                    },
                  ),
                ),

              Padding(
                padding: EdgeInsets.all(
                  R.size(context, 11),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preview.host,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: R.sp(context, 13),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(
                      height: R.size(context, 4),
                    ),

                    Text(
                      preview.title.isEmpty ? preview.url : preview.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: R.sp(context, 15),
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    if (preview.description.isNotEmpty) ...[
                      SizedBox(
                        height: R.size(context, 4),
                      ),
                      Text(
                        preview.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: R.sp(context, 14),
                          height: 1.25,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SimpleLinkBox extends StatelessWidget {
  final String url;
  final VoidCallback onTap;

  const _SimpleLinkBox({
    required this.url,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(url);
    final host = uri?.host.replaceFirst('www.', '') ?? url;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        R.size(context, 15),
      ),
      child: Container(
        padding: EdgeInsets.all(
          R.size(context, 12),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            R.size(context, 15),
          ),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(
                  alpha: 0.65,
                ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.link_rounded,
              color: const Color(0xFF087887),
              size: R.size(context, 24),
            ),

            SizedBox(
              width: R.size(context, 9),
            ),

            Expanded(
              child: Text(
                host,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF087887),
                  fontSize: R.sp(context, 15),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkPreviewLoadingBox extends StatelessWidget {
  final String url;

  const _LinkPreviewLoadingBox({
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(url);
    final host = uri?.host.replaceFirst('www.', '') ?? url;

    return Container(
      padding: EdgeInsets.all(
        R.size(context, 12),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          R.size(context, 15),
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(
                alpha: 0.65,
              ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: R.size(context, 18),
            height: R.size(context, 18),
            child: const CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),

          SizedBox(
            width: R.size(context, 10),
          ),

          Expanded(
            child: Text(
              host,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: R.sp(context, 14),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkPreviewData {
  final String url;
  final String host;
  final String title;
  final String description;
  final String image;

  const _LinkPreviewData({
    required this.url,
    required this.host,
    required this.title,
    required this.description,
    required this.image,
  });
}

String _formatTweetTime(
  DateTime? createdAt,
) {
  if (createdAt == null) {
    return '';
  }

  final now = DateTime.now();

  final localCreatedAt = createdAt.toLocal();

  final difference = now.difference(
    localCreatedAt,
  );

  if (difference.isNegative || difference.inSeconds < 60) {
    return 'now';
  }

  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m';
  }

  if (difference.inHours < 24) {
    return '${difference.inHours}h';
  }

  if (difference.inDays < 7) {
    return '${difference.inDays}d';
  }

  final day = localCreatedAt.day.toString().padLeft(
        2,
        '0',
      );

  final month = localCreatedAt.month.toString().padLeft(
        2,
        '0',
      );

  if (localCreatedAt.year == now.year) {
    return '$day/$month';
  }

  return '$day/$month/${localCreatedAt.year}';
}