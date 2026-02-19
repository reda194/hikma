import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

/// AboutScreen - Displays app information, version, and credits
/// Note: A simplified version is also included in settings_screen.dart
/// This is the standalone version for navigation from menu
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  static const String version = '1.0.0';
  static const String buildNumber = '1';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  if (isDark)
                    const Color(0xFF09121D)
                  else
                    const Color(0xFFF8FCFF),
                  if (isDark)
                    const Color(0xFF0F1C2B)
                  else
                    const Color(0xFFEDF7FD),
                ],
              ),
            ),
          ),
          Positioned(
            top: -120,
            right: -70,
            child: _BackgroundGlow(
              size: 280,
              color: scheme.primary.withValues(alpha: isDark ? 0.25 : 0.16),
            ),
          ),
          Positioned(
            bottom: -160,
            left: -90,
            child: _BackgroundGlow(
              size: 300,
              color: scheme.secondary.withValues(alpha: isDark ? 0.22 : 0.14),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        scheme.primary,
                        scheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.32),
                        blurRadius: 36,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    size: 68,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    'حكمة',
                    style: GoogleFonts.notoNaskhArabic(
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Hikma',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                    letterSpacing: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Wisdom from the Prophetic Traditions',
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    color: scheme.onSurface.withValues(alpha: 0.68),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: scheme.primary.withValues(alpha: 0.28),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Version $version (Build $buildNumber)',
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const _InfoSection(
                  title: 'About Hikma',
                  icon: Icons.info_outline,
                  content:
                      'Hikma brings authentic Hadith from the six canonical '
                      'collections (Kutub al-Sittah) directly to your desktop. '
                      'Receive beautiful, non-intrusive notifications throughout '
                      'your day to reflect upon the wisdom of the Prophet '
                      'Muhammad (peace be upon him).',
                ),
                const SizedBox(height: 16),
                _InfoSection(
                  title: 'Hadith Collections',
                  icon: Icons.menu_book,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CollectionItem(
                        englishName: 'Sahih Al-Bukhari',
                        arabicName: 'صحيح البخاري',
                      ),
                      _CollectionItem(
                        englishName: 'Sahih Muslim',
                        arabicName: 'صحيح مسلم',
                      ),
                      _CollectionItem(
                        englishName: 'Sunan Abu Dawud',
                        arabicName: 'سنن أبي داود',
                      ),
                      _CollectionItem(
                        englishName: "Jami' Al-Tirmidhi",
                        arabicName: 'جامع الترمذي',
                      ),
                      _CollectionItem(
                        englishName: 'Sunan Ibn Majah',
                        arabicName: 'سنن ابن ماجه',
                      ),
                      _CollectionItem(
                        englishName: 'Sunan Al-Nasa\'i',
                        arabicName: 'سنن النسائي',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const _InfoSection(
                  title: 'Features',
                  icon: Icons.star_outline,
                  content: '• Random Hadith notifications\n'
                      '• Customizable reminder intervals\n'
                      '• Save and organize favorite Hadiths\n'
                      '• Beautiful frosted glass interface\n'
                      '• Offline caching for accessibility\n'
                      '• Multiple font size options\n'
                      '• Adjustable popup duration',
                ),
                const SizedBox(height: 16),
                _InfoSection(
                  title: 'Built With',
                  icon: Icons.code,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _TechChip(label: 'Flutter', icon: Icons.flutter_dash),
                      _TechChip(label: 'Dart', icon: Icons.code),
                      _TechChip(label: 'BLoC', icon: Icons.extension),
                      _TechChip(label: 'Hive', icon: Icons.storage),
                      _TechChip(label: 'Acrylic', icon: Icons.blur_on),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Card(
                  elevation: 0,
                  color: Colors.transparent,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: scheme.surface
                              .withValues(alpha: isDark ? 0.68 : 0.78),
                          border: Border.all(
                            color: scheme.onSurface
                                .withValues(alpha: isDark ? 0.16 : 0.1),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.favorite,
                              size: 16,
                              color: AppColors.favorite,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Made with love for the Muslim Ummah',
                              style: GoogleFonts.tajawal(
                                fontSize: 13,
                                color: scheme.onSurface.withValues(alpha: 0.72),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Data sourced from Sunnah.com API',
                              style: GoogleFonts.tajawal(
                                fontSize: 11,
                                color: scheme.onSurface.withValues(alpha: 0.56),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  '© 2025 Hikma. All rights reserved.',
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    color: scheme.onSurface.withValues(alpha: 0.46),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(
                      const ClipboardData(
                          text: 'Hikma v$version (Build $buildNumber)'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Version info copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy Version Info'),
                  style: TextButton.styleFrom(
                    foregroundColor: scheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Info section widget
class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? content;
  final Widget? child;

  const _InfoSection({
    required this.title,
    required this.icon,
    this.content,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: isDark ? 0.7 : 0.82),
              border: Border.all(
                color: scheme.onSurface.withValues(alpha: isDark ? 0.16 : 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: GoogleFonts.tajawal(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (content != null)
                  Text(
                    content!,
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      height: 1.6,
                      color: scheme.onSurface.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (child != null) child!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  final double size;
  final Color color;

  const _BackgroundGlow({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0.02),
            ],
          ),
        ),
      ),
    );
  }
}

/// Collection item widget
class _CollectionItem extends StatelessWidget {
  final String englishName;
  final String arabicName;

  const _CollectionItem({
    required this.englishName,
    required this.arabicName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                arabicName,
                style: GoogleFonts.notoNaskhArabic(
                  fontSize: 16,
                  color: AppColors.text,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            englishName,
            style: GoogleFonts.tajawal(
              fontSize: 12,
              color: AppColors.text.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tech stack chip widget
class _TechChip extends StatelessWidget {
  final String label;
  final IconData? icon;

  const _TechChip({
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// License dialog
class LicenseDialog extends StatelessWidget {
  const LicenseDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Licenses'),
      content: const SingleChildScrollView(
        child: Text(
          'Hikma is open source software.\n\n'
          'This application uses the following open source packages:\n\n'
          '• Flutter - BSD License\n'
          '• flutter_bloc - MIT License\n'
          '• Hive - Apache 2.0 License\n'
          '• window_manager - MIT License\n'
          '• flutter_acrylic - MIT License\n'
          '• google_fonts - Apache 2.0 License\n'
          '• dio - MIT License\n'
          '• connectivity_plus - BSD License\n'
          '• audioplayers - MIT License\n'
          '• system_tray - MIT License\n\n'
          'Hadith data is sourced from Sunnah.com\n'
          'and is used under fair use for educational purposes.',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
