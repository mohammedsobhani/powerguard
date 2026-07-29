import 'package:flutter/material.dart'; // ── REQUIRED TO RESOLVE 'Color' ──
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import '../../../../core/theme/app_theme.dart'; // ── REQUIRED TO RESOLVE 'AppColors' ──

// ── 1. THE COMPLETE IMMUTABLE BATTERY STATE MODEL ───────────────────────────
class BatteryState {
  final int level;
  final bool isCharging;
  final int healthScore;
  final int cycleCount;
  final double voltage;

  BatteryState({
    this.level = 100,
    this.isCharging = false,
    this.healthScore = 94, // Matches your UI screenshot defaults
    this.cycleCount = 142,
    this.voltage = 4.35,
  });

  BatteryState copyWith({
    int? level,
    bool? isCharging,
    int? healthScore,
    int? cycleCount,
    double? voltage,
  }) {
    return BatteryState(
      level: level ?? this.level,
      isCharging: isCharging ?? this.isCharging,
      healthScore: healthScore ?? this.healthScore,
      cycleCount: cycleCount ?? this.cycleCount,
      voltage: voltage ?? this.voltage,
    );
  }
}

// ── 2. THE NOTIFIER BRIDGE CONTROLLER ────────────────────────────────────────
class BatteryNotifier extends AutoDisposeNotifier<BatteryState> {
  @override
  BatteryState build() {
    // Start listening to the hardware channel events immediately upon initialization
    _listenToHardwareTelemetry();
    return BatteryState();
  }

  void _listenToHardwareTelemetry() {
    FlutterBackgroundService().on('updateTelemetry').listen((Map<String, dynamic>? event) {
      if (event != null) {
        final int liveLevel = event['level'] ?? 100;
        final bool charging = event['isCharging'] ?? false;

        // Push state mutations to update all UI consumers instantly
        state = state.copyWith(
          level: liveLevel,
          isCharging: charging,
        );
      }
    });
  }
}

// ── 3. EXPOSED RIVERPOD GLOBAL PROVIDER ──────────────────────────────────────
final batteryProvider = NotifierProvider.autoDispose<BatteryNotifier, BatteryState>(() {
  return BatteryNotifier();
});

// ── 4. DATA MODEL EXPECTED BY AI INSIGHT CARD UI LAYOUT ELEMENTS ─────────────
class BatteryInsight {
  final String emoji;
  final String message;
  final String sublabel;
  final Color color;

  const BatteryInsight({
    required this.emoji,
    required this.message,
    required this.sublabel,
    required this.color,
  });
}

// ── 5. THE PROVIDER DEFINITION FOR THE INSIGHT CARD ──────────────────────────
final aiInsightsProvider = Provider.autoDispose<List<BatteryInsight>>((ref) {
  // Watch the real-time battery level to update recommendations dynamically
  final battery = ref.watch(batteryProvider);

  return [
    BatteryInsight(
      emoji: '🔋',
      message: battery.isCharging
          ? 'Rapid power delivery active. Thermal parameters nominal.'
          : 'Discharge cycle optimized. Screen power drain is within safe targets.',
      sublabel: 'SYSTEM ECO OPTIMIZED',
      color: AppColors.good, // No longer invalid constant value
    ),
    BatteryInsight(
      emoji: '📱',
      message: 'Background rogue telemetry tasks were suspended to prevent passive idle drain.',
      sublabel: 'BACKGROUND APP CONTROL',
      color: AppColors.good,
    ),
    BatteryInsight(
      emoji: '🌡️',
      message: 'Battery module operating matrix stable at ideal core health parameters.',
      sublabel: 'CORE THERMAL STABILITY',
      color: AppColors.good,
    ),
  ];
});
// ── ADD THIS TO THE BOTTOM OF YOUR dashboard_provider.dart ───────────────────

// 1. Structural data model matching the drain history chart rules
class DrainHistoryEntry {
  final String day;
  final int drainPct;

  const DrainHistoryEntry({
    required this.day,
    required this.drainPct,
  });
}

// 2. The missing provider definition that returns the 7-day data tracking
final drainHistoryProvider = Provider.autoDispose<List<DrainHistoryEntry>>((ref) {
  return [
    const DrainHistoryEntry(day: 'MON', drainPct: 32),
    const DrainHistoryEntry(day: 'TUE', drainPct: 58),
    const DrainHistoryEntry(day: 'WED', drainPct: 74),
    const DrainHistoryEntry(day: 'THU', drainPct: 42),
    const DrainHistoryEntry(day: 'FRI', drainPct: 28),
    const DrainHistoryEntry(day: 'SAT', drainPct: 51),
    const DrainHistoryEntry(day: 'SUN', drainPct: 15),
  ];
});
// ── ADD THIS TO THE VERY BOTTOM OF YOUR dashboard_provider.dart ──────────────

// 1. Enum expected by FeatureGrid to assign status dot colors
enum FeatureStatus { active, training, idle }

// 2. Structural data model for individual smart tiles
class SmartFeature {
  final String emoji;
  final String name;
  final FeatureStatus status;
  final bool isEnabled;

