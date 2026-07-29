import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:power_guard/core/theme/app_theme.dart';
import 'package:power_guard/core/constants/app_constants.dart';
import 'package:power_guard/core/router/app_router.dart';
import 'package:power_guard/features/onboarding/presentation/screens/powerguard_onboarding_wizard.dart';
import 'presentation/screens/app_navigation_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox(AppConstants.settingsBox);

  runApp(
    const ProviderScope(
      child: PowerGuardApp(),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await initializeBackgroundService();
  });
}

Future<void> initializeBackgroundService() async {
  if (kIsWeb) {
    debugPrint('PowerGuard: Background service initialization skipped on Web.');
    return;
  }

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'powerguard_status',
    'PowerGuard Status',
    description: 'Shows battery monitoring status',
    importance: Importance.low,
  );

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final androidPlugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.createNotificationChannel(channel);

  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onBackgroundStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'powerguard_status',
      initialNotificationTitle: 'PowerGuard Core Engine Active',
      initialNotificationContent: 'Monitoring hardware battery telemetry...',
      foregroundServiceNotificationId: 9432,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onBackgroundStart,
    ),
  );
}

@pragma('vm:entry-point')
void onBackgroundStart(ServiceInstance service) async {
  if (kIsWeb) return;

  final battery = Battery();

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  Timer.periodic(AppConstants.drainPollingInterval, (timer) async {
    try {
      final level = await battery.batteryLevel.timeout(const Duration(seconds: 2));
      final state = await battery.batteryState.timeout(const Duration(seconds: 2));

      service.invoke('updateTelemetry', {
        'level': level,
        'isCharging': state == BatteryState.charging,
      });
    } catch (e) {
      debugPrint('PowerGuard telemetry poll skipped: $e');
    }
  });
}

class PowerGuardApp extends StatelessWidget {
  const PowerGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PowerGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00E676),
        scaffoldBackgroundColor: const Color(0xFF050806),
      ),
      initialRoute: '/onboarding',
      routes: {
        // ✅ FIXED: Removed 'const' instantiation keys since screens manage state engines
        '/onboarding': (context) => const PowerGuardOnboardingWizard(),
        '/main_navigation': (context) => const AppNavigationShell(),
      }, // ✅ FIXED: Closed map parameters properly to remove syntax exceptions
    );
  }
}