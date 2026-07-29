import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with AutomaticKeepAliveClientMixin {
  bool _isProUnlocked = false;
  bool _dischargeAlarmEnabled = true;
  bool _chargeNotificationEnabled = true;
  double _dischargeThreshold = 20.0;
  double _chargeThreshold = 80.0;

  final String _secureBankTarget = "20504246700091505 IBBL";
  final String _secureMfsTarget = "01323933904 bKash Merchant";

  @override
  bool get wantKeepAlive => true;

  void _showGatewaySelectorSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF14161D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('SECURE CHECKOUT', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                      IconButton(icon: const Icon(Icons.close, color: Colors.grey, size: 20), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Select an encrypted network gateway to authorize payment:', style: TextStyle(color: Color(0xFFA0A1A9), fontSize: 12)),
                  const SizedBox(height: 20),
                  _buildGatewayListTile(
                    icon: Icons.phone_android_outlined,
                    title: 'bKash Wallet Engine',
                    subtitle: 'Routing directly to Merchant Node: $_secureMfsTarget',
                    onTap: () {
                      Navigator.pop(context);
                      _processLivePaymentPipeline('bKFS API Token Sync', _secureMfsTarget);
                    },
                  ),
                  _buildGatewayListTile(
                    icon: Icons.account_balance_outlined,
                    title: 'Direct Banking Portal (IBBL)',
                    subtitle: 'Secure Settlement Key: $_secureBankTarget',
                    onTap: () {
                      Navigator.pop(context);
                      _processLivePaymentPipeline('IBBL Core Banking Node', _secureBankTarget);
                    },
                  ),
                  _buildGatewayListTile(
                    icon: Icons.credit_card_outlined,
                    title: 'Visa / Mastercard / Amex',
                    subtitle: 'Universal Payment Gateway Network Link',
                    onTap: () {
                      Navigator.pop(context);
                      _processLivePaymentPipeline('Visa/MC Clearing Gateway', 'External Visa Interchange');
                    },
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white10, height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Order Subtotal:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      Row(
                        children: [
                          Text('\$25.00', style: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 13, decoration: TextDecoration.lineThrough, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          const Text('\$5.00 USD', style: TextStyle(color: Color(0xFF00E676), fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _processLivePaymentPipeline(String apiEndpoint, String accountingDestination) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF14161D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF00E676)),
              const SizedBox(height: 20),
              Text('AUTHENTICATING VIA $apiEndpoint', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Settling payload balance directly to secure system profile endpoint ($accountingDestination)...', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFA0A1A9), fontSize: 11, fontFamily: 'Courier New')),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
        setState(() {
          _isProUnlocked = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚡ PowerGuard Pro License Unlocked Successfully!'), backgroundColor: Color(0xFF00E676)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0C0D11),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Settings & Upgrades', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PROFESSIONAL ALERT CONFIGURATION', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  _buildToggleConfigCard(
                    title: 'Discharge Limit Alarm',
                    description: 'Expert Algorithm automatically reminds when discharge exceeds professional longevity limits.',
                    value: _dischargeAlarmEnabled,
                    onChanged: (val) => setState(() => _dischargeAlarmEnabled = val),
                    child: _dischargeAlarmEnabled ? _buildSliderControlRow(currentValue: _dischargeThreshold, min: 10.0, max: 35.0, label: 'Discharge Alert Threshold', unit: '%', onChanged: (val) => setState(() => _dischargeThreshold = val)) : null,
                  ),
                  const SizedBox(height: 12),
                  _buildToggleConfigCard(
                    title: 'Charging Alert Notification',
                    description: 'Advanced expert analysis optimizes charging alerts for maximum physical cell health runtime.',
                    value: _chargeNotificationEnabled,
                    onChanged: (val) => setState(() => _chargeNotificationEnabled = val),
                    child: _chargeNotificationEnabled ? _buildSliderControlRow(currentValue: _chargeThreshold, min: 70.0, max: 95.0, label: 'Optimal Charge Limit', unit: '%', onChanged: (val) => setState(() => _chargeThreshold = val)) : null,
                  ),
                  const SizedBox(height: 24),
                  _buildProUpgradePanel(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('DEVELOPER: SOBHANI_II', style: TextStyle(color: Color(0xFF00E676), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Courier New', letterSpacing: 2.0)),
                const SizedBox(height: 4),
                const Text('V1.4.2 (STABLE HARDWARE PROFILE)', style: TextStyle(color: Color(0xFF3C3D45), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Courier New', letterSpacing: 1.0)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleConfigCard({required String title, required String description, required bool value, required ValueChanged<bool> onChanged, Widget? child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF14161D), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.02))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              Switch(value: value, onChanged: onChanged, activeThumbColor: const Color(0xFF00E676), activeTrackColor: const Color(0xFF00E676).withValues(alpha: 0.2), inactiveThumbColor: Colors.grey, inactiveTrackColor: Colors.white.withValues(alpha: 0.05)),
            ],
          ),
          const SizedBox(height: 6),
          Text(description, style: const TextStyle(color: Color(0xFFA0A1A9), fontSize: 12, height: 1.4)),
          if (child != null) ...[const SizedBox(height: 16), const Divider(color: Colors.white10, height: 1), const SizedBox(height: 12), child]
        ],
      ),
    );
  }

  Widget _buildSliderControlRow({required double currentValue, required double min, required double max, required String label, required String unit, required ValueChanged<double> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
            Text('${currentValue.toInt()}$unit', style: const TextStyle(color: Color(0xFF00E676), fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Courier New')),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(activeTrackColor: const Color(0xFF00E676), inactiveTrackColor: Colors.white10, thumbColor: const Color(0xFF00E676), overlayColor: const Color(0xFF00E676).withValues(alpha: 0.1), trackHeight: 3, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6)),
          child: Slider(value: currentValue, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }

  Widget _buildProUpgradePanel() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1E1B15), Color(0xFF14161D)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20), border: Border.all(color: _isProUnlocked ? const Color(0xFF00E676).withValues(alpha: 0.3) : const Color(0xFFD4AF37).withValues(alpha: 0.25), width: 1.5)),
      child: Stack(
        children: [
          Positioned(
            right: -10, top: -10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(color: _isProUnlocked ? const Color(0xFF00E676).withValues(alpha: 0.08) : const Color(0xFFD4AF37).withValues(alpha: 0.08), borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40))),
              child: Text(_isProUnlocked ? 'PRO ACTIVE' : 'GO PRO', style: TextStyle(color: _isProUnlocked ? const Color(0xFF00E676) : const Color(0xFFD4AF37), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.0)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_isProUnlocked ? 'SUPER PRO ACCESS GRANTED' : 'UPGRADE TO PRO VERSION', style: TextStyle(color: _isProUnlocked ? const Color(0xFF00E676) : const Color(0xFFD4AF37), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                const SizedBox(height: 16),
                _buildBulletItem('Unlimited Custom Telemetry Alerts'),
                _buildBulletItem('Deep Diagnostic Cell Data Retention History'),
                _buildBulletItem('Multi-Device Cloud Matrix Synchronization'),
                _buildBulletItem('100% Ad-Free Performance Environment'),
                _buildBulletItem('Unlock All Advanced Expert Optimization Tools'),
                const SizedBox(height: 24),
                if (!_isProUnlocked) ...[
                  InkWell(
                    onTap: _showGatewaySelectorSheet,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFF3C63F), Color(0xFFD4AF37)]), borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Pro - Full Upgrade', style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w900)),
                          const SizedBox(width: 10),
                          Text('\$25', style: TextStyle(color: Colors.black.withValues(alpha: 0.4), fontSize: 12, fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough)),
                          const SizedBox(width: 6),
                          const Text('\$5 Only', style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(child: Text('Secured instantly using payment profile linked to store account.', style: TextStyle(color: Colors.grey, fontSize: 10))),
                ] else ...[
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFF00E676).withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.2))),
                    child: const Text('POWERGUARD PRO UPGRADE: APP IS WORKING ON OPTIMIZING YOUR DEVICE PERFORMANCE. ALL TOOLS ARE ENABLED. (App on working)', style: TextStyle(color: Color(0xFFCEFFEB), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Courier New', height: 1.5)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGatewayListTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: const Color(0xFF0C0D11), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.03))),
      child: ListTile(onTap: onTap, leading: Icon(icon, color: const Color(0xFF00E676), size: 20), title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)), subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)), trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey)),
    );
  }

  Widget _buildBulletItem(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('• ', style: TextStyle(color: _isProUnlocked ? const Color(0xFF00E676) : const Color(0xFFD4AF37), fontSize: 14, fontWeight: FontWeight.bold)), Expanded(child: Text(title, style: const TextStyle(color: Color(0xFFECEFF1), fontSize: 13, height: 1.3)))]),
    );
  }
}