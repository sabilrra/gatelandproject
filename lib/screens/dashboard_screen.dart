import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Color _primaryColor = const Color(0xFF09095E);
  final Color _bgColor = const Color(0xFFFBFBFF);
  final Color _cardBorderColor = const Color(0xFFFFEBEB);

  int _currentIndex = 0;
  Map<String, dynamic>? _activeBill;
  List<dynamic> _announcements = [];
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoadingData = true);
    try {
      final bill = await ApiService().getMyBill();
      final announcements = await ApiService().getAnnouncements();
      if (mounted) {
        setState(() {
          _activeBill = bill;
          _announcements = announcements;
          _isLoadingData = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return 'Rp 175.000';
    final int val = amount is int ? amount : int.tryParse(amount.toString()) ?? 175000;
    final s = val.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp ${buf.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final user = DummyDataStore().currentUser;
    final String firstName = (user != null && user.nama.isNotEmpty) ? user.nama.split(' ').first : 'Warga';

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          color: _primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLoadingData)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: LinearProgressIndicator(color: _primaryColor, backgroundColor: _primaryColor.withValues(alpha: 0.1)),
                  ),
                // 1. Top Navigation / App Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/logo.png', width: 28, height: 28),
                      const SizedBox(width: 8),
                      Text(
                        'GateLand',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/notifikasi'),
                        child: const Icon(Icons.notifications_none_outlined, color: Colors.black87, size: 26),
                      ),
                      const SizedBox(width: 14),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.pushNamed(context, '/profile');
                          setState(() {});
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Tooltip(
                            message: 'Buka Profil',
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: _primaryColor.withValues(alpha: 0.3), width: 1.5),
                              ),
                              child: const CircleAvatar(
                                radius: 18,
                                backgroundColor: Color(0xFFFFD1D1),
                                backgroundImage: AssetImage('assets/profile_avatar.jpg'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Header (Greeting)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, $firstName!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: _primaryColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Selamat Datang di GateLand',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/chatbot');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0F0FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.support_agent, color: _primaryColor, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. Billing Card (Tagihan)
              _buildBillingCard(),
              const SizedBox(height: 32),

              // 4. Pengumuman Terbaru
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_active_outlined, size: 18, color: Colors.black87),
                      const SizedBox(width: 8),
                      const Text(
                        'PENGUMUMAN TERBARU',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black87),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/notifikasi');
                    },
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B6BA5), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (_announcements.isNotEmpty) ...[
                for (final item in _announcements.take(3)) ...[
                  _buildAnnouncementCard(
                    tag: (item['category'] ?? 'Pengumuman').toString(),
                    tagColor: item['urgency'] == 'penting' ? const Color(0xFFF6C8C8) : const Color(0xFFF9E4E4),
                    tagTextColor: const Color(0xFFA02020),
                    date: (item['eventDate'] ?? (item['createdAt'] != null ? item['createdAt'].toString().substring(0, 10) : 'Terbaru')).toString(),
                    title: (item['title'] ?? '').toString(),
                    content: (item['content'] ?? '').toString(),
                    isImportant: item['urgency'] == 'penting',
                  ),
                  const SizedBox(height: 16),
                ],
              ] else ...[
                _buildAnnouncementCard(
                  tag: 'Info',
                  tagColor: const Color(0xFFF9E4E4),
                  tagTextColor: const Color(0xFFA02020),
                  date: 'Hari ini',
                  title: 'Belum Ada Pengumuman Baru',
                  content: 'Pengumuman resmi dari pengelola cluster akan tampil di sini secara otomatis saat diterbitkan oleh Admin.',
                  isImportant: false,
                ),
              ],
              const SizedBox(height: 32),

              // 5. Agenda Warga
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black87),
                      const SizedBox(width: 8),
                      const Text(
                        'AGENDA WARGA',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black87),
                      ),
                    ],
                  ),
                  const Text(
                    'Bulan Ini',
                    style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Grid Agenda
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: [
                  _buildAgendaCard(
                    icon: Icons.cleaning_services_outlined,
                    title: 'KERJA BAKTI LINGKUNGAN',
                    date: 'Minggu, 15 Ags 2026',
                    time: '07:00 WIB',
                    location: 'Sekitar Rumah Warga',
                  ),
                  _buildAgendaCard(
                    icon: Icons.accessibility_new_outlined,
                    title: 'SENAM SEHAT WARGA',
                    date: 'Minggu, 22 Ags 2026',
                    time: '06:30 WIB',
                    location: 'Lapangan Fasum',
                  ),
                  _buildAgendaCard(
                    icon: Icons.groups_outlined,
                    title: 'RAPAT RT BULANAN',
                    date: 'Sabtu, 28 Ags 2026',
                    time: '19:30 WIB',
                    location: 'Balai Warga RW 06',
                  ),
                  _buildAgendaCard(
                    icon: Icons.medical_services_outlined,
                    title: 'POSYANDU BALITA & LANSIA',
                    date: 'Selasa, 10 Ags 2026',
                    time: '08:30 WIB',
                    location: 'Pos RW 06',
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 6. Kontak Darurat & Layanan
              Row(
                children: const [
                  Icon(Icons.emergency_outlined, size: 16, color: Color(0xFF09095E)),
                  SizedBox(width: 8),
                  Text(
                    'KONTAK DARURAT & LAYANAN',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF09095E),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildContactCard(
                icon: Icons.shield_outlined,
                iconBg: const Color(0xFFFFECEC),
                iconColor: const Color(0xFFE53935),
                name: 'Pos Keamanan 24 Jam',
                phone: '+62 811-9283-001',
              ),
              const SizedBox(height: 12),
              _buildContactCard(
                icon: Icons.badge_outlined,
                iconBg: const Color(0xFFEEF0FF),
                iconColor: const Color(0xFF4B4B8A),
                name: 'Bambang Hermanto (RT 04)',
                phone: '+62 811-9283-RT04',
              ),
              const SizedBox(height: 12),
              _buildContactCard(
                icon: Icons.bolt,
                iconBg: const Color(0xFFF3F0FF),
                iconColor: const Color(0xFF6B4B8A),
                name: 'Pak Joko (Teknisi Listrik)',
                phone: '+62 812-9988-7711',
              ),
              const SizedBox(height: 12),
              _buildContactCard(
                icon: Icons.home_repair_service_outlined,
                iconBg: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF2563EB),
                name: 'Sedot WC & Sanitasi Cepat',
                phone: '+62 813-8877-6655',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 1) {
              Navigator.pushNamed(context, '/tagihan');
            } else if (index == 2) {
              Navigator.pushNamed(context, '/riwayat');
            }
          },
          backgroundColor: Colors.white,
          selectedItemColor: _primaryColor,
          unselectedItemColor: Colors.black45,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Tagihan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              activeIcon: Icon(Icons.history),
              label: 'Riwayat',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingCard() {
    final bool isPaid = _activeBill?['status'] == 'PAID';
    final String billMonth = (_activeBill?['month'] ?? 'Agustus 2026').toString();
    final String billDueDate = (_activeBill?['dueDate'] ?? '10 Agustus').toString();
    final String billAmount = _formatCurrency(_activeBill?['amount']);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFAFAFF), Color(0xFFFFF2F2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4B4B8A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  billMonth,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isPaid ? const Color(0xFFE6F9F1) : const Color(0xFFFBE4E4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(isPaid ? Icons.check_circle : Icons.schedule, size: 12, color: isPaid ? const Color(0xFF1A7A4A) : _primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      isPaid ? 'Lunas' : 'Jatuh Tempo: $billDueDate',
                      style: TextStyle(
                        color: isPaid ? const Color(0xFF1A7A4A) : _primaryColor, 
                        fontSize: 11, 
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            isPaid ? 'STATUS IURAN BULAN INI' : 'TOTAL TAGIHAN IURAN BULANAN',
            style: TextStyle(color: _primaryColor.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          Text(
            isPaid ? 'Terima kasih, tagihan Anda telah terverifikasi lunas.' : 'IPL, Kebersihan, Keamanan, & Kas RT',
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Text(
            isPaid ? 'LUNAS' : billAmount,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isPaid ? const Color(0xFF1A7A4A) : _primaryColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await Navigator.pushNamed(context, isPaid ? '/riwayat' : '/tagihan');
                _loadDashboardData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isPaid ? const Color(0xFF1A7A4A) : _primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isPaid ? 'Lihat Bukti Kwitansi' : 'Bayar Sekarang',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard({
    required String tag,
    required Color tagColor,
    required Color tagTextColor,
    required String date,
    required String title,
    required String content,
    required bool isImportant,
  }) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(
                  isImportant ? Icons.warning_amber_rounded : Icons.info_outline,
                  color: tagTextColor,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: tagColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$tag • $date',
                      style: TextStyle(color: tagTextColor, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    content,
                    style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.black87),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Tutup', style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorderColor, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: tagColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(isImportant ? Icons.warning_amber_rounded : Icons.info_outline, size: 12, color: tagTextColor),
                      const SizedBox(width: 4),
                      Text(
                        tag,
                        style: TextStyle(color: tagTextColor, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Text(date, style: const TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendaCard({
    required IconData icon,
    required String title,
    required String date,
    required String time,
    required String location,
  }) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(icon, color: _primaryColor, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAgendaInfoRow(Icons.calendar_today_outlined, date),
                const SizedBox(height: 8),
                _buildAgendaInfoRow(Icons.access_time, time),
                const SizedBox(height: 8),
                _buildAgendaInfoRow(Icons.location_on_outlined, location),
                const SizedBox(height: 14),
                const Text(
                  'Diharapkan kehadiran seluruh warga demi kebersamaan dan ketertiban lingkungan GateLand.',
                  style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Tutup', style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorderColor, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: _primaryColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _primaryColor,
                height: 1.3,
                letterSpacing: 0.1,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _buildAgendaInfoRow(Icons.calendar_today_outlined, date),
            const SizedBox(height: 5),
            _buildAgendaInfoRow(Icons.access_time, time),
            const SizedBox(height: 5),
            _buildAgendaInfoRow(Icons.location_on_outlined, location),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendaInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 10, color: Colors.black45),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String name,
    required String phone,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
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
                    children: [
                      Text(
                        'Hubungi $name',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        phone,
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Menghubungkan panggilan ke $name ($phone)...')),
                                );
                              },
                              icon: const Icon(Icons.phone, color: Colors.white),
                              label: const Text('Panggil Telepon', style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Membuka WhatsApp ke $name...')),
                                );
                              },
                              icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF1B8754)),
                              label: const Text('WhatsApp', style: TextStyle(color: Color(0xFF1B8754))),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF1B8754)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFECEC),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone_outlined, size: 13, color: _primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    'Hubungi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
