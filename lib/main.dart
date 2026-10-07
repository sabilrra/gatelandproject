import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/tagihan_screen.dart';
import 'screens/pembayaran_screen.dart';
import 'screens/konfirmasi_pembayaran_screen.dart';
import 'screens/kwitansi_screen.dart';
import 'screens/riwayat_screen.dart';
import 'screens/notifikasi_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profil_screen.dart';
import 'screens/ubah_kata_sandi_screen.dart';
import 'screens/lupa_kata_sandi_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GateLand App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF09095E)),
        fontFamily: GoogleFonts.inter().fontFamily,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
        '/tagihan': (context) => const TagihanScreen(),
        '/pembayaran': (context) => const PembayaranScreen(),
        '/konfirmasi_pembayaran': (context) => const KonfirmasiPembayaranScreen(),
        '/kwitansi': (context) => const KwitansiScreen(),
        '/riwayat': (context) => const RiwayatScreen(),
        '/notifikasi': (context) => const NotifikasiScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit-profil': (context) => const EditProfilScreen(),
        '/ubah-kata-sandi': (context) => const UbahKataSandiScreen(),
        '/lupa-kata-sandi': (context) => const LupaKataSandiScreen(),
      },
    );
  }
}
