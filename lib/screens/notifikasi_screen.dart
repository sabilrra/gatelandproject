import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/dummy_data.dart';
import '../services/api_service.dart';
import '../widgets/profile_avatar.dart';

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
  
  String _selectedFilter = 'Semua';
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;

  final List<String> _filters = [
    'Semua',
    'Pengumuman',
  ];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  String _formatRupiah(int amount) {
    final s = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final reverseIdx = s.length - i;
      buffer.write(s[i]);
      if (reverseIdx > 1 && reverseIdx % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString()}';
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService().getAnnouncements(),
        ApiService().getMyBill().catchError((_) => null),
      ]);

      final annList = (results[0] as List<dynamic>? ?? []);
      final billData = results[1] as Map<String, dynamic>?;
      final billsList = (billData?['bills'] as List<dynamic>?) ?? [];

      final combined = <Map<String, dynamic>>[];

      for (final b in billsList) {
        if (b is Map<String, dynamic>) {
          combined.add({
            ...b,
            '_notifType': 'bill',
            '_sortDate': b['createdAt']?.toString() ?? '',
          });
        }
      }

      for (final a in annList) {
        if (a is Map<String, dynamic>) {
          combined.add({
            ...a,
            '_notifType': 'announcement',
            '_sortDate': a['createdAt']?.toString() ?? '',
          });
        }
      }

      combined.sort((a, b) {
        final da = DateTime.tryParse(a['_sortDate']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        final db = DateTime.tryParse(b['_sortDate']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        return db.compareTo(da);
      });

      if (mounted) {
        setState(() {
          _notifications = combined;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedFilter == 'Pengumuman') {
      return _notifications.where((item) => item['_notifType'] == 'announcement').toList();
    }
    return _notifications;
  }

  @override
  Widget build(BuildContext context) {
    final visibleNotifications = _filteredNotifications;
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
            const SizedBox(height: 20),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadNotifications,
                color: _primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_isLoading) ...[
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ] else if (visibleNotifications.isEmpty) ...[
                        _buildEmptyStateCard(),
                      ] else ...[
                        _buildSectionHeader(
                          _selectedFilter == 'Pengumuman'
                              ? 'PENGUMUMAN RESMI PENGELOLA'
                              : 'NOTIFIKASI & PENGUMUMAN TERBARU',
                          'Terbaru',
                        ),
                        const SizedBox(height: 12),
                        for (final item in visibleNotifications) ...[
                          if (item['_notifType'] == 'bill')
                            _buildDynamicBillNotificationCard(item)
                          else
                            _buildDynamicAnnouncementCard(item),
                          const SizedBox(height: 12),
                        ],
                      ],
                      const SizedBox(height: 32),
                      _buildFooterInfo(),
                      const SizedBox(height: 32),
                    ],
                  ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
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
                    Icon(Icons.holiday_village_outlined, color: _primary, size: 22),
              ),
              const SizedBox(width: 8),
              Text(
                'GateLand',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _primary,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _primary.withValues(alpha: 0.3), width: 1.5),
              ),
              child: ProfileAvatar(
                photoUrl: DummyDataStore().profile.fotoUrl,
                radius: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
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
          if (_notifications.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFECEC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_notifications.length} Baru',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFE53935),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyStateCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFEBEB), width: 1.5),
        gradient: const LinearGradient(
          colors: [Color(0xFFFAFAFF), Color(0xFFFFF4F4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Illustration Bell with Check & Sparkles
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEFFE),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFDEDE), width: 6),
                ),
                child: const Center(
                  child: Icon(Icons.notifications_active, color: _primary, size: 48),
                ),
              ),
              Positioned(
                top: 38,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: _primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Belum Ada Notifikasi Baru',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _primary,
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.black54,
                height: 1.5,
              ),
              children: const [
                TextSpan(text: 'Semua informasi dan pengumuman dari pengurus\n'),
                TextSpan(
                  text: 'RT 04',
                  style: TextStyle(fontWeight: FontWeight.bold, color: _primary),
                ),
                TextSpan(text: ' sudah Anda ketahui. Kotak notifikasi Anda\nbersih dan mutakhir!'),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // Primary Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/tagihan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Cek Tagihan Bulan Ini',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Secondary Buttons Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/dashboard'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFCE6E6),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: _primary),
                      const SizedBox(width: 6),
                      Text(
                        'Agenda Warga',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _loadNotifications,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.refresh, size: 14, color: _primary),
                      const SizedBox(width: 6),
                      Text(
                        'Muat Ulang',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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

  Widget _buildDynamicBillNotificationCard(Map<String, dynamic> bill) {
    final title = (bill['month'] ?? 'Iuran Klaster').toString();
    final desc = (bill['description'] ?? '').toString().trim();
    final rawAmount = bill['amount'];
    final amount = rawAmount is int ? rawAmount : int.tryParse(rawAmount?.toString() ?? '0') ?? 0;
    final dueDate = (bill['dueDate'] ?? '-').toString();
    final isPaid = bill['status'] == 'PAID';
    final date = bill['createdAt'] != null ? bill['createdAt'].toString().substring(0, 10) : 'Hari ini';

    final contentText = desc.isNotEmpty
        ? '$desc\nNominal: ${_formatRupiah(amount)} • Jatuh tempo: $dueDate'
        : 'Tagihan iuran sebesar ${_formatRupiah(amount)} telah diterbitkan oleh Pengelola. Jatuh tempo: $dueDate.';

    return _buildNotificationCard(
      isUnread: !isPaid,
      iconData: Icons.receipt_long_outlined,
      iconColor: isPaid ? const Color(0xFF1B8754) : _badgePinkText,
      iconBg: isPaid ? const Color(0xFFE8F8F0) : _badgePinkBg,
      tagText: isPaid ? 'IURAN LUNAS' : 'IURAN BARU',
      tagBg: isPaid ? const Color(0xFFE8F8F0) : _badgePinkBg,
      tagTextColor: isPaid ? const Color(0xFF1B8754) : _badgePinkText,
      timeText: date,
      title: 'Tagihan Iuran: $title',
      content: contentText,
      actionText: isPaid ? 'Lihat Riwayat Tagihan' : 'Cek & Bayar Tagihan',
      actionIcon: Icons.keyboard_arrow_right,
      onActionTap: () => Navigator.pushNamed(context, '/tagihan'),
    );
  }

  Widget _buildDynamicAnnouncementCard(dynamic item) {
    final title = (item['title'] ?? 'Pengumuman').toString();
    final content = (item['content'] ?? '').toString();
    final category = (item['category'] ?? 'INFO').toString().toUpperCase();
    final urgency = item['urgency']?.toString().toLowerCase();
    final isImportant = urgency == 'penting';
    final date = (item['eventDate'] ?? (item['createdAt'] != null ? item['createdAt'].toString().substring(0, 10) : 'Hari ini')).toString();
    final author = (item['authorName'] ?? 'Admin').toString();

    return _buildNotificationCard(
      isUnread: isImportant,
      iconData: Icons.campaign_outlined,
      iconColor: isImportant ? _badgePinkText : _primary,
      iconBg: isImportant ? _badgePinkBg : _badgePurpleBg,
      tagText: category,
      tagBg: isImportant ? _badgePinkBg : _badgePurpleBg,
      tagTextColor: isImportant ? _badgePinkText : _primary,
      timeText: date,
      title: title,
      content: content,
      actionText: 'Detail Pengumuman',
      actionIcon: Icons.keyboard_arrow_right,
      onActionTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.campaign, color: _primary, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: _primary)),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Diterbitkan oleh: $author • $date', style: GoogleFonts.inter(fontSize: 11, color: Colors.black45)),
                  const SizedBox(height: 12),
                  Text(content, style: GoogleFonts.inter(fontSize: 13, color: Colors.black87, height: 1.5)),
                  if (item['location'] != null && item['location'].toString().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: _primary),
                        const SizedBox(width: 4),
                        Text('Lokasi: ${item['location']}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _primary)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
      },
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
