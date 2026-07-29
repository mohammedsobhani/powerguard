import 'package:flutter/material.dart';
import 'package:power_guard/features/stats/services/usage_permission_service.dart';
import 'package:power_guard/features/stats/services/battery_usage_service.dart';
import 'package:power_guard/features/stats/utils/report_generator.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with AutomaticKeepAliveClientMixin {
  bool _hasPermission = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _userLiveStats = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _checkStatusAndLoadData();
  }

  Future<void> _checkStatusAndLoadData() async {
    final granted = await UsagePermissionService.isPermissionGranted();
    if (granted) {
      final dynamicStats = await BatteryUsageService.getRealUserAppStats();
      setState(() {
        _userLiveStats = dynamicStats;
        _hasPermission = true;
        _isLoading = false;
      });
    } else {
      setState(() {
        _hasPermission = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0C0D11),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00E676))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0C0D11),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Application Stats', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        actions: [
          if (_hasPermission && _userLiveStats.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white, size: 22),
              onPressed: () => ReportGenerator.generateAndShareReport(_userLiveStats),
            ),
        ],
      ),
      body: _hasPermission
          ? (_userLiveStats.isEmpty ? _buildEmptyState() : _buildStatsView())
          : _buildPermissionGuard(),
    );
  }

  Widget _buildStatsView() {
    final double maxDrain = _userLiveStats.isNotEmpty
        ? _userLiveStats.map((e) => e['drainPct'] as double).reduce((a, b) => a > b ? a : b)
        : 1.0;

    return RefreshIndicator(
      color: const Color(0xFF00E676),
      backgroundColor: const Color(0xFF14161D),
      onRefresh: _checkStatusAndLoadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          // ✅ FIXED: Corrected syntax typo to resolve compilation errors
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NETWORK TELEMETRY & THREAD LOGS',
              style: TextStyle(color: Color(0xFF757570), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _userLiveStats.length,
              itemBuilder: (context, index) {
                final app = _userLiveStats[index];
                final appColor = app['color'] as Color;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFF14161D), borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(app['name'], style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          Text(app['state'].toString().toUpperCase(), style: TextStyle(color: appColor.withValues(alpha: 0.8), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.wifi, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('Wi-Fi: ${app['wifiData']}', style: const TextStyle(color: Color(0xFFA0A1A9), fontSize: 11, fontFamily: 'Courier New')),
                          const SizedBox(width: 14),
                          const Icon(Icons.cell_tower, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('Cellular: ${app['mobileData']}', style: const TextStyle(color: Color(0xFFA0A1A9), fontSize: 11, fontFamily: 'Courier New')),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('Time Active: ${app['duration']}', style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'BATTERY CAPACITY DRAIN PROFILE',
              style: TextStyle(color: Color(0xFF757570), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: const Color(0xFF14161D), borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: _userLiveStats.map((app) {
                  final double currentDrain = app['drainPct'] as double;
                  final appColor = app['color'] as Color;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(app['icon'], color: appColor, size: 16),
                                const SizedBox(width: 10),
                                Text(app['name'], style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Row(
                              children: [
                                Text('${app['mahConsumed']} mAh', style: const TextStyle(color: Color(0xFFA0A1A9), fontSize: 12, fontFamily: 'Courier New')),
                                const SizedBox(width: 8),
                                Text('-$currentDrain%', style: TextStyle(color: appColor, fontSize: 13, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: maxDrain > 0 ? currentDrain / maxDrain : 0,
                          backgroundColor: Colors.white.withValues(alpha: 0.03),
                          color: appColor,
                          minHeight: 5,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() => const Center(child: Text('No active foreground apps tracked yet for today.', style: TextStyle(color: Colors.grey, fontFamily: 'Courier New')));
  Widget _buildPermissionGuard() => const Center(child: Text('Permission required. Activate inside settings configuration panel.', style: TextStyle(color: Colors.white)));
}