import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/dummy_data.dart';

class KwitansiScreen extends StatefulWidget {
  const KwitansiScreen({super.key});

  @override
  State<KwitansiScreen> createState() => _KwitansiScreenState();
}

class _KwitansiScreenState extends State<KwitansiScreen> {
  static const Color _primary = Color(0xFF09095E);
  static const Color _bgColor = Color(0xFFF6F8FB);
  static const Color _cardBorder = Color(0xFFF0F4F8);
  static const Color _greyText = Color(0xFF6B7280);
  static const Color _greenText = Color(0xFF1A7A4A);
  static const Color _greenBg = Color(0xFFF0FDF4);
  static const Color _pinkTag = Color(0xFFFFE9E9);
  static const Color _pinkText = Color(0xFFC0392B);
  static const Color _blueText = Color(0xFF1E3A8A);

  bool _showDetails = true;
  String _transactionId = 'KWT/GATELAND/001';
  int _amount = 0;
  String _month = 'Periode Aktif';
  String _unit = DummyDataStore().profile.unit;
  String _residentName = DummyDataStore().activeUser.nama;
  String _method = 'QRIS';
  String _dateLabel = '';
  bool _isPaid = true;
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

  String _terbilangCore(int n) {
    const satuan = [
      '',
      'Satu',
      'Dua',
      'Tiga',
      'Empat',
      'Lima',
      'Enam',
      'Tujuh',
      'Delapan',
      'Sembilan',
      'Sepuluh',
      'Sebelas',
    ];
    if (n < 12) return satuan[n];
    if (n < 20) return '${_terbilangCore(n - 10)} Belas';
    if (n < 100) {
      final rem = n % 10;
      return '${_terbilangCore(n ~/ 10)} Puluh${rem > 0 ? ' ${_terbilangCore(rem)}' : ''}';
    }
    if (n < 200) {
      final rem = n - 100;
      return 'Seratus${rem > 0 ? ' ${_terbilangCore(rem)}' : ''}';
    }
    if (n < 1000) {
      final rem = n % 100;
      return '${_terbilangCore(n ~/ 100)} Ratus${rem > 0 ? ' ${_terbilangCore(rem)}' : ''}';
    }
    if (n < 2000) {
      final rem = n - 1000;
      return 'Seribu${rem > 0 ? ' ${_terbilangCore(rem)}' : ''}';
    }
    if (n < 1000000) {
      final rem = n % 1000;
      return '${_terbilangCore(n ~/ 1000)} Ribu${rem > 0 ? ' ${_terbilangCore(rem)}' : ''}';
    }
    final rem = n % 1000000;
    return '${_terbilangCore(n ~/ 1000000)} Juta${rem > 0 ? ' ${_terbilangCore(rem)}' : ''}';
  }

  String _terbilangRupiah(int amount) {
    if (amount <= 0) return 'Nol Rupiah';
    return '${_terbilangCore(amount).trim()} Rupiah';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadArgs) return;
    _didLoadArgs = true;

