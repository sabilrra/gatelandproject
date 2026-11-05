import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/dummy_data.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

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
  bool _hasRegisterError = false;
  bool _isLoading = false;

  final Color _primaryColor = const Color(0xFF090580);
  final Color _bgColor = const Color(0xFFFAF8FF);
  final Color _fieldColor = const Color(0xFFF3F2FF);
  final Color _errorRed = const Color(0xFFBA1A1A);
  final Color _errorDarkRed = const Color(0xFF93000A);
  final Color _errorBg = const Color(0xFFFFDAD6);

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || address.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi')),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kata sandi minimal 8 karakter')),
      );
      return;
    }

    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus menyetujui syarat & ketentuan')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await ApiService().register(
        name: name,
        email: email,
        password: password,
        role: 'USER',
      );

      if (res['status'] == 'success') {
        final newUser = UserData(
          nama: name,
          email: email,
          noWhatsapp: '+62$phone',
          alamat: address,
          password: password,
        );
        DummyDataStore().register(newUser);

        setState(() {
          _hasRegisterError = false;
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registrasi Berhasil! Silakan login dengan akun baru Anda.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
        return;
      } else {
        setState(() {
          _hasRegisterError = true;
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'Registrasi gagal.'),
              backgroundColor: _errorRed,
            ),
          );
        }
      }
    } catch (e) {
      final cleanMsg = e.toString().replaceAll('Exception: ', '');
      setState(() {
        _hasRegisterError = true;
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cleanMsg.isNotEmpty ? cleanMsg : 'Registrasi gagal.'),
            backgroundColor: _errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                          Text('Kirim OTP', style: TextStyle(fontSize: 11, color: _primaryColor, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'nama@email.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // WhatsApp
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Nomor WhatsApp Aktif', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                          Text('Kirim OTP', style: TextStyle(fontSize: 11, color: _primaryColor, fontWeight: FontWeight.w700)),
                        ],
                      ),
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
                              Icon(
                                Icons.chat_outlined,
                                color: _hasRegisterError ? _errorRed : Colors.black54,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text('+62', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
                              const SizedBox(width: 8),
                              Container(height: 20, width: 1, color: Colors.black26),
                              const SizedBox(width: 12),
                            ],
                          ),
                          filled: true,
                          fillColor: _hasRegisterError ? const Color(0xFFFCEFF3) : _fieldColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: _hasRegisterError ? BorderSide(color: _errorRed, width: 1.5) : BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: _hasRegisterError ? BorderSide(color: _errorRed, width: 1.5) : BorderSide.none,
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
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 8, left: 4),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 14, color: Color(0xFF09095E)),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Minimal 8 karakter kombinasi huruf & angka',
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
                            child: GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  builder: (ctx) => Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Syarat & Ketentuan Warga GateLand',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: _primaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          '1. Setiap warga wajib menjaga ketertiban, keamanan, dan kebersihan lingkungan klaster.\n'
                                          '2. Iuran bulanan (IPL, keamanan, kebersihan) dibayarkan sebelum tanggal 10 setiap bulannya.\n'
                                          '3. Akses gerbang utama menggunakan barcode/QR pass terdaftar demi keamanan bersama.',
                                          style: TextStyle(fontSize: 12, height: 1.5, color: Colors.black87),
                                        ),
                                        const SizedBox(height: 20),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
                                            onPressed: () {
                                              setState(() => _agreeTerms = true);
                                              Navigator.pop(ctx);
                                            },
                                            child: const Text('Setujui & Lanjutkan', style: TextStyle(color: Colors.white)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
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
                          ),
                        ],
                      ),
                      // Error Banner (shown when phone is already registered)
                      if (_hasRegisterError) ...[
                        const SizedBox(height: 16),
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
                                      'Pastikan Nomor WhatsApp Belum Pernah Terdaftar',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
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
                                child: Text(
                                  'Gunakan Nomor WhatsApp Lain Apabila Sudah Digunakan Dengan Format 812 3456 7890.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: _errorDarkRed,
                                    height: 1.4,
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
                                    'Tips: Pastikan Format Angka Sesuai.',
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

                      const SizedBox(height: 24),

                      // Register Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          disabledBackgroundColor: _primaryColor.withValues(alpha: 0.6),
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
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _hasRegisterError ? 'Coba Daftar Lagi' : 'Daftar Sekarang',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                                ],
                              ),
                      ),
                      const SizedBox(height: 20),

                      // Sudah Punya Akun Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sudah mempunyai akun? ',
                            style: GoogleFonts.plusJakartaSans(color: Colors.black54, fontSize: 13),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              'Masuk Di Sini',
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
                      const SizedBox(height: 32),
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
