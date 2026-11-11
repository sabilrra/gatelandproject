// Model dan penyimpanan data dummy untuk autentikasi GateLand.
//
// Menyimpan daftar pengguna terdaftar dan menyediakan
// fungsi login serta registrasi sederhana.

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
    this.nik = '',
    this.ttl = '',
    this.statusKependudukan = '',
    this.jumlahKeluarga = '',
    this.kontakDarurat = '',
    this.namaKontakDarurat = '',
    this.unit = '',
    this.cluster = '',
    this.wilayahRW = '',
    this.statusKepemilikan = '',
    this.dayaListrik = '',
    this.kendaraan = '',
    this.kendaraanTambahan = '',
    this.notifikasiTagihan = true,
    this.pengingatWA = false,
    this.statusPenghuni = '',
    this.fotoUrl = '',
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

  /// Sinkronkan session lokal dengan data user asli dari backend
  void syncFromBackendUser(Map<String, dynamic> userData, {String? password}) {
    final String name = (userData['name'] ?? 'Warga GateLand').toString();
    final String email = (userData['email'] ?? '').toString();
    final String rawWa = (userData['whatsapp'] ?? '').toString().trim();
    final String formattedWa = rawWa.isEmpty
        ? '-'
        : (rawWa.startsWith('+') ? rawWa : '+$rawWa');
    final String rawAddress = (userData['address'] ?? '').toString().trim();
    final String address = rawAddress.isNotEmpty ? rawAddress : '';

    currentUser = UserData(
      nama: name,
      email: email,
      noWhatsapp: formattedWa,
      alamat: address,
      password: password ?? currentUser?.password ?? '',
    );

    String readField(String key) => (userData[key] ?? '').toString().trim();

    profile.unit = rawAddress;
    profile.cluster = rawAddress.isNotEmpty ? 'Cluster GateLand, $rawAddress' : '';
    profile.nik = readField('nik');
    profile.ttl = readField('birthPlaceDate');
    profile.statusKependudukan = readField('residencyStatus');
    profile.jumlahKeluarga = readField('familyCount');
    profile.namaKontakDarurat = readField('emergencyContactName');
    profile.kontakDarurat = readField('emergencyContactPhone');
    profile.wilayahRW = readField('rwArea');
    profile.statusPenghuni = readField('occupancyStatus');
    profile.statusKepemilikan = readField('ownershipType');
    profile.dayaListrik = readField('powerWater');
    profile.kendaraan = readField('vehicles');
    profile.kendaraanTambahan = '';
    profile.fotoUrl = readField('photoUrl');
  }

  UserData get activeUser {
    if (currentUser != null) return currentUser!;
    return UserData(
      nama: 'Warga GateLand',
      email: 'warga@gmail.com',
      noWhatsapp: '-',
      alamat: 'Cluster GateLand',
      password: '',
    );
  }
}
