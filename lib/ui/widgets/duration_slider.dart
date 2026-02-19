import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Duration slider widget for popup display duration (4-30 seconds)
class DurationSlider extends StatelessWidget {
  final int duration; // Duration in seconds (4-30 range)
  final ValueChanged<int> onChanged;

  const DurationSlider({
    super.key,
    required this.duration,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Duration preview label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _formatDuration(duration),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Slider
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 14,
            ),
            overlayShape: const RoundSliderOverlayShape(
              overlayRadius: 24,
            ),
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.black.withValues(alpha: 0.1),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.2),
            valueIndicatorColor: AppColors.primary,
            valueIndicatorTextStyle: const TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: Slider(
            value: duration.toDouble(),
            min: 4,
            max: 30,
            divisions: 26, // 30 - 4 = 26 steps
            label: '${duration}s',
            onChanged: (value) {
              // Clamp to valid range and round to integer
              final clamped = value.round().clamp(4, 30);
              onChanged(clamped);
            },
          ),
        ),

        const SizedBox(height: 12),

        // Range labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '4s',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.black.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '30s',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.black.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Description text
        Text(
          'Popup will display for ${_formatDuration(duration)} before auto-dismissing',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.black.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Format duration as human-readable string
  String _formatDuration(int seconds) {
    if (seconds == 1) {
      return '1 second';
    }
    return '$seconds seconds';
  }
}
