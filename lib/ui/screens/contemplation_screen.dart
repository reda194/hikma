import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/hadith/hadith_bloc.dart';
import '../../bloc/hadith/hadith_event.dart';
import '../../bloc/hadith/hadith_state.dart';
import '../../bloc/favorites/favorites_bloc.dart';
import '../../bloc/favorites/favorites_event.dart';
import '../../data/models/hadith.dart';
import '../../data/models/hadith_collection.dart';
import '../../core/theme/app_colors.dart';

/// ContemplationScreen - Full-screen, distraction-free Hadith reading
class ContemplationScreen extends StatefulWidget {
  const ContemplationScreen({super.key});

  @override
  State<ContemplationScreen> createState() => _ContemplationScreenState();
}

class _ContemplationScreenState extends State<ContemplationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late FocusNode _keyboardFocusNode;
  Hadith? _currentHadith;

  @override
  void initState() {
    super.initState();

    // Setup fade-in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _keyboardFocusNode = FocusNode();

    _fadeController.forward();

    // Load initial Hadith
    _loadHadith();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _keyboardFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _loadHadith() {
    final state = context.read<HadithBloc>().state;
    if (state is HadithLoaded && state.hadith != Hadith.empty()) {
      setState(() => _currentHadith = state.hadith);
    } else {
      context.read<HadithBloc>().add(
            FetchRandomHadith(collection: HadithCollection.all),
          );
    }
  }

  void _nextHadith() {
    context.read<HadithBloc>().add(
          FetchRandomHadith(collection: HadithCollection.all),
        );
  }

  void _toggleFavorite() {
    if (_currentHadith != null) {
      context.read<FavoritesBloc>().add(ToggleFavorite(_currentHadith!));
    }
  }

  void _exit() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            _exit();
          } else if (event.logicalKey == LogicalKeyboardKey.keyN) {
            _nextHadith();
          }
        }
      },
      child: BlocListener<HadithBloc, HadithState>(
        listener: (context, state) {
          if (state is HadithLoaded && mounted) {
            setState(() => _currentHadith = state.hadith);
            _fadeController
              ..reset()
              ..forward();
          }
        },
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF071423),
                  const Color(0xFF0B2C46),
                  const Color(0xFF0E3A5A),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -120,
                  right: -80,
                  child: _buildGlowOrb(
                    size: 280,
                    color: AppColors.primaryLight.withValues(alpha: 0.25),
                  ),
                ),
                Positioned(
                  bottom: -180,
                  left: -120,
                  child: _buildGlowOrb(
                    size: 340,
                    color: AppColors.white.withValues(alpha: 0.09),
                  ),
                ),
                SafeArea(
                  child: _currentHadith == null
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                          ),
                        )
                      : FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              _buildTopBar(),
                              Expanded(
                                child: Center(
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 28,
                                      vertical: 18,
                                    ),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 980,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(28),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 12,
                                            sigmaY: 12,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.fromLTRB(
                                              34,
                                              34,
                                              34,
                                              28,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.white
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(28),
                                              border: Border.all(
                                                color: AppColors.white
                                                    .withValues(alpha: 0.22),
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                Directionality(
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  child: Text(
                                                    _currentHadith!.arabicText,
                                                    style: GoogleFonts
                                                        .notoNaskhArabic(
                                                      fontSize: 35,
                                                      height: 2.2,
                                                      color: AppColors.white,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                const SizedBox(height: 26),
                                                Container(
                                                  width: 120,
                                                  height: 1,
                                                  color: AppColors.white
                                                      .withValues(alpha: 0.4),
                                                ),
                                                const SizedBox(height: 18),
                                                Text(
                                                  '${_currentHadith!.narrator} • ${_currentHadith!.sourceBook}',
                                                  style: GoogleFonts.tajawal(
                                                    fontSize: 14,
                                                    color: AppColors.white
                                                        .withValues(
                                                            alpha: 0.84),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              _buildBottomBar(),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlowOrb({required double size, required Color color}) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              AppColors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.08),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.18),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _exit,
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.white,
                  tooltip: 'Exit (Esc)',
                ),
                Text(
                  'Contemplation Mode',
                  style: GoogleFonts.tajawal(
                    fontSize: 15,
                    color: AppColors.white.withValues(alpha: 0.86),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            icon: Icons.bookmark_border_rounded,
            label: 'Save',
            onTap: _toggleFavorite,
          ),
          _ActionButton(
            icon: Icons.skip_next_rounded,
            label: 'Next (N)',
            onTap: _nextHadith,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.28),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.16),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: AppColors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
