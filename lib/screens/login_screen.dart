import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/dummy_data.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(text: 'sabila@gmail.com');
  final TextEditingController _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;
  bool _rememberMe = true;

  final Color _primaryColor = const Color(0xFF090580);
  final Color _titleColor = const Color(0xFF010045);
  final Color _bgColor = const Color(0xFFFAF8FF);
  final Color _textColor = const Color(0xFF191B25);
  final Color _subtextColor = const Color(0xFF464652);
  final Color _hintColor = const Color(0xFF767684);
  final Color _linkPurple = const Color(0xFF595894);
  final Color _errorRed = const Color(0xFFBA1A1A);
  final Color _errorDarkRed = const Color(0xFF93000A);
  final Color _errorBg = const Color(0xFFFFDAD6);

  bool _hasLoginError = false;
  bool _isLoading = false;
  String _errorMessage = 'Password yang kamu masukkan salah.';

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _hasLoginError = true;
        _errorMessage = 'Email dan password wajib diisi.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasLoginError = false;
    });

    try {
      final res = await ApiService().login(email, password);
      if (res['status'] == 'success') {
        final userData = res['data']?['user'];
        final userName = userData?['name'] ?? 'Sabila Aulia';
        final userEmail = userData?['email'] ?? email;

        DummyDataStore().currentUser = UserData(
          nama: userName,
          email: userEmail,
          noWhatsapp: '0812-3456-7890',
          alamat: 'Cluster Anggrek, Blok B2 No. 14',
          password: password,
        );

        setState(() {
          _hasLoginError = false;
          _isLoading = false;
        });

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
        return;
      } else {
        setState(() {
          _hasLoginError = true;
          _errorMessage = res['message'] ?? 'Email atau password salah.';
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      final cleanMsg = e.toString().replaceAll('Exception: ', '');
      setState(() {
        _hasLoginError = true;
        _errorMessage = cleanMsg.isNotEmpty ? cleanMsg : 'Email atau password salah.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'GateLand',
                      style: GoogleFonts.inter(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: _titleColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _hasLoginError
                          ? 'Aplikasi Pengelolaan Iuran & Warga Lingkungan'
                          : 'Smart Living Starts Here.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: _subtextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Welcome Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2DFFF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.home_outlined, size: 14, color: Color(0xFF15124D)),
                                const SizedBox(width: 4),
                                Text(
                                  'Portal Warga',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF15124D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _hasLoginError ? 'Selamat Datang Kembali!' : 'Selamat Datang!',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Masuk untuk mengelola tagihan & info warga',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: _subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F2FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.waving_hand, color: _primaryColor, size: 22),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Email Field
              Text(
                'Email :',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: _textColor),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: _textColor),
                decoration: InputDecoration(
                  hintText: 'contoh: nama@email.com',
                  hintStyle: GoogleFonts.plusJakartaSans(color: _hintColor, fontSize: 13),
                  prefixIcon: Icon(Icons.email_outlined, color: _hintColor, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE1E1EF)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE1E1EF)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),

              // Password Field Header (with Lupa Password right-aligned)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Password',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _hasLoginError ? _errorRed : _textColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/lupa-kata-sandi');
                    },
                    child: Text(
                      'Lupa Password?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _linkPurple,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: _textColor),
                decoration: InputDecoration(
                  hintText: 'Masukkan kata sandi',
                  hintStyle: GoogleFonts.plusJakartaSans(color: _hintColor, fontSize: 13),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: _hasLoginError ? _errorRed : _hintColor,
                    size: 20,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: _hintColor,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: _hasLoginError ? const Color(0xFFFCEFF3) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _hasLoginError ? _errorRed : const Color(0xFFE1E1EF),
                      width: _hasLoginError ? 1.5 : 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _hasLoginError ? _errorRed : const Color(0xFFE1E1EF),
                      width: _hasLoginError ? 1.5 : 1,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              // Error Banner (shown when password is wrong)
              if (_hasLoginError) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _errorBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _errorRed.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _errorRed,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.error_outline, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _errorDarkRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: _errorDarkRed,
                              height: 1.4,
                            ),
                            children: const [
                              TextSpan(text: 'Pastikan kombinasi huruf besar, kecil, dan angka sudah sesuai. Percobaan tersisa '),
                              TextSpan(
                                text: '3 kali',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(text: ' lagi.'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Divider(color: _errorRed.withValues(alpha: 0.2), height: 1),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 14, color: _errorRed),
                          const SizedBox(width: 6),
                          Text(
                            'Tips: Periksa apakah tombol Caps Lock aktif.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: _errorDarkRed,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // Remember Me Checkbox
              if (!_hasLoginError)
                Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1E1EF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (val) {
                          setState(() {
                            _rememberMe = val ?? false;
                          });
                        },
                        activeColor: _primaryColor,
                        side: BorderSide.none,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ingat Saya',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: _subtextColor),
                    ),
                  ],
                ),
              const SizedBox(height: 20),

              // Login Button
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  disabledBackgroundColor: _primaryColor.withValues(alpha: 0.6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _hasLoginError ? 'Coba Masuk Lagi' : 'Masuk',
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                        ],
                      ),
              ),
              const SizedBox(height: 24),

              // OR Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFFE1E1EF))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'ATAU',
                      style: GoogleFonts.plusJakartaSans(color: _hintColor, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFE1E1EF))),
                ],
              ),
              const SizedBox(height: 24),

              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tidak mempunyai akun? ',
                    style: GoogleFonts.plusJakartaSans(color: _subtextColor, fontSize: 13, fontWeight: FontWeight.w400),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text(
                      'Daftar Di Sini',
                      style: GoogleFonts.plusJakartaSans(
                        color: _primaryColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Help Link
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: Row(
                        children: [
                          Icon(Icons.support_agent, color: _primaryColor, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Bantuan Pengurus RT/RW',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _primaryColor,
                            ),
                          ),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Jika Anda warga baru atau mengalami kendala login, silakan hubungi pengurus klaster GateLand:',
                            style: TextStyle(fontSize: 12, height: 1.4),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F1FE),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('• Sekretariat RT 04: +62 811-9283-RT04', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                SizedBox(height: 6),
                                Text('• Pos Keamanan 24 Jam: +62 811-9283-001', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('Tutup', style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.help_outline, size: 16, color: _subtextColor),
                    const SizedBox(width: 4),
                    Text(
                      'Butuh bantuan pengurus RT/RW?',
                      style: GoogleFonts.plusJakartaSans(color: _subtextColor, fontSize: 12, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
