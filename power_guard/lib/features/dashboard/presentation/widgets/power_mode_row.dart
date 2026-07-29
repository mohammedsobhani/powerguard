import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/dashboard_provider.dart';

class PowerModeRow extends ConsumerWidget {
  const PowerModeRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(powerModeProvider);

    // ✅ FIX: Removed 'const' keyword assignments from internal list generations
    final modes = [
      const _ModeItem(mode: PowerMode.performance, label: 'PERFORM', icon: Icons.bolt_rounded, activeColor: AppColors.bad),
      const _ModeItem(mode: PowerMode.balanced, label: 'BAL', icon: Icons.balance_rounded, activeColor: AppColors.primary),
      const _ModeItem(mode: PowerMode.eco, label: 'ECO', icon: Icons.eco_rounded, activeColor: AppColors.good),
      const _ModeItem(mode: PowerMode.ultraSave, label: 'ULTRA', icon: Icons.battery_saver_rounded, activeColor: AppColors.warn),
    ];

    return Row(
      children: List.generate(modes.length, (index) {
        final item = modes[index];
        final isActive = currentMode == item.mode;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == modes.length - 1 ? 0 : 8,
            ),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                ref.read(powerModeProvider.notifier).set(item.mode);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isActive
                      ? item.activeColor.withValues(alpha: 0.12)
                      : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isActive ? item.activeColor : AppColors.borderDark,
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      item.icon,
                      size: 20,
                      color: isActive ? item.activeColor : AppColors.mutedDark,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.label,
                      style: GoogleFonts.dmMono(
                        fontSize: 10,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? item.activeColor : AppColors.mutedDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ModeItem {
  final PowerMode mode;
  final String label;
  final IconData icon;
  final Color activeColor;

  const _ModeItem({
    required this.mode,
    required this.label,
    required this.icon,
    required this.activeColor,
  });
}
