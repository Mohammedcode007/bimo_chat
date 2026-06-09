import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';

class TweetComposer extends StatefulWidget {
  final void Function(String text) onPost;

  const TweetComposer({super.key, required this.onPost});

  @override
  State<TweetComposer> createState() => _TweetComposerState();
}

class _TweetComposerState extends State<TweetComposer> {
  final controller = TextEditingController();

  bool get canPost => controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void post() {
    final text = controller.text.trim();

    if (text.isEmpty) return;

    widget.onPost(text);
    controller.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          R.size(context, 16),
          R.size(context, 12),
          R.size(context, 16),
          R.size(context, 12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: canPost ? post : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.black.withValues(
                      alpha: 0.25,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text('Post'),
                ),
              ],
            ),

            SizedBox(height: R.size(context, 8)),

            TextField(
              controller: controller,
              autofocus: true,
              minLines: 4,
              maxLines: 8,
              style: TextStyle(
                color: Colors.black,
                fontSize: R.sp(context, 20),
                height: 1.35,
              ),
              decoration: InputDecoration(
                hintText: 'What is happening?!',
                hintStyle: TextStyle(
                  color: Colors.black.withValues(alpha: 0.35),
                  fontSize: R.sp(context, 20),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
