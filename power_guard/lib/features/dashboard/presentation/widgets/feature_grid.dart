import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/dashboard_provider.dart';

class FeatureGrid extends ConsumerWidget {
  const FeatureGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final features = ref.watch(smartFeaturesProvider);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: features.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) {
        final feature = features[index];

        // Pick colors reflecting activation state
        final statusColor = feature.status == FeatureStatus.active
            ? AppColors.good
            : feature.status == FeatureStatus.training
            ? AppColors.primary
            : AppColors.mutedDark;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: feature.isEnabled
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.borderDark,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Details Area: Emoji + Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.surface2Dark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        feature.emoji,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),

                  // Small sleek custom tracking toggle switch
                  SizedBox(
                    height: 20,
                    width: 35,
                    child: Transform.scale(
                      scale: 0.7,
                      child: Switch(
                        value: feature.isEnabled,
                        activeThumbColor: AppColors.primary,
                        activeTrackColor: AppColors.primary.withValues(alpha: 0.2),
                        inactiveThumbColor: AppColors.mutedDark,
                        inactiveTrackColor: AppColors.surface2Dark,
                        onChanged: (val) {
                          HapticFeedback.lightImpact();
                          ref.read(smartFeaturesProvider.notifier).toggle(index);
                        },
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom Details Area: Labels + Status Badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.syne(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        feature.status.name.toUpperCase(),
                        style: GoogleFonts.dmMono(
                          fontSize: 8,
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
        );
      },
    );
  }
}