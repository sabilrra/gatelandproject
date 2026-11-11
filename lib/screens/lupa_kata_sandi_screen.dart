import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LupaKataSandiScreen extends StatefulWidget {
  const LupaKataSandiScreen({super.key});

  @override
  State<LupaKataSandiScreen> createState() => _LupaKataSandiScreenState();
}

class _LupaKataSandiScreenState extends State<LupaKataSandiScreen> {
  final Color _primaryColor = const Color(0xFF09095E);
  final Color _bgColor = const Color(0xFFFBFBFF);

  final TextEditingController _contactController = TextEditingController();
  String _selectedMethod = 'whatsapp'; // 'whatsapp' atau 'email'
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _sendVerificationCode() async {
    final input = _contactController.text.trim();

    if (input.isEmpty) {
      setState(() {
        _errorMessage = _selectedMethod == 'whatsapp'
            ? 'Nomor WhatsApp atau email tidak boleh kosong.'
            : 'Email tidak boleh kosong.';
      });
      return;
    }

    if (_selectedMethod == 'email') {
      final emailRegex = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$');
      if (!emailRegex.hasMatch(input)) {
        setState(() => _errorMessage = 'Format email tidak valid.');
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService().sendOtp(
        input,
        method: _selectedMethod,
      );
      final resData = result['data'] as Map<String, dynamic>? ?? {};
      final resolvedEmail = resData['email'] as String? ?? input;
      final maskedTarget =
          resData['maskedTarget'] as String? ??
          resData['maskedEmail'] as String? ??
          input;

      if (!mounted) return;

      Navigator.pushNamed(
        context,
        '/verifikasi-otp',
        arguments: {
          'email': resolvedEmail,
          'maskedEmail': maskedTarget,
          'method': _selectedMethod,
          'rawTarget': input,
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildCustomRadio(bool selected) {
    if (selected) {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black87, width: 6),
        ),
      );
    }
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: Color(0xFFE2E8F0),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildMethodCard({
    required String methodKey,
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    String? caption,
    IconData? captionIcon,
    Color? captionColor,
  }) {
    final isSelected = _selectedMethod == methodKey;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedMethod = methodKey;
        _errorMessage = null;
      }),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3F51B5)
                : const Color(0xFFF1F1F7),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF0FE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3F51B5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                  if (caption != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (captionIcon != null) ...[
                          Icon(
                            captionIcon,
                            size: 12,
                            color: captionColor ?? Colors.black45,
                          ),
                          const SizedBox(width: 2),
                        ],
                        Text(
                          caption,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: captionColor != null
                                ? FontWeight.w700
                                : FontWeight.normal,
                            color: captionColor ?? Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            _buildCustomRadio(isSelected),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWhatsapp = _selectedMethod == 'whatsapp';

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Bar (Back button only)
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF0FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.black87,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Title & Description
              const Text(
                'Lupa Kata Sandi?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Masukkan email atau nomor WhatsApp yang terdaftar, lalu pilih metode pengiriman kode OTP untuk mereset kata sandi Anda.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),

              // 3. Input Kontak Terdaftar
              Text(
                isWhatsapp
                    ? 'Nomor WhatsApp / Email Terdaftar'
                    : 'Email Terdaftar',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _errorMessage != null
                        ? const Color(0xFFE53935)
                        : const Color(0xFFE2E2F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _contactController,
                  keyboardType: isWhatsapp
                      ? TextInputType.text
                      : TextInputType.emailAddress,
                  autocorrect: false,
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() => _errorMessage = null);
                    }
                  },
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      isWhatsapp ? Icons.chat_bubble_outline : Icons.mail_outline,
                      size: 18,
                      color: _errorMessage != null
                          ? const Color(0xFFE53935)
                          : Colors.black54,
                    ),
                    hintText: isWhatsapp
                        ? '081234567890 atau contoh@gmail.com'
                        : 'contoh@gmail.com',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: Colors.black38,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 14,
                      color: Color(0xFFE53935),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFE53935),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 22),

              // 4. Section: Pilih Metode Pengiriman OTP
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pilih Metode Pengiriman OTP',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Aman & Terenkripsi',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3F51B5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Method 1: WhatsApp (Fonnte)
              _buildMethodCard(
                methodKey: 'whatsapp',
                icon: Icons.chat_bubble_outline,
                title: 'WhatsApp',
                badge: 'Rekomendasi',
                subtitle: 'Kode OTP 6-digit dikirim ke WhatsApp terdaftar',
                caption: 'Pengiriman Instan (~5 detik)',
                captionIcon: Icons.bolt,
                captionColor: const Color(0xFF3F51B5),
              ),
              const SizedBox(height: 12),

              // Method 2: Email Terdaftar
              _buildMethodCard(
                methodKey: 'email',
                icon: Icons.mail_outline,
                title: 'Email Terdaftar',
                subtitle: 'Kode OTP 6-digit akan dikirim ke email Anda',
                caption: 'Estimasi 1 - 2 menit',
              ),
              const SizedBox(height: 18),

              // 5. Card: Keamanan Informasi Akun
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF3FE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color: Color(0xFF3F51B5),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keamanan Informasi Akun',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Kode verifikasi bersifat rahasia dan berlaku 5 menit. Petugas GateLand maupun Pengurus RT tidak akan pernah meminta kode OTP Anda.',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 6. Action Button: Kirim Kode Verifikasi
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _sendVerificationCode,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Kirim Kode Verifikasi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Kembali ke Halaman Sebelumnya Link
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        size: 14,
                        color: Color(0xFF3F51B5),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Kembali ke Halaman Sebelumnya',
                        style: TextStyle(
                          color: Color(0xFF3F51B5),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
