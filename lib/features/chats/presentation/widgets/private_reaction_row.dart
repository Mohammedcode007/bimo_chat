import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';

class PrivateReactionRow extends StatelessWidget {
  final ValueChanged<String> onSelected;

  const PrivateReactionRow({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const reactions = ['❤️', '😂', '😮', '😢', '👍', '👎'];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: R.size(context, 18),
        vertical: R.size(context, 8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: reactions.map((reaction) {
          return InkWell(
            onTap: () => onSelected(reaction),
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: EdgeInsets.all(R.size(context, 8)),
              child: Text(
                reaction,
                style: TextStyle(fontSize: R.sp(context, 28)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
