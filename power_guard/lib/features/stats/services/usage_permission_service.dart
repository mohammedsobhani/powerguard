import 'package:flutter/services.dart';

class UsagePermissionService {
  static const MethodChannel _channel = MethodChannel('com.example.power_guard/usage_stats');

  /// Checks if the PACKAGE_USAGE_STATS permission is already granted by the OS
  static Future<bool> isPermissionGranted() async {
    try {
      final bool granted = await _channel.invokeMethod('checkUsagePermission');
      return granted;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Opens the native Android 'Apps with Usage Access' system settings panel
  static Future<void> openSettings() async {
    try {
      await _channel.invokeMethod('openUsageSettings');
    } on PlatformException catch (e) {
      print("Could not open settings: ${e.message}");
    }
  }
}