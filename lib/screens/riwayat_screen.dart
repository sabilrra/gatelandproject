import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/dummy_data.dart';
import '../services/api_service.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  static const Color _primary = Color(0xFF09095E);
  static const Color _bgColor = Color(0xFFFBFBFF);
  static const Color _greyText = Color(0xFF6B7280);
  static const Color _blueBg = Color(0xFFF0F4FF);
  static const Color _greenTag = Color(0xFFE6F9F1);
  static const Color _greenText = Color(0xFF1A7A4A);
  static const Color _greenDot = Color(0xFF27AE60);
  static const Color _badgeBg = Color(0xFFF1F5F9);
  static const Color _badgeText = Color(0xFF475569);
  static const Color _pinkBg = Color(0xFFFFF2F2);

  bool _isSearching = false;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _dbRiwayat = [];

  @override
  void initState() {
    super.initState();
    final apiUser = ApiService().currentUser;
    if (DummyDataStore().currentUser == null && apiUser != null) {
      DummyDataStore().syncFromBackendUser(apiUser);
    }
    _loadHistory();
  }

  String _monthName(int m) {
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    if (m >= 1 && m <= 12) return months[m - 1];
    return 'Bulan';
  }

  Future<void> _loadHistory() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final me = await ApiService().getMe();
      if (me != null) {
        DummyDataStore().syncFromBackendUser(me);
      }
      final list = await ApiService().getMyPaymentHistory();
      if (mounted) {
        setState(() {
          _dbRiwayat = list.map((item) {
            final dt = item['createdAt'] != null ? DateTime.tryParse(item['createdAt'].toString()) : null;
            final isSettled = item['status'] == 'SETTLEMENT';
            final dateStr = dt != null ? '${dt.day.toString().padLeft(2, '0')} ${_monthName(dt.month)} ${dt.year}' : 'Hari ini';
            final timeStr = dt != null ? '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} WIB' : '-';

            final rawAmount = item['amount'] is int
                ? item['amount'] as int
                : int.tryParse(item['amount']?.toString() ?? '0') ?? 0;
            final formatted = rawAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

            return {
              'transactionId': item['id'],
              'title': 'Iuran Keamanan & Kebersihan',
              'rawAmount': rawAmount,
              'amount': 'Rp $formatted',
              'method': item['paymentChannel'] ?? 'QRIS',
              'unit': item['unit'] ?? DummyDataStore().profile.unit,
              'date': dateStr,
              'time': timeStr,
              'status': item['status'] ?? 'PENDING',
              'isPaid': isSettled,
            };
          }).toList();
          _isLoading = false;
        });
      }
      return;
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredRiwayat {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _dbRiwayat;
    return _dbRiwayat.where((d) {
      final title = d['title'].toString().toLowerCase();
      final method = d['method'].toString().toLowerCase();
      final date = d['date'].toString().toLowerCase();
      return title.contains(query) || method.contains(query) || date.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredRiwayat;
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadHistory,
                color: _primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTopProfile(),
                      const SizedBox(height: 24),
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildFilterRow(),
                      const SizedBox(height: 16),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (items.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE8E8F0)),
                          ),
                          child: Text(
                            _searchController.text.trim().isNotEmpty
                                ? 'Tidak ada transaksi yang cocok.'
                                : 'Belum ada riwayat pembayaran.',
                            style: GoogleFonts.inter(color: Colors.black54, fontSize: 13),
                          ),
                        )
                      else
                        ...items.map((data) => _buildRiwayatCard(data)),
                      const SizedBox(height: 8),
                      _buildKembaliButton(),
                      const SizedBox(height: 24),
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

  Widget _buildTopProfile() {
    final store = DummyDataStore();
    final user = store.activeUser;
    final profile = store.profile;

    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/profile'),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _pinkBg,
              border: Border.all(color: _primary.withValues(alpha: 0.2)),
            ),
            child: ClipOval(
              child: Image.asset(
                profile.fotoUrl,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => const Icon(Icons.person, color: _primary),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WARGA RT 04 / RW 08',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _primary,
                letterSpacing: 0.5,
              ),
            ),
            Row(
              children: [
                Text(
                  profile.unit,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 4),
                const Text('•', style: TextStyle(color: _greyText, fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  user.nama.split(' ').first,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    if (_isSearching) {
      return Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8E8F0)),
        ),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: (_) => setState(() {}),
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'Cari riwayat...',
            hintStyle: GoogleFonts.inter(color: _greyText, fontSize: 14),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: IconButton(
              icon: const Icon(Icons.close, color: _primary, size: 20),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _isSearching = false;
                });
              },
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Riwayat Pembayaran',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _primary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Catatan transaksi & bukti pembayaran iuran warga',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: _greyText,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _isSearching = true;
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8E8F0)),
            ),
            child: const Icon(Icons.search, color: _primary, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Menampilkan riwayat tahun 2026',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: _primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFCE8E8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Text(
                'Periode: Semua',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _primary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, size: 14, color: _primary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRiwayatCard(Map<String, dynamic> data) {
    final bool isPaid = data['isPaid'] == true;
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/kwitansi',
          arguments: {
            'transactionId': data['transactionId'],
            'amount': data['rawAmount'] ?? 0,
            'method': data['method'],
            'unit': data['unit'],
            'date': '${data['date']}, ${data['time']}',
            'isPaid': isPaid,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _blueBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.verified_user_outlined, size: 18, color: _primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'],
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _greyText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data['amount'],
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _badgeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    data['method'],
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: _badgeText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPaid ? _greenTag : const Color(0xFFFFF0D9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (isPaid ? _greenText : const Color(0xFFB86E00)).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isPaid ? _greenDot : const Color(0xFFD97706),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isPaid ? 'Selesai' : 'Menunggu Verifikasi',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isPaid ? _greenText : const Color(0xFFB86E00),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          data['date'],
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          data['time'],
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: _greyText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, size: 16, color: Colors.black38),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKembaliButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/dashboard');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(
          'Kembali ke Beranda',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
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
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/tagihan');
          } else if (index == 2) {
            // Already on riwayat
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
