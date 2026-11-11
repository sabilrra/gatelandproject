import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UbahKataSandiScreen extends StatefulWidget {
  const UbahKataSandiScreen({super.key});

  @override
  State<UbahKataSandiScreen> createState() => _UbahKataSandiScreenState();
}

class _UbahKataSandiScreenState extends State<UbahKataSandiScreen> {
  final Color _primaryColor = const Color(0xFF09095E);
  final Color _bgColor = const Color(0xFFFBFBFF);
  final Color _inputFillColor = const Color(0xFFF3F3FA);

  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _logoutOtherDevices = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Args dari VerifikasiOtpScreen
  late String _email;
  late String _otpCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _email = args?['email'] as String? ?? '';
    _otpCode = args?['otpCode'] as String? ?? '';
  }

  @override
  void dispose() {
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _showErrorPopup(String title, String message) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.lock_outline, color: Color(0xFFD32F2F), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFB71C1C),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(fontSize: 12.5, color: Colors.black87, height: 1.45),
              ),
              const SizedBox(height: 16),
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
                    'Perbaiki Kata Sandi',
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

  Future<void> _savePassword() async {
    final newPass = _newPassController.text;
    final confirmPass = _confirmPassController.text;

    if (newPass.isEmpty) {
      const msg = 'Kata sandi baru tidak boleh kosong.';
      setState(() => _errorMessage = msg);
      await _showErrorPopup('Kata Sandi Wajib Diisi', msg);
      return;
    }

    final missingRules = <String>[];
    if (newPass.length < 8) missingRules.add('minimal 8 karakter');
    if (RegExp(r'\s').hasMatch(newPass)) missingRules.add('tidak boleh mengandung spasi');
    if (!RegExp(r'[A-Z]').hasMatch(newPass)) missingRules.add('kombinasi huruf kapital (A–Z)');
    if (!RegExp(r'[0-9]').hasMatch(newPass)) missingRules.add('kombinasi angka (0–9)');
    if (!RegExp(r'[^A-Za-z0-9\s]').hasMatch(newPass)) {
      missingRules.add('simbol seperti tanda seru (!) atau strip (-)');
    }

    if (missingRules.isNotEmpty) {
      final msg = 'Kata sandi baru belum memenuhi ketentuan: ${missingRules.join(', ')}.';
      setState(() => _errorMessage = msg);
      await _showErrorPopup('Kata Sandi Belum Memenuhi Syarat', msg);
      return;
    }

    if (newPass != confirmPass) {
      const msg = 'Konfirmasi kata sandi baru tidak cocok.';
      setState(() => _errorMessage = msg);
      await _showErrorPopup('Konfirmasi Tidak Cocok', msg);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ApiService().verifyOtp(
        email: _email,
        code: _otpCode,
        newPassword: newPass,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Kata sandi baru berhasil disimpan!'),
            ],
          ),
          backgroundColor: const Color(0xFF1B8754),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // Kembali ke halaman login setelah reset berhasil
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _errorMessage = msg;
      });
      await _showErrorPopup('Gagal Mengubah Kata Sandi', msg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasMinLength = _newPassController.text.length >= 8;
    final hasUppercase = _newPassController.text.contains(RegExp(r'[A-Z]'));
    final hasNumber = _newPassController.text.contains(RegExp(r'[0-9]'));
    final hasSpecial =
        _newPassController.text.contains(RegExp(r'[^A-Za-z0-9\s]'));
    final isMatch = _newPassController.text.isNotEmpty &&
        _newPassController.text == _confirmPassController.text;

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

              // 2. Badge & Title
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF0FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.security, size: 13, color: _primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      'KEAMANAN AKUN WARGA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Buat Kata Sandi Baru',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pastikan kata sandi baru Anda kuat dan tidak mudah ditebak untuk menjaga keamanan data hunian dan portal warga.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Error message global
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F0),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFCDD2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          size: 16, color: Color(0xFFE53935)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFFE53935)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Kata Sandi Baru
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Kata Sandi Baru',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87),
                  ),
                  Text(
                    'Rekomendasi Aman',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3F51B5)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: _inputFillColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _newPassController,
                  obscureText: _obscureNew,
                  onChanged: (val) => setState(() {
                    _errorMessage = null;
                  }),
                  style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.key_outlined,
                        size: 18, color: Colors.black54),
                    suffixIcon: GestureDetector(
                      onTap: () =>
                          setState(() => _obscureNew = !_obscureNew),
                      child: Icon(
                        _obscureNew
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 18,
                        color: Colors.black54,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Checklist Persyaratan Kata Sandi
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildChecklistItem('Minimal 8 karakter', hasMinLength),
                    const SizedBox(height: 6),
                    _buildChecklistItem(
                        'Kombinasi huruf kapital (A–Z)',
                        hasUppercase),
                    const SizedBox(height: 6),
                    _buildChecklistItem('Kombinasi angka (0–9)', hasNumber),
                    const SizedBox(height: 6),
                    _buildChecklistItem(
                        'Mengandung simbol seperti tanda seru (!) atau strip (-)',
                        hasSpecial),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Konfirmasi Kata Sandi Baru
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Konfirmasi Kata Sandi Baru',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87),
                  ),
                  if (isMatch)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF0FE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check,
                              size: 10, color: Color(0xFF3F51B5)),
                          SizedBox(width: 4),
                          Text(
                            'Kata sandi cocok',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3F51B5)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: _inputFillColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _confirmPassController,
                  obscureText: _obscureConfirm,
                  onChanged: (val) => setState(() {
                    _errorMessage = null;
                  }),
                  style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.sync,
                        size: 18, color: Colors.black54),
                    suffixIcon: GestureDetector(
                      onTap: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      child: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 18,
                        color: Colors.black54,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 5. Card: Keluar dari Perangkat Lain
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1F1F7)),
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
                      child: Icon(Icons.devices_outlined,
                          color: _primaryColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keluar dari perangkat lain',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Secara otomatis mengeluarkan akun Anda dari semua sesi aplikasi atau ponsel lain yang aktif.',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _logoutOtherDevices,
                      activeThumbColor: _primaryColor,
                      activeTrackColor:
                          _primaryColor.withValues(alpha: 0.4),
                      onChanged: (val) =>
                          setState(() => _logoutOtherDevices = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 6. Action Button: Simpan Kata Sandi Baru
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _savePassword,
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
                            Icon(Icons.save_outlined,
                                color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Simpan Kata Sandi Baru',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward,
                                color: Colors.white, size: 16),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),

              // Batal Button
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistItem(String title, bool isChecked) {
    return Row(
      children: [
        Icon(
          isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 15,
          color: isChecked ? const Color(0xFF3F51B5) : Colors.black38,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: isChecked ? Colors.black87 : Colors.black45,
              fontWeight:
                  isChecked ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
