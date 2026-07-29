import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';

class BatteryService {
  final _service = FlutterBackgroundService();
  final _telemetryController = StreamController<Map<String, dynamic>>.broadcast();

  BatteryService() {
    _initListener();
  }

  // Bind to the underlying background telemetry stream channel
  void _initListener() {
    _service.on('updateTelemetry').listen((event) {
      if (event != null) {
        _telemetryController.add(event);
      }
    });
  }

  // Expose the clean native hardware telemetry stream to Riverpod
  Stream<Map<String, dynamic>> get telemetryStream => _telemetryController.stream;

  // Manual fallback mechanism to ping the background thread for data right now
  void refreshTelemetry() {
    _service.invoke('refresh');
  }

  // Safely close stream channels when destroyed
  void dispose() {
    _telemetryController.close();
  }
}