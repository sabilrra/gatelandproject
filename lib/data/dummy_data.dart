/// Model dan penyimpanan data dummy untuk autentikasi GateLand.
///
/// Menyimpan daftar pengguna terdaftar dan menyediakan
/// fungsi login serta registrasi sederhana.

class UserData {
  final String nama;
  final String email;
  final String noWhatsapp;
  final String alamat;
  final String password;

  UserData({
    required this.nama,
    required this.email,
    required this.noWhatsapp,
    required this.alamat,
    required this.password,
  });
}

class DummyDataStore {
  // Singleton pattern agar data tetap konsisten di seluruh aplikasi
  static final DummyDataStore _instance = DummyDataStore._internal();
  factory DummyDataStore() => _instance;
  DummyDataStore._internal();

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
}
