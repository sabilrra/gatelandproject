import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Model ────────────────────────────────────────────────────────────────────
enum TagihanStatus { menunggu, lunas }
enum TagihanTipe { wajib, iuranKhusus }

class TagihanItem {
  final String id;
  final String nama;
  final String deskripsi;
  final int jumlah;
  final TagihanStatus status;
  final TagihanTipe tipe;
  final IconData icon;

  const TagihanItem({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.jumlah,
    required this.status,
    required this.tipe,
    required this.icon,
  });
}

final List<TagihanItem> _dummyTagihan = [
  TagihanItem(
    id: '1',
    nama: 'Iuran Keamanan & Satpam 24 Jam',
    deskripsi: 'Portal otomatis & patroli malam',
    jumlah: 50000,
    status: TagihanStatus.menunggu,
    tipe: TagihanTipe.wajib,
    icon: Icons.shield_outlined,
  ),
  TagihanItem(
    id: '2',
    nama: 'Iuran Kebersihan & Sampah',
    deskripsi: 'Jadwal angkut: Sen, Rab, Sab',
    jumlah: 100000,
    status: TagihanStatus.menunggu,
    tipe: TagihanTipe.wajib,
    icon: Icons.local_shipping_outlined,
  ),
  TagihanItem(
    id: '3',
    nama: 'Kas RT & Sosial Warga',
    deskripsi: 'Kas Bulanan RT & Dana Darurat',
    jumlah: 25000,
    status: TagihanStatus.menunggu,
    tipe: TagihanTipe.wajib,
    icon: Icons.home_outlined,
  ),
  TagihanItem(
    id: '4',
    nama: 'Iuran Perbaikan Jalan & Paving',
    deskripsi: 'Lunas pada 28 Agu 2026 \u2022 QRIS',
    jumlah: 75000,
    status: TagihanStatus.lunas,
    tipe: TagihanTipe.iuranKhusus,
    icon: Icons.check_circle_outline,
  ),
];

String _formatRupiah(int amount) {
  final s = amount.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp ${buf.toString()}';
}

class TagihanScreen extends StatefulWidget {
  const TagihanScreen({super.key});

  @override
  State<TagihanScreen> createState() => _TagihanScreenState();
}

class _TagihanScreenState extends State<TagihanScreen> {
  static const Color _primary = Color(0xFF09095E);
  static const Color _bgColor = Color(0xFFFBFBFF);
  static const Color _cardBorder = Color(0xFFFFEBEB);
  static const Color _pinkBg = Color(0xFFFFF2F2);
  static const Color _orangeTag = Color(0xFFFFF0D9);
  static const Color _orangeText = Color(0xFFB86E00);
  static const Color _pinkTag = Color(0xFFFFE9E9);
  static const Color _pinkText = Color(0xFFC0392B);
  static const Color _greenTag = Color(0xFFE6F9F1);
  static const Color _greenText = Color(0xFF1A7A4A);
  static const Color _greenDot = Color(0xFF27AE60);

  int _tabIndex = 0;
  final Set<String> _selected = {'1', '2', '3'};

  List<TagihanItem> get _filtered {
    switch (_tabIndex) {
      case 1:
        return _dummyTagihan.where((t) => t.status == TagihanStatus.menunggu).toList();
      case 2:
        return _dummyTagihan.where((t) => t.status == TagihanStatus.lunas).toList();
      default:
        return _dummyTagihan;
    }
  }

  List<TagihanItem> get _pending =>
      _dummyTagihan.where((t) => t.status == TagihanStatus.menunggu).toList();

  int get _totalSelected => _filtered
      .where((t) => _selected.contains(t.id) && t.status == TagihanStatus.menunggu)
      .fold(0, (sum, t) => sum + t.jumlah);

  int get _totalLunas =>
      _dummyTagihan.where((t) => t.status == TagihanStatus.lunas).fold(0, (s, t) => s + t.jumlah);

  bool get _allPendingSelected => _pending.every((t) => _selected.contains(t.id));

