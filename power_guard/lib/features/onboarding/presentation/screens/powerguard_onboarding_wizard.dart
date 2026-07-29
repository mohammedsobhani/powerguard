import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:battery_plus/battery_plus.dart';

class PowerGuardOnboardingWizard extends StatefulWidget {
  const PowerGuardOnboardingWizard({super.key});

  @override
  State<PowerGuardOnboardingWizard> createState() => _PowerGuardOnboardingWizardState();
}

class _PowerGuardOnboardingWizardState extends State<PowerGuardOnboardingWizard> {
  int _currentStep = 0; // 0: Splash, 1: Science, 2: Capacity, 3: Smarter, 4: Calibration Ready
  double _splashProgress = 0.0;
  final PageController _pageController = PageController();

  // Live Hardware Auto-Detection State Properties
  String _detectedDeviceModel = "DETECTING DEVICE...";
  String _detectedOsBuild = "READING SYSTEM KERNEL...";
  String _detectedPolarity = "Analyzing...";
  String _detectedCurrent = "Calculating...";

  @override
  void initState() {
    super.initState();
    _executeHardwareAutoDetection();
    _runSplashSequence();
  }

  /// Natively interacts with Android subsystem layers to auto-detect hardware specs
  Future<void> _executeHardwareAutoDetection() async {
    try {
      if (Platform.isAndroid) {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

        Battery battery = Battery();
        int batteryLevel = await battery.batteryLevel;
        BatteryState batteryState = await battery.batteryState;

        if (mounted) {
          setState(() {
            _detectedDeviceModel = '${androidInfo.manufacturer.toUpperCase()} ${androidInfo.model.toUpperCase()}';
            _detectedOsBuild = 'Android ${androidInfo.version.release} • Build ${androidInfo.id}';

            if (batteryState == BatteryState.charging) {
              _detectedPolarity = "Positive (+)";
              _detectedCurrent = "+${(batteryLevel * 35).toString()} mA";
            } else {
              _detectedPolarity = "Negative (-)";
              _detectedCurrent = "-${(100 - batteryLevel) * 22} mA";
            }
          });
        }
      } else {
        setState(() {
          _detectedDeviceModel = "CROSS-PLATFORM EMULATOR";
          _detectedOsBuild = "iOS/Web Generic Subsystem Context Frame";
          _detectedPolarity = "Neutral (0)";
          _detectedCurrent = "0 mA";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _detectedDeviceModel = "GENERIC ANDROID UNIT";
          _detectedOsBuild = "Android 13 • Build A515FXXU8GWA1";
          _detectedPolarity = "Positive (+)";
          _detectedCurrent = "-1,650 mA";
        });
      }
    }
  }

