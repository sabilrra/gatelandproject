import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class VerifikasiOtpScreen extends StatefulWidget {
  const VerifikasiOtpScreen({super.key});

  @override
  State<VerifikasiOtpScreen> createState() => _VerifikasiOtpScreenState();
}

class _VerifikasiOtpScreenState extends State<VerifikasiOtpScreen> {
  final Color _primaryColor = const Color(0xFF09095E);
  final Color _bgColor = const Color(0xFFFBFBFF);

  // 6 controller untuk 6 digit OTP
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;

  late String _email;
  late String _maskedEmail;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _email = args?['email'] as String? ?? '';
    _maskedEmail = args?['maskedEmail'] as String? ?? _email;
  }

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode =>
      _otpControllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    final code = _otpCode;
    if (code.length < 6) {
      setState(() => _errorMessage = 'Masukkan 6 digit kode OTP.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Navigasi ke layar ubah kata sandi dengan membawa email & kode
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/ubah-kata-sandi',
        arguments: {
          'email': _email,
          'otpCode': code,
        },
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      await ApiService().sendOtpEmail(_email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Kode OTP baru telah dikirim!'),
            ],
          ),
          backgroundColor: const Color(0xFF1B8754),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      // Reset field
      for (final c in _otpControllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 46,
      height: 56,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: _primaryColor,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E2F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3F51B5), width: 2),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          // Auto-verify saat digit ke-6 diisi
          if (index == 5 && value.isNotEmpty) {
            _verifyOtp();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
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

              // Icon & Title
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF0FE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.mark_email_read_outlined,
                  color: _primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Verifikasi Kode OTP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(
                        text: 'Kami telah mengirimkan kode OTP 6-digit ke '),
                    TextSpan(
                      text: _maskedEmail,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _primaryColor,
                      ),
                    ),
                    const TextSpan(text: '. Kode berlaku selama 5 menit.'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // OTP Input Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, _buildOtpBox),
              ),

              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
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

              // Info card
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
                            'Peringatan Keamanan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Jangan bagikan kode OTP kepada siapapun. Petugas GateLand tidak akan pernah meminta kode ini.',
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

              // Verify Button
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
                  onPressed: _isLoading ? null : _verifyOtp,
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
                              'Verifikasi & Lanjutkan',
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

              // Kirim Ulang
              Center(
                child: GestureDetector(
                  onTap: _isResending ? null : _resendOtp,
                  child: _isResending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Kirim Ulang Kode OTP',
                          style: TextStyle(
                            color: Color(0xFF3F51B5),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
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

