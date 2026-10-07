import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/dummy_data.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Color _primaryColor = const Color(0xFF09095E);
  final Color _bgColor = const Color(0xFFFBFBFF);
  final Color _cardBorderColor = const Color(0xFFFFEBEB);

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = DummyDataStore().currentUser;
    final String firstName = (user != null && user.nama.isNotEmpty) ? user.nama.split(' ').first : 'Warga';

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      Icon(Icons.notifications_none_outlined, color: Colors.black87, size: 26),
                      const SizedBox(width: 16),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFFFFD1D1),
                        child: Icon(Icons.person, color: _primaryColor, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
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
                        style: TextStyle(fontSize: 13, color: Colors.black87),
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
              Container(
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
                          child: const Text(
                            'Agustus 2026',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBE4E4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.schedule, size: 12, color: _primaryColor),
                              const SizedBox(width: 4),
                              Text(
                                'Jatuh Tempo: 10 Agustus',
                                style: TextStyle(color: _primaryColor, fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'TOTAL TAGIHAN IURAN BULANAN',
                      style: TextStyle(color: _primaryColor.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'IPL, Kebersihan, Keamanan, & Kas RT',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Rp 175.000',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: _primaryColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Bayar Sekarang',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                  const Text(
                    'Lihat Semua',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B6BA5), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildAnnouncementCard(
                tag: 'Penting',
                tagColor: const Color(0xFFF6C8C8),
                tagTextColor: const Color(0xFFA02020),
                date: '16 Sep 2026',
                title: 'Perubahan Jadwal Pengangkutan Sampah',
                content: 'Pengangkutan sampah minggu ini akan dilakukan pada hari Jumat, 18 September. Mohon meletakkan tempat sampah di depan pagar sebelum pukul 07.00.',
                isImportant: true,
              ),
              const SizedBox(height: 16),
              _buildAnnouncementCard(
                tag: 'Info',
                tagColor: const Color(0xFFF9E4E4),
                tagTextColor: const Color(0xFFA02020),
                date: '14 Sep 2026',
                title: 'Gangguan Distribusi Air',
                content: 'Distribusi air akan mengalami gangguan sementara pada Senin, 21 September karena perawatan pompa tandon utama. Harap warga menyiapkan kebutuhan air sebelumnya.',
                isImportant: false,
              ),
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
                    location: 'Balai Warga RW 05',
                  ),
                  _buildAgendaCard(
                    icon: Icons.medical_services_outlined,
                    title: 'POSYANDU BALITA & LANSIA',
                    date: 'Selasa, 10 Ags 2026',
                    time: '08:30 WIB',
                    location: 'Pos RW 05',
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
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
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          selectedItemColor: _primaryColor,
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
    return Container(
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
    );
  }

  Widget _buildAgendaCard({
    required IconData icon,
    required String title,
    required String date,
    required String time,
    required String location,
  }) {
    return Container(
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
            child: Icon(icon, color: _primaryColor, size: 18),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
              height: 1.2,
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 10),
          _buildAgendaInfoRow(Icons.calendar_today_outlined, date),
          const SizedBox(height: 4),
          _buildAgendaInfoRow(Icons.access_time, time),
          const SizedBox(height: 4),
          _buildAgendaInfoRow(Icons.location_on_outlined, location),
        ],
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
}
