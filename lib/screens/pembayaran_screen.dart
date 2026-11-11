import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/dummy_data.dart';
import '../services/api_service.dart';

class PembayaranScreen extends StatefulWidget {
  const PembayaranScreen({super.key});

  @override
  State<PembayaranScreen> createState() => _PembayaranScreenState();
}

class _PembayaranScreenState extends State<PembayaranScreen> {
  static const Color _primary = Color(0xFF09095E);
  static const Color _bgColor = Color(0xFFF6F8FB);
  static const Color _cardBorder = Color(0xFFE8E8F0);
  static const Color _redText = Color(0xFFC0392B);
  static const Color _redBg = Color(0xFFFFE9E9);
  static const Color _greenText = Color(0xFF1A7A4A);
  static const Color _greenBg = Color(0xFFE6F9F1);
  static const Color _orangeText = Color(0xFFB86E00);
  static const Color _orangeBg = Color(0xFFFFF0D9);

  final int _currentIndex = 1;
  final ScrollController _scrollController = ScrollController();
  String? _selectedMethod; // null = Pilih metode, 'qris' = QRIS, 'transfer' = Transfer Manual
  String? _transactionId;
  int? _billId;
  int _amount = 0;
  String _month = 'Periode Aktif';
  String _unit = DummyDataStore().profile.unit;
  int _billCount = 1;
  bool _didLoadArgs = false;

