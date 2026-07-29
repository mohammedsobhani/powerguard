import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/dashboard_provider.dart';

class HealthScoreCard extends ConsumerWidget {
  const HealthScoreCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final battery = ref.watch(batteryProvider);

    return Container(
      margin: const EdgeInsets.only(top: AppConstants.itemSpacing),
      padding: const EdgeInsets.all(AppConstants.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title Header ────────────────────────────────
          Text(
            'BATTERY HEALTH & LIFECYCLE',
            style: GoogleFonts.dmMono(
              fontSize: 10,
              letterSpacing: 1.5,
              color: AppColors.mutedDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // ── Score & Stats Main Row ───────────────────────
          Row(
            children: [
              // Large Circular/Radial Percentage Layout Vibe
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.good.withValues(alpha: 0.2),
                    width: 6,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${battery.healthScore}%',
                    style: GoogleFonts.syne(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.good,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Breakdown Technical Stats Column
              Expanded(
                child: Column(
                  children: [
                    _HealthDetailRow(
                      label: 'Condition',
                      value: battery.healthScore >= 80 ? 'Excellent' : 'Service Required',
                      valueColor: battery.healthScore >= 80 ? AppColors.good : AppColors.warn,
                    ),
                    Divider(color: AppColors.borderDark.withValues(alpha: 0.4), height: 12),
                    _HealthDetailRow(
                      label: 'Cycle Count',
                      value: '${battery.cycleCount} / 500',
                    ),
                    Divider(color: AppColors.borderDark.withValues(alpha: 0.4), height: 12),
                    _HealthDetailRow(
                      label: 'Voltage Peak',
                      value: '${battery.voltage} V',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthDetailRow extends StatelessWidget {
  const _HealthDetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmMono(
            fontSize: 11,
            color: AppColors.mutedDark,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.syne(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textDark,
          ),
        ),
      ],
    );
  }
}