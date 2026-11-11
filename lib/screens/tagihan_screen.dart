import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/dummy_data.dart';
import '../services/api_service.dart';

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
  final Set<String> _selected = {};
  List<TagihanItem> _tagihanItems = [];
  bool _isLoading = false;
  String _unitLabel = DummyDataStore().profile.unit;
  String _dueDateLabel = '-';
  String _periodLabel = 'Periode Aktif';
  String _lastPaidLabel = '-';

  @override
  void initState() {
    super.initState();
    final apiUser = ApiService().currentUser;
    if (DummyDataStore().currentUser == null && apiUser != null) {
      DummyDataStore().syncFromBackendUser(apiUser);
      _unitLabel = DummyDataStore().profile.unit;
    }
    _loadTagihan();
  }

  Future<void> _loadTagihan() async {
    setState(() => _isLoading = true);
    try {
      final me = await ApiService().getMe();
      if (me != null) {
        DummyDataStore().syncFromBackendUser(me);
      }
      final bill = await ApiService().getMyBill();
      final String fallbackUnit = DummyDataStore().profile.unit;

      if (bill != null) {
        final String status = (bill['status'] ?? 'NONE').toString();
        final String resolvedUnit =
            (bill['unit'] != null &&
                    bill['unit'].toString().trim().isNotEmpty &&
                    bill['unit'].toString().trim() != '-')
                ? bill['unit'].toString().trim()
                : fallbackUnit;
        final String dueDate = (bill['dueDate'] ?? '-').toString();
        final String period = (bill['month'] ?? 'Periode Aktif').toString();
        final rawBills = bill['bills'];

        final List<TagihanItem> loadedItems = [];
        final Set<String> initialSelected = {};
        String lastPaid = '-';

        if (rawBills is List && rawBills.isNotEmpty) {
          for (final raw in rawBills) {
            if (raw is! Map) continue;
            final map = Map<String, dynamic>.from(raw);
            final bool isPaid = map['status'] == 'PAID';
            final int amount = map['amount'] is int
                ? map['amount'] as int
                : int.tryParse(map['amount']?.toString() ?? '0') ?? 0;
            final String id = (map['id'] ?? loadedItems.length + 1).toString();
            final String month = (map['month'] ?? 'Iuran Bulanan').toString();
            final String itemDue = (map['dueDate'] ?? dueDate).toString();
            final String itemUnit =
                (map['unit'] != null && map['unit'].toString().trim().isNotEmpty && map['unit'].toString().trim() != '-')
                    ? map['unit'].toString().trim()
                    : resolvedUnit;

            if (isPaid && lastPaid == '-') {
              lastPaid = month;
            }

            loadedItems.add(
              TagihanItem(
                id: id,
                nama: month,
                deskripsi: '$itemUnit • Jatuh Tempo: $itemDue',
                jumlah: amount,
                status: isPaid ? TagihanStatus.lunas : TagihanStatus.menunggu,
                tipe: TagihanTipe.wajib,
                icon: isPaid ? Icons.check_circle_outline : Icons.shield_outlined,
              ),
            );
            if (!isPaid && amount > 0) {
              initialSelected.add(id);
            }
          }
        } else if (status == 'UNPAID' || status == 'PAID') {
          final bool isPaid = status == 'PAID';
          final int amount = bill['amount'] is int
              ? bill['amount'] as int
              : int.tryParse(bill['amount']?.toString() ?? '0') ?? 0;
          if (amount > 0 || isPaid) {
            final String id = (bill['id'] ?? '1').toString();
            if (isPaid) lastPaid = period;
            loadedItems.add(
              TagihanItem(
                id: id,
                nama: period,
                deskripsi: '$resolvedUnit • Jatuh Tempo: $dueDate',
                jumlah: amount,
                status: isPaid ? TagihanStatus.lunas : TagihanStatus.menunggu,
                tipe: TagihanTipe.wajib,
                icon: isPaid ? Icons.check_circle_outline : Icons.shield_outlined,
              ),
            );
            if (!isPaid && amount > 0) {
              initialSelected.add(id);
            }
          }
        }

        if (mounted) {
          setState(() {
            _unitLabel = resolvedUnit;
            _dueDateLabel = dueDate;
            _periodLabel = period;
            _lastPaidLabel = lastPaid;
            _tagihanItems = loadedItems;
            _selected
              ..clear()
              ..addAll(initialSelected);
            _isLoading = false;
          });
        }
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _unitLabel = DummyDataStore().profile.unit;
        _dueDateLabel = '-';
        _periodLabel = 'Periode Aktif';
        _lastPaidLabel = '-';
        _tagihanItems = [];
        _selected.clear();
        _isLoading = false;
      });
    }
  }

  List<TagihanItem> get _filtered {
    switch (_tabIndex) {
      case 1:
        return _tagihanItems.where((t) => t.status == TagihanStatus.menunggu).toList();
      case 2:
        return _tagihanItems.where((t) => t.status == TagihanStatus.lunas).toList();
      default:
        return _tagihanItems;
    }
  }

  List<TagihanItem> get _pending =>
      _tagihanItems.where((t) => t.status == TagihanStatus.menunggu).toList();

  List<TagihanItem> get _paidItems =>
      _tagihanItems.where((t) => t.status == TagihanStatus.lunas).toList();

  int get _totalSelected => _filtered
      .where((t) => _selected.contains(t.id) && t.status == TagihanStatus.menunggu)
      .fold(0, (sum, t) => sum + t.jumlah);

  int get _totalLunas =>
      _paidItems.fold(0, (s, t) => s + t.jumlah);

  bool get _allPendingSelected => _pending.isNotEmpty && _pending.every((t) => _selected.contains(t.id));

  Widget? _buildBottomSheet() {
    if (_tabIndex == 2) {
      return _totalLunas > 0 ? _buildLunasBottomBar() : null;
    }
    if (_pending.isEmpty || _tagihanItems.isEmpty) {
      return null;
    }
    return _buildPaymentBottomBar();
  }

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
    final bool hasNoBillsAtAll = !_isLoading && _tagihanItems.isEmpty;
    final bool showEmptyAllPaid = !_isLoading && _tagihanItems.isNotEmpty && _tabIndex == 1 && _pending.isEmpty;

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadTagihan,
                color: _primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 20),
                      _buildTitle(),
                      const SizedBox(height: 20),
                      _buildTabBar(),
                      const SizedBox(height: 24),
                      if (hasNoBillsAtAll) ...[
                        _buildSummaryCard(),
                        const SizedBox(height: 24),
                        _buildNoBillsCard(),
                        const SizedBox(height: 40),
                      ] else if (showEmptyAllPaid) ...[
                        _buildListHeader(),
                        const SizedBox(height: 20),
                        _buildAllPaidCard(),
                        const SizedBox(height: 40),
                      ] else ...[
                        _buildSummaryCard(),
                        const SizedBox(height: 24),
                        _buildListHeader(),
                        const SizedBox(height: 14),
                        ..._buildItemList(),
                        const SizedBox(height: 110),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomSheet(),
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
          currentIndex: 1,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushNamed(context, '/dashboard');
            } else if (index == 2) {
              Navigator.pushNamed(context, '/riwayat');
            }
          },
          backgroundColor: Colors.white,
          selectedItemColor: _primary,
          unselectedItemColor: Colors.black45,
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
              icon: Icon(Icons.history),
              activeIcon: Icon(Icons.history),
              label: 'Riwayat',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoBillsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E8F5), width: 1.5),
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
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F3FF),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.receipt_long_outlined, color: _primary, size: 38),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Belum Ada Tagihan Aktif',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _primary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _loadTagihan,
              icon: const Icon(Icons.refresh, size: 16, color: _primary),
              label: Text(
                'Muat Ulang',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: _primary),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllPaidCard() {
    return Container(
      width: double.infinity,
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
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3FF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFDEDE), width: 6),
            ),
            child: const Center(
              child: Icon(Icons.check_circle_outline, color: _primary, size: 44),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Semua Tagihan Sudah Lunas!',
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
              children: [
                const TextSpan(text: 'Hebat! Seluruh iuran warga periode\n'),
                TextSpan(
                  text: _periodLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: _primary),
                ),
                const TextSpan(
                  text: ' dan bulan sebelumnya\ntelah terselesaikan dengan baik. Terima\nkasih atas partisipasi aktif Anda dalam\nmenjaga kenyamanan klaster GateLand!',
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/riwayat'),
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
                    'Lihat Riwayat & Kwitansi',
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
                        'Jadwal Berikutnya',
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
                  onPressed: _loadTagihan,
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
          const SizedBox(height: 8),
        ],
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
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE8E8F0), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back, size: 18, color: _primary),
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
              Text(_unitLabel,
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
        Text('Kelola & selesaikan iuran warga paguyuban',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.black54)),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF5).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTabItem(0, 'Semua', null),
          _buildTabItem(1, 'Menunggu', '${_pending.length}'),
          _buildTabItem(2, 'Sudah Lunas', null),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, String? badge) {
    final isActive = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? _primary : Colors.black54,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF9C3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      badge,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF854D0E),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
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
            isLunas
                ? 'Terakhir: $_lastPaidLabel'
                : 'Jatuh Tempo: ${_pending.isEmpty ? '-' : _dueDateLabel}',
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
                      _paidItems.isEmpty
                          ? 'Belum ada iuran berstatus lunas'
                          : '${_paidItems.length} Iuran Periode Terbayar',
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
        Text(_periodLabel,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.black45)),
      ],
    );
  }

  List<Widget> _buildItemList() {
    if (_isLoading) {
      return const [
        Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        ),
      ];
    }
    if (_filtered.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
            child: Text(
              _tabIndex == 2
                  ? 'Belum ada iuran yang sudah lunas.'
                  : 'Belum ada iuran pada kategori ini.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.black54),
            ),
          ),
        ),
      ];
    }
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
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/kwitansi',
                          arguments: {
                            'transactionId': 'BILL-${item.id}',
                            'amount': item.jumlah,
                            'month': item.nama,
                            'unit': _unitLabel,
                            'isPaid': true,
                          },
                        );
                      },
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
            onTap: () async {
              final selectedItems = _filtered
                  .where((t) => _selected.contains(t.id) && t.status == TagihanStatus.menunggu)
                  .toList();
              if (selectedItems.isEmpty || _totalSelected <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pilih minimal satu tagihan untuk dibayar.'),
                  ),
                );
                return;
              }
              final primaryItem = selectedItems.first;
              await Navigator.pushNamed(
                context,
                '/pembayaran',
                arguments: {
                  'billId': int.tryParse(primaryItem.id),
                  'amount': _totalSelected,
                  'month': primaryItem.nama,
                  'unit': _unitLabel,
                  'count': selectedItems.length,
                },
              );
              _loadTagihan();
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
            onTap: () {
              Navigator.pushNamed(
                context,
                '/kwitansi',
                arguments: {
                  'amount': _totalLunas,
                  'month': _periodLabel,
                  'unit': _unitLabel,
                  'isPaid': true,
                },
              );
            },
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
