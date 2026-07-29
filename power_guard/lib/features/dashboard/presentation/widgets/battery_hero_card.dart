import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/dashboard_provider.dart';

class BatteryHeroCard extends ConsumerWidget {
  const BatteryHeroCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch our live hardware data provider channel stream
    final battery = ref.watch(batteryProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: [
          // Dynamic Live Percentage displays here!
          Text(
            '${battery.level}%',
            style: GoogleFonts.syne(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),

          // Charging state subtext configuration
          Text(
            battery.isCharging ? '⚡ CHARGING ACTIVE' : 'OPTIMIZED • DISCHARGING',
            style: GoogleFonts.dmMono(
              fontSize: 11,
              letterSpacing: 1.2,
              color: battery.isCharging ? AppColors.good : AppColors.mutedDark,
            ),
          ),
        ],
      ),
    );
  }
}