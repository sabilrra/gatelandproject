import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  static const Color _primary = Color(0xFF09095E);
  static const Color _bgColor = Color(0xFFFBFBFF);
  static const Color _greyText = Color(0xFF6B7280);
  
  // Chip Colors
  static const Color _chipActiveBg = _primary;
  static const Color _chipActiveText = Colors.white;
  static const Color _chipInactiveBg = Color(0xFFF0F4FF);
  static const Color _chipInactiveText = Color(0xFF64748B);

  // Badge Colors
  static const Color _badgePinkBg = Color(0xFFFFF0F5);
  static const Color _badgePinkText = Color(0xFFE11D48);
  
  static const Color _badgePurpleBg = Color(0xFFEEF2FF);
  static const Color _badgePurpleText = Color(0xFF312E81);

  static const Color _badgeGreyBg = Color(0xFFF1F5F9);
  static const Color _badgeGreyText = Color(0xFF475569);
  
  String _selectedFilter = 'Semua (4)';

  final List<String> _filters = [
    'Semua (4)',
    'Pembayaran (2)',
    'Agenda (1)',
    'Pengumuman (1)',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopBar(),
            _buildHeader(),
            const SizedBox(height: 16),
            _buildFilterChips(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionHeader('HARI INI', 'Agustus 2026'),
                    const SizedBox(height: 12),
                    _buildPembayaranNotification(),
                    const SizedBox(height: 12),
                    _buildAgendaNotification(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('KEMARIN', '13 Ags 2026'),
                    const SizedBox(height: 12),
                    _buildPengumumanNotification(),
                    const SizedBox(height: 12),
                    _buildSistemNotification(),
                    const SizedBox(height: 32),
                    _buildFooterInfo(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.black87),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFD1D1),
            ),
            child: const Icon(Icons.person, color: _primary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Pusat Notifikasi',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4E6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '2 Baru',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE11D48),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: _filters.map((filter) {
          final isActive = filter == _selectedFilter;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? _chipActiveBg : _chipInactiveBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                filter,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? _chipActiveText : _chipInactiveText,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String dayStr, String dateStr) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              dayStr,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFFCBD5E1),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        Text(
          dateStr,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: _greyText,
          ),
        ),
      ],
    );
  }

  Widget _buildPembayaranNotification() {
    return _buildNotificationCard(
      isUnread: true,
      iconData: Icons.account_balance_wallet,
      iconColor: _primary,
      iconBg: const Color(0xFFEEF2FF),
      tagText: 'IURAN KAS RT',
      tagBg: _badgePinkBg,
      tagTextColor: _badgePinkText,
      timeText: '10 menit lalu • 14:40 WIB',
      title: 'Pembayaran Iuran Berhasil Dikonfirmasi!',
      content: 'Setoran iuran Agustus 2026 sebesar Rp 175.000 telah diverifikasi oleh Bendahara RT 04. Bukti kwitansi resmi telah diterbitkan secara digital.',
      actionText: 'Lihat Bukti Kwitansi',
      actionIcon: Icons.receipt_long,
      onActionTap: () => Navigator.pushNamed(context, '/kwitansi'),
    );
  }

  Widget _buildAgendaNotification() {
    return _buildNotificationCard(
      isUnread: true,
      iconData: Icons.calendar_today,
      iconColor: _badgePurpleText,
      iconBg: _badgePurpleBg,
      tagText: 'AGENDA BULANAN',
      tagBg: _badgePurpleBg,
      tagTextColor: _badgePurpleText,
      timeText: '2 jam yang lalu',
      title: 'Agenda Baru: Kerja Bakti Lingkungan',
      content: 'Pengurus RT 04 mengundang seluruh warga Perumahan Sekar Indah untuk berpartisipasi pada Minggu, 15 Ags 2026 pukul 07:00 WIB di Sekitar Lapangan & Selokan Warga.',
      locationText: 'Pos RT 4 RW 8',
      actionText: 'Lihat Detail Agenda',
      actionIcon: Icons.arrow_forward,
    );
  }

  Widget _buildPengumumanNotification() {
    return _buildNotificationCard(
      isUnread: false,
      iconData: Icons.campaign_outlined,
      iconColor: _badgeGreyText,
      iconBg: _badgeGreyBg,
      tagText: 'PENGUMUMAN RT',
      tagBg: _badgeGreyBg,
      tagTextColor: _badgeGreyText,
      timeText: 'Kemarin, 09:15 WIB',
      title: 'Perubahan Jadwal Pengangkutan Sampah',
      content: 'Pengangkutan sampah minggu ini dimajukan menjadi Jumat, 14 Ags pukul 07.00 WIB dikarenakan hari libur nasional. Mohon letakkan tong sampah di luar pagar depan.',
      actionText: 'Baca Surat Edaran',
      actionIcon: Icons.keyboard_arrow_right,
    );
  }

  Widget _buildSistemNotification() {
    return _buildNotificationCard(
      isUnread: false,
      iconData: Icons.shield_outlined,
      iconColor: _primary,
      iconBg: const Color(0xFFEEF2FF),
      tagText: 'SISTEM GATE',
      tagBg: _badgePurpleBg,
      tagTextColor: _badgePurpleText,
      timeText: 'Kemarin, 08:00 WIB',
      title: 'Verifikasi Berkas Domisili Diterima',
      content: 'Pendaftaran berkas warga Kavling Edelweiss Blok B4 No. 12 telah disetujui petugas keamanan. Barcode QR pass Gate Utama Anda kini berstatus aktif.',
    );
  }

  Widget _buildNotificationCard({
    required bool isUnread,
    required IconData iconData,
    required Color iconColor,
    required Color iconBg,
    required String tagText,
    required Color tagBg,
    required Color tagTextColor,
    required String timeText,
    required String title,
    required String content,
    String? locationText,
    String? actionText,
    IconData? actionIcon,
    VoidCallback? onActionTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFFE8E8F0).withValues(alpha: 0.5),
            blurRadius: 1,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          if (isUnread)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: _primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(iconData, size: 18, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: tagBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tagText,
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: tagTextColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeText,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: _greyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                content,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: _greyText,
                  height: 1.5,
                ),
              ),
              if (locationText != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Text(
                        locationText,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (actionText != null) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: onActionTap,
                  child: Row(
                    children: [
                      Text(
                        actionText,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(actionIcon ?? Icons.arrow_forward, size: 14, color: _primary),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterInfo() {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFFF1F5F9),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.notifications_off_outlined, size: 16, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 12),
        Text(
          'Semua notifikasi dalam 30 hari terakhir ditampilkan.',
          style: GoogleFonts.inter(
            fontSize: 10,
            color: _greyText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Smart Living, Start Here',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
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
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/tagihan');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/riwayat');
          }
        },
        backgroundColor: Colors.white,
        selectedItemColor: _primary,
        unselectedItemColor: Colors.black54,
        selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 11),
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
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }
}
