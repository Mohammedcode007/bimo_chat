import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';
import '../../data/tweet_models.dart';

class TweetReplySheet extends StatefulWidget {
  final TweetModel tweet;
  final void Function(String text) onReply;

  const TweetReplySheet({
    super.key,
    required this.tweet,
    required this.onReply,
  });

  @override
  State<TweetReplySheet> createState() =>
      _TweetReplySheetState();
}

class _TweetReplySheetState
    extends State<TweetReplySheet> {
  final TextEditingController controller =
      TextEditingController();

  bool get canReply =>
      controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();

    controller.addListener(
      _onTextChanged,
    );
  }

  void _onTextChanged() {
    if (!mounted) return;

    setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(
      _onTextChanged,
    );

    controller.dispose();

    super.dispose();
  }

  void sendReply() {
    final text =
        controller.text.trim();

    if (text.isEmpty) return;

    widget.onReply(text);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final username =
        widget.tweet.author?.username.trim() ??
        '';

    final replyingTo = username.isEmpty
        ? 'Replying to this tweet'
        : 'Replying to @$username';

    return SafeArea(
      child: Padding(
        padding:
            EdgeInsetsDirectional.fromSTEB(
          R.size(context, 16),
          R.size(context, 14),
          R.size(context, 16),
          R.size(context, 14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: R.size(context, 46),
              height: R.size(context, 5),
              margin: EdgeInsets.only(
                bottom: R.size(context, 12),
              ),
              decoration: BoxDecoration(
                color: colorScheme.onSurface
                    .withValues(
                  alpha: 0.25,
                ),
                borderRadius:
                    BorderRadius.circular(999),
              ),
            ),

            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                  ),
                ),

                const Spacer(),

                ElevatedButton(
                  onPressed:
                      canReply ? sendReply : null,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        colorScheme.onSurface,
                    foregroundColor:
                        colorScheme.surface,
                    disabledBackgroundColor:
                        colorScheme.onSurface
                            .withValues(
                      alpha: 0.25,
                    ),
                    disabledForegroundColor:
                        colorScheme.surface
                            .withValues(
                      alpha: 0.75,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        999,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Reply',
                  ),
                ),
              ],
            ),

            SizedBox(
              height: R.size(context, 8),
            ),

            Align(
              alignment:
                  AlignmentDirectional.centerStart,
              child: Text(
                replyingTo,
                style: TextStyle(
                  color:
                      const Color(0xFF1D9BF0),
                  fontSize:
                      R.sp(context, 14),
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ),

            SizedBox(
              height: R.size(context, 10),
            ),

            TextField(
              controller: controller,
              autofocus: true,
              minLines: 3,
              maxLines: 7,
              maxLength: 500,
              textInputAction:
                  TextInputAction.newline,
              style: TextStyle(
                fontSize:
                    R.sp(context, 18),
                height: 1.35,
              ),
              decoration:
                  const InputDecoration(
                hintText:
                    'Post your reply',
                border:
                    InputBorder.none,
                enabledBorder:
                    InputBorder.none,
                focusedBorder:
                    InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}