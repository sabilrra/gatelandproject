import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  static const Color _greyText = Color(0xFF6B7280);

  int _currentIndex = 1;

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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTopBar(context),
                    const SizedBox(height: 24),
                    _buildDetailPembayaranCard(),
                    const SizedBox(height: 16),
                    _buildQrisCard(),
                    const SizedBox(height: 16),
                    _buildTransferManualCard(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildCekStatusButton(),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildTopBar(BuildContext context) {
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
              Text('Unit 1',
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
                  color: _redBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('BELUM BAYAR',
                    style: GoogleFonts.inter(
                        fontSize: 10, fontWeight: FontWeight.w800, color: _redText)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow(Icons.verified_user_outlined, 'Jenis Tagihan',
              'Iuran Kebersihan & Keamanan'),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.home_outlined, 'Unit Hunian',
              'RT 04 / RW 08 – Unit 1',
              subValue: 'Blok A3 No. 12 (Ibu Azizah Pratama)'),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.calendar_today_outlined, 'Periode Pembayaran',
              'September 2026'),
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
                  Text('Rp 175.000',
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
                        color: Colors.black.withOpacity(0.05),
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
                    Text('Rp 175.000',
                        style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w700, color: _primary)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
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
                        onPressed: () {},
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
                _buildInstructionItem('Nominal tagihan terisi otomatis sebesar Rp 175.000 tanpa perlu input manual.'),
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
                  onPressed: () {},
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
                Navigator.pushNamed(context, '/konfirmasi_pembayaran');
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

  Widget _buildCekStatusButton() {
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Untuk prototype, kita arahkan ke kwitansi. 
              // Jika ingin simulasi manual, bisa diubah ke /tagihan
              Navigator.pushNamed(context, '/kwitansi');
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
            color: Colors.black.withOpacity(0.05),
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
