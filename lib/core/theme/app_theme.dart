import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// App theme configuration
class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(Color text, Color muted, Color onPrimary) {
    return TextTheme(
      displayLarge: GoogleFonts.cormorantGaramond(
        fontSize: 42,
        fontWeight: FontWeight.w700,
        color: text,
      ),
      displayMedium: GoogleFonts.cormorantGaramond(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: text,
      ),
      displaySmall: GoogleFonts.notoNaskhArabic(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: text,
      ),
      headlineMedium: GoogleFonts.notoNaskhArabic(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: text,
      ),
      titleLarge: GoogleFonts.tajawal(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: text,
      ),
      titleMedium: GoogleFonts.tajawal(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: text,
      ),
      bodyLarge: GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: text,
      ),
      bodyMedium: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: muted,
      ),
      labelLarge: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: onPrimary,
      ),
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
    required Color appBarBackground,
    required Color cardBorder,
  }) {
    final text = colorScheme.onSurface;
    final muted = text.withValues(alpha: 0.72);
    final textTheme = _textTheme(text, muted, colorScheme.onPrimary);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: textTheme,
      iconTheme: IconThemeData(color: colorScheme.primary),
      dividerColor: cardBorder,
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: brightness == Brightness.light ? 0.6 : 0,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          side: BorderSide(color: cardBorder, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackground,
        foregroundColor: text,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface.withValues(alpha: 0.84),
        hintStyle: textTheme.bodyMedium,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.primary.withValues(alpha: 0.96),
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.onPrimary;
            }
            return text;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary;
            }
            return colorScheme.surface.withValues(alpha: 0.8);
          }),
          side: WidgetStatePropertyAll(BorderSide(color: cardBorder)),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return text.withValues(alpha: 0.85);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary.withValues(alpha: 0.7);
          }
          return muted.withValues(alpha: 0.35);
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          shape: const WidgetStatePropertyAll(
            StadiumBorder(),
          ),
          backgroundColor: WidgetStatePropertyAll(
            colorScheme.primary.withValues(alpha: 0.92),
          ),
          foregroundColor: WidgetStatePropertyAll(colorScheme.onPrimary),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: Color(0xFF0F4D73),
      onPrimary: AppColors.white,
      secondary: Color(0xFF2AB7A8),
      onSecondary: AppColors.white,
      surface: Color(0xFFFCFEFF),
      onSurface: Color(0xFF0E2A3E),
      error: AppColors.error,
      onError: AppColors.white,
    );

    return _buildTheme(
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackground: AppColors.background,
      appBarBackground: const Color(0xFFEFF6FB),
      cardBorder: const Color(0xFFCFDCE8),
    );
  }

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: Color(0xFF6EC5FF),
      onPrimary: Color(0xFF04243A),
      secondary: Color(0xFF5CE4D1),
      onSecondary: Color(0xFF022821),
      surface: Color(0xFF121D29),
      onSurface: Color(0xFFE8F2FC),
      error: Color(0xFFF06B6B),
      onError: Color(0xFF290304),
    );

    return _buildTheme(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackground: const Color(0xFF0B121A),
      appBarBackground: const Color(0xFF0E1620),
      cardBorder: const Color(0xFF243647),
    );
  }
}
