import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../data/dummy_data.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreeTerms = false;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  final Color _primaryColor = const Color(0xFF09095E);
  final Color _bgColor = const Color(0xFFF9FAFF);
  final Color _fieldColor = const Color(0xFFF4F5FB);

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

  // ─── Register ──────────────────────────────────────────────
  Future<void> _register() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi')),
      );
      return;
    }

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

    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus menyetujui syarat & ketentuan')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await ApiService.register(
        name: _nameController.text.trim(),
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (res['status'] == 'success') {
        // Juga simpan di DummyDataStore sebagai fallback
        final newUser = UserData(
          nama: _nameController.text.trim(),
          email: email,
          noWhatsapp: '+62${_phoneController.text.trim()}',
          alamat: _addressController.text.trim(),
          password: password,
        );
        DummyDataStore().register(newUser);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi Berhasil! Silakan login dengan akun baru Anda.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Registrasi gagal.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Fallback ke DummyDataStore lokal jika backend tidak tersedia
        final newUser = UserData(
          nama: _nameController.text.trim(),
          email: email,
          noWhatsapp: '+62${_phoneController.text.trim()}',
          alamat: _addressController.text.trim(),
          password: password,
        );
        final success = DummyDataStore().register(newUser);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registrasi Berhasil (offline)! Silakan login.'),
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email sudah terdaftar.')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF0F0FF),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back, color: _primaryColor, size: 20),
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.assignment_ind_outlined, color: _primaryColor, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'PENDAFTARAN WARGA',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _primaryColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Identitas Diri Penghuni',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Lengkapi data Anda untuk verifikasi domisili',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Main White Container wrapping the form
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cluster GateLand Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F5FB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.black12, width: 0.5),
                              ),
                              child: Image.asset('assets/logo.png', width: 20, height: 20, fit: BoxFit.contain),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Cluster GateLand',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: _primaryColor,
                                ),
                              ),
                            ),
                            const Icon(Icons.verified_user_outlined, color: Colors.black54, size: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Nama Lengkap
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Nama Lengkap', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                          Text('Sesuai KTP', style: TextStyle(fontSize: 11, color: _primaryColor, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _nameController,
                        hintText: 'Contoh: Budi Santoso',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                          Text('Harus @gmail.com', style: TextStyle(fontSize: 11, color: _primaryColor, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        onChanged: _onEmailChanged,
                        decoration: InputDecoration(
                          hintText: 'nama@gmail.com',
                          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                          prefixIcon: const Icon(Icons.email_outlined, color: Colors.black54, size: 20),
                          suffixText: '@gmail.com',
                          suffixStyle: TextStyle(
                            color: _primaryColor.withOpacity(0.5),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          filled: true,
                          fillColor: _fieldColor,
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

                      // WhatsApp
                      const Text('Nomor WhatsApp Aktif', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          hintText: '812 3456 7890',
                          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                          prefixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 14),
                              const Icon(Icons.chat_outlined, color: Colors.black54, size: 20),
                              const SizedBox(width: 8),
                              const Text('+62', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
                              const SizedBox(width: 8),
                              Container(height: 20, width: 1, color: Colors.black26),
                              const SizedBox(width: 12),
                            ],
                          ),
                          filled: true,
                          fillColor: _fieldColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // Alamat
                      const Text('Alamat / Blok & No Unit Rumah', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _addressController,
                        hintText: 'Contoh: Blok B4 Unit 1',
                        icon: Icons.location_on_outlined,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 8, left: 4),
                        child: Text(
                          'Pastikan sesuai dengan surat kepemilikan / kontrak sewa.',
                          style: TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password
                      const Text('Kata Sandi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        onChanged: (_) => setState(() => _passwordError = null),
                        decoration: InputDecoration(
                          hintText: 'Buat kata sandi akun',
                          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.black54, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.black54,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: _fieldColor,
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
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 4),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 14, color: _primaryColor),
                            const SizedBox(width: 4),
                            const Expanded(
                              child: Text(
                                'Min 8 karakter, huruf kapital, angka & simbol wajib',
                                style: TextStyle(fontSize: 11, color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Term and Conditions
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _agreeTerms = !_agreeTerms;
                              });
                            },
                            child: Container(
                              width: 20,
                              height: 20,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                color: _agreeTerms ? _primaryColor : const Color(0xFFFFE5E5),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _agreeTerms ? _primaryColor : const Color(0xFFFCA5A5),
                                  width: 1.5,
                                ),
                              ),
                              child: _agreeTerms
                                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.5),
                                children: [
                                  const TextSpan(text: 'Saya menyetujui '),
                                  TextSpan(
                                    text: 'syarat & ketentuan',
                                    style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                                  ),
                                  const TextSpan(text: ' tata tertib warga GateLand.'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Register Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _register,
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
                                    'Daftar Sekarang',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                                ],
                              ),
                      ),
                      const SizedBox(height: 40), // extra padding at bottom
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.black54, size: 20),
        filled: true,
        fillColor: _fieldColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
      keyboardType: keyboardType,
    );
  }
}
