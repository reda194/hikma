import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/hadith_collection.dart';
import '../../data/models/user_settings.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../../bloc/settings/settings_state.dart';
import '../../bloc/settings/settings_event.dart';
import '../../core/theme/app_colors.dart';

/// SettingsScreen - User settings and preferences
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(const LoadSettings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.notoNaskhArabic(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is! SettingsLoaded) {
            return const Center(
              child: Text('Failed to load settings'),
            );
          }

          final settings = state.settings;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Display Settings Section
              _buildSectionHeader('Display', Icons.palette_outlined),
              _buildCard(
                children: [
                  _buildFontSizeTile(settings),
                  _buildDivider(),
                ],
              ),

              const SizedBox(height: 16),

              // Hadith Settings Section
              _buildSectionHeader('Hadith', Icons.menu_book_outlined),
              _buildCard(
                children: [
                  _buildCollectionTile(settings),
                  _buildDivider(),
                  _buildReminderIntervalTile(settings),
                  _buildDivider(),
                  _buildPopupDurationTile(settings),
                ],
              ),

              const SizedBox(height: 16),

              // Notifications Section
              _buildSectionHeader('Notifications', Icons.notifications_outlined),
              _buildCard(
                children: [
                  _buildSwitchTile(
                    title: 'Notification Sound',
                    subtitle: 'Play sound when Hadith popup appears',
                    value: settings.soundEnabled,
                    onChanged: (value) {
                      context.read<SettingsBloc>().add(ToggleSound(value));
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Application Settings Section
              _buildSectionHeader('Application', Icons.apps_outlined),
              _buildCard(
                children: [
                  _buildSwitchTile(
                    title: 'Auto-start at Login',
                    subtitle: 'Launch Hikma automatically when you log in',
                    value: settings.autoStartEnabled,
                    onChanged: (value) {
                      context.read<SettingsBloc>().add(ToggleAutoStart(value));
                    },
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    title: 'Show in Dock',
                    subtitle: 'Display Hikma icon in macOS Dock',
                    value: settings.showInDock,
                    onChanged: (value) {
                      context.read<SettingsBloc>().add(ToggleShowInDock(value));
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // About link
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AboutScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline),
                  label: const Text('About Hikma'),
                ),
              ),

              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.notoNaskhArabic(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildFontSizeTile(UserSettings settings) {
    return ListTile(
      leading: const Icon(Icons.text_fields),
      title: const Text('Font Size'),
      subtitle: Text(settings.fontSize.displayLabel),
      trailing: SegmentedButton<FontSize>(
        segments: FontSize.values.map((size) {
          return ButtonSegment(
            value: size,
            label: Text(
              size == FontSize.small
                  ? 'S'
                  : size == FontSize.medium
                      ? 'M'
                      : size == FontSize.large
                          ? 'L'
                          : 'XL',
              style: const TextStyle(fontSize: 12),
            ),
          );
        }).toList(),
        selected: {settings.fontSize},
        onSelectionChanged: (Set<FontSize> selection) {
          context.read<SettingsBloc>().add(
                UpdateFontSize(selection.first),
              );
        },
      ),
    );
  }

  Widget _buildCollectionTile(UserSettings settings) {
    return ListTile(
      leading: const Icon(Icons.library_books),
      title: const Text('Source Collection'),
      subtitle: Text(settings.sourceCollection.displayName),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showCollectionPicker(context, settings.sourceCollection),
    );
  }

  Widget _buildReminderIntervalTile(UserSettings settings) {
    return ListTile(
      leading: const Icon(Icons.schedule),
      title: const Text('Reminder Interval'),
      subtitle: Text(settings.reminderInterval.displayLabel),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showReminderIntervalPicker(
        context,
        settings.reminderInterval,
      ),
    );
  }

  Widget _buildPopupDurationTile(UserSettings settings) {
    return ListTile(
      leading: const Icon(Icons.timer_outlined),
      title: const Text('Popup Duration'),
      subtitle: Text(settings.popupDuration.displayLabel),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showPopupDurationPicker(context, settings.popupDuration),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title),
      subtitle: Text(subtitle),
      activeColor: AppColors.primary,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 16, endIndent: 16);
  }

  void _showCollectionPicker(
    BuildContext context,
    HadithCollection current,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Select Collection',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Divider(),
              ...HadithCollection.values.map((collection) {
                return RadioListTile<HadithCollection>(
                  title: Text(collection.displayName),
                  subtitle: Text(collection.arabicName),
                  value: collection,
                  groupValue: current,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<SettingsBloc>().add(
                            UpdateSourceCollection(value),
                          );
                      Navigator.of(context).pop();
                    }
                  },
                  selected: collection == current,
                  activeColor: AppColors.primary,
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showReminderIntervalPicker(
    BuildContext context,
    ReminderInterval current,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Reminder Interval',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Divider(),
              ...ReminderInterval.values.map((interval) {
                return RadioListTile<ReminderInterval>(
                  title: Text(interval.displayLabel),
                  value: interval,
                  groupValue: current,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<SettingsBloc>().add(
                            UpdateReminderInterval(value),
                          );
                      Navigator.of(context).pop();
                    }
                  },
                  selected: interval == current,
                  activeColor: AppColors.primary,
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showPopupDurationPicker(
    BuildContext context,
    PopupDuration current,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Popup Duration',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Divider(),
              ...PopupDuration.values.map((duration) {
                return RadioListTile<PopupDuration>(
                  title: Text(duration.displayLabel),
                  subtitle: duration == PopupDuration.manual
                      ? const Text('Popup stays visible until dismissed')
                      : null,
                  value: duration,
                  groupValue: current,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<SettingsBloc>().add(
                            UpdatePopupDuration(value),
                          );
                      Navigator.of(context).pop();
                    }
                  },
                  selected: duration == current,
                  activeColor: AppColors.primary,
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

/// AboutScreen embedded within settings_screen.dart for convenience
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // App Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                size: 56,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 24),

            // App Name
            Text(
              'Hikma',
              style: GoogleFonts.notoNaskhArabic(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),

            // Tagline
            const Text(
              'Wisdom from the Prophetic Traditions',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Version
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.text.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),

            // Description
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Hikma brings authentic Hadith from the six canonical collections (Kutub al-Sittah) directly to your desktop. Receive beautiful, non-intrusive notifications throughout your day to reflect upon the wisdom of the Prophet Muhammad (peace be upon him).',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Collections info
            const _InfoCard(
              title: 'Collections',
              icon: Icons.menu_book,
              content: 'Sahih Al-Bukhari\n'
                  'Sahih Muslim\n'
                  'Sunan Abu Dawud\n'
                  "Jami' Al-Tirmidhi\n"
                  'Sunan Ibn Majah\n'
                  'Sunan Al-Nasa\'i',
            ),
            const SizedBox(height: 16),

            // Features info
            const _InfoCard(
              title: 'Features',
              icon: Icons.star,
              content: '• Random Hadith notifications\n'
                  '• Customizable reminders\n'
                  '• Save favorite Hadiths\n'
                  '• Beautiful frosted glass UI\n'
                  '• Offline caching',
            ),
            const SizedBox(height: 32),

            // Credits
            Text(
              'Made with Flutter for macOS',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.text.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Data sourced from Sunnah.com API',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.text.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String content;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
