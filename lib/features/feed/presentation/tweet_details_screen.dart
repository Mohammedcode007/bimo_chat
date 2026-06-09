import 'package:flutter/material.dart';

import '../../../core/utils/responsive.dart';
import '../data/tweet_model.dart';
import 'widgets/mention_text.dart';
import 'widgets/tweet_actions_bar.dart';
import 'widgets/tweet_media_preview.dart';

class TweetDetailsScreen extends StatefulWidget {
  final TweetModel tweet;
  final void Function(TweetModel tweet) onTweetChanged;

  const TweetDetailsScreen({
    super.key,
    required this.tweet,
    required this.onTweetChanged,
  });

  @override
  State<TweetDetailsScreen> createState() => _TweetDetailsScreenState();
}

class _TweetDetailsScreenState extends State<TweetDetailsScreen> {
  late TweetModel tweet;
  final replyController = TextEditingController();

  bool get canReply => replyController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    tweet = widget.tweet;
    replyController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    replyController.dispose();
    super.dispose();
  }

  void addReply() {
    final text = replyController.text.trim();
    if (text.isEmpty) return;

    final reply = TweetReplyModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorName: 'Mohammed',
      username: 'mohammed',
      avatarUrl: '',
      text: text,
      time: 'now',
    );

    setState(() {
      tweet = tweet.copyWith(
        commentsCount: tweet.commentsCount + 1,
        replies: [reply, ...tweet.replies],
      );
      replyController.clear();
    });

    widget.onTweetChanged(tweet);
  }

  void toggleLike() {
    setState(() {
      tweet = tweet.copyWith(
        isLiked: !tweet.isLiked,
        likesCount: tweet.isLiked ? tweet.likesCount - 1 : tweet.likesCount + 1,
      );
    });

    widget.onTweetChanged(tweet);
  }

  void toggleRepost() {
    setState(() {
      tweet = tweet.copyWith(
        isReposted: !tweet.isReposted,
        repostsCount: tweet.isReposted
            ? tweet.repostsCount - 1
            : tweet.repostsCount + 1,
      );
    });

    widget.onTweetChanged(tweet);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.black,
        title: Text(
          'Post',
          style: TextStyle(
            color: Colors.black,
            fontSize: R.sp(context, 21),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _TweetDetailsMain(tweet: tweet),

                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    R.size(context, 16),
                    R.size(context, 8),
                    R.size(context, 16),
                    R.size(context, 8),
                  ),
                  child: TweetActionsBar(
                    tweet: tweet,
                    onCommentTap: () {},
                    onRepostTap: toggleRepost,
                    onLikeTap: toggleLike,
                    onShareTap: () {},
                  ),
                ),

                Divider(height: 1, color: Colors.black.withValues(alpha: 0.10)),

                ...tweet.replies.map((reply) {
                  return _ReplyTile(reply: reply);
                }),
              ],
            ),
          ),

          _ReplyInput(
            controller: replyController,
            canReply: canReply,
            onSend: addReply,
          ),
        ],
      ),
    );
  }
}

class _TweetDetailsMain extends StatelessWidget {
  final TweetModel tweet;

  const _TweetDetailsMain({required this.tweet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        R.size(context, 16),
        R.size(context, 12),
        R.size(context, 16),
        R.size(context, 10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: R.size(context, 25),
                backgroundColor: const Color(0xFFDDE7E8),
                child: tweet.avatarUrl.trim().isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          tweet.avatarUrl,
                          width: R.size(context, 50),
                          height: R.size(context, 50),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Text(
                        tweet.authorName[0].toUpperCase(),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: R.sp(context, 18),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),

              SizedBox(width: R.size(context, 12)),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tweet.authorName,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: R.sp(context, 17),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '@${tweet.username}',
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.50),
                        fontSize: R.sp(context, 15),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: R.size(context, 14)),

          MentionText(
            text: tweet.text,
            fontSize: 22,
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),

          TweetMediaPreview(tweet: tweet),

          SizedBox(height: R.size(context, 14)),

          Text(
            tweet.time,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.55),
              fontSize: R.sp(context, 15),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplyTile extends StatelessWidget {
  final TweetReplyModel reply;

  const _ReplyTile({required this.reply});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(
        R.size(context, 16),
        R.size(context, 12),
        R.size(context, 16),
        R.size(context, 12),
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withValues(alpha: 0.10),
            width: 0.7,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: R.size(context, 22),
            backgroundColor: const Color(0xFFDDE7E8),
            child: Text(
              reply.authorName[0].toUpperCase(),
              style: TextStyle(
                color: Colors.black,
                fontSize: R.sp(context, 16),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          SizedBox(width: R.size(context, 11)),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      reply.authorName,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: R.sp(context, 16),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: R.size(context, 5)),
                    Text(
                      '@${reply.username} · ${reply.time}',
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.50),
                        fontSize: R.sp(context, 14.5),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: R.size(context, 4)),

                MentionText(
                  text: reply.text,
                  fontSize: 17,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplyInput extends StatelessWidget {
  final TextEditingController controller;
  final bool canReply;
  final VoidCallback onSend;

  const _ReplyInput({
    required this.controller,
    required this.canReply,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsetsDirectional.fromSTEB(
          R.size(context, 12),
          R.size(context, 8),
          R.size(context, 12),
          R.size(context, 8),
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(color: Colors.black.withValues(alpha: 0.10)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: R.sp(context, 18),
                ),
                decoration: const InputDecoration(
                  hintText: 'Post your reply',
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              onPressed: canReply ? onSend : null,
              icon: Icon(
                Icons.send_rounded,
                color: canReply
                    ? const Color(0xFF1D9BF0)
                    : Colors.black.withValues(alpha: 0.25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
