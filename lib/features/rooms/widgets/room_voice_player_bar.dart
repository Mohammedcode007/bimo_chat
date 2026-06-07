import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';

class RoomVoicePlayerBar extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onPause;
  final VoidCallback onClose;

  const RoomVoicePlayerBar({
    super.key,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onPause,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: R.size(context, 46),
      padding: EdgeInsets.symmetric(horizontal: R.size(context, 12)),
      color: colorScheme.surface,
      child: Row(
        children: [
          IconButton(
            onPressed: onPlayPause,
            icon: Icon(
              isPlaying
                  ? Icons.pause_circle_filled_rounded
                  : Icons.play_circle_fill_rounded,
              color: const Color(0xFF087887),
              size: R.size(context, 30),
            ),
          ),
          Expanded(
            child: Text(
              isPlaying ? 'Playing voice...' : 'Voice paused',
              style: TextStyle(
                fontSize: R.sp(context, 14),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: onPause,
            icon: Icon(Icons.pause_rounded, size: R.size(context, 24)),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close_rounded, size: R.size(context, 24)),
          ),
        ],
      ),
    );
  }
}
