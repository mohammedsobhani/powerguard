import 'package:flutter/foundation.dart'; // ── ✅ FIX: Resolves 'kDebugMode'
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import '../ai_insights/providers/insight_engine.dart';

class BatteryWidgetManager {
  BatteryWidgetManager._();

  // The unique string identifying your native Android AppWidgetProvider layer
  static const String _androidWidgetName = 'PowerGuardWidgetProvider';

  /// Serializes live Riverpod context data and flushes it to native widget storage
  static Future<void> updateWidgetData(InsightContext context, String topInsight) async {
    try {
      // 1. Write the values into the shared platform channel buffer
      await Future.wait([
        HomeWidget.saveWidgetData<int>('battery_level', context.batteryLevel),
        HomeWidget.saveWidgetData<bool>('is_charging', context.isCharging),
        HomeWidget.saveWidgetData<String>('top_insight', topInsight),
      ]);

      // 2. Signal the native Android launcher layout engine to force a frame redraw
      await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
      );
    } on PlatformException catch (e) {
      if (kDebugMode) {
        // ── ✅ FIX: Uses debugPrint instead of raw print to honor lint rules
        debugPrint('Failed to sync data to native Home Widget layer: $e');
      }
    }
  }
}