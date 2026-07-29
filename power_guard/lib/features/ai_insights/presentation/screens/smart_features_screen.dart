import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';

class SmartFeaturesScreen extends ConsumerWidget {
  const SmartFeaturesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the global smart features list state notifier
    final features = ref.watch(smartFeaturesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'SMART AUTOMATIONS',
          style: GoogleFonts.syne(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppConstants.screenPadding),
        itemCount: features.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final feature = features[index];

          // Dynamically map state enum color keys
          final statusColor = feature.status == FeatureStatus.active
              ? AppColors.good
              : feature.status == FeatureStatus.training
              ? AppColors.primary
              : AppColors.mutedDark;

          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: feature.isEnabled
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : AppColors.borderDark,
                width: feature.isEnabled ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── TOP ROW: ICON + TITLE + TOGGLE ───────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surface2Dark,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              feature.emoji,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feature.name,
                              style: GoogleFonts.syne(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  feature.status.name.toUpperCase(),
                                  style: GoogleFonts.dmMono(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Sleek Modern Switch Interaction
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: feature.isEnabled,
                        activeThumbColor: AppColors.primary,
                        activeTrackColor: AppColors.primary.withValues(alpha: 0.2),
                        inactiveThumbColor: AppColors.mutedDark,
                        inactiveTrackColor: AppColors.surface2Dark,
                        onChanged: (val) {
                          HapticFeedback.lightImpact();
                          // Mutates state in real-time across home grids and monitors!
                          ref.read(smartFeaturesProvider.notifier).toggle(index);
                        },
                      ),
                    ),
                  ],
                ),

                // ── DYNAMIC DESCRIPTION EXPANSE PANEL ────────────────────────
                if (feature.isEnabled) ...[
                  const SizedBox(height: 16),
                  Divider(color: AppColors.borderDark.withValues(alpha: 0.5), height: 1),
                  const SizedBox(height: 14),
                  Text(
                    _getFeatureDescription(feature.name),
                    style: GoogleFonts.dmMono(
                      fontSize: 11,
                      color: AppColors.mutedDark,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // Pure Helper matching details panels based on module strings
  String _getFeatureDescription(String name) {
    switch (name) {
      case 'AI Drain Predictor':
        return 'Analyzing live machine learning models against discharge vectors to estimate real-time hardware runtime depletion profiles.';
      case 'Thermal Throttle':
        return 'Monitoring core thermal thresholds. Automatically caps clock execution profiles when system temperature crosses high parameters.';
      case 'Deep Sleep Sync':
        return 'Intercepting background radio communication states during hours of prolonged device passivity to halt standby leakage.';
      case 'Ultra Saving Mode':
        return 'Forces screen execution boundaries to strict low-frequency render pathways and suspends non-essential ecosystem updates.';
      default:
        return 'System automation sub-routine tracking hardware parameters to safely reduce performance current drawing coefficients.';
    }
  }
}