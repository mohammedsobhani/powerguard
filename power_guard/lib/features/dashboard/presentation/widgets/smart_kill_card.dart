import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/dashboard_provider.dart';

class SmartKillCard extends ConsumerWidget {
  const SmartKillCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apps = ref.watch(drainAppsProvider);
    final activeApps = apps.where((app) => !app.isKilled).toList();

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
          // ── Header Row ─────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SMART BACKGROUND KILL',
                    style: GoogleFonts.dmMono(
                      fontSize: 10,
                      letterSpacing: 1.5,
                      color: AppColors.mutedDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activeApps.isEmpty
                        ? 'System fully optimized'
                        : '${activeApps.length} Rogue apps draining power',
                    style: GoogleFonts.syne(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: activeApps.isEmpty ? AppColors.good : AppColors.textDark,
                    ),
                  ),
                ],
              ),
              if (activeApps.isNotEmpty)
                TextButton(
                  onPressed: () {
                    HapticFeedback.vibrate();
                    ref.read(drainAppsProvider.notifier).killAll();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'KILL ALL',
                    style: GoogleFonts.dmMono(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // ── App Drain List ─────────────────────────────
          if (apps.isEmpty)
            const SizedBox.shrink()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: apps.length,
              separatorBuilder: (_, __) => Divider(
                color: AppColors.borderDark.withValues(alpha: 0.5),
                height: 16,
              ),
              itemBuilder: (context, index) {
                final app = apps[index];
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: app.isKilled ? 0.35 : 1.0,
                  child: Row(
                    children: [
                      // App Emoji Icon Area
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surface2Dark,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            app.emoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // App Info Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.name,
                              style: GoogleFonts.syne(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: app.isKilled ? AppColors.mutedDark : AppColors.textDark,
                                decoration: app.isKilled ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              app.isKilled ? 'TERMINATED' : app.drainLabel,
                              style: GoogleFonts.dmMono(
                                fontSize: 9,
                                color: app.isKilled
                                    ? AppColors.good
                                    : app.isSafe
                                    ? AppColors.good
                                    : AppColors.mutedDark,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Kill / Revive Action Button
                      IconButton(
                        onPressed: app.isSafe
                            ? null
                            : () {
                          HapticFeedback.lightImpact();
                          ref.read(drainAppsProvider.notifier).killApp(index);
                        },
                        icon: Icon(
                          app.isKilled
                              ? Icons.refresh_rounded
                              : app.isSafe
                              ? Icons.verified_user_rounded
                              : Icons.gpp_bad_rounded,
                          size: 18,
                          color: app.isKilled
                              ? AppColors.primary
                              : app.isSafe
                              ? AppColors.good.withValues(alpha: 0.4)
                              : AppColors.bad.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}