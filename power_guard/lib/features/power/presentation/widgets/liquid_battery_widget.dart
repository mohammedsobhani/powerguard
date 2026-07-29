import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'wave_painter.dart';

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