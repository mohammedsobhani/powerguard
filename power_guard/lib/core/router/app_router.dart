import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:power_guard/features/power/presentation/screens/power_dashboard_screen.dart';
import 'package:power_guard/features/stats/presentation/screens/stats_screen.dart';
import 'package:power_guard/features/settings/presentation/screens/settings_screen.dart';
// ✅ ADDED: Import your real production AI Terminal screen widget
import 'package:power_guard/features/ai_insights/presentation/screens/ai_chat_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/power',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // Index 0: Power Dashboard Subtree
          StatefulShellBranch(routes: [
            GoRoute(path: '/power', builder: (context, state) => const PowerDashboardScreen())
          ]),

          // Index 1: Stats Telemetry Subtree
          StatefulShellBranch(routes: [
            GoRoute(path: '/stats', builder: (context, state) => const StatsScreen())
          ]),

          // Index 2: ✅ UPDATED: Points directly to your functional cyberpunk AI chat terminal
          StatefulShellBranch(routes: [
            GoRoute(path: '/ai', builder: (context, state) => const AiChatScreen())
          ]),

          // Index 3: Points seamlessly to your functional Hive-powered Settings UI
          StatefulShellBranch(routes: [
            GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen())
          ]),
        ],
      ),
    ],
  );
});

class MainNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainNavigationShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF14161D), // Deep midnight navbar container
        selectedItemColor: const Color(0xFF00E676), // Vibrant telemetry green highlight
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.flash_on), label: 'Power'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.psychology), label: 'AI'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}