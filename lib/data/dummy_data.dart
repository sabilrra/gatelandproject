/// Model dan penyimpanan data dummy untuk autentikasi GateLand.
///
/// Menyimpan daftar pengguna terdaftar dan menyediakan
/// fungsi login serta registrasi sederhana.

class UserData {
  String nama;
  String email;
  String noWhatsapp;
  String alamat;
  String password;

  UserData({
    required this.nama,
    required this.email,
    required this.noWhatsapp,
    required this.alamat,
    required this.password,
  });
}

class UserProfile {
  String nik;
  String ttl;
  String statusKependudukan;
  String jumlahKeluarga;
  String kontakDarurat;
  String namaKontakDarurat;
  String unit;
  String cluster;
  String wilayahRW;
  String statusKepemilikan;
  String dayaListrik;
  String kendaraan;
  String kendaraanTambahan;
  bool notifikasiTagihan;
  bool pengingatWA;
  String statusPenghuni; // 'Pemilik Rumah' atau 'Penyewa / Kontrak'
  String fotoUrl;

  UserProfile({
    this.nik = '3271 0454 0588 0004',
    this.ttl = 'Bandung, 14 Mei 1988',
    this.statusKependudukan = 'Warga Tetap',
    this.jumlahKeluarga = '4 Jiwa (2 Dewasa, 2 Anak)',
    this.kontakDarurat = '0812-9876-5432',
    this.namaKontakDarurat = 'Budi Santoso (Suami)',
    this.unit = 'Unit 1',
    this.cluster = 'Cluster Anggrek, Blok B2 No. 14',
    this.wilayahRW = 'RT 04 / RW 08, GateLand',
    this.statusKepemilikan = 'Pemilik Rumah (SHM)',
    this.dayaListrik = 'PLN 3.500 VA • PDAM Tirta',
    this.kendaraan = '1 Mobil (B 1234 DT)',
    this.kendaraanTambahan = '2 Sepeda Motor (Stiker Aktif)',
    this.notifikasiTagihan = true,
    this.pengingatWA = true,
    this.statusPenghuni = 'Pemilik Rumah',
    this.fotoUrl = 'assets/profile_avatar.jpg',
  });
}

class DummyDataStore {
  // Singleton pattern agar data tetap konsisten di seluruh aplikasi
  static final DummyDataStore _instance = DummyDataStore._internal();
  factory DummyDataStore() => _instance;
  DummyDataStore._internal();

  // Profile data
  final UserProfile profile = UserProfile();

  // Daftar user dummy yang sudah terdaftar
  final List<UserData> _users = [
    UserData(
      nama: 'Budi Santoso',
      email: 'budi@gateland.com',
      noWhatsapp: '081234567890',
      alamat: 'Blok B4 No. 12',
      password: 'budi1234',
    ),
    UserData(
      nama: 'Siti Rahmawati',
      email: 'siti@gateland.com',
      noWhatsapp: '081298765432',
      alamat: 'Blok A2 No. 5',
      password: 'siti1234',
    ),
    UserData(
      nama: 'Admin GateLand',
      email: 'admin@gateland.com',
      noWhatsapp: '08110001111',
      alamat: 'Blok C1 No. 1',
      password: 'admin123',
    ),
    UserData(
      nama: 'Sabila Raulia',
      email: 'sabilarraulia@gmail.com',
      noWhatsapp: '081200001527',
      alamat: 'Blok D3 No. 7',
      password: 'Sabil1527',
    ),
  ];

  List<UserData> get users => List.unmodifiable(_users);

  /// Login: cek email dan password di daftar user.
  /// Mengembalikan [UserData] jika cocok, null jika tidak.
  UserData? login(String email, String password) {
    try {
      return _users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase() && u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  /// Register: tambahkan user baru ke daftar.
  /// Mengembalikan `true` jika berhasil, `false` jika email sudah terdaftar.
  bool register(UserData newUser) {
    final emailExists = _users.any(
      (u) => u.email.toLowerCase() == newUser.email.toLowerCase(),
    );
    if (emailExists) return false;

    _users.add(newUser);
    return true;
  }

  // Menyimpan user yang sedang login (session sederhana)
  UserData? currentUser;

  UserData get activeUser {
    if (currentUser != null) return currentUser!;
    return UserData(
      nama: 'Azizah Pratama',
      email: 'azizah.putri@gateland.id',
      noWhatsapp: '0812-3456-7890',
      alamat: 'Cluster Anggrek, Blok B2 No. 14',
      password: 'password123',
    );
  }
}
