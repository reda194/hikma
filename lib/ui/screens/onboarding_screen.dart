import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/theme/app_colors.dart';

/// Onboarding screen shown on first launch
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onOnboardingComplete;

  const OnboardingScreen({
    super.key,
    required this.onOnboardingComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      icon: Icons.menu_book_rounded,
      title: 'Welcome to Hikma',
      description:
          'Your companion for wisdom and tranquility. '
          'Hikma brings you beautiful Hadith from the Prophet Muhammad (peace be upon him) '
          'to inspire and guide your day.',
      color: AppColors.primary,
    ),
    OnboardingPage(
      icon: Icons.notifications_active_rounded,
      title: 'Gentle Reminders',
      description:
          'Receive regular Hadith notifications at your preferred interval. '
          'Each reminder is a moment of reflection and peace in your busy day.',
      color: AppColors.primaryLight,
    ),
    OnboardingPage(
      icon: Icons.apps_rounded,
      title: 'Menu Bar Access',
      description:
          'Hikma lives in your menu bar for quick access. '
          'Click the icon anytime to read a new Hadith, view your favorites, '
          'or adjust settings.',
      color: AppColors.primary,
    ),
    OnboardingPage(
      icon: Icons.favorite_rounded,
      title: 'Save & Reflect',
      description:
          'Bookmark your favorite Hadith for later reading. '
          'Use Contemplation Mode for focused reading without distractions. '
          'Track your reading journey with statistics.',
      color: AppColors.primaryLight,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final settingsBox = Hive.box(StorageKeys.settingsBox);
    await settingsBox.put(StorageKeys.onboardingCompleted, true);
    widget.onOnboardingComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.primary.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildPageIndicator(index == _currentPage),
                ),
              ),
            ),

            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    style: GoogleFonts.notoNaskhArabic(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 56,
              color: page.color,
            ),
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            page.title,
            style: GoogleFonts.notoNaskhArabic(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            style: GoogleFonts.notoNaskhArabic(
              fontSize: 16,
              height: 1.6,
              color: AppColors.text,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.text.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
