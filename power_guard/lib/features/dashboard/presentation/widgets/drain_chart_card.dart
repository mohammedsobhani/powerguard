import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/dashboard_provider.dart';

class DrainChartCard extends ConsumerWidget {
  const DrainChartCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(drainHistoryProvider);

    return Container(
      margin: const EdgeInsets.only(top: AppConstants.sectionSpacing),
      padding: const EdgeInsets.all(AppConstants.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Text ────────────────────────────────
          Text(
            '7-DAY DRAIN HISTORY',
            style: GoogleFonts.dmMono(
              fontSize: 10,
              letterSpacing: 1.5,
              color: AppColors.mutedDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          // ── Chart Rows/Bars Container ──────────────────
          // ✅ FIX: Removed the illegal SliverToBoxAdapter block!
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: history.map((entry) {
                final barHeightRatio = (entry.drainPct / 100.0).clamp(0.05, 1.0);

                // Color codes based on how heavy the day's total drain was
                final barColor = entry.drainPct >= 65
                    ? AppColors.bad
                    : entry.drainPct >= 45
                    ? AppColors.warn
                    : AppColors.primary;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Percentage label above bar
                    Text(
                      '${entry.drainPct}%',
                      style: GoogleFonts.dmMono(
                        fontSize: 8,
                        color: AppColors.mutedDark,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Outer Bar bounding container
                    Expanded(
                      child: FractionallySizedBox(
                        heightFactor: barHeightRatio,
                        child: Container(
                          width: 14,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                barColor,
                                barColor.withValues(alpha: 0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Day String Label
                    Text(
                      entry.day,
                      style: GoogleFonts.dmMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}