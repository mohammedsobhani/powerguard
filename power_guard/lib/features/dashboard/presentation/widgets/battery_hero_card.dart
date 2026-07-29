import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/dashboard_provider.dart';

class BatteryHeroCard extends ConsumerStatefulWidget {
  const BatteryHeroCard({super.key});

  @override
  ConsumerState<BatteryHeroCard> createState() => _BatteryHeroCardState();
}

class _BatteryHeroCardState extends ConsumerState<BatteryHeroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerCtrl;
  int _displayLevel = 0;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Animate battery % counter from 0 → real value
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final target = ref.read(batteryProvider).level;
      _animateCounter(target);
    });
  }

  void _animateCounter(int target) {
    final step = Duration(milliseconds: (900 ~/ target).clamp(12, 40));
    int current = 0;
    void tick(_) {
      if (!mounted) return;
      current = (current + 2).clamp(0, target);
      setState(() => _displayLevel = current);
      if (current < target) {
        Future.delayed(step, () => tick(null));
      }
    }

    tick(null);
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final battery = ref.watch(batteryProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.itemSpacing),
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: % + SVG battery ──────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BATTERY LEVEL',
                      style: GoogleFonts.dmMono(
                        fontSize: 10,
                        letterSpacing: 2.5,
                        color: AppColors.mutedDark,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Animated counter
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.heroGradient.createShader(bounds),
                      child: Text(
                        '$_displayLevel%',
                        style: GoogleFonts.syne(
                          fontSize: 62,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -3,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Status pill
                    Row(
                      children: [
                        _PulseDot(),
                        const SizedBox(width: 6),
                        Text(
                          battery.isCharging
                              ? 'CHARGING'
                              : 'OPTIMIZED · CHARGING PAUSED',
                          style: GoogleFonts.dmMono(
                            fontSize: 10,
                            letterSpacing: 1,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // SVG-style battery icon
              _BatteryIcon(level: battery.level),
            ],
          ),

          const SizedBox(height: 18),

          // ── Animated drain bar ────────────────────────
          _DrainBar(level: battery.level, shimmerCtrl: _shimmerCtrl),

          const SizedBox(height: 16),

          // ── Bottom stats row ──────────────────────────
          Row(
            children: [
              _StatChip(
                value: battery.estimatedTime,
                label: 'TIME LEFT',
                valueColor: AppColors.primary,
              ),
              const SizedBox(width: 10),
              _StatChip(
                value: '${battery.drainPerHour}W',
                label: 'DRAIN/HR',
                valueColor: AppColors.warn,
              ),
              const SizedBox(width: 10),
              _StatChip(
                value: '${battery.temperature.toInt()}°C',
                label: 'TEMP',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Pulse dot ───────────────────────────────────────────────────────────────
class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ─── Battery icon ─────────────────────────────────────────────────────────────
class _BatteryIcon extends StatelessWidget {
  const _BatteryIcon({required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    final fillColor = level >= 50
        ? AppColors.primary
        : level >= 20
        ? AppColors.warn
        : AppColors.bad;

    return SizedBox(
      width: 52,
      height: 88,
      child: CustomPaint(
        painter: _BatteryPainter(level: level / 100.0, fillColor: fillColor),
      ),
    );
  }
}

class _BatteryPainter extends CustomPainter {
  const _BatteryPainter({required this.level, required this.fillColor});
  final double level;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = AppColors.border2Dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final fillPaint = Paint()
      ..color = fillColor
          .withValues(alpha: 0.9) // Updated configuration
      ..style = PaintingStyle.fill;

    final capPaint = Paint()
      ..color = AppColors.border2Dark
      ..style = PaintingStyle.fill;

    const r = 8.0;

    // Terminal cap at top
    final capRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.28, 0, size.width * 0.44, 6),
      const Radius.circular(3),
    );
    canvas.drawRRect(capRect, capPaint);

    // Battery body outline
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 7, size.width, size.height - 7),
      Radius.circular(r),
    );
    canvas.drawRRect(bodyRect, borderPaint);

    // Fill area (clipped to body with padding)
    final fillHeight = (size.height - 7 - 8) * level;
    final fillTop = (size.height - 4) - fillHeight;

    final fillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(4, fillTop, size.width - 8, fillHeight),
      Radius.circular(r - 2),
    );

    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 9, size.width - 4, size.height - 13),
        Radius.circular(r - 1),
      ),
    );
    canvas.drawRRect(fillRect, fillPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BatteryPainter old) =>
      old.level != level || old.fillColor != fillColor;
}

// ─── Animated drain bar ───────────────────────────────────────────────────────
class _DrainBar extends StatelessWidget {
  const _DrainBar({required this.level, required this.shimmerCtrl});
  final int level;
  final AnimationController shimmerCtrl;

  @override
  Widget build(BuildContext context) {
    final barColor = level >= 50
        ? AppColors.primary
        : level >= 20
        ? AppColors.warn
        : AppColors.bad;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Track
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.surface2Dark,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Fill
            AnimatedContainer(
              duration: AppConstants.animVerySlow,
              curve: Curves.easeOut,
              height: 10,
              width: constraints.maxWidth * (level / 100.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    barColor,
                    barColor.withValues(alpha: 0.7),
                  ], // Updated configuration
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              // Shimmer overlay
              child: AnimatedBuilder(
                animation: shimmerCtrl,
                builder: (_, __) {
                  return ShaderMask(
                    blendMode: BlendMode.srcATop,
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment(shimmerCtrl.value * 3 - 1.5, 0),
                      end: Alignment(shimmerCtrl.value * 3, 0),
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(
                          alpha: 0.25,
                        ), // Updated configuration
                        Colors.transparent,
                      ],
                    ).createShader(bounds),
                    child: Container(color: Colors.white),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Stat chip ───────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  const _StatChip({required this.value, required this.label, this.valueColor});

  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface2Dark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.dmMono(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.dmMono(
                fontSize: 8,
                letterSpacing: 1,
                color: AppColors.mutedDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
