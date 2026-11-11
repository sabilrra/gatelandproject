import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/dummy_data.dart';
import '../services/api_service.dart';
import '../widgets/profile_avatar.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final Color _primaryColor = const Color(0xFF09095E);
  final Color _bgColor = const Color(0xFFFBFBFF);
  final Color _inputFillColor = const Color(0xFFF3F3FA);

  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _nikController;
  late TextEditingController _ttlController;
  late TextEditingController _familyCountController;
  late TextEditingController _unitController;
  late TextEditingController _rwAreaController;
  late TextEditingController _ownershipController;
  late TextEditingController _powerWaterController;
  late TextEditingController _vehiclesController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyPhoneController;

  String _statusKependudukan = '';
  String _statusPenghuni = '';
  String _fotoPath = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final store = DummyDataStore();
    final user = store.activeUser;
    final profile = store.profile;

    _nameController = TextEditingController(text: user.nama);
    _emailController = TextEditingController(text: user.email);

    String phone = user.noWhatsapp.replaceAll('+62', '').trim();
    if (phone == '-') phone = '';
    if (phone.startsWith('62') && phone.length > 9) phone = phone.substring(2);
    if (phone.startsWith('0')) phone = phone.substring(1);
    _phoneController = TextEditingController(text: phone);

    _nikController = TextEditingController(text: profile.nik);
    _ttlController = TextEditingController(text: profile.ttl);
    _familyCountController = TextEditingController(text: profile.jumlahKeluarga);
    _unitController = TextEditingController(text: profile.unit == 'GateLand' ? '' : profile.unit);
    _rwAreaController = TextEditingController(text: profile.wilayahRW);
    _ownershipController = TextEditingController(text: profile.statusKepemilikan);
    _powerWaterController = TextEditingController(text: profile.dayaListrik);
    _vehiclesController = TextEditingController(
      text: [profile.kendaraan, profile.kendaraanTambahan]
          .where((s) => s.trim().isNotEmpty)
          .join(', '),
    );
    _emergencyNameController = TextEditingController(text: profile.namaKontakDarurat);
    _emergencyPhoneController = TextEditingController(text: profile.kontakDarurat);

    _statusKependudukan = profile.statusKependudukan;
    _statusPenghuni = profile.statusPenghuni;
    _fotoPath = profile.fotoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nikController.dispose();
    _ttlController.dispose();
    _familyCountController.dispose();
    _unitController.dispose();
    _rwAreaController.dispose();
    _ownershipController.dispose();
    _powerWaterController.dispose();
    _vehiclesController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFrom(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 480,
        maxHeight: 480,
        imageQuality: 70,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      final ext = picked.name.toLowerCase().endsWith('.png') ? 'png' : 'jpeg';
      final dataUrl = 'data:image/$ext;base64,${base64Encode(bytes)}';

      if (mounted) {
        setState(() => _fotoPath = dataUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil dipilih')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih foto: $e')),
        );
      }
    }
  }

  void _showPhotoPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Foto Profil',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF0FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.photo_library_outlined, color: _primaryColor),
                ),
                title: const Text('Pilih dari Galeri', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImageFrom(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF0FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.camera_alt_outlined, color: _primaryColor),
                ),
                title: const Text('Ambil Foto dengan Kamera', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImageFrom(ImageSource.camera);
                },
              ),
              if (_fotoPath.isNotEmpty)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEEEE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline, color: Color(0xFFE53935)),
                  ),
                  title: const Text(
                    'Hapus Foto Profil',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFFE53935)),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _deletePhoto();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _deletePhoto() {
    setState(() {
      _fotoPath = '';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Foto profil dihapus')),
    );
  }

  Future<void> _saveChanges() async {
    final updatedName = _nameController.text.trim();
    final updatedEmail = _emailController.text.trim().toLowerCase();
    final rawPhone = _phoneController.text.trim();
    final updatedUnit = _unitController.text.trim();

    if (updatedName.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama lengkap minimal 2 karakter.'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    if (!updatedEmail.endsWith('@gmail.com') || !updatedEmail.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email harus valid dan menggunakan domain @gmail.com.'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final store = DummyDataStore();
    final cleanPhoneDigits = rawPhone.replaceAll(RegExp(r'\D'), '');
    final formattedWa = cleanPhoneDigits.isEmpty ? '' : '+62 $cleanPhoneDigits';

    try {
      if (ApiService().isLoggedIn) {
        final payload = <String, dynamic>{
          'name': updatedName,
          'email': updatedEmail,
          'whatsapp': cleanPhoneDigits.isEmpty ? null : '62$cleanPhoneDigits',
          'address': updatedUnit,
          'nik': _nikController.text.trim(),
          'birthPlaceDate': _ttlController.text.trim(),
          'residencyStatus': _statusKependudukan,
          'familyCount': _familyCountController.text.trim(),
          'emergencyContactName': _emergencyNameController.text.trim(),
          'emergencyContactPhone': _emergencyPhoneController.text.trim(),
          'rwArea': _rwAreaController.text.trim(),
          'occupancyStatus': _statusPenghuni,
          'ownershipType': _ownershipController.text.trim(),
          'powerWater': _powerWaterController.text.trim(),
          'vehicles': _vehiclesController.text.trim(),
          'photoUrl': _fotoPath,
        };

        final res = await ApiService().updateProfile(payload);
        final updatedUser = res['data'] as Map<String, dynamic>?;
        if (updatedUser != null) {
          store.syncFromBackendUser(updatedUser);
        }
      } else {
        if (store.currentUser != null) {
          store.currentUser!.nama = updatedName;
          store.currentUser!.email = updatedEmail;
          store.currentUser!.noWhatsapp = formattedWa.isEmpty ? '-' : formattedWa;
          store.currentUser!.alamat = updatedUnit;
        }
        store.profile.nik = _nikController.text.trim();
        store.profile.ttl = _ttlController.text.trim();
        store.profile.statusKependudukan = _statusKependudukan;
        store.profile.jumlahKeluarga = _familyCountController.text.trim();
        store.profile.namaKontakDarurat = _emergencyNameController.text.trim();
        store.profile.kontakDarurat = _emergencyPhoneController.text.trim();
        store.profile.unit = updatedUnit;
        store.profile.cluster = updatedUnit.isNotEmpty ? 'Cluster GateLand, $updatedUnit' : '';
        store.profile.wilayahRW = _rwAreaController.text.trim();
        store.profile.statusPenghuni = _statusPenghuni;
        store.profile.statusKepemilikan = _ownershipController.text.trim();
        store.profile.dayaListrik = _powerWaterController.text.trim();
        store.profile.kendaraan = _vehiclesController.text.trim();
        store.profile.kendaraanTambahan = '';
        store.profile.fotoUrl = _fotoPath;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text('Perubahan profil berhasil disimpan & disinkronkan ke admin!')),
            ],
          ),
          backgroundColor: const Color(0xFF1B8754),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unitPreview = _unitController.text.trim();
    final rwPreview = _rwAreaController.text.trim();
    final badgeHeader = [
      if (unitPreview.isNotEmpty) unitPreview,
      if (rwPreview.isNotEmpty) rwPreview,
    ].join(' • ');

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.black87, size: 22),
                  ),
                  Row(
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        width: 22,
                        height: 22,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.holiday_village_outlined, color: _primaryColor, size: 22),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Edit Profil',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _primaryColor,
                        ),
                      ),
                    ],
                  ),
                  ProfileAvatar(
                    photoUrl: _fotoPath,
                    radius: 16,
                    iconColor: _primaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Avatar Photo & Actions
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showPhotoPickerOptions,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ProfileAvatar(
                              photoUrl: _fotoPath,
                              radius: 44,
                              iconColor: _primaryColor,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _showPhotoPickerOptions,
                          child: Row(
                            children: [
                              Icon(Icons.refresh, size: 14, color: _primaryColor),
                              const SizedBox(width: 4),
                              Text(
                                'Ganti Foto',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 18),
                        GestureDetector(
                          onTap: _deletePhoto,
                          child: const Row(
                            children: [
                              Icon(Icons.delete_outline, size: 14, color: Color(0xFFE53935)),
                              SizedBox(width: 4),
                              Text(
                                'Hapus',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFE53935),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Format JPG, PNG maks. 5MB',
                      style: TextStyle(fontSize: 10, color: Colors.black45),
                    ),
                    if (badgeHeader.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF0FE),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle, color: Color(0xFF3F51B5), size: 16),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  badgeHeader,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF09095E),
                                  ),
                                ),
                                const Text(
                                  'Cluster GateLand',
                                  style: TextStyle(fontSize: 9, color: Color(0xFF09095E)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Card: Informasi Pribadi & Kependudukan
              _buildSectionCard(
                icon: Icons.person_outline,
                title: 'Informasi Pribadi & Kependudukan',
                subtitle: 'Data kependudukan akan terlihat oleh pengelola klaster',
                children: [
                  _buildInputLabel('Nama Lengkap Sesuai KTP'),
                  _buildInputField(
                    controller: _nameController,
                    prefixIcon: Icons.badge_outlined,
                    hintText: 'Masukkan nama lengkap',
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInputLabel('Alamat Email'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF0FE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, size: 10, color: Color(0xFF3F51B5)),
                            SizedBox(width: 4),
                            Text(
                              'Terverifikasi',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3F51B5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  _buildInputField(
                    controller: _emailController,
                    prefixIcon: Icons.mail_outline,
                    hintText: 'nama@gmail.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  _buildInputLabel('Nomor WhatsApp Aktif'),
                  Row(
                    children: [
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: _inputFillColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '+62',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: _inputFillColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
                            decoration: const InputDecoration(
                              hintText: '81234567890',
                              hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildInputLabel('Nomor Induk Kependudukan (NIK)'),
                  _buildInputField(
                    controller: _nikController,
                    prefixIcon: Icons.credit_card_outlined,
                    hintText: 'Contoh: 3271045405880004',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  _buildInputLabel('Tempat, Tanggal Lahir'),
                  _buildInputField(
                    controller: _ttlController,
                    prefixIcon: Icons.cake_outlined,
                    hintText: 'Contoh: Bandung, 14 Mei 1988',
                  ),
                  const SizedBox(height: 16),

                  _buildInputLabel('Status Kependudukan'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildChoiceButton(
                          label: 'Warga Tetap',
                          selected: _statusKependudukan == 'Warga Tetap',
                          onTap: () => setState(() {
                            _statusKependudukan = _statusKependudukan == 'Warga Tetap' ? '' : 'Warga Tetap';
                          }),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildChoiceButton(
                          label: 'Warga Kontrak',
                          selected: _statusKependudukan == 'Warga Kontrak',
                          onTap: () => setState(() {
                            _statusKependudukan = _statusKependudukan == 'Warga Kontrak' ? '' : 'Warga Kontrak';
                          }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildInputLabel('Jumlah Anggota Keluarga'),
                  _buildInputField(
                    controller: _familyCountController,
                    prefixIcon: Icons.groups_outlined,
                    hintText: 'Contoh: 4 Jiwa (2 Dewasa, 2 Anak)',
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 4. Card: Data Hunian & Kepemilikan (SEMUA BISA DIEDIT)
              _buildSectionCard(
                icon: Icons.apartment,
                title: 'Data Hunian & Kepemilikan',
                subtitle: 'Lengkapi atau ubah data unit, kepemilikan, dan kendaraan Anda',
                children: [
                  _buildInputLabel('Blok & Nomor Unit'),
                  _buildInputField(
                    controller: _unitController,
                    prefixIcon: Icons.home_outlined,
                    hintText: 'Contoh: Blok B5 Unit 5',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),

                  _buildInputLabel('Wilayah Rukun Warga'),
                  _buildInputField(
                    controller: _rwAreaController,
                    prefixIcon: Icons.location_city_outlined,
                    hintText: 'Contoh: RT 04 / RW 08, GateLand',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),

                  _buildInputLabel('Status Penghuni'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildChoiceButton(
                          label: 'Pemilik Rumah',
                          selected: _statusPenghuni == 'Pemilik Rumah',
                          onTap: () => setState(() {
                            _statusPenghuni = 'Pemilik Rumah';
                            if (_ownershipController.text.trim().isEmpty ||
                                _ownershipController.text.trim() == 'Penyewa / Kontrak') {
                              _ownershipController.text = 'Pemilik Rumah (SHM)';
                            }
                          }),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildChoiceButton(
                          label: 'Penyewa / Kontrak',
                          selected: _statusPenghuni == 'Penyewa / Kontrak',
                          onTap: () => setState(() {
                            _statusPenghuni = 'Penyewa / Kontrak';
                            if (_ownershipController.text.trim().isEmpty ||
                                _ownershipController.text.trim() == 'Pemilik Rumah (SHM)') {
                              _ownershipController.text = 'Penyewa / Kontrak';
                            }
                          }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildInputLabel('Status Kepemilikan'),
                  _buildInputField(
                    controller: _ownershipController,
                    prefixIcon: Icons.verified_user_outlined,
                    hintText: 'Contoh: Pemilik Rumah (SHM)',
                  ),
                  const SizedBox(height: 16),

                  _buildInputLabel('Daya Listrik & Sanitasi Air'),
                  _buildInputField(
                    controller: _powerWaterController,
                    prefixIcon: Icons.bolt_outlined,
                    hintText: 'Contoh: PLN 2.200 VA • PDAM Tirta',
                  ),
                  const SizedBox(height: 16),

                  _buildInputLabel('Kendaraan Terdaftar'),
                  _buildInputField(
                    controller: _vehiclesController,
                    prefixIcon: Icons.directions_car_outlined,
                    hintText: 'Contoh: 1 Mobil (B 1234 DT), 2 Motor',
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 5. Card: Kontak Darurat (Emergency)
              _buildSectionCard(
                icon: Icons.emergency,
                iconColor: const Color(0xFFE53935),
                iconBgColor: const Color(0xFFFFEEEE),
                title: 'Kontak Darurat (Emergency)',
                subtitle: 'Dihubungi satpam & pos gerbang jika terjadi kendala darurat',
                children: [
                  _buildInputLabel('Nama Kontak Darurat'),
                  _buildInputField(
                    controller: _emergencyNameController,
                    prefixIcon: Icons.person_outline,
                    hintText: 'Contoh: Budi Santoso (Suami)',
                  ),
                  const SizedBox(height: 16),
                  _buildInputLabel('Nomor Telepon Darurat'),
                  _buildInputField(
                    controller: _emergencyPhoneController,
                    prefixIcon: Icons.phone_outlined,
                    hintText: 'Contoh: 0812-9876-5432',
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 6. Card: Keamanan & Preferensi (tanpa toggle Pengingat Iuran via WA)
              _buildSectionCard(
                title: 'Keamanan & Preferensi',
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/ubah-kata-sandi');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: _inputFillColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.restore, color: _primaryColor, size: 18),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ubah Kata Sandi',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Perbarui kata sandi akun warga',
                                  style: TextStyle(fontSize: 10, color: Colors.black45),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 18, color: Colors.black45),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 7. Simpan Perubahan Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: _isSaving ? null : _saveChanges,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_outlined, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Simpan Perubahan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      color: _primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined, size: 13, color: Colors.black38),
                    SizedBox(width: 6),
                    Text(
                      'GateLand Community • Privasi Warga Dilindungi',
                      style: TextStyle(fontSize: 10, color: Colors.black38),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: selected ? _primaryColor : _inputFillColor,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selected) ...[
              const Icon(Icons.check, size: 14, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    IconData? icon,
    Color? iconColor,
    Color? iconBgColor,
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBgColor ?? const Color(0xFFEFF0FE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor ?? _primaryColor, size: 18),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _primaryColor,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 10, color: Colors.black45),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData prefixIcon,
    String? hintText,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: _inputFillColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          prefixIcon: Icon(prefixIcon, size: 18, color: Colors.black45),
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 12.5, color: Colors.black38),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}
