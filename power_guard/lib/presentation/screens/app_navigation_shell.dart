import 'package:flutter/material.dart';
import 'package:power_guard/features/power/presentation/screens/power_dashboard_screen.dart';
import 'package:power_guard/features/stats/presentation/screens/stats_screen.dart';
import 'package:power_guard/features/ai_insights/presentation/screens/ai_chat_screen.dart';
import 'package:power_guard/features/settings/presentation/screens/settings_screen.dart';

class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({super.key});

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  int _currentIndex = 0;

  // 🧭 The scrolling coordinator tracking page slide offsets
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose(); // Wipes memory stream handles to maximize performance
    super.dispose();
  }

  /// Triggers automatically as the page view is dragged horizontally
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /// Animates the sliding transaction when a bottom nav button is tapped
  void _onBottomNavTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic, // Decelerates organically like social timelines
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0D11),

      // 📱 The core horizontal slider view engine
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        // BouncingScrollPhysics creates an elastic rubber-band feel when over-scrolling edges
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        children: [
          const PowerDashboardScreen(),
          const StatsScreen(),
          const AiChatScreen(),
          const SettingsScreen(),
        ],
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.02), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onBottomNavTapped,
          backgroundColor: const Color(0xFF14161D),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF00E676),
          unselectedItemColor: const Color(0xFF757570),
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.bolt), label: 'Power'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
            BottomNavigationBarItem(icon: Icon(Icons.psychology), label: 'AI'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}