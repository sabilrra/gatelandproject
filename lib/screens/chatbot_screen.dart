import 'dart:ui';
import 'package:flutter/material.dart';
import '../data/dummy_data.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final Color _primaryColor = const Color(0xFF09095E);
  final Color _userBubbleColor = const Color(0xFF4A4E80); // Dark muted blue for user
  final Color _botBubbleColor = const Color(0xFFFDE9E9); // Light pink for bot
  final Color _botBorderColor = const Color(0xFFF5B6B6); // Soft red border
  final Color _bgColor = const Color(0xFFF9FAFF);

  late List<Map<String, dynamic>> _messages;

  @override
  void initState() {
    super.initState();
    final user = DummyDataStore().currentUser;
    final firstName = (user != null && user.nama.isNotEmpty) ? user.nama.split(' ').first : 'Warga';

    _messages = [
      {
        'isUser': false,
        'text': 'Halo $firstName! 👋 Ada yang bisa Gita bantu hari ini terkait iuran, fasilitas perumahan, atau jadwal kegiatan warga?',
        'time': '10:40',
      },
      {
        'isUser': true,
        'text': 'Apakah tagihan IPL bulan Agustus saya sudah terverifikasi?',
        'time': '10:41',
      },
      {
        'isUser': false,
        'text': 'Tagihan IPL Agustus 2026 sebesar **Rp 175.000** sudah tercatat dan siap dibayarkan sebelum jatuh tempo **10 Agustus**. Kamu bisa langsung klik tombol Bayar di Beranda ya! 😊',
        'time': '10:42',
      },
    ];
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final now = TimeOfDay.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      _messages.add({
        'isUser': true,
        'text': _controller.text.trim(),
        'time': timeStr,
      });
      
      _messages.add({
        'isUser': false,
        'text': 'Maaf, Gita saat ini masih dalam tahap belajar dan belum bisa memproses permintaan baru. Nantikan update selanjutnya ya! 😊',
        'time': timeStr,
      });
    });
    
    _controller.clear();
    
    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF09095E), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEBEBFF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.support_agent, color: _primaryColor, size: 22),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981), // Green dot
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Text(
              'Gita',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.black.withValues(alpha: 0.05), height: 1.0),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEFF5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Hari ini, 10:42 WIB',
                        style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                }
                final msg = _messages[index - 1];
                return _buildChatBubble(msg['text'], msg['time'], msg['isUser']);
              },
            ),
          ),
          
          // Quick Suggestions
          Container(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
            ),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                },
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildSuggestionChip('💳 Cek status tagihan IPL'),
                    const SizedBox(width: 8),
                    _buildSuggestionChip('🧹 Jadwal kerja bakti minggu ini'),
                    const SizedBox(width: 8),
                    _buildSuggestionChip('⚠️ Lapor fasilitas rusak'),
                  ],
                ),
              ),
            ),
          ),
          
          // Input Area
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), // Extra bottom padding for SafeArea
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: 'Tanyakan sesuatu...',
                              hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.attach_file, color: Colors.black38, size: 20),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_outlined, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return GestureDetector(
      onTap: () {
        _controller.text = text.substring(3); // Remove emoji
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE0E0FF)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, color: Color(0xFF09095E), fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildChatBubble(String text, String time, bool isUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFEBEBFF),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.support_agent, color: _primaryColor, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser ? _userBubbleColor : _botBubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 16 : 0),
                  topRight: Radius.circular(isUser ? 0 : 16),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                ),
                border: isUser ? null : Border.all(color: _botBorderColor, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: isUser ? Colors.white : const Color(0xFF2B2B3B),
                        fontSize: 14,
                        height: 1.5,
                      ),
                      children: _parseBoldText(text),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 10,
                          color: isUser ? Colors.white70 : Colors.black45,
                        ),
                      ),
                      if (isUser) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.done_all, size: 12, color: Color(0xFF10B981)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (!isUser) const SizedBox(width: 40), // Margin for bot message
          if (isUser) const SizedBox(width: 8), // Margin for user message
        ],
      ),
    );
  }

  // Simple parser to make **text** bold
  List<TextSpan> _parseBoldText(String text) {
    final spans = <TextSpan>[];
    final parts = text.split('**');
    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 1) {
        spans.add(TextSpan(text: parts[i], style: const TextStyle(fontWeight: FontWeight.bold)));
      } else {
        spans.add(TextSpan(text: parts[i]));
      }
    }
    return spans;
  }
}
