import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/hadith.dart';
import '../../bloc/popup/popup_bloc.dart';
import '../../bloc/popup/popup_event.dart';
import '../../bloc/popup/popup_state.dart';
import '../../bloc/favorites/favorites_bloc.dart';
import '../../bloc/favorites/favorites_event.dart' as favorites_event;
import '../../core/theme/app_colors.dart';

/// Native NSPanel popup widget with hover-to-pause and action buttons
/// This is displayed inside the native macOS NSPanel via platform channel
class NotificationPopup extends StatefulWidget {
  final Hadith hadith;
  final Duration displayDuration;

  const NotificationPopup({
    super.key,
    required this.hadith,
    required this.displayDuration,
  });

  @override
  State<NotificationPopup> createState() => _NotificationPopupState();
}

class _NotificationPopupState extends State<NotificationPopup>
    with TickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _slideController;
  late AnimationController _progressController;
  late AnimationController _actionButtonController;

  @override
  void initState() {
    super.initState();

    // Slide-in animation controller
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Progress indicator animation controller
    _progressController = AnimationController(
      duration: widget.displayDuration,
      vsync: this,
    );

    // Action buttons reveal animation controller
    _actionButtonController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    // Start slide-in animation
    _slideController.forward();
    _progressController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _progressController.dispose();
    _actionButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PopupBloc, PopupState>(
      listener: (context, state) {
        if (state is PopupVisible) {
          // Update hover state from BLoC
          if (_isHovered != state.isHovered) {
            setState(() {
              _isHovered = state.isHovered;
            });

            // Animate action buttons on hover
            if (_isHovered) {
              _actionButtonController.forward();
            } else {
              _actionButtonController.reverse();
            }

            // Pause/resume progress animation
            if (_isHovered) {
              _progressController.stop();
            } else {
              _progressController.forward();
            }
          }
        }
      },
      child: MouseRegion(
        onEnter: (_) {
          context.read<PopupBloc>().add(const HoverChanged(isHovered: true));
          _notifyNativeHoverChanged(true);
        },
        onExit: (_) {
          context.read<PopupBloc>().add(const HoverChanged(isHovered: false));
          _notifyNativeHoverChanged(false);
        },
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0), // Start from right
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeOutCubic,
          )),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: 400,
                constraints: const BoxConstraints(
                  minHeight: 200,
                  maxHeight: 450,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.92),
                      AppColors.primary.withValues(alpha: 0.88),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top accent line
                    _buildTopAccentLine(),

                    // Header with close button
                    _buildHeader(),

                    // Hadith content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: _buildHadithContent(),
                      ),
                    ),

                    // Citation badges
                    _buildCitationBadges(),

                    // Circular progress indicator
                    _buildCircularProgress(),

                    // Action buttons (reveal on hover)
                    _buildActionBar(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Top gradient accent line
  Widget _buildTopAccentLine() {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLight,
            AppColors.white.withValues(alpha: 0.8),
            AppColors.primaryLight,
          ],
        ),
      ),
    );
  }

  /// Header with logo watermark and close button
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          // Hikma logo watermark (subtle)
          Positioned(
            left: 0,
            top: 4,
            child: Opacity(
              opacity: 0.15,
              child: Text(
                'حكمة',
                style: GoogleFonts.amiri(
                  fontSize: 14,
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          // Close button (right)
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => _handleClose(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hadith content with RTL Arabic text
  Widget _buildHadithContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Arabic text with RTL direction
        Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            widget.hadith.arabicText,
            style: GoogleFonts.notoNaskhArabic(
              fontSize: 24,
              height: 1.8,
              color: AppColors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ),

        const SizedBox(height: 16),

        // Narrator
        Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            widget.hadith.narrator,
            style: GoogleFonts.notoNaskhArabic(
              fontSize: 16,
              color: AppColors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  /// Citation badges (collection, number)
  Widget _buildCitationBadges() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          // Collection badge
          _Badge(
            icon: Icons.menu_book_rounded,
            label: widget.hadith.collection.displayName,
          ),

          // Hadith number badge
          _Badge(
            icon: Icons.tag_rounded,
            label: '${widget.hadith.bookNumber}:${widget.hadith.hadithNumber}',
          ),
        ],
      ),
    );
  }

  /// Circular progress indicator
  Widget _buildCircularProgress() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: 24,
        height: 24,
        child: AnimatedBuilder(
          animation: _progressController,
          builder: (context, child) {
            return CustomPaint(
              painter: _CircularProgressPainter(
                progress: _isHovered ? _progressController.value : 1.0,
                color: AppColors.white.withValues(alpha: 0.8),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Action buttons bar (Save, Copy, Next)
  Widget _buildActionBar() {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: _actionButtonController,
        curve: Curves.easeOut,
      ),
      axis: Axis.vertical,
      axisAlignment: -1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.08),
          border: Border(
            top: BorderSide(
              color: AppColors.white.withValues(alpha: 0.1),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ActionButton(
              icon: Icons.star_rounded,
              label: 'Save',
              onTap: () => _handleSave(),
            ),
            _ActionButton(
              icon: Icons.copy_rounded,
              label: 'Copy',
              onTap: () => _handleCopy(),
            ),
            _ActionButton(
              icon: Icons.refresh_rounded,
              label: 'Next',
              onTap: () => _handleNext(),
            ),
          ],
        ),
      ),
    );
  }

  /// Notify native Swift of hover state change
  void _notifyNativeHoverChanged(bool hovered) {
    // This is handled via platform channel
    // PopupWindowManager sends this to Swift
  }

  /// Handle close button tap
  void _handleClose() {
    // Slide out animation before dismissing
    _slideController.reverse().then((_) {
      if (mounted) {
        context.read<PopupBloc>().add(const DismissPopup(savePosition: false));
      }
    });
  }

  /// Handle save button tap
  void _handleSave() {
    context.read<FavoritesBloc>().add(
          favorites_event.ToggleFavorite(widget.hadith),
        );
  }

  /// Handle copy button tap
  void _handleCopy() {
    context.read<PopupBloc>().add(const CopyHadith());
  }

  /// Handle next button tap
  void _handleNext() {
    context.read<PopupBloc>().add(const ShowNextHadith());
  }
}

/// Custom painter for circular progress indicator
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Citation badge widget
class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Badge({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppColors.white.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Action button widget
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 0.92).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      ),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _controller.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _isPressed
                ? AppColors.white.withValues(alpha: 0.2)
                : AppColors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: AppColors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
