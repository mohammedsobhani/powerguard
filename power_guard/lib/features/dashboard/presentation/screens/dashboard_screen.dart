import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../widgets/battery_hero_card.dart';
import '../widgets/power_mode_row.dart';
import '../widgets/smart_kill_card.dart';
import '../widgets/health_score_card.dart';
import '../widgets/drain_chart_card.dart';
import '../widgets/ai_insight_card.dart';
import '../widgets/feature_grid.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ─────────────────────────────────
          SliverToBoxAdapter(
            child: _DashboardAppBar()
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.2, end: 0, duration: 400.ms),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.screenPadding,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Battery Hero ───────────────────────
                const BatteryHeroCard()
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 500.ms)
                    .slideY(begin: 0.1, end: 0),

                // ── Power Modes ────────────────────────
                const PgSectionHeader(title: 'POWER MODE'),
                const PowerModeRow().animate().fadeIn(
                  delay: 150.ms,
                  duration: 500.ms,
                ),

                // ── Smart Kill ─────────────────────────
                const SmartKillCard().animate().fadeIn(
                  delay: 200.ms,
                  duration: 500.ms,
                ),

                // ── Health Score ───────────────────────
                const HealthScoreCard().animate().fadeIn(
                  delay: 250.ms,
                  duration: 500.ms,
                ),

                // ── Drain Chart ────────────────────────
                const DrainChartCard().animate().fadeIn(
                  delay: 300.ms,
                  duration: 500.ms,
                ),

                // ── AI Insights ────────────────────────
                const AiInsightCard().animate().fadeIn(
                  delay: 350.ms,
                  duration: 500.ms,
                ),

                // ── Smart Features Grid ────────────────
                const PgSectionHeader(title: 'SMART FEATURES'),
                const FeatureGrid().animate().fadeIn(
                  delay: 400.ms,
                  duration: 500.ms,
                ),

                // Bottom safe area padding
                const SizedBox(height: 90),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// APP BAR
// ─────────────────────────────────────────────────────────────────────────────
class _DashboardAppBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: AppConstants.screenPadding,
        right: AppConstants.screenPadding,
        bottom: 8,
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 14,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Center(
              child: Text('⚡', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PowerGuard',
                style: GoogleFonts.syne(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                'SMART BATTERY AI',
                style: GoogleFonts.dmMono(
                  fontSize: 9,
                  letterSpacing: 2,
                  color: AppColors.mutedDark,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Notification bell
          _NotifButton(),
        ],
      ),
    );
  }
}

class _NotifButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.textDark,
              size: 20,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: AppColors.bad,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surfaceDark, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
