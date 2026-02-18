import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/hadith.dart';
import '../../data/models/hadith_collection.dart';
import '../../data/models/user_settings.dart';
import '../../bloc/hadith/hadith_bloc.dart';
import '../../bloc/hadith/hadith_event.dart';
import '../../bloc/hadith/hadith_state.dart';
import '../../bloc/favorites/favorites_bloc.dart';
import '../../bloc/favorites/favorites_state.dart';
import '../../bloc/favorites/favorites_event.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/hadith_card.dart';

/// PopupContent widget - Contains the Hadith display and action buttons
/// Used inside HadithPopup and dialog variants
class PopupContent extends StatefulWidget {
  final String? hadithId;
  final Hadith? hadith;
  final int remainingSeconds;
  final bool isDismissible;
  final VoidCallback onClose;

  const PopupContent({
    super.key,
    this.hadithId,
    this.hadith,
    this.remainingSeconds = 0,
    this.isDismissible = true,
    required this.onClose,
  });

  @override
  State<PopupContent> createState() => _PopupContentState();
}

class _PopupContentState extends State<PopupContent> {
  Hadith? _currentHadith;

  @override
  void initState() {
    super.initState();
    _currentHadith = widget.hadith;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_currentHadith == null && widget.hadithId != null) {
      // Load hadith from repository using hadithId if needed
      // This would require access to a local cache or making an API call
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.95),
              AppColors.primary.withOpacity(0.85),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with drag indicator and close button
            _buildHeader(context),

            // Hadith content
            Flexible(
              child: BlocBuilder<HadithBloc, HadithState>(
                builder: (context, hadithState) {
                  if (hadithState is HadithError) {
                    return _buildErrorState(hadithState as HadithError);
                  }
                  if (hadithState is HadithLoading) {
                    return _buildLoadingState();
                  }

                  final hadith = _currentHadith ??
                      (hadithState is HadithLoaded ? hadithState.hadith : null);

                  if (hadith == null) {
                    return _buildLoadingState();
                  }

                  return _buildHadithContent(context, hadith);
                },
              ),
            ),

            // Action buttons
            _buildActionBar(context),

            // Countdown indicator (if applicable)
            if (widget.remainingSeconds > 0)
              _buildCountdownIndicator(widget.remainingSeconds),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App title/icon
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Hikma',
                style: GoogleFonts.notoNaskhArabic(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ],
          ),

          // Close button
          if (widget.isDismissible)
            IconButton(
              onPressed: widget.onClose,
              icon: const Icon(Icons.close_rounded),
              color: AppColors.white,
              tooltip: 'Close',
              iconSize: 20,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildHadithContent(BuildContext context, Hadith hadith) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          // Hadith card with transparent background
          HadithCardTransparent(
            hadith: hadith,
            fontSize: 26.0,
          ),
          const SizedBox(height: 8),

          // Collection badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.menu_book_rounded,
                  size: 14,
                  color: AppColors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  hadith.collection.displayName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(32.0),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.white,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_rounded,
            color: AppColors.white.withOpacity(0.7),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No Hadiths available',
            style: GoogleFonts.notoNaskhArabic(
              fontSize: 18,
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your data files and restart the app',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    final hadith = _currentHadith ??
        (context.read<HadithBloc>().state is HadithLoaded
            ? (context.read<HadithBloc>().state as HadithLoaded).hadith
            : null);

    if (hadith == null) return const SizedBox.shrink();

    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, favState) {
        final isFavorite = favState is FavoritesLoaded &&
            favState.isFavorite(hadith.id);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.1),
            border: Border(
              top: BorderSide(
                color: AppColors.white.withOpacity(0.1),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionButton(
                icon: isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                label: 'Save',
                onTap: () {
                  context.read<FavoritesBloc>().add(
                        ToggleFavorite(hadith),
                      );
                },
                isActive: isFavorite,
              ),
              _ActionButton(
                icon: Icons.copy_rounded,
                label: 'Copy',
                onTap: () async {
                  await _copyHadithToClipboard(hadith);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hadith copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              _ActionButton(
                icon: Icons.refresh_rounded,
                label: 'Next',
                onTap: () {
                  context.read<HadithBloc>().add(
                        const FetchRandomHadith(collection: HadithCollection.all),
                      );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountdownIndicator(int seconds) {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.white.withOpacity(0.8),
            AppColors.white.withOpacity(0.3),
          ],
        ),
      ),
      child: LinearProgressIndicator(
        value: seconds / 120.0, // Assuming max 2 minutes for visual
        backgroundColor: AppColors.transparent,
        valueColor: AlwaysStoppedAnimation<Color>(
          AppColors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  /// Copy Hadith to clipboard with formatting
  /// Format: "Arabic text — Narrator | Source"
  Future<void> _copyHadithToClipboard(Hadith hadith) async {
    final formattedText = '${hadith.arabicText} — ${hadith.narrator} | ${hadith.sourceBook}';
    await Clipboard.setData(ClipboardData(text: formattedText));
  }

  Widget _buildErrorState(HadithError errorState) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.white.withOpacity(0.7),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Could not load Hadith',
            style: GoogleFonts.notoNaskhArabic(
              fontSize: 18,
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your connection and try again',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<HadithBloc>().add(
                FetchRandomHadith(collection: HadithCollection.all),
              );
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white.withOpacity(0.2),
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Action button widget for popup actions
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.white.withOpacity(0.2)
                : AppColors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: widget.isActive
                    ? AppColors.favorite
                    : AppColors.white,
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.white.withOpacity(0.8),
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
