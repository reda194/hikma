import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/hadith/hadith_bloc.dart';

/// StatsWidget displays reading statistics
class StatsWidget extends StatefulWidget {
  const StatsWidget({super.key});

  @override
  State<StatsWidget> createState() => _StatsWidgetState();
}

class _StatsWidgetState extends State<StatsWidget> {
  int _todayCount = 0;
  int _weekCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    try {
      final repository = context.read<HadithBloc>().repository;
      final today = await repository.getTodayReadCount();
      final week = await repository.getWeekReadCount();

      if (mounted) {
        setState(() {
          _todayCount = today;
          _weekCount = week;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading Statistics',
              style: textTheme.titleMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.95),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      label: 'Today',
                      value: _todayCount.toString(),
                      icon: Icons.today,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color:
                        scheme.onSurface.withValues(alpha: isDark ? 0.2 : 0.12),
                  ),
                  Expanded(
                    child: _StatItem(
                      label: 'This Week',
                      value: _weekCount.toString(),
                      icon: Icons.date_range,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Icon(
          icon,
          color: scheme.primary,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: textTheme.displaySmall?.copyWith(
            fontSize: 38,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 12,
            color: scheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
