import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/dashboard_provider.dart';

class AiInsightCard extends ConsumerWidget {
  const AiInsightCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(aiInsightsProvider);

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
            'AI BATTERY INSIGHTS',
            style: GoogleFonts.dmMono(
              fontSize: 10,
              letterSpacing: 1.5,
              color: AppColors.mutedDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // ── Horizontal Insights Slider ─────────────────
          SizedBox(
            height: 95,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: insights.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final insight = insights[index];

                return Container(
                  width: 260,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface2Dark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: insight.color.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Emoji/Icon Indicator
                      Text(
                        insight.emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 10),

                      // Message Breakdown Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              insight.message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.syne(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textDark,
                                height: 1.3,
                              ),
                            ),
                            Text(
                              insight.sublabel,
                              style: GoogleFonts.dmMono(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: insight.color,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}