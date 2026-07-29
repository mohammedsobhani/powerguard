import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// INSIGHT MODEL
// ─────────────────────────────────────────────────────────────────────────────

enum InsightSeverity { info, warning, critical }
enum InsightCategory { thermal, gps, display, network, app, charging, habit }

class Insight {
  const Insight({
    required this.id,
    required this.emoji,
    required this.title,
    required this.detail,
    required this.sublabel,
    required this.severity,
    required this.category,
    required this.color,
    this.actionLabel,
    this.actionKey,
    this.potentialSavingPct,
    this.timestamp,
  });

  final String           id;
  final String           emoji;
  final String           title;
  final String           detail;
  final String           sublabel;
  final InsightSeverity  severity;
  final InsightCategory  category;
  final Color            color;
  final String?          actionLabel;
  final String?          actionKey;
  final int?             potentialSavingPct;
  final DateTime?        timestamp;
}

// ─────────────────────────────────────────────────────────────────────────────
// INSIGHT RULE ENGINE
// Evaluates battery context and emits ranked insights
// ─────────────────────────────────────────────────────────────────────────────

class InsightRuleEngine {
  InsightRuleEngine._();

  /// Runs all rules against current context, returns sorted list
  static List<Insight> evaluate({
    required int         batteryLevel,
    required double      temperature,
    required double      drainPerHour,
    required bool        isCharging,
    required int         healthScore,
    required List<String> highDrainApps,
    required List<String> activeGpsApps,
    required bool        isDarkModeOn,
    required bool        is5GActive,
    required int         overnightDrainPct,
    required int         screenBrightnessPct,
  }) {
    final insights = <Insight>[];

    // ── Rule 1: Overnight background drain ────────────
    if (overnightDrainPct >= 15) {
      insights.add(Insight(
        id: 'overnight_drain',
        emoji: '⚠️',
        title: 'High overnight drain detected',
        detail:
        '${highDrainApps.isNotEmpty ? highDrainApps.first : "An app"} '
            'drained $overnightDrainPct% while screen was off.',
        sublabel: 'AUTO-RESTRICT SUGGESTED',
        severity: InsightSeverity.warning,
        category: InsightCategory.app,
        color: AppColors.warn,
        actionLabel: 'Restrict Now',
        actionKey: 'restrict_overnight',
        potentialSavingPct: overnightDrainPct ~/ 2,
        timestamp: DateTime.now(),
      ));
    }

    // ── Rule 2: Dark mode on AMOLED ───────────────────
    if (!isDarkModeOn) {
      insights.add(const Insight(
        id: 'dark_mode',
        emoji: '💡',
        title: 'Enable Dark Mode to save battery',
        detail: 'Enabling Dark Mode saves ~8% daily on AMOLED screens.',
        sublabel: 'DISPLAY OPTIMIZATION',
        severity: InsightSeverity.info,
        category: InsightCategory.display,
        color: AppColors.primary,
        actionLabel: 'Enable Dark Mode',
        actionKey: 'enable_dark_mode',
        potentialSavingPct: 8,
      ));
    }

    // ── Rule 3: High temperature ─────────────────────
    if (temperature >= AppConstants.highTempThreshold) {
      insights.add(Insight(
        id: 'high_temp',
        emoji: '🌡️',
        title: 'Battery temperature is high',
        detail:
        'Temp reached ${temperature.toInt()}°C. '
            'Avoid charging or heavy use until it cools.',
        sublabel: 'THERMAL ALERT · NOW',
        severity: temperature >= AppConstants.criticalTempThreshold
            ? InsightSeverity.critical
            : InsightSeverity.warning,
        category: InsightCategory.thermal,
        color: AppColors.bad,
        actionLabel: 'Enable Eco Mode',
        actionKey: 'enable_eco',
        potentialSavingPct: null,
        timestamp: DateTime.now(),
      ));
    }

    // ── Rule 4: GPS running in unused apps ────────────
    if (activeGpsApps.length >= 3) {
      insights.add(Insight(
        id: 'ghost_gps',
        emoji: '📍',
        title: 'GPS active in ${activeGpsApps.length} unused apps',
        detail:
        'Location services running in apps you haven\'t opened this week.',
        sublabel: 'GPS DRAIN DETECTED',
        severity: InsightSeverity.warning,
        category: InsightCategory.gps,
        color: AppColors.blue,
        actionLabel: 'Review GPS Apps',
        actionKey: 'review_gps',
        potentialSavingPct: 6,
        timestamp: DateTime.now(),
      ));
    }

    // ── Rule 5: Weak 5G signal ────────────────────────
    if (is5GActive) {
      insights.add(const Insight(
        id: 'weak_5g',
        emoji: '📶',
        title: 'Switch to 4G to reduce radio drain',
        detail:
        'Weak 5G signal forces radio to search harder, draining ~12% extra.',
        sublabel: 'SIGNAL OPTIMIZATION',
        severity: InsightSeverity.info,
        category: InsightCategory.network,
        color: AppColors.purple,
        actionLabel: 'Force 4G',
        actionKey: 'force_4g',
        potentialSavingPct: 12,
      ));
    }

    // ── Rule 6: Health score degrading ───────────────
    if (healthScore < 70) {
      insights.add(Insight(
        id: 'health_low',
        emoji: '🏥',
        title: 'Battery health is degrading',
        detail:
        'Health score $healthScore/100. Avoid charging overnight '
            'and enable Charge Guardian.',
        sublabel: 'BATTERY HEALTH',
        severity: InsightSeverity.critical,
        category: InsightCategory.charging,
        color: AppColors.bad,
        actionLabel: 'Enable Charge Guardian',
        actionKey: 'enable_charge_guardian',
        potentialSavingPct: null,
      ));
    }

    // ── Rule 7: High screen brightness ───────────────
    if (screenBrightnessPct >= 80) {
      insights.add(Insight(
        id: 'brightness',
        emoji: '☀️',
        title: 'Screen brightness is very high',
        detail:
        'Brightness at $screenBrightnessPct% is draining ~10% extra per day.',
        sublabel: 'DISPLAY DRAIN',
        severity: InsightSeverity.info,
        category: InsightCategory.display,
        color: AppColors.yellow,
        actionLabel: 'Auto-Brightness',
        actionKey: 'auto_brightness',
        potentialSavingPct: 10,
      ));
    }

    // ── Rule 8: Critical battery + charging paused ───
    if (batteryLevel <= AppConstants.criticalBatteryThreshold && !isCharging) {
      insights.add(Insight(
        id: 'critical_battery',
        emoji: '🔴',
        title: 'Critical battery level!',
        detail:
        'Only $batteryLevel% remaining. '
            'Ultra Save mode has been activated automatically.',
        sublabel: 'CRITICAL · AUTO ULTRA SAVE',
        severity: InsightSeverity.critical,
        category: InsightCategory.app,
        color: AppColors.bad,
        actionLabel: 'Find Charger',
        actionKey: 'critical_sos',
        potentialSavingPct: null,
        timestamp: DateTime.now(),
      ));
    }

    // Sort: critical → warning → info, then by saving potential
    insights.sort((a, b) {
      final severityOrder = {
        InsightSeverity.critical: 0,
        InsightSeverity.warning: 1,
        InsightSeverity.info: 2,
      };
      final cmp = severityOrder[a.severity]!
          .compareTo(severityOrder[b.severity]!);
      if (cmp != 0) return cmp;
      return (b.potentialSavingPct ?? 0)
          .compareTo(a.potentialSavingPct ?? 0);
    });

    return insights;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INSIGHT PROVIDER LAYER
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class InsightContext {
  const InsightContext({
    required this.batteryLevel,
    required this.temperature,
    required this.drainPerHour,
    required this.isCharging,
    required this.healthScore,
    required this.highDrainApps,
    required this.activeGpsApps,
    required this.isDarkModeOn,
    required this.is5GActive,
    required this.overnightDrainPct,
    required this.screenBrightnessPct,
  });

  final int           batteryLevel;
  final double        temperature;
  final double        drainPerHour;
  final bool          isCharging;
  final int           healthScore;
  final List<String> highDrainApps;
  final List<String> activeGpsApps;
  final bool          isDarkModeOn;
  final bool          is5GActive;
  final int           overnightDrainPct;
  final int           screenBrightnessPct;

  InsightContext copyWith({
    int? batteryLevel,
    double? temperature,
    double? drainPerHour,
    bool? isCharging,
    int? healthScore,
    List<String>? highDrainApps,
    List<String>? activeGpsApps,
    bool? isDarkModeOn,
    bool? is5GActive,
    int? overnightDrainPct,
    int? screenBrightnessPct,
  }) {
    return InsightContext(
      batteryLevel: batteryLevel ?? this.batteryLevel,
      temperature: temperature ?? this.temperature,
      drainPerHour: drainPerHour ?? this.drainPerHour,
      isCharging: isCharging ?? this.isCharging,
      healthScore: healthScore ?? this.healthScore,
      highDrainApps: highDrainApps ?? this.highDrainApps,
      activeGpsApps: activeGpsApps ?? this.activeGpsApps,
      isDarkModeOn: isDarkModeOn ?? this.isDarkModeOn,
      is5GActive: is5GActive ?? this.is5GActive,
      overnightDrainPct: overnightDrainPct ?? this.overnightDrainPct,
      screenBrightnessPct: screenBrightnessPct ?? this.screenBrightnessPct,
    );
  }
}

final insightContextProvider = NotifierProvider<InsightContextNotifier, InsightContext>(() {
  return InsightContextNotifier();
});

class InsightContextNotifier extends Notifier<InsightContext> {
  @override
  InsightContext build() {
    _connectBackgroundStreamChannel();

    return const InsightContext(
      batteryLevel:        73,
      temperature:         38.0,
      drainPerHour:        1.8,
      isCharging:          false,
      healthScore:         82,
      highDrainApps:       ['Instagram', 'TikTok'],
      activeGpsApps:       ['Uber', 'Maps', 'Weather', 'Instagram', 'Chrome'],
      isDarkModeOn:        false,
      is5GActive:          true,
      overnightDrainPct:   22,
      screenBrightnessPct: 85,
    );
  }

  void _connectBackgroundStreamChannel() {
    FlutterBackgroundService().on('updateTelemetry').listen((Map<String, dynamic>? event) {
      if (event != null) {
        final int liveLevel = event['level'] ?? state.batteryLevel;
        final bool liveCharging = event['isCharging'] ?? state.isCharging;

        state = state.copyWith(
          batteryLevel: liveLevel,
          isCharging: liveCharging,
        );
      }
    });
  }

  void update(InsightContext ctx) => state = ctx;

  void setTemperature(double t) {
    state = state.copyWith(temperature: t);
  }
}

// ── 3. LIVE ENGINE CONSUMER LINK ─────────────────────────────────────────────
final liveInsightsProvider = Provider.autoDispose<List<Insight>>((ref) {
  final ctx = ref.watch(insightContextProvider);

  return InsightRuleEngine.evaluate(
    batteryLevel:        ctx.batteryLevel,
    temperature:         ctx.temperature,
    drainPerHour:        ctx.drainPerHour,
    isCharging:          ctx.isCharging,
    healthScore:         ctx.healthScore,
    highDrainApps:       ctx.highDrainApps,
    activeGpsApps:       ctx.activeGpsApps,
    isDarkModeOn:        ctx.isDarkModeOn,
    is5GActive:          ctx.is5GActive,
    overnightDrainPct:   ctx.overnightDrainPct,
    screenBrightnessPct: ctx.screenBrightnessPct,
  );
});