import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/hadith/hadith_bloc.dart';
import '../../bloc/hadith/hadith_state.dart';
import '../../data/repositories/hadith_repository.dart';
import '../../core/theme/app_colors.dart';

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
      final repository = (context.read<HadithBloc>() as HadithBloc).repository;
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading Statistics',
              style: GoogleFonts.notoNaskhArabic(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
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
                    color: AppColors.text.withOpacity(0.1),
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
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary.withOpacity(0.7),
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.notoNaskhArabic(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.text.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
