import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/hadith.dart';
import '../../../core/theme/app_colors.dart';
import 'citation_text.dart';

/// HadithCard widget displays a Hadith with RTL Arabic text and citation
class HadithCard extends StatelessWidget {
  final Hadith hadith;
  final double fontSize;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isCompact;

  const HadithCard({
    super.key,
    required this.hadith,
    this.fontSize = 24.0,
    this.onTap,
    this.onLongPress,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isCompact ? 16.0 : 24.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.white,
                AppColors.surface.withValues(alpha: 0.3),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hadith text with RTL direction
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  hadith.arabicText,
                  style: GoogleFonts.notoNaskhArabic(
                    fontSize: fontSize,
                    height: 2.0,
                    color: AppColors.text,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.justify,
                  textDirection: TextDirection.rtl,
                ),
              ),
              const SizedBox(height: 16),

              // Divider
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.transparent,
                      AppColors.primary.withValues(alpha: 0.3),
                      AppColors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Citation information
              CitationText(
                narrator: hadith.narrator,
                source: hadith.sourceBook,
                chapter: hadith.chapter,
                bookNumber: hadith.bookNumber,
                hadithNumber: hadith.hadithNumber,
                collection: hadith.collection,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Variant of HadithCard with transparent background for popups
class HadithCardTransparent extends StatelessWidget {
  final Hadith hadith;
  final double fontSize;

  const HadithCardTransparent({
    super.key,
    required this.hadith,
    this.fontSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hadith text with RTL direction
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              hadith.arabicText,
              style: GoogleFonts.notoNaskhArabic(
                fontSize: fontSize,
                height: 2.0,
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(height: 12),

          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.transparent,
                  AppColors.white.withValues(alpha: 0.3),
                  AppColors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Citation information
          CitationText(
            narrator: hadith.narrator,
            source: hadith.sourceBook,
            chapter: hadith.chapter,
            bookNumber: hadith.bookNumber,
            hadithNumber: hadith.hadithNumber,
            collection: hadith.collection,
            isLight: true,
          ),
        ],
      ),
    );
  }
}