  String _formatRupiah(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp ${buf.toString()}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadArgs) return;
    _didLoadArgs = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _billId = args['billId'] is int
          ? args['billId'] as int
          : int.tryParse(args['billId']?.toString() ?? '');
      final rawAmt = args['amount'];
      if (rawAmt is int) {
        _amount = rawAmt;
      } else if (rawAmt != null) {
        _amount = int.tryParse(rawAmt.toString()) ?? 0;
      }
      if (args['month'] != null && args['month'].toString().trim().isNotEmpty) {
        _month = args['month'].toString();
      }
      if (args['unit'] != null && args['unit'].toString().trim().isNotEmpty) {
        _unit = args['unit'].toString();
      }
      if (args['count'] is int) {
        _billCount = args['count'] as int;
      }
    }

    if (_amount <= 0) {
      _loadActiveBill();
    }
  }

  Future<void> _loadActiveBill() async {
    try {
      final me = await ApiService().getMe();
      if (me != null) {
        DummyDataStore().syncFromBackendUser(me);
      }
      final bill = await ApiService().getMyBill();
      if (bill != null && mounted) {
        final String status = (bill['status'] ?? 'NONE').toString();
        final int amt = bill['amount'] is int
            ? bill['amount'] as int
            : int.tryParse(bill['amount']?.toString() ?? '0') ?? 0;
        final String resolvedUnit =
            (bill['unit'] != null && bill['unit'].toString().trim().isNotEmpty && bill['unit'].toString().trim() != '-')
                ? bill['unit'].toString().trim()
                : DummyDataStore().profile.unit;
        setState(() {
          _billId = bill['id'] is int ? bill['id'] as int : int.tryParse(bill['id']?.toString() ?? '');
          _amount = status == 'NONE' ? 0 : amt;
          _month = (bill['month'] ?? 'Periode Aktif').toString();
          _unit = resolvedUnit;
        });
      }
    } catch (_) {}
  }

  Map<String, dynamic> _paymentRouteArgs() => {
        'billId': _billId,
        'amount': _amount,
        'month': _month,
        'unit': _unit,
        'count': _billCount,
      };

  void _selectMethod(String? method) async {
    if (method != null && _amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Total tagihan saat ini Rp 0. Belum ada tagihan aktif.'),
        ),
      );
      return;
    }

    setState(() {
      _selectedMethod = method;
    });
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    if (method == 'qris' && _transactionId == null && _amount > 0) {
      try {
        final res = await ApiService().createQrisTransaction(
          billId: _billId,
          amount: _amount,
          residentName: DummyDataStore().activeUser.nama,
          unit: _unit,
        );
        if (mounted) {
          setState(() {
            _transactionId = res['transactionId'] as String?;
          });
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedMethod == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectedMethod != null) {
          _selectMethod(null);
        }
      },
      child: Scaffold(
        backgroundColor: _bgColor,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: _buildTopBar(context),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDetailPembayaranCard(),
                      const SizedBox(height: 20),
                      if (_selectedMethod == null) ...[
                        _buildPilihMetodePembayaran(),
                      ] else if (_selectedMethod == 'qris') ...[
                        _buildSelectedMethodBar('QRIS'),
                        const SizedBox(height: 12),
                        _buildQrisCard(),
                        const SizedBox(height: 16),
                        _buildTransferManualCard(),
                      ] else ...[
                        _buildSelectedMethodBar('Transfer Manual Bank'),
                        const SizedBox(height: 12),
                        _buildTransferManualDetailCard(),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomSheet: _selectedMethod == 'qris'
            ? _buildCekStatusButton()
            : _selectedMethod == 'transfer'
                ? _buildUploadBuktiButton()
                : null,
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            if (_selectedMethod != null) {
              _selectMethod(null);
            } else {
              Navigator.pop(context);
            }
          },
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _cardBorder, width: 1.5),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: _primary),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF2F2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFEBEB), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: _primary, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(_unit,
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w700, color: _primary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailPembayaranCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.15],
          colors: [
            Color(0xFFFFF2F4),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE0E5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9BAD).withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: _primary),
                  const SizedBox(width: 8),
                  Text('Detail Pembayaran',
                      style: GoogleFonts.inter(
                          fontSize: 15, fontWeight: FontWeight.w800, color: _primary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _amount <= 0 ? _greenBg : _redBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_amount <= 0 ? 'TIDAK ADA TAGIHAN' : 'BELUM BAYAR',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _amount <= 0 ? _greenText : _redText)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow(Icons.verified_user_outlined, 'Jenis Tagihan',
              'Iuran Kebersihan & Keamanan'),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.home_outlined, 'Unit Hunian',
              '${DummyDataStore().profile.wilayahRW} • $_unit',
              subValue: DummyDataStore().activeUser.nama),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.calendar_today_outlined, 'Periode Pembayaran',
              _month),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF0F4F8), height: 1, thickness: 1),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('TOTAL TAGIHAN BERSIH',
                      style: GoogleFonts.inter(
                          fontSize: 10, fontWeight: FontWeight.w700, color: Colors.black45, letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(_formatRupiah(_amount),
                      style: GoogleFonts.inter(
                          fontSize: 18, fontWeight: FontWeight.w800, color: _primary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {String? subValue}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F7FB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: _primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black45)),
              const SizedBox(height: 4),
              Text(value,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _primary)),
              if (subValue != null) ...[
                const SizedBox(height: 2),
                Text(subValue,
                    style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black45)),
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPilihMetodePembayaran() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.circle, size: 8, color: _primary),
            const SizedBox(width: 8),
            Text(
              'Pilih metode Pembayaran',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildMethodOptionCard(
          badgeWidget: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _redBg, width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'QRIS',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _redText,
              ),
            ),
          ),
          title: 'QRIS',
          pillText: 'Otomatis',
          pillBg: _greenBg,
          pillColor: _greenText,
          subtitle: 'BCA, Mandiri, GoPay, OVO, Dana, ShopeePay',
          onTap: () => _selectMethod('qris'),
        ),
        const SizedBox(height: 12),
        _buildMethodOptionCard(
          badgeWidget: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2F2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFE5E5)),
            ),
            child: const Icon(Icons.receipt_long_outlined, size: 20, color: _redText),
          ),
          title: 'Transfer Manual Bank',
          pillText: 'BCA',
          pillBg: Colors.white,
          pillColor: _primary,
          pillBorder: const Color(0xFFE8E8F0),
          subtitle: 'Alternatif jika QRIS bermasalah (perlu konfirmasi)',
          onTap: () => _selectMethod('transfer'),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F7FB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8E8F0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 18, color: _primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pilih QRIS untuk konfirmasi pembayaran otomatis realtime tanpa upload bukti transfer.',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMethodOptionCard({
    required Widget badgeWidget,
    required String title,
    required String pillText,
    required Color pillBg,
    required Color pillColor,
    Color? pillBorder,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              badgeWidget,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: pillBg,
                            borderRadius: BorderRadius.circular(12),
                            border: pillBorder != null ? Border.all(color: pillBorder) : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (pillText == 'Otomatis') ...[
                                Icon(Icons.circle, size: 5, color: pillColor),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                pillText,
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: pillColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7FB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: _primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedMethodBar(String methodName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.circle, size: 8, color: _primary),
            const SizedBox(width: 8),
            Text(
              'Metode Pembayaran',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _primary,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _selectMethod(null),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FB),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _cardBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.swap_horiz_rounded, size: 14, color: _primary),
                const SizedBox(width: 4),
                Text(
                  'Ganti Metode',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQrisCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFF9F9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: Color(0xFFFFEBEB))),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: _redBg, width: 1.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('QRIS',
                            style: GoogleFonts.inter(
                                fontSize: 12, fontWeight: FontWeight.w800, color: _redText)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('QRIS',
                                    style: GoogleFonts.inter(
                                        fontSize: 14, fontWeight: FontWeight.w700, color: _primary)),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _greenBg,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.circle, size: 6, color: _greenText),
                                      const SizedBox(width: 4),
                                      Text('Otomatis',
                                          style: GoogleFonts.inter(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600,
                                              color: _greenText)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text('BCA, Mandiri, GoPay, OVO, Dana, ShopeePay',
                                style: GoogleFonts.inter(
                                    fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black54)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFEBEB)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 14, color: _redText),
                            const SizedBox(width: 6),
                            Text('Selesaikan pembayaran dalam:',
                                style: GoogleFonts.inter(
                                    fontSize: 11, fontWeight: FontWeight.w500, color: _redText)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _redBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('14 : 59',
                              style: GoogleFonts.inter(
                                  fontSize: 12, fontWeight: FontWeight.w700, color: _redText)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _orangeBg,
                    border: Border.all(color: const Color(0xFFFFE5B4)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.circle, size: 8, color: _orangeText),
                      const SizedBox(width: 6),
                      Text('Status: Menunggu Pembayaran',
                          style: GoogleFonts.inter(
                              fontSize: 11, fontWeight: FontWeight.w600, color: _orangeText)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.qr_code_2, size: 180, color: _primary),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('QRIS',
                            style: GoogleFonts.inter(
                                fontSize: 10, fontWeight: FontWeight.w800, color: _redText)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Nominal: ',
                        style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black54)),
                    Text(_formatRupiah(_amount),
                        style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w700, color: _primary)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text('Kode QRIS berhasil disimpan ke galeri!'),
                                ],
                              ),
                              backgroundColor: const Color(0xFF1B8754),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        icon: const Icon(Icons.download_outlined, size: 16, color: _primary),
                        label: Text('Simpan QR',
                            style: GoogleFonts.inter(
                                fontSize: 13, fontWeight: FontWeight.w600, color: _primary)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: _cardBorder),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.share, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text('Tautan & kode QRIS siap dibagikan!'),
                                ],
                              ),
                              backgroundColor: _primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        icon: const Icon(Icons.share_outlined, size: 16, color: _redText),
                        label: Text('Bagikan',
                            style: GoogleFonts.inter(
                                fontSize: 13, fontWeight: FontWeight.w600, color: _redText)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _redBg,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 16, color: _primary),
                    const SizedBox(width: 8),
                    Text('Petunjuk Singkat QRIS Otomatis:',
                        style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w700, color: _primary)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInstructionItem('Buka aplikasi Mobile Banking atau E-Wallet (BCA, GoPay, OVO, Dana, dll).'),
                const SizedBox(height: 8),
                _buildInstructionItem('Pilih menu Pindai / Scan QRIS, lalu arahkan kamera ke barcode di atas atau unggah screenshot gambar.'),
                const SizedBox(height: 8),
                _buildInstructionItem('Nominal tagihan terisi otomatis sebesar ${_formatRupiah(_amount)} tanpa perlu input manual.'),
                const SizedBox(height: 8),
                _buildInstructionItem('Masukkan PIN Anda. Sistem GateLand akan memverifikasi pembayaran secara realtime tanpa upload bukti struk.'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sync, size: 14, color: Colors.black45),
                const SizedBox(width: 6),
                Text('Mengecek status pembayaran secara otomatis...',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.black45)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4, right: 8),
          child: Icon(Icons.circle, size: 4, color: Colors.black45),
        ),
        Expanded(
          child: Text(text,
              style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black87, height: 1.4)),
        ),
      ],
    );
  }

  Widget _buildTransferManualCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFEBEB)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFFFEBEB)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.receipt_long_outlined, size: 20, color: _redText),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Transfer Manual Bank',
                              style: GoogleFonts.inter(
                                  fontSize: 13, fontWeight: FontWeight.w700, color: _primary)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFFE8E8F0)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('BCA',
                                style: GoogleFonts.inter(
                                    fontSize: 10, fontWeight: FontWeight.w700, color: _primary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('Alternatif jika QRIS bermasalah (perlu konfirmasi)',
                          style: GoogleFonts.inter(
                              fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nomor Rekening Kas RT:',
                        style: GoogleFonts.inter(
                            fontSize: 10, fontWeight: FontWeight.w500, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text('1234 - 5678 - 9101 - 1121',
                        style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w800, color: _primary, letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text('a.n Kas Paguyuban Sekar Indah',
                        style: GoogleFonts.inter(
                            fontSize: 10, fontWeight: FontWeight.w500, color: Colors.black54)),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(const ClipboardData(text: '1234567891011121'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.copy, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Nomor Rekening BCA Kas RT disalin!'),
                          ],
                        ),
                        backgroundColor: const Color(0xFF1B8754),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 14, color: _primary),
                  label: Text('Salin',
                      style: GoogleFonts.inter(
                          fontSize: 11, fontWeight: FontWeight.w600, color: _primary)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    side: const BorderSide(color: Color(0xFFE8E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/konfirmasi_pembayaran',
                  arguments: _paymentRouteArgs(),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Upload bukti transfer manual di sini',
                      style: GoogleFonts.inter(
                          fontSize: 11, fontWeight: FontWeight.w600, color: _redText)),
                  const SizedBox(width: 4),
                  const Icon(Icons.open_in_new, size: 12, color: _redText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferManualDetailCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF9F9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: Color(0xFFFFEBEB))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFFFEBEB)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.receipt_long_outlined, size: 20, color: _redText),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Transfer Manual Bank',
                              style: GoogleFonts.inter(
                                  fontSize: 14, fontWeight: FontWeight.w700, color: _primary)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFFE8E8F0)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('BCA',
                                style: GoogleFonts.inter(
                                    fontSize: 10, fontWeight: FontWeight.w700, color: _primary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('Verifikasi manual oleh bendahara RT (1x24 jam)',
                          style: GoogleFonts.inter(
                              fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F7FB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE8E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nomor Rekening Kas RT:',
                              style: GoogleFonts.inter(
                                  fontSize: 10, fontWeight: FontWeight.w500, color: Colors.black54)),
                          const SizedBox(height: 4),
                          Text('1234 - 5678 - 9101 - 1121',
                              style: GoogleFonts.inter(
                                  fontSize: 14, fontWeight: FontWeight.w800, color: _primary, letterSpacing: 0.5)),
                          const SizedBox(height: 4),
                          Text('a.n Kas Paguyuban Sekar Indah',
                              style: GoogleFonts.inter(
                                  fontSize: 10, fontWeight: FontWeight.w500, color: Colors.black54)),
                        ],
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(const ClipboardData(text: '1234567891011121'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.copy, color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text('Nomor Rekening BCA Kas RT disalin!'),
                                ],
                              ),
                              backgroundColor: const Color(0xFF1B8754),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 14, color: _primary),
                        label: Text('Salin',
                            style: GoogleFonts.inter(
                                fontSize: 11, fontWeight: FontWeight.w600, color: _primary)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: Size.zero,
                          side: const BorderSide(color: Color(0xFFE8E8F0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE8E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nominal Transfer:',
                              style: GoogleFonts.inter(
                                  fontSize: 10, fontWeight: FontWeight.w500, color: Colors.black54)),
                          const SizedBox(height: 4),
                          Text(_formatRupiah(_amount),
                              style: GoogleFonts.inter(
                                  fontSize: 15, fontWeight: FontWeight.w800, color: _primary)),
                        ],
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: '$_amount'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.copy, color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Text('Nominal ${_formatRupiah(_amount)} disalin!'),
                                ],
                              ),
                              backgroundColor: const Color(0xFF1B8754),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 14, color: _primary),
                        label: Text('Salin Nominal',
                            style: GoogleFonts.inter(
                                fontSize: 11, fontWeight: FontWeight.w600, color: _primary)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          minimumSize: Size.zero,
                          side: const BorderSide(color: Color(0xFFE8E8F0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F7FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: _primary),
                          const SizedBox(width: 8),
                          Text('Petunjuk Transfer Manual:',
                              style: GoogleFonts.inter(
                                  fontSize: 12, fontWeight: FontWeight.w700, color: _primary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionItem('Buka aplikasi m-Banking atau kunjungi ATM BCA terdekat.'),
                      const SizedBox(height: 8),
                      _buildInstructionItem('Transfer ke rekening 1234-5678-9101-1121 a.n Kas Paguyuban Sekar Indah.'),
                      const SizedBox(height: 8),
                      _buildInstructionItem('Masukkan nominal sesuai tagihan yaitu tepat ${_formatRupiah(_amount)}.'),
                      const SizedBox(height: 8),
                      _buildInstructionItem('Simpan bukti transfer dan klik tombol di bawah untuk konfirmasi & unggah bukti.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBuktiButton() {
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
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              if (_amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Total tagihan saat ini Rp 0. Belum ada tagihan aktif.')),
                );
                return;
              }
              Navigator.pushNamed(
                context,
                '/konfirmasi_pembayaran',
                arguments: _paymentRouteArgs(),
              );
            },
            icon: const Icon(Icons.upload_file_outlined, size: 18, color: Colors.white),
            label: Text('Konfirmasi & Unggah Bukti',
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCekStatusButton() {
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
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              if (_amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Total tagihan saat ini Rp 0. Belum ada tagihan aktif.')),
                );
                return;
              }
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              // Konfirmasi / simulasi penyelesaian pembayaran ke backend
              String? trxId = _transactionId;
              try {
                if (trxId == null) {
                  final created = await ApiService().createQrisTransaction(
                    billId: _billId,
                    amount: _amount,
                    residentName: DummyDataStore().activeUser.nama,
                    unit: _unit,
                  );
                  trxId = created['transactionId'] as String?;
                }
                await ApiService().simulatePayQris(trxId);
                if (mounted) {
                  Navigator.pop(context); // Tutup loading dialog
                  Navigator.pushNamed(
                    context,
                    '/kwitansi',
                    arguments: {
                      'transactionId': trxId,
                      'amount': _amount,
                      'month': _month,
                      'unit': _unit,
                      'method': 'QRIS',
                      'isPaid': true,
                    },
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context); // Tutup loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: _redText,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
            label: Text('Cek Status Pembayaran',
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
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
        currentIndex: _currentIndex,
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
        ],
      ),
    );
  }
}