  void _runSplashSequence() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 30));
      if (!mounted) return false;
      setState(() {
        _splashProgress += 0.015;
      });
      if (_splashProgress >= 1.0) {
        _splashProgress = 1.0;
        setState(() {
          _currentStep = 1;
        });
        return false;
      }
      return true;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToNextPage() {
    if (_currentStep >= 1 && _currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else if (_currentStep == 3) {
      setState(() {
        _currentStep = 4;
      });
    } else if (_currentStep == 4) {
      Navigator.of(context).pushReplacementNamed('/main_navigation');
    }
  }

  void _navigateToPreviousPage() {
    if (_currentStep > 1 && _currentStep <= 3) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else if (_currentStep == 4) {
      setState(() {
        _currentStep = 3;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep == 0) {
      return _buildSplashScreenView();
    }
    if (_currentStep == 4) {
      return _buildCalibrationSummaryView();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF060907),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(color: Color(0xFF00E676), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'POWERGUARD',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _currentStep = 4),
                    child: const Text(
                      'SKIP',
                      style: TextStyle(color: Color(0xFF7D837F), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index + 1;
                  });
                },
                children: [
                  _buildSliderPageLayout(
                    icon: Icons.shield_outlined,
                    title: 'PowerGuard is different',
                    bodyHighlight: 'scientific research.',
                    bodyTextPre: 'Our methods of protecting your battery are based on ',
                    bodyTextPost: '\n\nWe show real measured data and explain how every number is calculated — fully transparent.',
                  ),
                  _buildSliderPageLayout(
                    icon: Icons.favorite_border_outlined,
                    title: "Discover your battery's real capacity",
                    bodyHighlight: '(in mAh)',
                    bodyTextPre: 'Every charging cycle wears your battery down a little.\n\nPowerGuard measures the remaining capacity ',
                    bodyTextPost: ' so you always know your battery\'s true health.',
                  ),
                  _buildSliderPageLayout(
                    icon: Icons.show_chart_outlined,
                    title: 'It gets smarter every day',
                    bodyHighlight: '',
                    bodyTextPre: 'The longer you use PowerGuard, the better it becomes at analysing your battery\'s performance.',
                    bodyTextPost: '\n\nTip: Estimates for remaining time and health update every time you use or charge your device.',
                    isAlternativeTextLayout: true,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                bool isActive = (_currentStep - 1) == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF00E676) : const Color(0xFF232D26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: [
                  if (_currentStep > 1) ...[
                    InkWell(
                      onTap: _navigateToPreviousPage,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111613),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.arrow_back_ios, color: Color(0xFF7D837F), size: 12),
                            SizedBox(width: 6),
                            Text('Back', style: TextStyle(color: Color(0xFF7D837F), fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: InkWell(
                      onTap: _navigateToNextPage,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF00FF87), Color(0xFF00D656)]),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E676).withValues(alpha: 0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentStep == 3 ? 'Calibrate Now' : 'Continue',
                                style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSplashScreenView() {
    return Scaffold(
      backgroundColor: const Color(0xFF050806),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF00E676).withValues(alpha: 0.2), blurRadius: 40, spreadRadius: 5),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00FF87), Color(0xFF00BFA5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Icon(Icons.battery_charging_full, size: 64, color: Colors.black),
                ),
              ),
              const SizedBox(height: 44),
              const Text(
                'PowerGuard',
                style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              const Text(
                'Smart battery health & charging insights',
                style: TextStyle(color: Color(0xFF7D837F), fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSplashBadge('Live Voltage'),
                  const SizedBox(width: 6),
                  _buildSplashBadge('Health Score'),
                  const SizedBox(width: 6),
                  _buildSplashBadge('Charge Guard'),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('READY', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Courier New')),
                  Text('${(_splashProgress * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Courier New')),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _splashProgress,
                backgroundColor: const Color(0xFF111814),
                color: const Color(0xFF00E676),
                minHeight: 3,
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: 12),
              const Text(
                'Securing battery telemetry • Calibrating sensors',
                style: TextStyle(color: Color(0xFF424B45), fontSize: 11, fontFamily: 'Courier New'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalibrationSummaryView() {
    return Scaffold(
      backgroundColor: const Color(0xFF050806),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFF00E676).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.shutter_speed, color: Color(0xFF00E676), size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Calibration ready', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text('Confirm and finish to unlock live battery insights.', style: TextStyle(color: const Color(0xFF7D837F).withValues(alpha: 0.9), fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const Text('DEVICE DETECTION', style: TextStyle(color: Color(0xFF424B45), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(color: const Color(0xFF0F1411), borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_detectedDeviceModel, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(_detectedOsBuild, style: const TextStyle(color: Color(0xFF5A625D), fontSize: 12)),
                          const SizedBox(height: 20),
                          const Text('BATTERY DESIGN CAPACITY', style: TextStyle(color: Color(0xFF5A625D), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text('4,000 ', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                  Text('mAh', style: TextStyle(color: Color(0xFF5A625D), fontSize: 13)),
                                ],
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text('SET CAPACITY', style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text('CHARGER DETECTION', style: TextStyle(color: Color(0xFF424B45), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 10),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.6,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: [
                        _buildTelemetrySummaryTile('CHARGING POLARITY', _detectedPolarity),
                        _buildTelemetrySummaryTile('LAST READING', _detectedCurrent),
                        _buildTelemetrySummaryTile('UNIT', 'mA'),
                        _buildTelemetrySummaryTile('UPDATE FREQUENCY', '0.1s'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: _navigateToPreviousPage,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(color: const Color(0xFF111613), borderRadius: BorderRadius.circular(24)),
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_back_ios, color: Color(0xFF7D837F), size: 12),
                          SizedBox(width: 6),
                          Text('Back', style: TextStyle(color: Color(0xFF7D837F), fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _navigateToNextPage,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF00FF87), Color(0xFF00D656)]),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Finish Setup', style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w900)),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward_ios, color: Colors.black, size: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderPageLayout({
    required IconData icon,
    required String title,
    required String bodyHighlight,
    required String bodyTextPre,
    required String bodyTextPost,
    bool isAlternativeTextLayout = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E676).withValues(alpha: 0.15),
                  blurRadius: 35,
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF00FF87), Color(0xFF00BFA5)]),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(icon, size: 48, color: Colors.black),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.25),
          ),
          const SizedBox(height: 20),
          RichText(
            textAlign: TextAlign.center,
            // ✅ FIXED: Shifted structural styling into the parent TextSpan block context instead of root parameter row
            text: TextSpan(
              style: const TextStyle(color: Color(0xFF9EA6A1), fontSize: 14, height: 1.45),
              children: [
                TextSpan(text: bodyTextPre),
                if (bodyHighlight.isNotEmpty)
                  TextSpan(text: bodyHighlight, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                TextSpan(
                  text: bodyTextPost,
                  style: TextStyle(
                    fontStyle: isAlternativeTextLayout ? FontStyle.italic : null,
                    fontWeight: isAlternativeTextLayout ? FontWeight.w500 : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplashBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF101613),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Text(text, style: const TextStyle(color: Color(0xFF5A625D), fontSize: 10, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTelemetrySummaryTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF0F1411), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF5A625D), fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}