  void _toggleSelectAll(bool? v) {
    setState(() {
      if (v == true) {
        for (final t in _pending) {
          _selected.add(t.id);
        }
      } else {
        for (final t in _pending) {
          _selected.remove(t.id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 20),
                    _buildTitle(),
                    const SizedBox(height: 20),
                    _buildTabBar(),
                    const SizedBox(height: 16),
                    _buildSummaryCard(),
                    const SizedBox(height: 24),
                    _buildListHeader(),
                    const SizedBox(height: 14),
                    ..._buildItemList(),
                    const SizedBox(height: 110),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _tabIndex == 2 ? _buildLunasBottomBar() : _buildPaymentBottomBar(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: 1,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushNamed(context, '/dashboard');
            } else if (index == 2) {
              Navigator.pushNamed(context, '/riwayat');
            } else if (index == 3) {
              Navigator.pushNamed(context, '/profile');
            }
          },
          backgroundColor: Colors.white,
          selectedItemColor: _primary,
          unselectedItemColor: Colors.black54,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
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
              label: 'Tagihan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE8E8F0), width: 1.5),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: _primary),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: _pinkBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _cardBorder, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: _primary, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text('Unit 1',
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w700, color: _primary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tagihan',
          style: GoogleFonts.inter(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: _primary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text('Kelola & Selesaikan Iuran Warga',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.black54)),
      ],
    );
  }

  Widget _buildTabBar() {
    final tabs = [
      ('Semua', _dummyTagihan.length),
      ('Menunggu', _pending.length),
      ('Sudah Lunas', _dummyTagihan.where((t) => t.status == TagihanStatus.lunas).length),
    ];
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F8),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isActive = _tabIndex == i;
          
          Color getActiveBg() {
            if (i == 0) return _pinkBg;
            if (i == 1) return const Color(0xFFFFF9EE);
            return _greenTag;
          }
          
          Color getActiveBorder() {
            if (i == 0) return _cardBorder;
            if (i == 1) return const Color(0xFFFFE5B4);
            return _greenDot;
          }
          
          Color getActiveText() {
            if (i == 2) return _greenText;
            return _primary;
          }
          
          Color getActiveBadgeText() {
            if (i == 0) return _primary;
            if (i == 1) return _orangeText;
            return _greenText;
          }

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tabIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isActive ? getActiveBg() : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  border: isActive ? Border.all(color: getActiveBorder(), width: 1.5) : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tabs[i].$1,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? getActiveText() : Colors.black45,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : Colors.black12,
                        borderRadius: BorderRadius.circular(10),
                        border: isActive ? Border.all(color: getActiveBorder(), width: 1.5) : null,
                      ),
                      child: Text(
                        '${tabs[i].$2}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isActive ? getActiveBadgeText() : Colors.black45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final isLunas = _tabIndex == 2;
    final selectedCount = _filtered
        .where((t) => _selected.contains(t.id) && t.status == TagihanStatus.menunggu)
        .length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _pinkBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLunas ? 'TOTAL IURAN TERBAYAR' : 'TOTAL TAGIHAN TERPILIH',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _primary.withValues(alpha: 0.7),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isLunas ? _formatRupiah(_totalLunas) : _formatRupiah(_totalSelected),
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: _primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              isLunas
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _greenTag,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _greenDot.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: _greenDot, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 5),
                          Text('Semua Lunas',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _greenText,
                              )),
                        ],
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBE4E4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$selectedCount dari ${_pending.length} dipilih',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _pinkText,
                        ),
                      ),
                    ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isLunas ? 'Terakhir: 28 Agu 2026' : 'Jatuh Tempo: 10 Okt',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.black45),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFEEDDDD)),
          const SizedBox(height: 12),
          isLunas
              ? Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 17, color: _greenDot),
                    const SizedBox(width: 8),
                    Text(
                      '4 Iuran Periode Berjalan Lunas',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _primary,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _toggleSelectAll(!_allPendingSelected),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: Checkbox(
                              value: _allPendingSelected,
                              onChanged: _toggleSelectAll,
                              activeColor: _primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              side: const BorderSide(color: Color(0xFFCCCCDD), width: 1.5),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(width: 9),
                          Text(
                            'Pilih Semua Tagihan Belum Lunas',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _selected.clear()),
                      child: Text(
                        'Reset',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Daftar Rincian Iuran',
            style: GoogleFonts.inter(
                fontSize: 16, fontWeight: FontWeight.w800, color: _primary)),
        Text('Periode Sep 2026',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.black45)),
      ],
    );
  }

  List<Widget> _buildItemList() {
    return _filtered.map((item) {
      final isLunas = item.status == TagihanStatus.lunas;
      final isChecked = _selected.contains(item.id);
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isChecked && !isLunas
                  ? _primary.withValues(alpha: 0.25)
                  : const Color(0xFFEEEEF5),
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: isLunas
                    ? Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: _greenTag,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _greenDot, width: 1.5),
                        ),
                        child: const Icon(Icons.check, size: 14, color: _greenDot),
                      )
                    : SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
                          value: isChecked,
                          onChanged: (v) {
                            setState(() {
                              v == true
                                  ? _selected.add(item.id)
                                  : _selected.remove(item.id);
                            });
                          },
                          activeColor: _primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          side: const BorderSide(color: Color(0xFFCCCCDD), width: 1.5),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildTag(
                          item.tipe == TagihanTipe.wajib ? 'Wajib' : 'Iuran Khusus',
                          _pinkTag,
                          _pinkText,
                        ),
                        const SizedBox(width: 6),
                        isLunas
                            ? _buildDotTag('Lunas', _greenTag, _greenText, _greenDot)
                            : _buildTag('Menunggu', _orangeTag, _orangeText),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      item.nama,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _primary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(item.icon, size: 13, color: Colors.black38),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            item.deskripsi,
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.black45),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatRupiah(item.jumlah),
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w800, color: _primary),
                  ),
                  const SizedBox(height: 2),
                  isLunas
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _greenTag,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Terbayar',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _greenText)),
                        )
                      : Text('/bulan',
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.black38)),
                  if (isLunas) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xFFDDDDEE), width: 1.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text('Lihat Bukti',
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _primary)),
                            const SizedBox(width: 3),
                            const Icon(Icons.chevron_right,
                                size: 13, color: _primary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildTag(String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w700, color: textColor)),
    );
  }

  Widget _buildDotTag(String label, Color bg, Color textColor, Color dotColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w700, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildPaymentBottomBar() {
    final count = _filtered
        .where((t) => _selected.contains(t.id) && t.status == TagihanStatus.menunggu)
        .length;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total ($count iuran)',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.white54)),
                Text(
                  _formatRupiah(_totalSelected),
                  style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/pembayaran');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25), width: 1.5),
              ),
              child: Row(
                children: [
                  Text('Lanjut Pembayaran',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLunasBottomBar() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: _greenTag, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.check_circle_rounded, size: 22, color: _greenDot),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Semua Tagihan Lunas',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _primary)),
                Text('Tidak ada iuran tertunggak',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.black45)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf_rounded, size: 15, color: Colors.white),
                  const SizedBox(width: 6),
                  Text('Unduh PDF',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
