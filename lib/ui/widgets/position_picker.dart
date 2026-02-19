import 'package:flutter/material.dart';
import '../../data/models/user_settings.dart';
import '../../core/theme/app_colors.dart';

/// Visual position picker for popup placement selection
/// Shows a 16:9 screen preview with 5 clickable position buttons
class PositionPicker extends StatelessWidget {
  final PopupPositionType selected;
  final ValueChanged<PopupPositionType> onChanged;

  const PositionPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Screen preview rectangle (16:9 aspect ratio)
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.black.withValues(alpha: 0.15),
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                // Screen label
                Center(
                  child: Text(
                    'Screen Preview',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ),

                // Position buttons
                _PositionButton(
                  position: PopupPositionType.topLeft,
                  selected: selected == PopupPositionType.topLeft,
                  onTap: () => onChanged(PopupPositionType.topLeft),
                  alignment: Alignment.topLeft,
                ),
                _PositionButton(
                  position: PopupPositionType.topRight,
                  selected: selected == PopupPositionType.topRight,
                  onTap: () => onChanged(PopupPositionType.topRight),
                  alignment: Alignment.topRight,
                ),
                _PositionButton(
                  position: PopupPositionType.bottomLeft,
                  selected: selected == PopupPositionType.bottomLeft,
                  onTap: () => onChanged(PopupPositionType.bottomLeft),
                  alignment: Alignment.bottomLeft,
                ),
                _PositionButton(
                  position: PopupPositionType.bottomRight,
                  selected: selected == PopupPositionType.bottomRight,
                  onTap: () => onChanged(PopupPositionType.bottomRight),
                  alignment: Alignment.bottomRight,
                ),
                _PositionButton(
                  position: PopupPositionType.center,
                  selected: selected == PopupPositionType.center,
                  onTap: () => onChanged(PopupPositionType.center),
                  alignment: Alignment.center,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Current selection label
        Text(
          selected.displayLabel,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Individual position button on the screen preview
class _PositionButton extends StatelessWidget {
  final PopupPositionType position;
  final bool selected;
  final VoidCallback onTap;
  final Alignment alignment;

  const _PositionButton({
    required this.position,
    required this.selected,
    required this.onTap,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: _getPadding(),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary
                  : AppColors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? AppColors.primary
                    : AppColors.black.withValues(alpha: 0.15),
                width: selected ? 2 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: AnimatedScale(
              scale: selected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _getIcon(),
                color: selected ? AppColors.white : Colors.black45,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  EdgeInsets _getPadding() {
    switch (position) {
      case PopupPositionType.topLeft:
        return const EdgeInsets.only(top: 16, left: 16);
      case PopupPositionType.topRight:
        return const EdgeInsets.only(top: 16, right: 16);
      case PopupPositionType.bottomLeft:
        return const EdgeInsets.only(bottom: 16, left: 16);
      case PopupPositionType.bottomRight:
        return const EdgeInsets.only(bottom: 16, right: 16);
      case PopupPositionType.center:
        return EdgeInsets.zero;
    }
  }

  IconData _getIcon() {
    switch (position) {
      case PopupPositionType.topLeft:
        return AlignHorizontalLeft.rounded;
      case PopupPositionType.topRight:
        return AlignHorizontalRight.rounded;
      case PopupPositionType.bottomLeft:
        return AlignHorizontalLeft.rounded;
      case PopupPositionType.bottomRight:
        return AlignHorizontalRight.rounded;
      case PopupPositionType.center:
        return CropSquare.rounded;
    }
  }
}

/// Icon placeholder for center position
class CropSquare {
  static const rounded = Icons.crop_square_rounded;
}

/// AlignHorizontalLeft icon placeholder
class AlignHorizontalLeft {
  static const rounded = Icons.align_horizontal_left_rounded;
}

/// AlignHorizontalRight icon placeholder
class AlignHorizontalRight {
  static const rounded = Icons.align_horizontal_right_rounded;
}
