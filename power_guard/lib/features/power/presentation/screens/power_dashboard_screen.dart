import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:power_guard/features/power/data/models/battery_telemetry.dart';
import 'package:power_guard/features/power/data/repositories/telemetry_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 1. PRIMARY POWER DASHBOARD SCREEN VIEW LAYER
// ─────────────────────────────────────────────────────────────────────────────
class PowerDashboardScreen extends StatefulWidget {
  const PowerDashboardScreen({super.key});

  @override
  State<PowerDashboardScreen> createState() => _PowerDashboardScreenState();
}

class _PowerDashboardScreenState extends State<PowerDashboardScreen> {
  final TelemetryRepository _telemetryRepository = TelemetryRepository();
  late Stream<BatteryTelemetry> _telemetryStream;

  @override
  void initState() {
    super.initState();
    _telemetryStream = _telemetryRepository.telemetryStream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0D11),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'PowerGuard',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: StreamBuilder<BatteryTelemetry>(
        stream: _telemetryStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00E676)),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text('Error accessing core hardware streams.',
                  style: TextStyle(color: Colors.white)),
            );
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🌊 A. Reconfigured Circular SuperDart Battery Header Module
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14161D),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: LiquidBatteryWidget(
                    batteryLevel: data.batteryLevel / 100.0,
                  ),
                ),
                const SizedBox(height: 24),

                // 🎴 B. Auto-Detected 9-Card Diagnostic Telemetry Grid
                TelemetryGrid(telemetry: data),
                const SizedBox(height: 24),

                // 📊 C. Continuous Lifecycle History Footer Box
                _buildBatteryLifecycleCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBatteryLifecycleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF14161D),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BATTERY HEALTH & LIFECYCLE',
            style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          SizedBox(height: 16),
          Text(
            'Average Charge Time',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            '0 → 80% in ~1h 40m\n0 → 100% in ~4h 50m',
            style: TextStyle(color: Color(0xFFA0A1A9), fontSize: 13, height: 1.5),
          ),
          SizedBox(height: 8),
          Text(
            'Based on 298 cycles',
            style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. SUPERDART-INSPIRED LIQUID GYRO CIRCULAR ORB WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class LiquidBatteryWidget extends StatefulWidget {
  final double batteryLevel;

  const LiquidBatteryWidget({super.key, required this.batteryLevel});

  @override
  State<LiquidBatteryWidget> createState() => _LiquidBatteryWidgetState();
}

class _LiquidBatteryWidgetState extends State<LiquidBatteryWidget>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _particleController;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  double _tiltAngle = 0.0;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _accelerometerSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      if (mounted) {
        setState(() {
          double targetAngle = math.atan2(event.x, event.y);
          _tiltAngle = _tiltAngle * 0.85 + targetAngle * 0.15;
        });
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _particleController.dispose();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double canvasSize = 240.0;
    const double coreOrbSize = 165.0;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. ✨ THE MOLECULAR DOT ORBIT FIELD
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _particleController.value * 2 * math.pi,
                child: CustomPaint(
                  size: const Size(canvasSize, canvasSize),
                  painter: SuperDartParticlePainter(),
                ),
              );
            },
          ),

          // 2. 🔮 THE FLOATING GLOWING CIRCULAR LIQUID CORE
          Container(
            width: coreOrbSize,
            height: coreOrbSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00BFA5).withValues(alpha: 0.1),
                  const Color(0xFF0C0D11),
                ],
                radius: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF64FFDA).withValues(alpha: 0.25),
                  blurRadius: 30,
                  spreadRadius: 1,
                ),
                // ✅ FIXED: Replaced non-existent property 'insert: true' with native inner style blur parameters
                BoxShadow(
                  color: const Color(0xFF00E676).withValues(alpha: 0.15),
                  blurRadius: 12,
                  blurStyle: BlurStyle.inner,
                ),
              ],
            ),
            child: ClipOval(
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: -_tiltAngle,
                    alignment: Alignment.center,
                    child: CustomPaint(
                      size: const Size(coreOrbSize, coreOrbSize),
                      painter: WavePainter(
                        waveAnimation: _waveController.value,
                        fillLevel: widget.batteryLevel,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 3. 🏁 RE-ALIGNED TYPOGRAPHY OVERLAY (PowerGuard Underneath)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${(widget.batteryLevel * 100).toInt()}',
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    '%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'POWERGUARD',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                  color: const Color(0xFF64FFDA),
                  fontFamily: 'Courier New',
                  fontStyle: FontStyle.italic,
                  shadows: [
                    Shadow(
                      blurRadius: 8.0,
                      color: const Color(0xFF64FFDA).withValues(alpha: 0.5),
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

class SuperDartParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final Paint dotPaint = Paint()..style = PaintingStyle.fill;

    // Ring 1 (Inner Ring)
    const int innerCount = 36;
    const double innerRadius = 96.0;
    for (int i = 0; i < innerCount; i++) {
      final double angle = (i * 2 * math.pi) / innerCount;
      final double x = center.dx + innerRadius * math.cos(angle);
      final double y = center.dy + innerRadius * math.sin(angle);

      double dotSize = (i % 3 == 0) ? 2.5 : 1.2;
      dotPaint.color = Colors.white.withValues(alpha: (i % 2 == 0) ? 0.45 : 0.2);
      canvas.drawCircle(Offset(x, y), dotSize, dotPaint);
    }

    // Ring 2 (Outer Ring)
    const int outerCount = 48;
    const double outerRadius = 114.0;
    for (int i = 0; i < outerCount; i++) {
      final double angle = (i * 2 * math.pi) / outerCount;
      final double x = center.dx + outerRadius * math.cos(angle);
      final double y = center.dy + outerRadius * math.sin(angle);

      double dotSize = (i % 4 == 0) ? 2.0 : 1.0;
      dotPaint.color = Colors.white.withValues(alpha: (i % 3 == 0) ? 0.35 : 0.15);
      canvas.drawCircle(Offset(x, y), dotSize, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. MATHEMATICAL SINE-COSINE LIQUID WAVE PAINTER CANVAS ENGINE
// ─────────────────────────────────────────────────────────────────────────────
class WavePainter extends CustomPainter {
  final double waveAnimation;
  final double fillLevel;

  WavePainter({required this.waveAnimation, required this.fillLevel});

  @override
  void paint(Canvas canvas, Size size) {
    final double viewHeight = size.height;
    final double viewWidth = size.width;
    final double fillTargetHeight = viewHeight * (1.0 - fillLevel);

    const double waveAmplitude = 6.0;
    const double waveFrequency = 1.6;

    final Paint backPaint = Paint()
      ..color = const Color(0xFF00BFA5).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final Path backPath = Path()..moveTo(0, fillTargetHeight);

    final Paint frontPaint = Paint()
      ..color = const Color(0xFF00E676)
      ..style = PaintingStyle.fill;

    final Path frontPath = Path()..moveTo(0, fillTargetHeight);

    for (double x = 0; x <= viewWidth; x++) {
      final double backY = fillTargetHeight + math.sin((waveAnimation * 360 * math.pi / 180) + (x * waveFrequency * math.pi / viewWidth)) * waveAmplitude;
      backPath.lineTo(x, backY);

      final double frontY = fillTargetHeight + math.cos((waveAnimation * 360 * math.pi / 180) + (x * waveFrequency * math.pi / viewWidth)) * waveAmplitude;
      frontPath.lineTo(x, frontY);
    }

    backPath.lineTo(viewWidth, viewHeight); backPath.lineTo(0, viewHeight); backPath.close();
    frontPath.lineTo(viewWidth, viewHeight); frontPath.lineTo(0, viewHeight); frontPath.close();

    canvas.drawPath(backPath, backPaint);
    canvas.drawPath(frontPath, frontPaint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. THE AUTO-DETECTED 9-CARD HARDWARE TELEMETRY GRID MODULE
// ─────────────────────────────────────────────────────────────────────────────
class TelemetryGrid extends StatelessWidget {
  final BatteryTelemetry telemetry;
  const TelemetryGrid({super.key, required this.telemetry});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> items = [
      {'value': '${telemetry.voltage}mV', 'label': 'Voltage'},
      {'value': '${telemetry.temperature.toStringAsFixed(1)}°C', 'label': 'Temperature'},
      {'value': '${telemetry.batteryLevel}%', 'label': 'Battery Level'},
      {'value': telemetry.chargeStatus, 'label': 'Charge Status'},
      {'value': '${telemetry.maxCapacity} mAh', 'label': 'Max Capacity'},
      {'value': telemetry.pluggedStatus, 'label': 'Plugged'},
      {'value': telemetry.health, 'label': 'Health'},
      {'value': telemetry.manufacturer, 'label': 'Manufacturer'},
      {'value': telemetry.model, 'label': 'Model'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.12,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(color: const Color(0xFFEDEDE8), borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                items[index]['value']!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: -0.3),
              ),
              const SizedBox(height: 6),
              Text(
                items[index]['label']!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF757570), fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      },
    );
  }
}