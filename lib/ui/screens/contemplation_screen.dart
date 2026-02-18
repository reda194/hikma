import 'dart:async';
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

    _fadeController.forward();

    // Load initial Hadith
    _loadHadith();
  }

  @override
  void dispose() {
    _fadeController.dispose();
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

    // Small delay to get the new Hadith from state
    Future.delayed(const Duration(milliseconds: 100), () {
      final state = context.read<HadithBloc>().state;
      if (state is HadithLoaded) {
        setState(() => _currentHadith = state.hadith);
      }
    });
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
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            _exit();
          } else if (event.logicalKey == LogicalKeyboardKey.keyN) {
            _nextHadith();
          }
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withOpacity(0.95),
                AppColors.primary,
                AppColors.primary.withOpacity(0.95),
              ],
            ),
          ),
          child: SafeArea(
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
                        // Top action bar
                        _buildTopBar(),

                        // Main content
                        Expanded(
                          child: Center(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Arabic text
                                  Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: Text(
                                      _currentHadith!.arabicText,
                                      style: GoogleFonts.notoNaskhArabic(
                                        fontSize: 32,
                                        height: 2.2,
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  // Narrator and source
                                  Text(
                                    '${_currentHadith!.narrator} | ${_currentHadith!.sourceBook}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.white.withOpacity(0.7),
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Bottom action bar
                        _buildBottomBar(),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
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
            style: GoogleFonts.notoNaskhArabic(
              fontSize: 14,
              color: AppColors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(width: 48), // Balance the close button
        ],
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.white.withOpacity(0.2),
          ),
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
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