  const SmartFeature({
    required this.emoji,
    required this.name,
    required this.status,
    required this.isEnabled,
  });

  SmartFeature copyWith({String? emoji, String? name, FeatureStatus? status, bool? isEnabled}) {
    return SmartFeature(
      emoji: emoji ?? this.emoji,
      name: name ?? this.name,
      status: status ?? this.status,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

// 3. State Notifier to handle toggling features on and off smoothly
class SmartFeaturesNotifier extends AutoDisposeNotifier<List<SmartFeature>> {
  @override
  List<SmartFeature> build() {
    return [
      const SmartFeature(emoji: '🤖', name: 'AI Drain Predictor', status: FeatureStatus.active, isEnabled: true),
      const SmartFeature(emoji: '🌡️', name: 'Thermal Throttle', status: FeatureStatus.active, isEnabled: false),
      const SmartFeature(emoji: '💤', name: 'Deep Sleep Sync', status: FeatureStatus.training, isEnabled: true),
      const SmartFeature(emoji: '⚡', name: 'Ultra Saving Mode', status: FeatureStatus.idle, isEnabled: false),
    ];
  }

  // Handles the interactive toggle updates when a user changes a tile switch state
  void toggle(int index) {
    final currentList = [...state];
    final item = currentList[index];
    currentList[index] = item.copyWith(isEnabled: !item.isEnabled);
    state = currentList;
  }
}

// 4. Exposed global Riverpod provider instance watched by the FeatureGrid UI layout
final smartFeaturesProvider = NotifierProvider.autoDispose<SmartFeaturesNotifier, List<SmartFeature>>(() {
  return SmartFeaturesNotifier();
});

// ── ADD THIS TO THE ABSOLUTE BOTTOM OF YOUR dashboard_provider.dart ──────────

// 1. Enum defining your hardware profile options
enum PowerMode { performance, balanced, eco, ultraSave }

// 2. State Notifier to update the active mode state across the app architecture
class PowerModeNotifier extends AutoDisposeNotifier<PowerMode> {
  @override
  PowerMode build() {
    // Sets default profile to ECO mode on launch (matching your initial UI layout screenshot)
    return PowerMode.eco;
  }

  // Updates the state whenever a user clicks a different profile button tile
  void set(PowerMode dynamicMode) {
    state = dynamicMode;
  }
}

// 3. Exposed global Riverpod provider watched by your interactive Row widget UI
final powerModeProvider = NotifierProvider.autoDispose<PowerModeNotifier, PowerMode>(() {
  return PowerModeNotifier();
});

// ── ADD THIS TO THE ABSOLUTE BOTTOM OF YOUR dashboard_provider.dart ──────────

// 1. Data model tracking individual process memory blocks and execution states
class DrainAppEntry {
  final String emoji;
  final String name;
  final String drainLabel;
  final bool isSafe;
  final bool isKilled;

  const DrainAppEntry({
    required this.emoji,
    required this.name,
    required this.drainLabel,
    required this.isSafe,
    required this.isKilled,
  });

  DrainAppEntry copyWith({
    String? emoji,
    String? name,
    String? drainLabel,
    bool? isSafe,
    bool? isKilled,
  }) {
    return DrainAppEntry(
      emoji: emoji ?? this.emoji,
      name: name ?? this.name,
      drainLabel: drainLabel ?? this.drainLabel,
      isSafe: isSafe ?? this.isSafe,
      isKilled: isKilled ?? this.isKilled,
    );
  }
}

// 2. State Notifier managing interactive process suspension operations
class DrainAppsNotifier extends AutoDisposeNotifier<List<DrainAppEntry>> {
  @override
  List<DrainAppEntry> build() {
    // Populate with mock apps matching your original UI card screenshot layout
    return [
      const DrainAppEntry(emoji: '📸', name: 'Instagram', drainLabel: 'Background • 340mAh/hr', isSafe: false, isKilled: false),
      const DrainAppEntry(emoji: '🎵', name: 'Spotify', drainLabel: 'Sync Idle • 120mAh/hr', isSafe: false, isKilled: false),
      const DrainAppEntry(emoji: '💬', name: 'WhatsApp', drainLabel: 'Push Sync active', isSafe: true, isKilled: false),
      const DrainAppEntry(emoji: '🎮', name: 'Dead Cells', drainLabel: 'Cached RAM Sleep', isSafe: false, isKilled: false),
    ];
  }

  // Toggles the termination state of a single specific task
  void killApp(int index) {
    final currentList = [...state];
    final app = currentList[index];
    if (!app.isSafe) {
      currentList[index] = app.copyWith(isKilled: !app.isKilled);
      state = currentList;
    }
  }

  // Mass suspends all volatile background tasks simultaneously
  void killAll() {
    state = state.map((app) {
      return app.isSafe ? app : app.copyWith(isKilled: true);
    }).toList();
  }
}

// 3. Exposed global Riverpod provider channel watched by your SmartKillCard UI
final drainAppsProvider = NotifierProvider.autoDispose<DrainAppsNotifier, List<DrainAppEntry>>(() {
  return DrainAppsNotifier();
});