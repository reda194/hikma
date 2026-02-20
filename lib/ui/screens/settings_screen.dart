import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/hadith_collection.dart';
import '../../data/models/user_settings.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../../bloc/settings/settings_state.dart';
import '../../bloc/settings/settings_event.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/stats_widget.dart';
import 'about_screen.dart';

/// SettingsScreen - User settings and preferences
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(const LoadSettings());
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: AppColors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          // Show error SnackBar for error states
          if (state is SettingsError) {
            _showErrorSnackBar(state.message);
          }
        },
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

          return Stack(
            children: [
              Positioned(
                top: -120,
                right: -60,
                child: _GlowBubble(
                  size: 260,
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: isDark ? 0.28 : 0.18),
                ),
              ),
              Positioned(
                bottom: -140,
                left: -70,
                child: _GlowBubble(
                  size: 240,
                  color: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: isDark ? 0.24 : 0.16),
                ),
              ),
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildHeaderCard(settings),
                  const SizedBox(height: 16),
                  const StatsWidget(),
                  const SizedBox(height: 18),
                  _buildSectionHeader(
                      context, 'Display', Icons.palette_outlined),
                  _buildCard(
                    children: [
                      _buildFontSizeTile(settings),
                      _buildDivider(),
                      _buildPopupLayoutTile(settings),
                      _buildDivider(),
                      _buildSwitchTile(
                        title: 'Dark Mode',
                        subtitle: 'Use dark theme',
                        value: settings.darkModeEnabled,
                        onChanged: (value) {
                          context
                              .read<SettingsBloc>()
                              .add(ToggleDarkMode(value));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader(
                      context, 'Hadith', Icons.menu_book_outlined),
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
                  _buildSectionHeader(
                    context,
                    'Notifications',
                    Icons.notifications_outlined,
                  ),
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
                  _buildSectionHeader(
                      context, 'Application', Icons.apps_outlined),
                  _buildCard(
                    children: [
                      _buildSwitchTile(
                        title: 'Auto-start at Login',
                        subtitle: 'Launch Hikma automatically when you log in',
                        value: settings.autoStartEnabled,
                        onChanged: (value) {
                          context
                              .read<SettingsBloc>()
                              .add(ToggleAutoStart(value));
                        },
                      ),
                      _buildDivider(),
                      _buildSwitchTile(
                        title: 'Show in Dock',
                        subtitle: 'Display Hikma icon in macOS Dock',
                        value: settings.showInDock,
                        onChanged: (value) {
                          context
                              .read<SettingsBloc>()
                              .add(ToggleShowInDock(value));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: FilledButton.tonalIcon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AboutScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.info_outline_rounded),
                      label: const Text('About Hikma'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(UserSettings settings) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            if (isDark)
              const Color(0xFF10314C)
            else
              AppColors.primary.withValues(alpha: 0.96),
            if (isDark) const Color(0xFF1A4364) else AppColors.primaryDark,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: isDark ? 0.28 : 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: AppColors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personalize Hikma',
                  style: GoogleFonts.tajawal(
                    color: scheme.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${settings.reminderInterval.displayLabel} reminders • ${settings.sourceCollection.displayName}',
                  style: GoogleFonts.tajawal(
                    color: scheme.onPrimary.withValues(alpha: 0.8),
                    fontSize: 13,
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

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    final color = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 0, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color.withValues(alpha: 0.92)),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color.withValues(alpha: 0.92),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    final isDark = _isDark(context);
    final scheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: isDark ? 0 : 0.8,
      shadowColor: AppColors.shadow,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: (isDark ? scheme.onSurface : AppColors.border).withValues(
            alpha: isDark ? 0.16 : 1,
          ),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: isDark ? 0.68 : 0.78),
          ),
          child: Column(children: children),
        ),
      ),
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

  Widget _buildPopupLayoutTile(UserSettings settings) {
    return ListTile(
      leading: const Icon(Icons.aspect_ratio_rounded),
      title: const Text('Popup Layout'),
      subtitle: Text(settings.popupLayoutMode.displayLabel),
      trailing: SegmentedButton<PopupLayoutMode>(
        segments: const [
          ButtonSegment(
            value: PopupLayoutMode.compact,
            label: Text('Compact'),
          ),
          ButtonSegment(
            value: PopupLayoutMode.spacious,
            label: Text('Spacious'),
          ),
        ],
        selected: {settings.popupLayoutMode},
        onSelectionChanged: (selection) {
          context.read<SettingsBloc>().add(
                UpdatePopupLayoutMode(selection.first),
              );
        },
      ),
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
    final scheme = Theme.of(context).colorScheme;

    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(
        title,
        style: GoogleFonts.tajawal(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      activeThumbColor: scheme.onPrimary,
      activeTrackColor: scheme.primary.withValues(alpha: 0.72),
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
                return _buildSelectionTile(
                  title: collection.displayName,
                  subtitle: collection.arabicName,
                  selected: collection == current,
                  onTap: () {
                    context.read<SettingsBloc>().add(
                          UpdateSourceCollection(collection),
                        );
                    Navigator.of(context).pop();
                  },
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
                return _buildSelectionTile(
                  title: interval.displayLabel,
                  selected: interval == current,
                  onTap: () {
                    context.read<SettingsBloc>().add(
                          UpdateReminderInterval(interval),
                        );
                    Navigator.of(context).pop();
                  },
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
                return _buildSelectionTile(
                  title: duration.displayLabel,
                  subtitle: duration == PopupDuration.manual
                      ? 'Popup stays visible until dismissed'
                      : null,
                  selected: duration == current,
                  onTap: () {
                    context.read<SettingsBloc>().add(
                          UpdatePopupDuration(duration),
                        );
                    Navigator.of(context).pop();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectionTile({
    required String title,
    String? subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected
              ? colorScheme.primary.withValues(alpha: 0.18)
              : Colors.transparent,
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        child: selected
            ? Icon(
                Icons.check_rounded,
                size: 14,
                color: colorScheme.primary,
              )
            : null,
      ),
    );
  }
}

class _GlowBubble extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowBubble({
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
              color.withValues(alpha: 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
