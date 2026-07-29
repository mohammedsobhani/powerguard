import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../providers/insight_engine.dart'; // ✅ FIX: Corrected folder relative path tracking

class AiScreen extends ConsumerWidget {
  const AiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch our live-computed engine rules stream
    final insights = ref.watch(liveInsightsProvider);

    // Calculate how many total battery points can be reclaimed right now
    final potentialSavings = insights.fold<int>(
      0,
          (sum, item) => sum + (item.potentialSavingPct ?? 0),
    );

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
          'AI DIAGNOSTICS',
          style: GoogleFonts.syne(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── TOP IMPACT SUMMARY CONTAINER ──────────────────────────────────
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(AppConstants.screenPadding),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'POTENTIAL RECLAIMABLE POWER',
                        style: GoogleFonts.dmMono(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Extends life by up to $potentialSavings%',
                        style: GoogleFonts.syne(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '+$potentialSavings%',
                  style: GoogleFonts.syne(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // ── CORE INSIGHTS SCROLLABLE LIST ─────────────────────────────────
          Expanded(
            child: insights.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🛡️', style: TextStyle(fontSize: 36)),
                  const SizedBox(height: 12),
                  Text(
                    'System Fully Optimized',
                    style: GoogleFonts.syne(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.good,
                    ),
                  ),
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenPadding,
                vertical: 10,
              ),
              itemCount: insights.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = insights[index];

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Emoji + Title + Severity Tag
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.emoji, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: GoogleFonts.syne(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.sublabel,
                                  style: GoogleFonts.dmMono(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: item.color,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Main Description Body Detail text
                      Text(
                        item.detail,
                        style: GoogleFonts.dmMono(
                          fontSize: 11,
                          color: AppColors.mutedDark,
                          height: 1.4,
                        ),
                      ),

                      // Action Button Block
                      if (item.actionLabel != null) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 38,
                          child: ElevatedButton(
                            onPressed: () {
                              debugPrint('Triggering Optimization Key: ${item.actionKey}');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.surface2Dark,
                              foregroundColor: item.color,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide( // ✅ FIX: BorderSide instead of Border.all
                                  color: item.color.withValues(alpha: 0.25),
                                ),
                              ),
                            ),
                            child: Text(
                              item.actionLabel!.toUpperCase(),
                              style: GoogleFonts.dmMono(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
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