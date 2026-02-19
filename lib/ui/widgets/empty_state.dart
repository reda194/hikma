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
      message: 'Start saving Hadiths you love by tapping the bookmark icon on any Hadith card.',
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
      message: 'Could not find any favorites matching "$query". Try a different search term.',
      actionLabel: 'Clear Search',
      onAction: onClear,
    );
  }

  /// Empty state for offline mode
  factory EmptyState.offline({VoidCallback? onRetry}) {
    return EmptyState(
      icon: 'cloud_off',
      title: 'Offline Mode',
      message: 'No cached Hadiths available. Connect to the internet to load more content.',
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
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with animated fade-in
            _buildIcon(context),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: GoogleFonts.notoNaskhArabic(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: GoogleFonts.notoNaskhArabic(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.text.withValues(alpha: 0.7),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Action button (if provided)
            if (actionLabel != null && onAction != null)
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.explore_outlined),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    IconData iconData;

    // Map string icon names to IconData
    switch (icon) {
      case 'bookmark_border':
        iconData = Icons.bookmark_border;
        break;
      case 'search_off':
        iconData = Icons.search_off;
        break;
      case 'cloud_off':
        iconData = Icons.cloud_off;
        break;
      case 'error_outline':
        iconData = Icons.error_outline;
        break;
      default:
        iconData = Icons.inbox_outlined;
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Icon(
        iconData,
        size: 48,
        color: AppColors.primary.withValues(alpha: 0.6),
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
            style: GoogleFonts.notoNaskhArabic(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.text.withValues(alpha: 0.6),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: GoogleFonts.notoNaskhArabic(
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
