import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // ── Backgrounds ──────────────────────────────────────
  static const bgDark = Color(0xFF06080F);
  static const surfaceDark = Color(0xFF111520);
  static const surface2Dark = Color(0xFF181C28);
  static const borderDark = Color(0xFF1C2030);
  static const border2Dark = Color(0xFF242838);

  // ── Backgrounds Light ─────────────────────────────────
  static const bgLight = Color(0xFFF4F6FB);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const borderLight = Color(0xFFE8ECF2);

  // ── Accent Colors ────────────────────────────────────
  static const primary = Color(0xFF00E5A0); // neon green
  static const primaryDark = Color(0xFF00B87A);
  static const blue = Color(0xFF4D9FFF);
  static const yellow = Color(0xFFFFCC00);
  static const red = Color(0xFFFF5E5E);
  static const purple = Color(0xFFB06AFF);
  static const cyan = Color(0xFF00E5FF);

  // ── Text ─────────────────────────────────────────────
  static const textDark = Color(0xFFDDE2F0);
  static const mutedDark = Color(0xFF4A5270);
  static const textLight = Color(0xFF0D1017);
  static const mutedLight = Color(0xFF8A94AA);

  // ── Semantic ─────────────────────────────────────────
  static const good = Color(0xFF00E5A0);
  static const warn = Color(0xFFFFCC00);
  static const bad = Color(0xFFFF5E5E);

  // ── Gradients ────────────────────────────────────────
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF00FFCC)],
  );

  static const batteryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, Color(0xFF00FFB3)],
  );

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00E5A0), Color(0xFF00C8FF)],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// TYPOGRAPHY
// ─────────────────────────────────────────────────────────────────────────────

class AppTextStyles {
  AppTextStyles._();

  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      // Display — hero battery percentage
      displayLarge: GoogleFonts.syne(
        fontSize: 64,
        fontWeight: FontWeight.w800,
        letterSpacing: -3,
        color: textColor,
      ),
      displayMedium: GoogleFonts.syne(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        letterSpacing: -2,
        color: textColor,
      ),
      displaySmall: GoogleFonts.syne(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
        color: textColor,
      ),

      // Headlines
      headlineLarge: GoogleFonts.syne(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.syne(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.syne(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),

      // Title
      titleLarge: GoogleFonts.syne(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: GoogleFonts.syne(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleSmall: GoogleFonts.syne(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),

      // Body
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodySmall: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: textColor.withValues(alpha: 0.7), //  Modern way
      ),

      // Label — mono for data labels
      labelLarge: GoogleFonts.dmMono(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
        color: textColor,
      ),
      labelMedium: GoogleFonts.dmMono(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.5,
        color: textColor.withValues(alpha: 0.7), //  Modern way
      ),
      labelSmall: GoogleFonts.dmMono(
        fontSize: 9,
        fontWeight: FontWeight.w400,
        letterSpacing: 2,
        color: textColor.withValues(alpha: 0.5), //  Modern way
      ),
    );
  }

  static TextTheme get darkTextTheme => _buildTextTheme(AppColors.textDark);
  static TextTheme get lightTextTheme => _buildTextTheme(AppColors.textLight);
}

// ─────────────────────────────────────────────────────────────────────────────
// THEME DATA
// ─────────────────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      textTheme: AppTextStyles.darkTextTheme,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.blue,
        tertiary: AppColors.yellow,
        error: AppColors.red,
        surface: AppColors.surfaceDark,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: AppColors.textDark,
      ),
      cardTheme: CardThemeData(
        //  Fixed Type
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderDark),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.syne(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xF0111520),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.mutedDark,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
        space: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.syne(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.black;
          return AppColors.mutedDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.borderDark;
        }),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.borderDark,
        thumbColor: AppColors.primary,
        overlayColor: Color(0x2000E5A0),
      ),
      extensions: const [PowerGuardThemeExtension.dark],
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLight,
      textTheme: AppTextStyles.lightTextTheme,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryDark,
        secondary: AppColors.blue,
        tertiary: AppColors.yellow,
        error: AppColors.red,
        surface: AppColors.surfaceLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textLight,
      ),
      cardTheme: CardThemeData(
        //  Fixed Type
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderLight),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.syne(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textLight,
        ),
        iconTheme: const IconThemeData(color: AppColors.textLight),
      ),
      extensions: const [PowerGuardThemeExtension.light],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// THEME EXTENSION (custom tokens accessible via Theme.of(context))
// ─────────────────────────────────────────────────────────────────────────────

class PowerGuardThemeExtension
    extends ThemeExtension<PowerGuardThemeExtension> {
  const PowerGuardThemeExtension({
    required this.cardColor,
    required this.borderColor,
    required this.mutedColor,
    required this.surfaceColor,
  });

  final Color cardColor;
  final Color borderColor;
  final Color mutedColor;
  final Color surfaceColor;

  static const dark = PowerGuardThemeExtension(
    cardColor: AppColors.surfaceDark,
    borderColor: AppColors.borderDark,
    mutedColor: AppColors.mutedDark,
    surfaceColor: AppColors.surface2Dark,
  );

  static const light = PowerGuardThemeExtension(
    cardColor: AppColors.surfaceLight,
    borderColor: AppColors.borderLight,
    mutedColor: AppColors.mutedLight,
    surfaceColor: AppColors.bgLight,
  );

  @override
  PowerGuardThemeExtension copyWith({
    Color? cardColor,
    Color? borderColor,
    Color? mutedColor,
    Color? surfaceColor,
  }) {
    return PowerGuardThemeExtension(
      cardColor: cardColor ?? this.cardColor,
      borderColor: borderColor ?? this.borderColor,
      mutedColor: mutedColor ?? this.mutedColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
    );
  }

  @override
  PowerGuardThemeExtension lerp(
    ThemeExtension<PowerGuardThemeExtension>? other,
    double t,
  ) {
    if (other is! PowerGuardThemeExtension) return this;
    return PowerGuardThemeExtension(
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      mutedColor: Color.lerp(mutedColor, other.mutedColor, t)!,
      surfaceColor: Color.lerp(surfaceColor, other.surfaceColor, t)!,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// THEME MODE PROVIDER (Riverpod)
// ─────────────────────────────────────────────────────────────────────────────

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final box = Hive.box('settings');
    final savedMode = box.get('theme_mode', defaultValue: 'dark') as String;
    state = savedMode == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  void toggle() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    Hive.box(
      'settings',
    ).put('theme_mode', next == ThemeMode.dark ? 'dark' : 'light');
    state = next;
  }

  void setDark() {
    _set(ThemeMode.dark);
  }

  void setLight() {
    _set(ThemeMode.light);
  }

  void _set(ThemeMode mode) {
    Hive.box(
      'settings',
    ).put('theme_mode', mode == ThemeMode.dark ? 'dark' : 'light');
    state = mode;
  }
}
