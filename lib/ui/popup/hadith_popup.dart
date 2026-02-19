import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';
import '../../data/models/hadith.dart';
import '../../bloc/popup/popup_bloc.dart';
import '../../bloc/popup/popup_event.dart';
import '../../bloc/popup/popup_state.dart';
import '../../core/theme/app_colors.dart';
import 'popup_content.dart';

/// HadithPopup - A draggable floating window with frosted glass effect
/// Displays Hadith notifications with window_manager integration
class HadithPopup extends StatefulWidget {
  final WindowEffect windowEffect;
  final Color backgroundColor;

  const HadithPopup({
    super.key,
    this.windowEffect = WindowEffect.acrylic,
    this.backgroundColor = AppColors.primary,
  });

  @override
  State<HadithPopup> createState() => _HadithPopupState();
}

class _HadithPopupState extends State<HadithPopup>
    with SingleTickerProviderStateMixin, WindowListener {
  Offset _position = const Offset(100, 100);
  bool _isDragging = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Setup fade-in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();

    // Setup window
    _setupWindow();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _setupWindow() async {
    await Window.initialize();
    await windowManager.setAsFrameless();
    await windowManager.setHasShadow(true);
    await windowManager.setAspectRatio(16 / 10);
    await windowManager.setResizable(true);
    await windowManager.setTitle('Hikma - Hadith Popup');

    // Apply frosted glass effect
    await Window.setEffect(
      effect: widget.windowEffect,
      color: widget.backgroundColor.withValues(alpha: 0.3),
      dark: true,
    );
  }

  @override
  void onWindowClose() {
    // Prevent default close behavior, use Bloc event instead
    context.read<PopupBloc>().add(const DismissPopup(savePosition: true));
  }

  @override
  void onWindowFocus() {
    setState(() {});
  }

  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _position += details.delta;
    });

    // Update position in Bloc
    context.read<PopupBloc>().add(
          UpdatePosition(dx: _position.dx, dy: _position.dy),
        );
  }

  void _handleDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PopupBloc, PopupState>(
      listener: (context, state) {
        if (state is PopupHidden) {
          // Close window when popup is hidden
          windowManager.hide();
        } else if (state is PopupVisible) {
          // Show window when popup is visible
          windowManager.show();
          windowManager.focus();
        }
      },
      child: BlocBuilder<PopupBloc, PopupState>(
        builder: (context, state) {
          if (state is! PopupVisible) {
            return const SizedBox.shrink();
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: Material(
              color: AppColors.transparent,
              child: GestureDetector(
                onPanStart: _handleDragStart,
                onPanUpdate: _handleDragUpdate,
                onPanEnd: _handleDragEnd,
                behavior: HitTestBehavior.translucent,
                child: Stack(
                  children: [
                    // Main content
                    Positioned(
                      left: _position.dx,
                      top: _position.dy,
                      child: PopupContent(
                        hadith: state.hadith,
                        remainingSeconds: (state.remainingMillis / 1000).round(),
                        isDismissible: state.isDismissible,
                        onClose: () {
                          context.read<PopupBloc>().add(
                                const DismissPopup(savePosition: true),
                              );
                        },
                      ),
                    ),

                    // Drag indicator (top bar)
                    if (_isDragging)
                      Positioned(
                        left: _position.dx + 150,
                        top: _position.dy,
                        child: _buildDragIndicator(),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDragIndicator() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// Full-screen popup overlay for immersive Hadith display
class HadithPopupOverlay extends StatelessWidget {
  final Hadith hadith;
  final VoidCallback? onClose;

  const HadithPopupOverlay({
    super.key,
    required this.hadith,
    this.onClose,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Hadith hadith,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierColor: AppColors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return HadithPopupOverlay(
          hadith: hadith,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose ?? () => Navigator.of(context).pop(),
      child: Material(
        color: AppColors.transparent,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent closing when tapping content
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              constraints: const BoxConstraints(maxWidth: 500, minWidth: 350),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 40,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: PopupContent(
                hadith: hadith,
                onClose: onClose ?? () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
