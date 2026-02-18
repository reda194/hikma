import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

/// BookmarkButton widget with star icon for favoriting Hadiths
/// Supports filled/outline states and animated transitions
class BookmarkButton extends StatefulWidget {
  final String hadithId;
  final bool isFavorite;
  final VoidCallback? onToggle;
  final double size;
  final Color? filledColor;
  final Color? outlineColor;

  const BookmarkButton({
    super.key,
    required this.hadithId,
    required this.isFavorite,
    this.onToggle,
    this.size = 24.0,
    this.filledColor,
    this.outlineColor,
  });

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isFavorite) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(BookmarkButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorite != oldWidget.isFavorite) {
      if (widget.isFavorite) {
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Add haptic feedback
    HapticFeedback.lightImpact();

    if (widget.onToggle != null) {
      widget.onToggle!();
    }
    // Note: The FavoritesBloc should be handled at a higher level
    // through the onToggle callback to access the full Hadith object
  }

  @override
  Widget build(BuildContext context) {
    final filledColor = widget.filledColor ?? AppColors.favorite;
    final outlineColor = widget.outlineColor ?? AppColors.favoriteBorder;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          width: widget.size + 16,
          height: widget.size + 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isFavorite
                ? filledColor.withOpacity(0.15)
                : AppColors.transparent,
            border: Border.all(
              color: widget.isFavorite
                  ? filledColor.withOpacity(0.3)
                  : AppColors.transparent,
              width: 1,
            ),
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                );
              },
              child: widget.isFavorite
                  ? Icon(
                      Icons.star_rounded,
                      key: const ValueKey('filled'),
                      size: widget.size,
                      color: filledColor,
                    )
                  : Icon(
                      Icons.star_border_rounded,
                      key: const ValueKey('outline'),
                      size: widget.size,
                      color: outlineColor,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bookmark button variant for use in app bar
class BookmarkButtonAppBar extends StatelessWidget {
  final String hadithId;
  final bool isFavorite;
  final VoidCallback? onToggle;

  const BookmarkButtonAppBar({
    super.key,
    required this.hadithId,
    required this.isFavorite,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return BookmarkButton(
      hadithId: hadithId,
      isFavorite: isFavorite,
      onToggle: onToggle,
      size: 28.0,
    );
  }
}

/// Small bookmark button for cards
class BookmarkButtonSmall extends StatelessWidget {
  final String hadithId;
  final bool isFavorite;
  final VoidCallback? onToggle;

  const BookmarkButtonSmall({
    super.key,
    required this.hadithId,
    required this.isFavorite,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return BookmarkButton(
      hadithId: hadithId,
      isFavorite: isFavorite,
      onToggle: onToggle,
      size: 20.0,
    );
  }
}
