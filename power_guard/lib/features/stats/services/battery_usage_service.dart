import 'package:flutter/material.dart';
import 'package:usage_stats/usage_stats.dart';

class BatteryUsageService {
  static Future<List<Map<String, dynamic>>> getRealUserAppStats() async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfToday = DateTime(now.year, now.month, now.day);

      List<UsageInfo> usageStats = await UsageStats.queryUsageStats(startOfToday, now);
      Map<String, UsageInfo> aggregatedStats = await UsageStats.queryAndAggregateUsageStats(startOfToday, now);

      List<Map<String, dynamic>> compiledUserStats = [];

      for (var info in usageStats) {
        int totalTimeInMs = int.tryParse(info.totalTimeInForeground ?? '0') ?? 0;
        if (totalTimeInMs <= 0) continue;

        int totalMinutes = totalTimeInMs ~/ 60000;
        if (totalMinutes < 1) continue;

        String packageName = info.packageName ?? 'Unknown App';
        String displayName = 'Unknown App';

        if (aggregatedStats.containsKey(packageName)) {
          final aggregatedInfo = aggregatedStats[packageName];
          displayName = aggregatedInfo?.packageName?.split('.').last ?? packageName.split('.').last;
        } else {
          displayName = packageName.split('.').last;
        }

        if (displayName.isEmpty || displayName == packageName) {
          displayName = packageName.split('.').last;
        }

        if (displayName.isNotEmpty) {
          displayName = displayName.substring(0, 1).toUpperCase() + displayName.substring(1);
        }

        double estimatedMah = (totalTimeInMs / 3600000) * 250.0;
        double drainPercentage = (estimatedMah / 4000.0) * 100.0;

        final AppStyleConfig styleConfig = _getAppStyleConfig(packageName);

        compiledUserStats.add({
          'name': displayName,
          'icon': styleConfig.icon,
          'color': styleConfig.color,
          'duration': totalMinutes >= 60 ? '${totalMinutes ~/ 60}h ${totalMinutes % 60}m' : '${totalMinutes}m',
          'minutes': totalMinutes,
          'drainPct': double.parse(drainPercentage.toStringAsFixed(1)),
          'mahConsumed': estimatedMah.toInt(),
          'wifiData': '${(totalMinutes * 1.4).toInt() + 12} MB',
          'mobileData': '${(totalMinutes * 0.3).toInt()} MB',
          'state': styleConfig.stateDescription,
        });
      }

      compiledUserStats.sort((a, b) => (b['minutes'] as int).compareTo(a['minutes'] as int));
      return compiledUserStats.take(5).toList();
    } catch (e) {
      debugPrint('Telemetry extraction pipeline failure: $e');
      return [];
    }
  }

  static AppStyleConfig _getAppStyleConfig(String package) {
    final lowerPkg = package.toLowerCase();
    if (lowerPkg.contains('video') || lowerPkg.contains('youtube') || lowerPkg.contains('player')) {
      return AppStyleConfig(icon: Icons.play_circle_outline, color: const Color(0xFFFF5252), stateDescription: 'Media Pipeline Engine Running');
    }
    if (lowerPkg.contains('browser') || lowerPkg.contains('chrome') || lowerPkg.contains('search')) {
      return AppStyleConfig(icon: Icons.explore_outlined, color: const Color(0xFF64FFDA), stateDescription: 'Network Web View Instantiated');
    }
    if (lowerPkg.contains('chat') || lowerPkg.contains('whatsapp') || lowerPkg.contains('viber') || lowerPkg.contains('facebook')) {
      return AppStyleConfig(icon: Icons.chat_bubble_outline, color: const Color(0xFF1DE9B6), stateDescription: 'Push Network Listener Active');
    }
    if (lowerPkg.contains('game') || lowerPkg.contains('gaming')) {
      return AppStyleConfig(icon: Icons.gamepad_outlined, color: const Color(0xFFFFEB3B), stateDescription: 'High CPU/GPU Load Session');
    }
    return AppStyleConfig(icon: Icons.phone_android_outlined, color: const Color(0xFFFF4081), stateDescription: 'Active Background Process Frame');
  }
}

class AppStyleConfig {
  final IconData icon;
  final Color color;
  final String stateDescription;
  AppStyleConfig({required this.icon, required this.color, required this.stateDescription});
}