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

  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendVerificationCode() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _errorMessage = 'Email tidak boleh kosong.');
      return;
    }

    // Validasi format email sederhana
    final emailRegex = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _errorMessage = 'Format email tidak valid.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService().sendOtpEmail(email);
      final maskedEmail = result['data']?['maskedEmail'] as String? ?? email;

      if (!mounted) return;

      // Navigasi ke layar OTP dengan membawa email & maskedEmail
      Navigator.pushNamed(
        context,
        '/verifikasi-otp',
        arguments: {
          'email': email,
          'maskedEmail': maskedEmail,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Bar (Back button only — tanpa avatar)
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
                'Masukkan email yang terdaftar. Kami akan mengirimkan kode OTP untuk mereset kata sandi Anda.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // 3. Input Email
              const Text(
                'Email Terdaftar',
                style: TextStyle(
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
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
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
                      Icons.mail_outline,
                      size: 18,
                      color: _errorMessage != null
                          ? const Color(0xFFE53935)
                          : Colors.black54,
                    ),
                    hintText: 'contoh@email.com',
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

              // Error message
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

              const SizedBox(height: 24),

              // 4. Card: Pilih Metode Pengiriman OTP — Email saja
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF3F51B5),
                    width: 1.5,
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
                      child: Icon(
                        Icons.mail_outline,
                        color: _primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email Terdaftar',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Kode OTP 6-digit akan dikirim ke email Anda',
                            style: TextStyle(fontSize: 11, color: Colors.black54),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Estimasi 1 - 2 menit',
                            style: TextStyle(fontSize: 10, color: Colors.black45),
                          ),
                        ],
                      ),
                    ),
                    // Radio terpilih
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF09095E),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
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
