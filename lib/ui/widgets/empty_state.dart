import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// EmptyState widget for displaying when there's no content
class EmptyState extends StatelessWidget {
  final String icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  /// Empty state for no favorites
  factory EmptyState.noFavorites({VoidCallback? onExplore}) {
    return EmptyState(
      icon: 'bookmark_border',
      title: 'No Favorites Yet',
      message:
          'Start saving Hadiths you love by tapping the bookmark icon on any Hadith card.',
      actionLabel: 'Explore Hadiths',
      onAction: onExplore,
    );
  }

  /// Empty state for no search results
  factory EmptyState.noResults({String? query}) {
    return EmptyState(
      icon: 'search_off',
      title: 'No Results Found',
      message: query != null
          ? 'Could not find any Hadiths matching "$query". Try a different search term.'
          : 'Could not find any matching Hadiths. Try adjusting your filters.',
    );
  }

  /// Empty state for no search results in favorites
  factory EmptyState.noSearchResults({
    required String query,
    VoidCallback? onClear,
  }) {
    return EmptyState(
      icon: 'search_off',
      title: 'No Matching Favorites',
      message:
          'Could not find any favorites matching "$query". Try a different search term.',
      actionLabel: 'Clear Search',
      onAction: onClear,
    );
  }

  /// Empty state for offline mode
  factory EmptyState.offline({VoidCallback? onRetry}) {
    return EmptyState(
      icon: 'cloud_off',
      title: 'Offline Mode',
      message:
          'No cached Hadiths available. Connect to the internet to load more content.',
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }

  /// Empty state for errors
  factory EmptyState.error({
    required String errorMessage,
    VoidCallback? onRetry,
  }) {
    return EmptyState(
      icon: 'error_outline',
      title: 'Something Went Wrong',
      message: errorMessage,
      actionLabel: 'Try Again',
      onAction: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 560),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIcon(context),
              const SizedBox(height: 20),
              Text(
                title,
                style: GoogleFonts.tajawal(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                  height: 1.55,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              if (actionLabel != null && onAction != null)
                FilledButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(actionLabel!),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    IconData iconData;

    switch (icon) {
      case 'bookmark_border':
        iconData = Icons.bookmark_border_rounded;
        break;
      case 'search_off':
        iconData = Icons.search_off_rounded;
        break;
      case 'cloud_off':
        iconData = Icons.cloud_off_rounded;
        break;
      case 'error_outline':
        iconData = Icons.error_outline_rounded;
        break;
      default:
        iconData = Icons.inbox_outlined;
    }

    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.primaryLight.withValues(alpha: 0.12),
          ],
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Icon(
        iconData,
        size: 44,
        color: AppColors.primaryDark,
      ),
    );
  }
}

/// Compact empty state widget for smaller spaces
class EmptyStateCompact extends StatelessWidget {
  final String title;
  final String? subtitle;

  const EmptyStateCompact({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: AppColors.text.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.text.withValues(alpha: 0.6),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: GoogleFonts.tajawal(
                fontSize: 14,
                color: AppColors.text.withValues(alpha: 0.4),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
