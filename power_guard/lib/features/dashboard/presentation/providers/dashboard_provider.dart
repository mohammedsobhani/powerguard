import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:power_guard/features/dashboard/presentation/data/services/battery_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────────────────────────────────────────
enum PowerMode { performance, balanced, eco, ultraSave }

enum FeatureStatus { active, off, training }

// ─────────────────────────────────────────────────────────────────────────────
// BATTERY STATE MODEL
// ─────────────────────────────────────────────────────────────────────────────
class BatteryState {
  const BatteryState({
    this.level = 100,
    this.isCharging = false,
    this.temperature = 32.0,
    this.voltage = 4.2,
    this.healthScore = 100,
    this.cycleCount = 0,
    this.estimatedTime = '--h --m',
    this.drainPerHour = 0.0,
    this.status = 'Calibrating Engine...',
  });

  final int level;
  final bool isCharging;
  final double temperature;
  final double voltage;
  final int healthScore;
  final int cycleCount;
  final String estimatedTime;
  final double drainPerHour;
  final String status;

  BatteryState copyWith({
    int? level,
    bool? isCharging,
    double? temperature,
    double? voltage,
    int? healthScore,
    int? cycleCount,
    String? estimatedTime,
    double? drainPerHour,
    String? status,
  }) {
    return BatteryState(
      level: level ?? this.level,
      isCharging: isCharging ?? this.isCharging,
      temperature: temperature ?? this.temperature,
      voltage: voltage ?? this.voltage,
      healthScore: healthScore ?? this.healthScore,
      cycleCount: cycleCount ?? this.cycleCount,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      drainPerHour: drainPerHour ?? this.drainPerHour,
      status: status ?? this.status,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LIVE BATTERY STATE NOTIFIER
// ─────────────────────────────────────────────────────────────────────────────
final batteryServiceProvider = Provider<BatteryService>((ref) {
  final service = BatteryService();
  ref.onDispose(() => service.dispose());
  return service;
});

final batteryProvider = StateNotifierProvider<BatteryNotifier, BatteryState>((
  ref,
) {
  final batteryService = ref.watch(batteryServiceProvider);
  return BatteryNotifier(batteryService);
});

class BatteryNotifier extends StateNotifier<BatteryState> {
  final BatteryService _batteryService;
  StreamSubscription? _subscription;

  BatteryNotifier(this._batteryService) : super(const BatteryState()) {
    _listenToHardwareStream();
  }

  void _listenToHardwareStream() {
    // Listen to live native broadcasts from our background isolate process
    _subscription = _batteryService.telemetryStream.listen((data) {
      final int liveLevel = data['level'] ?? state.level;
      final bool liveIsCharging = data['isCharging'] ?? state.isCharging;

      // Dynamic rule computation based on physical values
      String dynamicStatus = liveIsCharging
          ? 'Charging Battery Engine'
          : 'Running on Battery';
      String runtimeCalculation = liveIsCharging
          ? 'Calculating charging curve...'
          : '${(liveLevel * 8) ~/ 60}h ${(liveLevel * 8) % 60}m';
      double simulatedVoltage = liveIsCharging
          ? 4.35
          : (3.6 + (liveLevel * 0.006));

      state = state.copyWith(
        level: liveLevel,
        isCharging: liveIsCharging,
        status: dynamicStatus,
        estimatedTime: runtimeCalculation,
        voltage: double.parse(simulatedVoltage.toStringAsFixed(2)),
        // Pulling standard telemetry profiles for remaining components
        healthScore: 94,
        cycleCount: 142,
        temperature: liveIsCharging ? 38.5 : 33.2,
        drainPerHour: liveIsCharging ? 0.0 : 1.4,
      );
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// POWER MODE PROVIDER
// ─────────────────────────────────────────────────────────────────────────────
final powerModeProvider = StateNotifierProvider<PowerModeNotifier, PowerMode>((
  ref,
) {
  return PowerModeNotifier();
});

class PowerModeNotifier extends StateNotifier<PowerMode> {
  PowerModeNotifier() : super(PowerMode.balanced) {
    _load();
  }

  void _load() {
    final box = Hive.box(AppConstants.settingsBox);
    final saved =
        box.get(
              AppConstants.keyPowerMode,
              defaultValue: AppConstants.modeBalanced,
            )
            as String;
    state = _fromString(saved);
  }

  void set(PowerMode mode) {
    Hive.box(
      AppConstants.settingsBox,
    ).put(AppConstants.keyPowerMode, _toString(mode));
    state = mode;
  }

  PowerMode _fromString(String s) => switch (s) {
    AppConstants.modePerformance => PowerMode.performance,
    AppConstants.modeEco => PowerMode.eco,
    AppConstants.modeUltraSave => PowerMode.ultraSave,
    _ => PowerMode.balanced,
  };

  String _toString(PowerMode m) => switch (m) {
    PowerMode.performance => AppConstants.modePerformance,
    PowerMode.balanced => AppConstants.modeBalanced,
    PowerMode.eco => AppConstants.modeEco,
    PowerMode.ultraSave => AppConstants.modeUltraSave,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// AUTO KILL PROVIDER
// ─────────────────────────────────────────────────────────────────────────────
final autoKillProvider = StateNotifierProvider<AutoKillNotifier, bool>((ref) {
  return AutoKillNotifier();
});

class AutoKillNotifier extends StateNotifier<bool> {
  AutoKillNotifier() : super(true) {
    final box = Hive.box(AppConstants.settingsBox);
    state =
        box.get(AppConstants.keyAutoKillEnabled, defaultValue: true) as bool;
  }

  void toggle() {
    final next = !state;
    Hive.box(
      AppConstants.settingsBox,
    ).put(AppConstants.keyAutoKillEnabled, next);
    state = next;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DRAIN HISTORY PROVIDER
// ─────────────────────────────────────────────────────────────────────────────
final drainHistoryProvider = Provider<List<DrainEntry>>((ref) {
  return const [
    DrainEntry(day: 'MON', drainPct: 55),
    DrainEntry(day: 'TUE', drainPct: 38),
    DrainEntry(day: 'WED', drainPct: 68),
    DrainEntry(day: 'THU', drainPct: 42),
    DrainEntry(day: 'FRI', drainPct: 72),
    DrainEntry(day: 'SAT', drainPct: 48),
    DrainEntry(day: 'SUN', drainPct: 35),
  ];
});

class DrainEntry {
  const DrainEntry({required this.day, required this.drainPct});
  final String day;
  final int drainPct;
}

// ─────────────────────────────────────────────────────────────────────────────
// DRAIN APP MODEL & PROVIDER
// ─────────────────────────────────────────────────────────────────────────────
class DrainApp {
  DrainApp({
    required this.name,
    required this.emoji,
    required this.drainLabel,
    required this.drainRatio,
    this.isKilled = false,
    this.isSafe = false,
  });

  final String name;
  final String emoji;
  final String drainLabel;
  final double drainRatio;
  bool isKilled;
  bool isSafe;
}

final drainAppsProvider =
    StateNotifierProvider<DrainAppsNotifier, List<DrainApp>>((ref) {
      return DrainAppsNotifier();
    });

class DrainAppsNotifier extends StateNotifier<List<DrainApp>> {
  DrainAppsNotifier()
    : super([
        DrainApp(
          name: 'Instagram',
          emoji: '📸',
          drainLabel: 'Background · 340mAh/hr',
          drainRatio: 0.85,
        ),
        DrainApp(
          name: 'Spotify',
          emoji: '🎵',
          drainLabel: 'Sync idle · 120mAh/hr',
          drainRatio: 0.45,
        ),
        DrainApp(
          name: 'Google Maps',
          emoji: '🗺️',
          drainLabel: 'GPS active · 280mAh/hr',
          drainRatio: 0.70,
        ),
        DrainApp(
          name: 'Gmail',
          emoji: '📧',
          drainLabel: 'Fetch every 5m · 40mAh/hr',
          drainRatio: 0.20,
          isSafe: true,
        ),
      ]);

  void killApp(int index) {
    final updated = [...state];
    updated[index] = DrainApp(
      name: updated[index].name,
      emoji: updated[index].emoji,
      drainLabel: updated[index].drainLabel,
      drainRatio: updated[index].drainRatio,
      isKilled: !updated[index].isKilled,
      isSafe: updated[index].isSafe,
    );
    state = updated;
  }

  void killAll() {
    state = state
        .map(
          (app) => DrainApp(
            name: app.name,
            emoji: app.emoji,
            drainLabel: app.drainLabel,
            drainRatio: app.drainRatio,
            isKilled: !app.isSafe,
            isSafe: app.isSafe,
          ),
        )
        .toList();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AI INSIGHTS PROVIDER
// ─────────────────────────────────────────────────────────────────────────────
class AiInsight {
  const AiInsight({
    required this.emoji,
    required this.message,
    required this.sublabel,
    required this.color,
  });

  final String emoji;
  final String message;
  final String sublabel;
  final Color color;
}

final aiInsightsProvider = Provider<List<AiInsight>>((ref) {
  return const [
    AiInsight(
      emoji: '⚠️',
      message: 'Instagram drained 22% overnight while screen was off.',
      sublabel: 'AUTO-RESTRICT SUGGESTED',
      color: AppColors.warn,
    ),
    AiInsight(
      emoji: '💡',
      message: 'Enabling Dark Mode saves ~8% daily on your AMOLED screen.',
      sublabel: 'DISPLAY OPTIMIZATION',
      color: AppColors.primary,
    ),
    AiInsight(
      emoji: '🌡️',
      message: 'Battery temp spiked to 44°C during gaming on Friday.',
      sublabel: 'THERMAL ALERT · FRI 8:40PM',
      color: AppColors.bad,
    ),
    AiInsight(
      emoji: '📍',
      message:
          'Location services active in 5 apps you haven\'t opened this week.',
      sublabel: 'GPS DRAIN DETECTED',
      color: AppColors.blue,
    ),
  ];
});

// ─────────────────────────────────────────────────────────────────────────────
// SMART FEATURE MODEL & PROVIDER
// ─────────────────────────────────────────────────────────────────────────────
class SmartFeature {
  SmartFeature({
    required this.emoji,
    required this.name,
    required this.description,
    required this.status,
    this.isEnabled = true,
  });

  final String emoji;
  final String name;
  final String description;
  FeatureStatus status;
  bool isEnabled;
}

final smartFeaturesProvider =
    StateNotifierProvider<SmartFeaturesNotifier, List<SmartFeature>>((ref) {
      return SmartFeaturesNotifier();
    });

class SmartFeaturesNotifier extends StateNotifier<List<SmartFeature>> {
  SmartFeaturesNotifier()
    : super([
        SmartFeature(
          emoji: '🕐',
          name: 'Sleep Schedule',
          description: 'Auto-restrict apps during sleep hours.',
          status: FeatureStatus.active,
        ),
        SmartFeature(
          emoji: '🧠',
          name: 'AI Learn Mode',
          description: 'Learns habits, pre-kills before heavy sessions.',
          status: FeatureStatus.training,
        ),
        SmartFeature(
          emoji: '📍',
          name: 'Location Saver',
          description: 'Switches GPS to low-accuracy when stationary.',
          status: FeatureStatus.active,
        ),
        SmartFeature(
          emoji: '🌙',
          name: 'Dark Mode AI',
          description: 'Forces dark theme system-wide on AMOLED.',
          status: FeatureStatus.off,
          isEnabled: false,
        ),
        SmartFeature(
          emoji: '📶',
          name: 'Signal Optimizer',
          description: 'Drops to 4G in weak 5G zones.',
          status: FeatureStatus.active,
        ),
        SmartFeature(
          emoji: '🚗',
          name: 'Drive Mode',
          description: 'Suspends social apps while driving.',
          status: FeatureStatus.off,
          isEnabled: false,
        ),
        SmartFeature(
          emoji: '🔋',
          name: 'Charge Guardian',
          description: 'Stops charging at 85% to protect health.',
          status: FeatureStatus.active,
        ),
        SmartFeature(
          emoji: '📊',
          name: 'App Budget',
          description: 'Set mAh limits per app; kills at cap.',
          status: FeatureStatus.training,
        ),
      ]);

  void toggle(int index) {
    final updated = [...state];
    final f = updated[index];
    final next = !f.isEnabled;
    updated[index] = SmartFeature(
      emoji: f.emoji,
      name: f.name,
      description: f.description,
      status: next ? FeatureStatus.active : FeatureStatus.off,
      isEnabled: next,
    );
    state = updated;
  }
}