    _residentName = DummyDataStore().activeUser.nama;
    _unit = DummyDataStore().profile.unit;

    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    _dateLabel = '${now.day} ${months[now.month - 1]} ${now.year}, $hh:$mm';

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      if (args['transactionId'] != null && args['transactionId'].toString().trim().isNotEmpty) {
        _transactionId = args['transactionId'].toString();
      }
      final rawAmt = args['amount'];
      if (rawAmt is int) {
        _amount = rawAmt;
      } else if (rawAmt != null) {
        _amount = int.tryParse(rawAmt.toString()) ?? 0;
      }
      if (args['month'] != null && args['month'].toString().trim().isNotEmpty) {
        _month = args['month'].toString();
      }
      if (args['unit'] != null && args['unit'].toString().trim().isNotEmpty && args['unit'].toString().trim() != '-') {
        _unit = args['unit'].toString();
      }
      if (args['residentName'] != null && args['residentName'].toString().trim().isNotEmpty) {
        _residentName = args['residentName'].toString();
      }
      if (args['method'] != null && args['method'].toString().trim().isNotEmpty) {
        _method = args['method'].toString();
      }
      if (args['date'] != null && args['date'].toString().trim().isNotEmpty) {
        _dateLabel = args['date'].toString();
      }
      if (args['isPaid'] is bool) {
        _isPaid = args['isPaid'] as bool;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    _buildReceiptCard(),
                    const SizedBox(height: 20),
                    _buildToggleCard(),
                    const SizedBox(height: 24),
                    Text(
                      'Kwitansi ini adalah bukti pembayaran sah yang diterbitkan secara\nelektronik oleh Cluster GateLand dan diakui oleh pengurus\nRT/RW',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF9CA3AF),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
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
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 16, color: _primary),
            ),
          ),
          Column(
            children: [
              Text(
                'Bukti Kwitansi',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _primary,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _isPaid ? _greenText : const Color(0xFFB86E00),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isPaid ? 'Resmi & Terverifikasi' : 'Menunggu Verifikasi',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _isPaid ? _greenText : const Color(0xFFB86E00),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 38), // placeholder to balance the row
        ],
      ),
    );
  }

  Widget _buildReceiptCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Decorative top border
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Row(
              children: [
                Expanded(flex: 3, child: Container(height: 6, color: _primary)),
                Expanded(flex: 2, child: Container(height: 6, color: const Color(0xFF8B5CF6))),
                Expanded(flex: 1, child: Container(height: 6, color: const Color(0xFFF472B6))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildReceiptHeader(),
                const SizedBox(height: 24),
                _buildVerificationBanner(),
                const SizedBox(height: 24),
                _buildDetailTable(),
              ],
            ),
          ),
          _buildDashedDivider(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_showDetails) ...[
                  _buildRincianSection(),
                  const SizedBox(height: 24),
                ],
                _buildTotalBox(),
                const SizedBox(height: 24),
                _buildFooterSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.maps_home_work_outlined, color: _primary, size: 28),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _pinkTag,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'E-KWITANSI RESMI',
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: _pinkText,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cluster GateLand',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                  ),
                ),
                Text(
                  '${DummyDataStore().profile.wilayahRW} • $_unit',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: _greyText,
                  ),
                ),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'NO. BUKTI',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: _greyText,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _transactionId,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _dateLabel,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerificationBanner() {
    final Color accentColor = _isPaid ? _greenText : const Color(0xFFB86E00);
    final Color bgColor = _isPaid ? _greenBg : const Color(0xFFFFF8EB);
    final Color borderColor = _isPaid ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A);
    final Color subColor = _isPaid ? const Color(0xFF166534) : const Color(0xFF92400E);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPaid ? Icons.check : Icons.schedule,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isPaid ? 'PEMBAYARAN TERVERIFIKASI' : 'MENUNGGU VERIFIKASI ADMIN',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                  Text(
                    _isPaid
                        ? 'Tercatat di Buku Kas Paguyuban'
                        : 'Sedang diperiksa oleh Pengurus RT',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: subColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 1),
            ),
            child: Transform.rotate(
              angle: -0.2,
              child: Text(
                _isPaid ? 'LUNAS' : 'PENDING',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: accentColor.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTable() {
    return Column(
      children: [
        _buildTableRow('Diterima Dari', _residentName, isBold: true),
        const SizedBox(height: 12),
        _buildTableRow('Alamat / Unit', '$_unit (${DummyDataStore().profile.wilayahRW})', isBlue: true, isBold: true),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Metode Pembayaran',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _greyText,
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _method,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Ref: $_transactionId',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTableRow(String label, String value, {bool isBold = false, bool isBlue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: _greyText,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBlue ? _blueText : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDashedDivider() {
    return Row(
      children: [
        Container(
          width: 8,
          height: 16,
          decoration: const BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final boxWidth = constraints.constrainWidth();
              const dashWidth = 5.0;
              const dashHeight = 1.0;
              final dashCount = (boxWidth / (2 * dashWidth)).floor();
              return Flex(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                direction: Axis.horizontal,
                children: List.generate(dashCount, (_) {
                  return SizedBox(
                    width: dashWidth,
                    height: dashHeight,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(color: Color(0xFFE5E7EB)),
                    ),
                  );
                }),
              );
            },
          ),
        ),
        Container(
          width: 8,
          height: 16,
          decoration: const BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildRincianSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RINCIAN POS IURAN (${_month.toUpperCase()})',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _greyText,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'JUMLAH',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _greyText,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_amount > 0)
          _buildRincianItem(
            _month,
            'Iuran Warga Cluster GateLand ($_unit)',
            _formatRupiah(_amount),
          )
        else
          Text(
            'Belum ada rincian iuran pada transaksi ini.',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: _greyText,
            ),
          ),
      ],
    );
  }

  Widget _buildRincianItem(String title, String subtitle, String amount, {bool isKhusus = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (isKhusus) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Khusus',
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Text(
          amount,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isPaid ? 'TOTAL DITERIMA' : 'TOTAL NOMINAL TRANSAKSI',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _greyText,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '"${_terbilangRupiah(_amount)}"',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    color: _blueText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatRupiah(_amount),
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Wrap(
                spacing: 2,
                runSpacing: 2,
                children: [
                  Container(width: 16, height: 16, color: const Color(0xFF2C3E50)),
                  Container(width: 6, height: 16, color: const Color(0xFFCBD5E1)),
                  Container(width: 10, height: 10, color: const Color(0xFF2C3E50)),
                  
                  Container(width: 8, height: 8, color: const Color(0xFF94A3B8)),
                  Container(width: 10, height: 12, color: const Color(0xFF2C3E50)),
                  Container(width: 8, height: 8, color: const Color(0xFFE2E8F0)),
                  Container(width: 6, height: 6, color: const Color(0xFF2C3E50)),

                  Container(width: 6, height: 6, color: const Color(0xFF64748B)),
                  Container(width: 14, height: 8, color: const Color(0xFF2C3E50)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VALIDASI HASH',
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: _greyText,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'DL-VERIFY-99214',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.check, size: 10, color: _greenText),
                    const SizedBox(width: 2),
                    Text(
                      'Tanda Tangan Elektronik',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: _greenText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Pengelola Cluster GateLand',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: _greyText,
              ),
            ),
            const SizedBox(height: 4),
            // Fake signature using CustomPainter
            SizedBox(
              width: 60,
              height: 30,
              child: CustomPaint(
                painter: _SignaturePainter(color: _primary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.description_outlined, color: _primary, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sertakan Rincian Detail',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Tampilkan pos iuran di lembar unduhan',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: _greyText,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: _showDetails,
            onChanged: (val) {
              setState(() {
                _showDetails = val;
              });
            },
            activeThumbColor: Colors.white,
            activeTrackColor: _primary,
            inactiveTrackColor: const Color(0xFFE5E7EB),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Kwitansi resmi berhasil diunduh (JPG)!'),
                    ],
                  ),
                  backgroundColor: const Color(0xFF1B8754),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            icon: const Icon(Icons.download, size: 18, color: Colors.white),
            label: Text(
              'Unduh Kwitansi (JPG)',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final Color color;

  _SignaturePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    
    // First hump
    path.quadraticBezierTo(
      size.width * 0.15, size.height * 0.2, 
      size.width * 0.35, size.height * 0.5
    );
    
    // Trough
    path.quadraticBezierTo(
      size.width * 0.55, size.height * 0.9, 
      size.width * 0.7, size.height * 0.3
    );
    
    // Last tail
    path.quadraticBezierTo(
      size.width * 0.85, size.height * 0.8, 
      size.width, size.height * 0.4
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
