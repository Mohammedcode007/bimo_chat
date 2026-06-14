import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';

class RoomVoicePlayerBar extends StatelessWidget {
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final VoidCallback onPlayPause;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onClose;

  const RoomVoicePlayerBar({
    super.key,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.onPlayPause,
    required this.onSeek,
    required this.onClose,
  });

  String formatDuration(Duration value) {
    final minutes = value.inMinutes;
    final seconds = value.inSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final maxMs = duration.inMilliseconds <= 0
        ? 1.0
        : duration.inMilliseconds.toDouble();

    final currentMs = position.inMilliseconds.clamp(0, maxMs.toInt()).toDouble();

    return Container(
      height: R.size(context, 42),
      padding: EdgeInsetsDirectional.fromSTEB(
        R.size(context, 8),
        R.size(context, 2),
        R.size(context, 6),
        R.size(context, 2),
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: R.size(context, 34),
              minHeight: R.size(context, 34),
            ),
            onPressed: onPlayPause,
            icon: Icon(
              isPlaying
                  ? Icons.pause_circle_filled_rounded
                  : Icons.play_circle_fill_rounded,
              color: const Color(0xFF087887),
              size: R.size(context, 28),
            ),
          ),

          SizedBox(width: R.size(context, 4)),

          Text(
            formatDuration(position),
            style: TextStyle(
              fontSize: R.sp(context, 11),
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: R.size(context, 2.2),
                thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: R.size(context, 5),
                ),
                overlayShape: RoundSliderOverlayShape(
                  overlayRadius: R.size(context, 10),
                ),
              ),
              child: Slider(
                min: 0,
                max: maxMs,
                value: currentMs,
                onChanged: (value) {
                  onSeek(Duration(milliseconds: value.toInt()));
                },
              ),
            ),
          ),

          Text(
            formatDuration(duration),
            style: TextStyle(
              fontSize: R.sp(context, 11),
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: R.size(context, 32),
              minHeight: R.size(context, 32),
            ),
            onPressed: onClose,
            icon: Icon(
              Icons.close_rounded,
              size: R.size(context, 20),
            ),
          ),
        ],
      ),
    );
  }
}