import 'package:flutter/material.dart';
import '../../data/models/battery_telemetry.dart'; // ✅ Simple local import

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
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEDEDE8),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                items[index]['value']!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                items[index]['label']!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF757570),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}