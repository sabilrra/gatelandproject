import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/dummy_data.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(text: 'sabilarraulia@gmail.com');
  final TextEditingController _passwordController = TextEditingController(text: 'Sabila1527-');
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  final Color _primaryColor = const Color(0xFF09095E);
  final Color _bgColor = const Color(0xFFF9FAFF);

  // ─── Validasi email @gmail.com ─────────────────────────────
  String? _validateEmail(String email) {
    if (email.isEmpty) return 'Email wajib diisi.';
    if (!email.endsWith('@gmail.com')) return 'Email harus menggunakan @gmail.com';
    final regex = RegExp(r'^[^\s@]+@gmail\.com$');
    if (!regex.hasMatch(email)) return 'Format email tidak valid.';
    return null;
  }

  // ─── Validasi password kuat ────────────────────────────────
  String? _validatePassword(String password) {
    if (password.isEmpty) return 'Password wajib diisi.';
    if (password.length < 8) return 'Password minimal 8 karakter.';
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password harus ada huruf kapital (A-Z).';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password harus ada angka (0-9).';
    }
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      return 'Password harus ada simbol (contoh: !@#\$%-_).';
    }
    return null;
  }

  // ─── Auto-append @gmail.com saat ketik ─────────────────────
  void _onEmailChanged(String value) {
    // Jika belum ada @, otomatis tambahkan @gmail.com di belakang
    if (value.isNotEmpty && !value.contains('@')) {
      final newText = '$value@gmail.com';
      _emailController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
    setState(() {
      _emailError = null;
    });
  }

  // ─── Login ─────────────────────────────────────────────────
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Client-side validation
    final eErr = _validateEmail(email);
    final pErr = _validatePassword(password);
    setState(() {
      _emailError = eErr;
      _passwordError = pErr;
    });
    if (eErr != null || pErr != null) return;

    setState(() => _isLoading = true);

    try {
      final res = await ApiService.login(email, password);

      if (!mounted) return;

      if (res['status'] == 'success') {
        final userData = res['data']?['user'];
        DummyDataStore().currentUser = UserData(
          nama: userData?['name'] ?? 'Warga GateLand',
          email: userData?['email'] ?? email,
          noWhatsapp: '0812-3456-7890',
          alamat: 'Cluster Anggrek, Blok B2 No. 14',
          password: password,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selamat datang, ${userData?['name'] ?? 'Warga'}!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        // Jika login API gagal, coba cek DummyData lokal sebagai fallback
        final fallbackUser = DummyDataStore().login(email, password);
        if (fallbackUser != null) {
          DummyDataStore().currentUser = fallbackUser;
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'Email atau password salah.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: _primaryColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Smart Living Starts Here.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Welcome Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                              color: const Color(0xFFEBEBFF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.home, size: 14, color: _primaryColor),
                                const SizedBox(width: 4),
                                Text(
                                  'Portal Warga',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Selamat Datang!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Masuk untuk mengelola tagihan & info warga',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0F0FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.waving_hand, color: _primaryColor),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Email Field
              const Text(
                'Email :',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Gunakan alamat @gmail.com',
                style: TextStyle(fontSize: 11, color: Colors.black45),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                onChanged: _onEmailChanged,
                decoration: InputDecoration(
                  hintText: 'nama@gmail.com',
                  hintStyle: const TextStyle(color: Colors.black38),
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.black54),
                  suffixText: '@gmail.com',
                  suffixStyle: TextStyle(
                    color: _primaryColor.withOpacity(0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: _emailError != null
                        ? const BorderSide(color: Colors.redAccent, width: 1.5)
                        : BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: _emailError != null
                        ? const BorderSide(color: Colors.redAccent, width: 1.5)
                        : BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              if (_emailError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    _emailError!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              const SizedBox(height: 16),

              // Password Field
              const Text(
                'Password',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Huruf kapital, angka, dan simbol wajib ada',
                style: TextStyle(fontSize: 11, color: Colors.black45),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: (_) => setState(() => _passwordError = null),
                decoration: InputDecoration(
                  hintText: 'Masukkan kata sandi',
                  hintStyle: const TextStyle(color: Colors.black38),
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.black54),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: _passwordError != null
                        ? const BorderSide(color: Colors.redAccent, width: 1.5)
                        : BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: _passwordError != null
                        ? const BorderSide(color: Colors.redAccent, width: 1.5)
                        : BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              if (_passwordError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    _passwordError!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              const SizedBox(height: 12),

              // Remember Me & Lupa Kata Sandi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (val) {
                            setState(() {
                              _rememberMe = val ?? false;
                            });
                          },
                          shape: const CircleBorder(),
                          activeColor: _primaryColor,
                          side: const BorderSide(color: Color(0xFFD0D0D0), width: 1.5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Ingat Saya', style: TextStyle(fontSize: 13, color: Colors.black87)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/lupa-kata-sandi');
                    },
                    child: Text(
                      'Lupa Kata Sandi?',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Login Button
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Masuk',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                        ],
                      ),
              ),
              const SizedBox(height: 24),

              // OR Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: Colors.black12)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('ATAU', style: TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const Expanded(child: Divider(color: Colors.black12)),
                ],
              ),
              const SizedBox(height: 24),

              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Tidak mempunyai akun? ', style: TextStyle(color: Colors.black54)),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text(
                      'Daftar Di Sini',
                      style: TextStyle(
                        color: _primaryColor,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Help Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.help_outline, size: 16, color: Colors.black45),
                  const SizedBox(width: 4),
                  const Text('Butuh bantuan pengurus RT/RW?', style: TextStyle(color: Colors.black45, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
