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
  bool _isLoading = false;
  bool _hasSubmitted = false;

  Map<String, String> _fieldErrors = {};
  String? _errorTitle;
  String? _errorSubtitle;

  final Color _primaryColor = const Color(0xFF090580);
  final Color _bgColor = const Color(0xFFFAF8FF);
  final Color _fieldColor = const Color(0xFFF3F2FF);
  final Color _errorRed = const Color(0xFFBA1A1A);
  final Color _errorDarkRed = const Color(0xFF93000A);
  final Color _errorBg = const Color(0xFFFFDAD6);
  final Color _errorFill = const Color(0xFFFCEFF3);
  final Color _successGreen = const Color(0xFF1A7A4A);

  bool _hasError(String field) => _fieldErrors.containsKey(field);

  void _clearFieldError(String field) {
    if (_fieldErrors.containsKey(field) || _errorTitle != null) {
      setState(() {
        _fieldErrors.remove(field);
        if (_fieldErrors.isEmpty) {
          _errorTitle = null;
          _errorSubtitle = null;
        }
      });
    }
  }

  Map<String, String> _validateLocally() {
    final errors = <String, String>{};
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty) {
      errors['name'] = 'Nama lengkap wajib diisi.';
    } else if (name.length < 2) {
      errors['name'] = 'Nama lengkap minimal 2 karakter.';
    }

    final gmailPattern = RegExp(r'^[A-Za-z0-9._%+-]+@gmail\.com$', caseSensitive: false);
    if (email.isEmpty) {
      errors['email'] = 'Email wajib diisi.';
    } else if (email.startsWith('.') ||
        email.endsWith('.@gmail.com') ||
        email.contains('..') ||
        !gmailPattern.hasMatch(email)) {
      errors['email'] = 'Email harus valid dan menggunakan @gmail.com (contoh: nama@gmail.com).';
    }

    final phoneDigits = phone.replaceAll(RegExp(r'\D'), '');
    if (phone.isEmpty) {
      errors['whatsapp'] = 'Nomor WhatsApp aktif wajib diisi.';
    } else if (!RegExp(r'^[+\d\s\-()]+$').hasMatch(phone)) {
      errors['whatsapp'] = 'Nomor WhatsApp hanya boleh berisi angka.';
    } else if (phoneDigits.length < 9 || phoneDigits.length > 15) {
      errors['whatsapp'] = 'Nomor WhatsApp harus berisi 9–15 digit angka (contoh: 812 3456 7890).';
    }

    if (address.isEmpty) {
      errors['address'] = 'Alamat / Blok & No. Unit rumah wajib diisi.';
    } else if (address.length < 3) {
      errors['address'] = 'Alamat / Blok & No. Unit minimal 3 karakter (contoh: Blok B5 Unit 5).';
    }

    final missingPassRules = <String>[];
    if (password.isEmpty) {
      errors['password'] = 'Kata sandi wajib diisi.';
    } else {
      if (password.length < 8) missingPassRules.add('minimal 8 karakter');
      if (RegExp(r'\s').hasMatch(password)) missingPassRules.add('tanpa spasi');
      if (!RegExp(r'[A-Z]').hasMatch(password)) missingPassRules.add('huruf kapital (A–Z)');
      if (!RegExp(r'[0-9]').hasMatch(password)) missingPassRules.add('angka (0–9)');
      if (!RegExp(r'[^A-Za-z0-9\s]').hasMatch(password)) {
        missingPassRules.add('simbol seperti tanda seru (!) atau strip (-)');
      }
      if (missingPassRules.isNotEmpty) {
        errors['password'] = 'Kata sandi kurang memenuhi syarat: ${missingPassRules.join(', ')}.';
      }
    }

    if (!_agreeTerms) {
      errors['terms'] = 'Anda harus menyetujui syarat & ketentuan warga GateLand.';
    }

    return errors;
  }

  void _applyBannerFromFieldErrors(Map<String, String> errors, {String? fallbackMessage}) {
    if (errors.isEmpty) {
      _errorTitle = 'Registrasi Belum Berhasil';
      _errorSubtitle = (fallbackMessage != null && fallbackMessage.isNotEmpty)
          ? fallbackMessage
          : 'Terjadi kesalahan saat memproses pendaftaran. Silakan periksa kembali data Anda.';
      return;
    }

    if (errors.length == 1) {
      final entry = errors.entries.first;
      switch (entry.key) {
        case 'password':
          _errorTitle = 'Kata Sandi Belum Sesuai Ketentuan';
          _errorSubtitle = entry.value;
          break;
        case 'whatsapp':
          _errorTitle = 'Periksa Nomor WhatsApp Anda';
          _errorSubtitle = entry.value;
          break;
        case 'email':
          _errorTitle = 'Periksa Alamat Email Anda';
          _errorSubtitle = entry.value;
          break;
        case 'address':
          _errorTitle = 'Periksa Alamat / Unit Rumah Anda';
          _errorSubtitle = entry.value;
          break;
        case 'name':
          _errorTitle = 'Periksa Nama Lengkap Anda';
          _errorSubtitle = entry.value;
          break;
        case 'terms':
          _errorTitle = 'Persetujuan Syarat & Ketentuan Diperlukan';
          _errorSubtitle = entry.value;
          break;
        default:
          _errorTitle = 'Data Pendaftaran Tidak Valid';
          _errorSubtitle = entry.value;
      }
      return;
    }

    const fieldLabels = {
      'name': 'Nama Lengkap',
      'email': 'Email',
      'whatsapp': 'Nomor WhatsApp',
      'address': 'Alamat / Unit',
      'password': 'Kata Sandi',
      'terms': 'Syarat & Ketentuan',
    };
    final summaryLines = errors.entries
        .map((e) => '• ${fieldLabels[e.key] ?? e.key}: ${e.value.replaceAll('\n', ' ')}')
        .join('\n');

    _errorTitle = 'Ada ${errors.length} Bagian yang Perlu Diperbaiki';
    _errorSubtitle = summaryLines;
  }

  static const Map<String, String> _fieldLabels = {
    'name': 'Nama Lengkap',
    'email': 'Email (@gmail.com)',
    'whatsapp': 'Nomor WhatsApp',
    'address': 'Alamat / Unit',
    'password': 'Kata Sandi',
    'terms': 'Syarat & Ketentuan',
  };

  IconData _iconForField(String? field) {
    switch (field) {
      case 'email':
        return Icons.mark_email_read_outlined;
      case 'whatsapp':
        return Icons.chat_outlined;
      case 'password':
        return Icons.lock_outline;
      case 'address':
        return Icons.location_on_outlined;
      case 'name':
        return Icons.person_outline;
      case 'terms':
        return Icons.fact_check_outlined;
      default:
        return Icons.error_outline;
    }
  }

  Future<void> _showValidationPopup(Map<String, String> errors) async {
    if (!mounted) return;
    final String? singleField = errors.length == 1 ? errors.keys.first : null;
    final String popupTitle = _errorTitle ?? 'Validasi Pendaftaran';
    final String popupBody = _errorSubtitle ?? 'Silakan periksa kembali data yang Anda masukkan.';

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _errorBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _iconForField(singleField),
                      color: _errorRed,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (errors.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _errorFill,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              singleField != null
                                  ? 'Kolom: ${_fieldLabels[singleField] ?? singleField}'
                                  : '${errors.length} Kolom Bermasalah',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _errorRed,
                              ),
                            ),
                          ),
                        Text(
                          popupTitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _errorDarkRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                popupBody,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: Colors.black87,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Perbaiki Data',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final password = _passwordController.text;

    final localErrors = _validateLocally();
    if (localErrors.isNotEmpty) {
      setState(() {
        _hasSubmitted = true;
        _fieldErrors = localErrors;
        _applyBannerFromFieldErrors(localErrors);
      });
      await _showValidationPopup(localErrors);
      return;
    }

    setState(() {
      _hasSubmitted = true;
      _isLoading = true;
      _fieldErrors = {};
      _errorTitle = null;
      _errorSubtitle = null;
    });

    try {
      final res = await ApiService().register(
        name: name,
        email: email,
        whatsapp: phone,
        address: address,
        password: password,
        role: 'USER',
      );

      if (res['status'] == 'success') {
        final userData = res['data']?['user'] as Map<String, dynamic>?;
        final normalizedWa = (userData?['whatsapp'] ?? '+62$phone').toString();
        final newUser = UserData(
          nama: name,
          email: email,
          noWhatsapp: normalizedWa,
          alamat: address,
          password: password,
        );
        DummyDataStore().register(newUser);
        if (userData != null) {
          DummyDataStore().syncFromBackendUser(userData, password: password);
        }

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registrasi Berhasil! Data Anda tersimpan, silakan login.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context, email);
        }
        return;
      } else {
        setState(() {
          _applyBannerFromFieldErrors({}, fallbackMessage: res['message']?.toString());
          _isLoading = false;
        });
        await _showValidationPopup({});
      }
    } catch (e) {
      final Map<String, String> serverFieldErrors = {};
      String rawMessage = e.toString().replaceAll('Exception: ', '');

      if (e is ApiException) {
        rawMessage = e.message;
        e.fieldErrors.forEach((key, value) {
          if (key.isNotEmpty && value.isNotEmpty) {
            serverFieldErrors[key] = value;
          }
        });
      }

      if (serverFieldErrors.isEmpty) {
        final lower = rawMessage.toLowerCase();
        if (lower.contains('sandi') || lower.contains('password')) {
          serverFieldErrors['password'] = rawMessage;
        } else if (lower.contains('email') || lower.contains('gmail')) {
          serverFieldErrors['email'] = rawMessage;
        } else if (lower.contains('whatsapp') || lower.contains('nomor whatsapp')) {
          serverFieldErrors['whatsapp'] = rawMessage;
        } else if (lower.contains('alamat') || lower.contains('unit') || lower.contains('blok')) {
          serverFieldErrors['address'] = rawMessage;
        } else if (lower.contains('nama')) {
          serverFieldErrors['name'] = rawMessage;
        }
      }

      if (mounted) {
        setState(() {
          _fieldErrors = serverFieldErrors;
          _applyBannerFromFieldErrors(serverFieldErrors, fallbackMessage: rawMessage);
          _isLoading = false;
        });
        await _showValidationPopup(serverFieldErrors);
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
                          Text(
                            'Nama Lengkap',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _hasError('name') ? _errorRed : Colors.black87,
                            ),
                          ),
                          Text('Sesuai KTP', style: TextStyle(fontSize: 11, color: _primaryColor, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _nameController,
                        hintText: 'Contoh: Budi Santoso',
                        icon: Icons.person_outline,
                        errorText: _fieldErrors['name'],
                        onChanged: (_) => _clearFieldError('name'),
                      ),
                      const SizedBox(height: 16),

                      // Email
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Email (@gmail.com)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _hasError('email') ? _errorRed : Colors.black87,
                            ),
                          ),
                          Text('Kirim OTP', style: TextStyle(fontSize: 11, color: _primaryColor, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'nama@gmail.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        errorText: _fieldErrors['email'],
                        onChanged: (_) => _clearFieldError('email'),
                      ),
                      const SizedBox(height: 16),

                      // WhatsApp
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Nomor WhatsApp Aktif',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _hasError('whatsapp') ? _errorRed : Colors.black87,
                            ),
                          ),
                          Text('Kirim OTP', style: TextStyle(fontSize: 11, color: _primaryColor, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _phoneController,
                        onChanged: (_) => _clearFieldError('whatsapp'),
                        decoration: InputDecoration(
                          hintText: '812 3456 7890',
                          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                          prefixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 14),
                              Icon(
                                Icons.chat_outlined,
                                color: _hasError('whatsapp') ? _errorRed : Colors.black54,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '+62',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: _hasError('whatsapp') ? _errorRed : Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(height: 20, width: 1, color: Colors.black26),
                              const SizedBox(width: 12),
                            ],
                          ),
                          filled: true,
                          fillColor: _hasError('whatsapp') ? _errorFill : _fieldColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: _hasError('whatsapp') ? BorderSide(color: _errorRed, width: 1.5) : BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: _hasError('whatsapp') ? BorderSide(color: _errorRed, width: 1.5) : BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _hasError('whatsapp') ? _errorRed : _primaryColor,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      if (_hasError('whatsapp'))
                        _buildFieldErrorText(_fieldErrors['whatsapp']!),
                      const SizedBox(height: 16),

                      // Alamat
                      Text(
                        'Alamat / Blok & No Unit Rumah',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _hasError('address') ? _errorRed : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _addressController,
                        hintText: 'Contoh: Blok B5 Unit 5',
                        icon: Icons.location_on_outlined,
                        errorText: _fieldErrors['address'],
                        onChanged: (_) => _clearFieldError('address'),
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
                      Text(
                        'Kata Sandi',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _hasError('password') ? _errorRed : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        onChanged: (_) {
                          setState(() {
                            _fieldErrors.remove('password');
                            if (_fieldErrors.isEmpty) {
                              _errorTitle = null;
                              _errorSubtitle = null;
                            }
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Buat kata sandi akun',
                          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: _hasError('password') ? _errorRed : Colors.black54,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: _hasError('password') ? _errorRed : Colors.black54,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: _hasError('password') ? _errorFill : _fieldColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: _hasError('password') ? BorderSide(color: _errorRed, width: 1.5) : BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: _hasError('password') ? BorderSide(color: _errorRed, width: 1.5) : BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _hasError('password') ? _errorRed : _primaryColor,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      if (_hasError('password'))
                        _buildFieldErrorText(_fieldErrors['password']!),
                      const SizedBox(height: 10),
                      _buildPasswordRequirementsBox(),
                      const SizedBox(height: 24),

                      // Term and Conditions
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _agreeTerms = !_agreeTerms;
                                if (_agreeTerms) {
                                  _fieldErrors.remove('terms');
                                  if (_fieldErrors.isEmpty) {
                                    _errorTitle = null;
                                    _errorSubtitle = null;
                                  }
                                }
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
                                  color: _agreeTerms
                                      ? _primaryColor
                                      : (_hasError('terms') ? _errorRed : const Color(0xFFFCA5A5)),
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
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  builder: (ctx) => Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight: MediaQuery.of(ctx).size.height * 0.72,
                                      ),
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
                                          const Flexible(
                                            child: SingleChildScrollView(
                                              child: Text(
                                                '1. Setiap warga wajib menjaga ketertiban, keamanan, kenyamanan, serta kebersihan lingkungan di seluruh area klaster GateLand.\n\n'
                                                '2. Iuran bulanan (IPL, keamanan, dan kebersihan) dibayarkan sebelum batas waktu yang telah ditentukan oleh pengelola klaster pada setiap periode penagihan guna menjaga kelancaran operasional dan fasilitas lingkungan.\n\n'
                                                '3. Data diri yang didaftarkan (nama lengkap, email aktif, nomor WhatsApp, dan alamat unit rumah) wajib benar serta dapat dipertanggungjawabkan untuk keperluan verifikasi admin dan informasi tagihan.\n\n'
                                                '4. Warga bersedia mematuhi seluruh tata tertib lingkungan, ketentuan parkir, serta aturan kunjungan tamu yang berlaku di klaster GateLand.',
                                                style: TextStyle(fontSize: 12.5, height: 1.55, color: Colors.black87),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: _primaryColor,
                                                padding: const EdgeInsets.symmetric(vertical: 13),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _agreeTerms = true;
                                                  _fieldErrors.remove('terms');
                                                  if (_fieldErrors.isEmpty) {
                                                    _errorTitle = null;
                                                    _errorSubtitle = null;
                                                  }
                                                });
                                                Navigator.pop(ctx);
                                              },
                                              child: const Text('Setujui & Lanjutkan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                        ],
                                      ),
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
                      if (_hasError('terms'))
                        _buildFieldErrorText(_fieldErrors['terms']!),

                      // Error Banner (shows exact failing field(s) & reason)
                      if (_errorTitle != null) ...[
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
                                      _errorTitle!,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: _errorDarkRed,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                                if (_errorSubtitle != null && _errorSubtitle!.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30),
                                    child: Text(
                                      _errorSubtitle!,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: _errorDarkRed,
                                        height: 1.45,
                                      ),
                                    ),
                                  ),
                                ],
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
                                    _errorTitle != null ? 'Coba Daftar Lagi' : 'Daftar Sekarang',
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

  Widget _buildFieldErrorText(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 14, color: _errorRed),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _errorRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordRequirementsBox() {
    final pass = _passwordController.text;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(pass);
    final hasNumber = RegExp(r'[0-9]').hasMatch(pass);
    final hasSymbol = RegExp(r'[^A-Za-z0-9\s]').hasMatch(pass);
    final hasMinLength = pass.length >= 8;
    final hasNoSpace = !RegExp(r'\s').hasMatch(pass);
    final showMissingAsError = _hasSubmitted && _hasError('password');

    Widget buildRuleRow(String label, bool isValid) {
      final Color iconColor = isValid
          ? _successGreen
          : (showMissingAsError ? _errorRed : _primaryColor.withValues(alpha: 0.45));
      final Color textColor = isValid
          ? _successGreen
          : (showMissingAsError ? _errorDarkRed : Colors.black54);
      final IconData iconData = isValid
          ? Icons.check_circle
          : (showMissingAsError ? Icons.cancel_outlined : Icons.radio_button_unchecked);

      return Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(iconData, size: 15, color: iconColor),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.3,
                  fontWeight: isValid ? FontWeight.w600 : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: showMissingAsError ? const Color(0xFFFFF4F4) : const Color(0xFFF4F5FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: showMissingAsError
              ? _errorRed.withValues(alpha: 0.35)
              : const Color(0xFFE1E3F5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 14,
                color: showMissingAsError ? _errorRed : _primaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                'Ketentuan Kata Sandi:',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: showMissingAsError ? _errorDarkRed : _primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          buildRuleRow('Kombinasi huruf kapital (A–Z)', hasUppercase),
          buildRuleRow('Kombinasi angka (0–9)', hasNumber),
          buildRuleRow('Simbol / karakter khusus seperti tanda seru (!) atau strip (-)', hasSymbol),
          buildRuleRow('Minimal 8 karakter', hasMinLength),
          if (!hasNoSpace)
            buildRuleRow('Tidak boleh mengandung spasi', false),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    final bool hasErr = errorText != null && errorText.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
            prefixIcon: Icon(icon, color: hasErr ? _errorRed : Colors.black54, size: 20),
            filled: true,
            fillColor: hasErr ? _errorFill : _fieldColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: hasErr ? BorderSide(color: _errorRed, width: 1.5) : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: hasErr ? BorderSide(color: _errorRed, width: 1.5) : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasErr ? _errorRed : _primaryColor,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          keyboardType: keyboardType,
        ),
        if (hasErr) _buildFieldErrorText(errorText),
      ],
    );
  }
}
