import 'package:flutter/material.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> with AutomaticKeepAliveClientMixin {
  final List<Map<String, dynamic>> _chatHistory = [];
  bool _isAiTyping = false;
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  final Map<String, String> _knowledgeBase = {
    '🔋 Overnight Charging Myth': '⚡ [SYSTEM RESPONSE: MYTH DEBUNKED]\n\nModern smartphones run on dedicated Power Management ICs (PMICs) that completely cut off current flow once the battery hits 100%. Keeping your device at 100% capacity inside a thick phone case traps ambient heat, which accelerates chemical degradation over time.',
    '🧪 Lithium-Ion vs Silicon Anodes': '🔬 [SYSTEM RESPONSE: CELL ARCHITECTURE]\n\nSilicon-dominant anodes can theoretically bind 4 lithium ions per single silicon atom, boosting overall volumetric energy density by up to 20-40%! However, pure silicon expands by up to 300% when absorbing lithium ions, risking structural fractures.',
    '⏳ 0% to 100% Cycle Misconception': '📉 [SYSTEM RESPONSE: DEEP DISCHARGE ANALYSIS]\n\nLithium-ion batteries experience the absolute lowest internal stress when maintained between 20% and 80%. A full 0-100% drain counts as one complete, punishing wear cycle.',
    '🚀 Future Battery Innovations': '🔮 [SYSTEM RESPONSE: THE HORIZON]\n\nSolid-State Batteries (SSBs) replace volatile liquid electrolytes with solid ceramics, completely eliminating thermal runaway fire risks while unlocking ultra-fast charging architectures.',
    '🌡️ High Ambient Thermal Impacts': '🔥 [SYSTEM RESPONSE: ENVIRONMENTAL STRESS DIAGNOSIS]\n\nOperating your phone at temperatures exceeding 35°C (95°F) permanently degrades battery capacity over time. Fast charging while playing heavy games creates an adverse environment.',
    '🔌 Fast Charging Degrades Health?': '⚡ [SYSTEM RESPONSE: ADAPTIVE POWER ANALYSIS]\n\nFast charging triggers high voltage bursts safely from 0% up to 80%. Once filled, the phone’s PMIC enters phase two, automatically slowing down speeds to prevent internal overheating.'
  };

  @override
  void initState() {
    super.initState();
    _chatHistory.add({'isUser': false, 'text': '⚡ PowerGuard AI Core Online. Select a parameter token below to query native physical hardware insights.'});
  }

  void _handlePromptSelection(String selectedPrompt) {
    if (_isAiTyping) return;
    setState(() {
      _chatHistory.add({'isUser': true, 'text': selectedPrompt});
      _isAiTyping = true;
    });
    _scrollToBottom();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _chatHistory.add({'isUser': false, 'text': _knowledgeBase[selectedPrompt] ?? 'Error executing compilation.'});
          _isAiTyping = false;
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final insertedPrompts = _chatHistory.where((msg) => msg['isUser'] == true).map((msg) => msg['text'] as String).toSet();
    final remainingPrompts = _knowledgeBase.keys.where((q) => !insertedPrompts.contains(q)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0C0D11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF14161D),
        elevation: 0,
        title: const Text('PowerGuard AI Core', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _chatHistory.length + (_isAiTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _chatHistory.length && _isAiTyping) return _buildAiTypingIndicator();
                final message = _chatHistory[index];
                return _buildChatBubble(message['isUser'] as bool, message['text'] as String);
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Color(0xFF14161D), borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (remainingPrompts.isNotEmpty) ...[
                  const Text('EXECUTE DIAGNOSTIC INITIALIZATION VECTOR:', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: remainingPrompts.map((question) {
                      return InkWell(
                        onTap: () => _handlePromptSelection(question),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(color: const Color(0xFF0C0D11), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.2))),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(question, style: const TextStyle(color: Color(0xFF00E676), fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF00E676)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ] else ...[
                  const Center(child: Text('ALL CORE PARAMETERS COMPILED FLUSH', style: TextStyle(color: Colors.grey, fontSize: 11, fontFamily: 'Courier New'))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(bool isUser, String text) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF00E676).withValues(alpha: 0.12) : const Color(0xFF14161D),
          borderRadius: BorderRadius.only(topLeft: const Radius.circular(16), topRight: const Radius.circular(16), bottomLeft: Radius.circular(isUser ? 16 : 4), bottomRight: Radius.circular(isUser ? 4 : 16)),
          border: Border.all(color: isUser ? const Color(0xFF00E676).withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.04)),
        ),
        child: Text(text, style: TextStyle(color: isUser ? const Color(0xFFCEFFEB) : const Color(0xFFECEFF1), fontSize: 13.5, fontFamily: isUser ? null : 'Courier New', height: 1.45)),
      ),
    );
  }

  Widget _buildAiTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: const Color(0xFF14161D), borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00E676))),
            const SizedBox(width: 12),
            Text('Parsing telemetry metrics...', style: TextStyle(color: const Color(0xFF00E676).withValues(alpha: 0.7), fontFamily: 'Courier New', fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}