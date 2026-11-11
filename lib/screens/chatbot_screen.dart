import 'dart:ui';
import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../services/api_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

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
  late String _sessionTimeLabel;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    final user = DummyDataStore().currentUser;
    final firstName = (user != null && user.nama.isNotEmpty) ? user.nama.split(' ').first : 'Warga';
    final now = TimeOfDay.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    _sessionTimeLabel = 'Hari ini, $timeStr WIB';

    _messages = [
      {
        'isUser': false,
        'text': 'Halo **$firstName**! 👋 Saya **Gita**, asisten virtual GateLand. Ada yang bisa Gita bantu hari ini seputar tagihan iuran, pengumuman pengurus, jadwal kebersihan, atau layanan warga?',
        'time': timeStr,
      },
    ];
  }

  void _scrollToBottom() {
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

  void _sendMessage() async {
    if (_isTyping) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final now = TimeOfDay.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Siapkan riwayat sebelum pesan baru ditambahkan
    final historyPayload = _messages
        .map((m) => {
              'role': m['isUser'] == true ? 'user' : 'model',
              'text': (m['text'] ?? '').toString(),
            })
        .toList();

    setState(() {
      _messages.add({
        'isUser': true,
        'text': text,
        'time': timeStr,
      });
      _isTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final reply = await ApiService().chatWithGita(text, history: historyPayload);
      final replyNow = TimeOfDay.now();
      final replyTime = '${replyNow.hour.toString().padLeft(2, '0')}:${replyNow.minute.toString().padLeft(2, '0')}';
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({
            'isUser': false,
            'text': reply,
            'time': replyTime,
          });
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({
            'isUser': false,
            'text': 'Gita sedang offline sejenak. Pastikan server backend GateLand aktif ya! 😊',
            'time': timeStr,
          });
        });
        _scrollToBottom();
      }
    }
  }

  void _attachSimulatedFile(String fileName) {
    final now = TimeOfDay.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      _messages.add({
        'isUser': true,
        'text': '📎 Mengirim lampiran: $fileName',
        'time': timeStr,
      });

      _messages.add({
        'isUser': false,
        'text': 'Lampiran **$fileName** sudah Gita terima! Segera kami teruskan ke petugas RT/RW klaster GateLand ya. Terima kasih! 🙏',
        'time': timeStr,
      });
    });

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
              itemCount: _messages.length + 1 + (_isTyping ? 1 : 0),
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
                      child: Text(
                        _sessionTimeLabel,
                        style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                }
                if (_isTyping && index == _messages.length + 1) {
                  return _buildTypingBubble();
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
                    _buildSuggestionChip('⚠️ Lapor kendala fasilitas'),
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
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (ctx) => SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: Colors.black12,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Lampirkan Berkas atau Foto',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 16),
                                      ListTile(
                                        leading: const CircleAvatar(
                                          backgroundColor: Color(0xFFEFF0FE),
                                          child: Icon(Icons.photo_library_outlined, color: Color(0xFF09095E)),
                                        ),
                                        title: const Text('Foto dari Galeri'),
                                        subtitle: const Text('Kirim foto bukti kendala fasilitas atau pembayaran'),
                                        onTap: () {
                                          Navigator.pop(ctx);
                                          _attachSimulatedFile('foto_kendala_jalan.jpg');
                                        },
                                      ),
                                      ListTile(
                                        leading: const CircleAvatar(
                                          backgroundColor: Color(0xFFFFECEE),
                                          child: Icon(Icons.camera_alt_outlined, color: Color(0xFFC0392B)),
                                        ),
                                        title: const Text('Buka Kamera'),
                                        subtitle: const Text('Ambil foto langsung dari ponsel Anda'),
                                        onTap: () {
                                          Navigator.pop(ctx);
                                          _attachSimulatedFile('kamera_foto_langsung.jpg');
                                        },
                                      ),
                                      ListTile(
                                        leading: const CircleAvatar(
                                          backgroundColor: Color(0xFFE8F8F0),
                                          child: Icon(Icons.description_outlined, color: Color(0xFF1B8754)),
                                        ),
                                        title: const Text('Dokumen PDF'),
                                        subtitle: const Text('Kirim surat atau berkas pendukung'),
                                        onTap: () {
                                          Navigator.pop(ctx);
                                          _attachSimulatedFile('surat_permohonan.pdf');
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
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
                    child: const Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFEBEBFF),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.support_agent, color: _primaryColor, size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _botBubbleColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _botBorderColor, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: _primaryColor),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Gita sedang mengetik...',
                  style: TextStyle(fontSize: 13, color: Color(0xFF2B2B3B), fontStyle: FontStyle.italic),
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
        if (_isTyping) return;
        _controller.text = text.replaceFirst(RegExp(r'^[^\w\s]+\s*'), '');
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD8D8EE)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, color: Color(0xFF09095E), fontWeight: FontWeight.w600),
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
                borderRadius: BorderRadius.circular(20),
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
                        const Icon(Icons.check, size: 13, color: Color(0xFF10B981)),
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
