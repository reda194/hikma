import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/hadith_collection.dart';
import '../../../core/theme/app_colors.dart';

/// CitationText widget displays the narrator, source, and chapter information
class CitationText extends StatelessWidget {
  final String narrator;
  final String source;
  final String chapter;
  final int bookNumber;
  final int hadithNumber;
  final HadithCollection collection;
  final bool isLight;

  const CitationText({
    super.key,
    required this.narrator,
    required this.source,
    required this.chapter,
    required this.bookNumber,
    required this.hadithNumber,
    required this.collection,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isLight ? AppColors.white.withValues(alpha: 0.9) : AppColors.primary;
    final subtextColor = isLight ? AppColors.white.withValues(alpha: 0.7) : AppColors.text.withValues(alpha: 0.7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Narrator/Chain (in Arabic if available)
        if (narrator.isNotEmpty) ...[
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 14,
                color: textColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  narrator,
                  style: GoogleFonts.notoNaskhArabic(
                    fontSize: 13,
                    color: textColor,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],

        // Source book with RTL for Arabic name
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildPill(
              icon: Icons.menu_book,
              label: collection.displayName,
              color: textColor,
            ),
            _buildPill(
              icon: Icons.bookmark,
              label: 'Book $bookNumber',
              color: subtextColor,
            ),
            _buildPill(
              icon: Icons.format_list_numbered,
              label: 'Hadith $hadithNumber',
              color: subtextColor,
            ),
          ],
        ),

        // Chapter if available
        if (chapter.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.folder_open,
                size: 14,
                color: subtextColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  chapter,
                  style: GoogleFonts.notoNaskhArabic(
                    fontSize: 12,
                    color: subtextColor,
                    fontWeight: FontWeight.w300,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPill({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLight
            ? AppColors.white.withValues(alpha: 0.15)
            : AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isLight
              ? AppColors.white.withValues(alpha: 0.2)
              : AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact citation variant for smaller displays
class CompactCitationText extends StatelessWidget {
  final String source;
  final int bookNumber;
  final int hadithNumber;

  const CompactCitationText({
    super.key,
    required this.source,
    required this.bookNumber,
    required this.hadithNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$source - Book $bookNumber, Hadith $hadithNumber',
      style: TextStyle(
        fontSize: 11,
        color: AppColors.text.withValues(alpha: 0.6),
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
