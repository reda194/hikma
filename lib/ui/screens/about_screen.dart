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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF7FBFD),
              Color(0xFFF1F6FA),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // App Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryLight,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  size: 64,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 24),

              // App Name in Arabic
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  'حكمة',
                  style: GoogleFonts.notoNaskhArabic(
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),

              // App Name in English
              Text(
                'Hikma',
                style: GoogleFonts.tajawal(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Tagline
              Text(
                'Wisdom from the Prophetic Traditions',
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Version
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Version $version (Build $buildNumber)',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Description Card
              const _InfoSection(
                title: 'About Hikma',
                icon: Icons.info_outline,
                content: 'Hikma brings authentic Hadith from the six canonical '
                    'collections (Kutub al-Sittah) directly to your desktop. '
                    'Receive beautiful, non-intrusive notifications throughout '
                    'your day to reflect upon the wisdom of the Prophet '
                    'Muhammad (peace be upon him).',
              ),

              const SizedBox(height: 16),

              // Collections Section
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

              // Features Section
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

              // Tech Stack Section
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

              const SizedBox(height: 32),

              // Attribution
              Card(
                elevation: 0,
                color: AppColors.surfaceElevated,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Data sourced from Sunnah.com API',
                        style: GoogleFonts.tajawal(
                          fontSize: 11,
                          color: AppColors.text.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Copyright
              Text(
                '© 2025 Hikma. All rights reserved.',
                style: GoogleFonts.tajawal(
                  fontSize: 11,
                  color: AppColors.text.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w500,
                ),
              ),

              // Copy version button
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
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
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
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
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
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (child != null) child!,
          ],
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
