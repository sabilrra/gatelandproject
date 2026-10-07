import 'package:flutter/material.dart';
import '../data/dummy_data.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final Color _primaryColor = const Color(0xFF09095E);
  final Color _bgColor = const Color(0xFFFBFBFF);
  final Color _inputFillColor = const Color(0xFFF3F3FA);

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyPhoneController;

  String _statusPenghuni = 'Pemilik Rumah';
  String _selectedKendaraan = '1 Mobil';
  final String _selectedKeluarga = '4 Orang';
  late bool _waReminder;

  @override
  void initState() {
    super.initState();
    final store = DummyDataStore();
    final user = store.activeUser;
    final profile = store.profile;

    _nameController = TextEditingController(text: user.nama.isNotEmpty ? user.nama : 'Azizah Putri Utami');
    _emailController = TextEditingController(text: user.email.isNotEmpty ? user.email : 'azizah.putri@gateland.id');

    // format phone number without +62 prefix for clean editing
    String phone = user.noWhatsapp.replaceAll('+62', '').trim();
    if (phone.startsWith('0')) phone = phone.substring(1);
    if (phone.isEmpty) phone = '812-3456-7890';
    _phoneController = TextEditingController(text: phone);

    _emergencyNameController = TextEditingController(text: profile.namaKontakDarurat);
    _emergencyPhoneController = TextEditingController(text: profile.kontakDarurat);

    _statusPenghuni = profile.statusPenghuni;
    _waReminder = profile.pengingatWA;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final store = DummyDataStore();
    final updatedName = _nameController.text.trim();
    final updatedEmail = _emailController.text.trim();
    final updatedPhone = '+62 ${_phoneController.text.trim()}';

    // update user
    if (store.currentUser != null) {
      store.currentUser!.nama = updatedName;
      store.currentUser!.email = updatedEmail;
      store.currentUser!.noWhatsapp = updatedPhone;
    } else {
      store.currentUser = UserData(
        nama: updatedName,
        email: updatedEmail,
        noWhatsapp: updatedPhone,
        alamat: store.profile.cluster,
        password: 'password123',
      );
    }

    // update profile details
    store.profile.namaKontakDarurat = _emergencyNameController.text.trim();
    store.profile.kontakDarurat = _emergencyPhoneController.text.trim();
    store.profile.statusPenghuni = _statusPenghuni;
    store.profile.pengingatWA = _waReminder;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Perubahan profil berhasil disimpan!'),
          ],
        ),
        backgroundColor: const Color(0xFF1B8754),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final store = DummyDataStore();
    final profile = store.profile;

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Bar: Back button, Logo + Title, and Avatar Thumbnail
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black87,
                        size: 20,
                      ),
                    ),
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
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage(profile.fotoUrl),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Avatar Photo & Actions
              Center(
                child: Column(
                  children: [
                    Stack(
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
                          child: ClipOval(
                            child: Image.asset(
                              profile.fotoUrl,
                              width: 88,
                              height: 88,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: const Color(0xFFFFD1D1),
                                child: Icon(Icons.person, color: _primaryColor, size: 50),
                              ),
                            ),
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
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pilih foto dari galeri/kamera')),
                            );
                          },
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
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Foto profil dihapus')),
                            );
                          },
                          child: Row(
                            children: const [
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
                            children: const [
                              Text(
                                'Unit 1 RT 04 / RW 08',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF09095E),
                                ),
                              ),
                              Text(
                                'Cluster GateLand',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF09095E),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Card: Informasi Pribadi
              _buildSectionCard(
                icon: Icons.person_outline,
                title: 'Informasi Pribadi',
                subtitle: 'Data sah kependudukan penghuni',
                children: [
                  _buildInputLabel('Nama Lengkap Sesuai KTP'),
                  _buildInputField(
                    controller: _nameController,
                    prefixIcon: Icons.badge_outlined,
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
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.info_outline, size: 12, color: Colors.black45),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Digunakan untuk notifikasi tagihan iuran & barcode akses gerbang warga.',
                          style: TextStyle(fontSize: 10, color: Colors.black45),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 4. Card: Data Hunian & Kepemilikan
              _buildSectionCard(
                icon: Icons.apartment,
                title: 'Data Hunian & Kepemilikan',
                subtitle: 'Terdaftar di kepengurusan perumahan',
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInputLabel('Blok & Nomor Unit'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF0FE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_outline, size: 10, color: Color(0xFF3F51B5)),
                            SizedBox(width: 4),
                            Text(
                              'Tervalidasi RT',
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
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: _inputFillColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.home_outlined, size: 18, color: Colors.black45),
                        SizedBox(width: 10),
                        Text(
                          'Unit 1 RT 04 / RW 08',
                          style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.home_work_outlined, size: 12, color: Colors.black45),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Hubungi pengurus RT jika Anda pindah unit atau nomor kavling berganti.',
                          style: TextStyle(fontSize: 10, color: Colors.black45),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildInputLabel('Status Penghuni'),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _statusPenghuni = 'Pemilik Rumah'),
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: _statusPenghuni == 'Pemilik Rumah' ? _primaryColor : _inputFillColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_statusPenghuni == 'Pemilik Rumah') ...[
                                  const Icon(Icons.check, size: 14, color: Colors.white),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  'Pemilik Rumah',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _statusPenghuni == 'Pemilik Rumah' ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _statusPenghuni = 'Penyewa / Kontrak'),
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: _statusPenghuni == 'Penyewa / Kontrak' ? _primaryColor : _inputFillColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_statusPenghuni == 'Penyewa / Kontrak') ...[
                                  const Icon(Icons.check, size: 14, color: Colors.white),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  'Penyewa / Kontrak',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _statusPenghuni == 'Penyewa / Kontrak' ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInputLabel('Anggota Keluarga & Kendaraan'),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Kelola detail keluarga & kendaraan')),
                          );
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit_outlined, size: 12, color: Color(0xFF3F51B5)),
                            SizedBox(width: 4),
                            Text(
                              'Kelola Detail',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3F51B5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Keluarga Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: _inputFillColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.groups_outlined, color: _primaryColor, size: 22),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Keluarga', style: TextStyle(fontSize: 10, color: Colors.black54)),
                                  Text(
                                    _selectedKeluarga,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Kendaraan Card (with Dropdown)
                      Expanded(
                        child: PopupMenuButton<String>(
                          onSelected: (val) => setState(() => _selectedKendaraan = val),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                              value: '1 Mobil',
                              child: Row(
                                children: [
                                  Icon(Icons.directions_car_outlined, size: 16, color: Color(0xFF09095E)),
                                  SizedBox(width: 8),
                                  Text('Kendaraan: 1 Mobil', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: '1 Motor',
                              child: Row(
                                children: [
                                  Icon(Icons.two_wheeler_outlined, size: 16, color: Color(0xFF09095E)),
                                  SizedBox(width: 8),
                                  Text('Kendaraan: 1 Motor', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: '1 Mobil + 2 Motor',
                              child: Row(
                                children: [
                                  Icon(Icons.local_shipping_outlined, size: 16, color: Color(0xFF09095E)),
                                  SizedBox(width: 8),
                                  Text('1 Mobil + 2 Motor', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: _inputFillColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.directions_car_outlined, color: _primaryColor, size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Kendaraan', style: TextStyle(fontSize: 10, color: Colors.black54)),
                                      Text(
                                        _selectedKendaraan,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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
                  ),
                  const SizedBox(height: 16),
                  _buildInputLabel('Nomor Telepon Darurat'),
                  _buildInputField(
                    controller: _emergencyPhoneController,
                    prefixIcon: Icons.phone_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 6. Card: Keamanan & Preferensi
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Ubah Kata Sandi',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Terakhir diperbarui 2 bulan lalu',
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
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                          child: Icon(Icons.notifications_none, color: _primaryColor, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Pengingat Iuran via WA',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Notifikasi H-3 sebelum jatuh tempo',
                                style: TextStyle(fontSize: 10, color: Colors.black45),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _waReminder,
                          activeThumbColor: _primaryColor,
                          activeTrackColor: _primaryColor.withValues(alpha: 0.4),
                          onChanged: (val) {
                            setState(() => _waReminder = val);
                          },
                        ),
                      ],
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
                  onPressed: _saveChanges,
                  child: const Row(
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

              // Batal Button
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

              // Footer
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.shield_outlined, size: 13, color: Colors.black38),
                    SizedBox(width: 6),
                    Text(
                      'GateLand Community • Privasi Warga Dilindungi',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black38,
                      ),
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
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: _inputFillColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          prefixIcon: Icon(prefixIcon, size: 18, color: Colors.black45),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}
