// ─────────────────────────────────────────────────────────────────────────────
// APP CONSTANTS
// ─────────────────────────────────────────────────────────────────────────────

abstract class AppConstants {
  AppConstants._();

  // ── App Info ──────────────────────────────────────────
  static const appName = 'PowerGuard';
  static const appVersion = '1.0.0';
  static const appTagline = 'Smart Battery AI';

  // ── Hive Box Names ────────────────────────────────────
  static const settingsBox = 'settings'; // ✅ Maintained your original name
  static const drainHistoryBox = 'drain_history';
  static const appDataBox = 'app_data';

  // ── Hive Keys ─────────────────────────────────────────
  static const keyThemeMode = 'theme_mode';
  static const keyPowerMode = 'power_mode';
  static const keyAutoKillEnabled = 'auto_kill_enabled';
  static const keySleepStart = 'sleep_start_hour';
  static const keySleepEnd = 'sleep_end_hour';
  static const keyChargeGuardian = 'charge_guardian';
  static const keyChargeLimit = 'charge_limit'; // ✅ Kept your original key name
  static const keyDriveMode = 'drive_mode';
  static const keyGpsOptimizer = 'gps_optimizer';
  static const keySignalOptimizer = 'signal_optimizer';
  static const keyDarkModeEnforcer = 'dark_mode_enforcer';
  static const keyOnboardingDone = 'onboarding_done';
  static const keySosContact = 'sos_contact';
  static const keySosTriggerPct = 'sos_trigger_pct';

  // ✅ NEW UNIQUE KEYS ADDED CLEANLY:
  static const keyIsPro = 'is_pro_user';
  static const keyDischargeLimit = 'discharge_alarm_limit';
  static const keySelectedLanguage = 'app_language';

  // ── Battery Thresholds ────────────────────────────────
  static const chargeGuardianDefault = 85; // stop charging at 85%
  static const sosTriggerDefault = 10; // SOS at 10%
  static const lowBatteryThreshold = 20;
  static const criticalBatteryThreshold = 5;
  static const highTempThreshold = 42.0; // °C
  static const criticalTempThreshold = 48.0; // °C

  // ── Power Modes ───────────────────────────────────────
  static const modePerformance = 'performance';
  static const modeBalanced = 'balanced';
  static const modeEco = 'eco';
  static const modeUltraSave = 'ultra_save';

  // ── UI Dimensions ─────────────────────────────────────
  static const borderRadius = 20.0;
  static const borderRadiusSm = 12.0;
  static const borderRadiusLg = 28.0;
  static const cardPadding = 18.0;
  static const screenPadding = 16.0;
  static const sectionSpacing = 20.0;
  static const itemSpacing = 12.0;

  // ── Animation Durations ───────────────────────────────
  static const animFast = Duration(milliseconds: 200);
  static const animNormal = Duration(milliseconds: 350);
  static const animSlow = Duration(milliseconds: 600);
  static const animVerySlow = Duration(milliseconds: 1200);

  // ── Background Service ────────────────────────────────
  static const drainPollingInterval = Duration(minutes: 1);
  static const historyRetentionDays = 30;
}