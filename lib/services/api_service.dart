import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String message;
  final Map<String, String> fieldErrors;
  final int statusCode;

  ApiException(
    this.message, {
    this.fieldErrors = const {},
    this.statusCode = 400,
  });

  @override
  String toString() => message;
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Menentukan Base URL secara otomatis:
  /// - Android Emulator: 10.0.2.2:3000 (menunjuk ke localhost Mac/PC)
  /// - iOS Simulator / Desktop / Web: localhost:3000
  static String get baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  static const String _keyToken = 'gateland_jwt_token';
  static const String _keyUser = 'gateland_user_data';

  String? _token;
  Map<String, dynamic>? _currentUser;

  String? get token => _token;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoggedIn => _token != null;

  /// Inisialisasi token dari SharedPreferences saat aplikasi start
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_keyToken);
    final userJson = prefs.getString(_keyUser);
    if (userJson != null) {
      try {
        _currentUser = jsonDecode(userJson) as Map<String, dynamic>;
      } catch (_) {
        _currentUser = null;
      }
    }
  }

  Map<String, String> _headers({bool withAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  ApiException _buildApiException(http.Response response, String fallbackMessage) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final String msg = (decoded['message'] ?? fallbackMessage).toString();
        final Map<String, String> fieldErrors = {};
        final errorsList = decoded['errors'];
        if (errorsList is List) {
          for (final item in errorsList) {
            if (item is Map<String, dynamic>) {
              final field = (item['field'] ?? '').toString().trim();
              final errMsg = (item['message'] ?? '').toString().trim();
              if (field.isNotEmpty && errMsg.isNotEmpty) {
                if (fieldErrors.containsKey(field)) {
                  fieldErrors[field] = '${fieldErrors[field]}\n$errMsg';
                } else {
                  fieldErrors[field] = errMsg;
                }
              }
            }
          }
        }
        return ApiException(msg, fieldErrors: fieldErrors, statusCode: response.statusCode);
      }
    } catch (_) {}
    return ApiException(fallbackMessage, statusCode: response.statusCode);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTHENTICATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// POST /api/auth/login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    final response = await http.post(
      url,
      headers: _headers(withAuth: false),
      body: jsonEncode({
        'email': email.trim().toLowerCase(),
        'password': password,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final resData = data['data'] as Map<String, dynamic>;
      _token = resData['token'] as String?;
      _currentUser = resData['user'] as Map<String, dynamic>?;

      final prefs = await SharedPreferences.getInstance();
      if (_token != null) await prefs.setString(_keyToken, _token!);
      if (_currentUser != null) {
        await prefs.setString(_keyUser, jsonEncode(_currentUser));
      }

      return data;
    } else {
      throw _buildApiException(response, 'Login gagal.');
    }
  }

  /// POST /api/auth/register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? whatsapp,
    String? address,
    String role = 'USER',
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/register');
    final Map<String, dynamic> body = {
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
      'role': role,
    };
    if (whatsapp != null && whatsapp.trim().isNotEmpty) {
      body['whatsapp'] = whatsapp.trim();
    }
    if (address != null && address.trim().isNotEmpty) {
      body['address'] = address.trim();
    }

    final response = await http.post(
      url,
      headers: _headers(withAuth: false),
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final resData = data['data'] as Map<String, dynamic>?;
      if (resData != null) {
        _token = resData['token'] as String?;
        _currentUser = resData['user'] as Map<String, dynamic>?;

        final prefs = await SharedPreferences.getInstance();
        if (_token != null) await prefs.setString(_keyToken, _token!);
        if (_currentUser != null) {
          await prefs.setString(_keyUser, jsonEncode(_currentUser));
        }
      }
      return data;
    } else {
      throw _buildApiException(response, 'Registrasi gagal.');
    }
  }

  /// PUT /api/auth/me — Update profil user yang sedang login
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> payload) async {
    final url = Uri.parse('$baseUrl/api/auth/me');
    final response = await http.put(
      url,
      headers: _headers(withAuth: true),
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final updatedUser = data['data'] as Map<String, dynamic>?;
      if (updatedUser != null) {
        _currentUser = updatedUser;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyUser, jsonEncode(updatedUser));
      }
      return data;
    } else {
      throw _buildApiException(response, 'Gagal menyimpan perubahan profil.');
    }
  }

  /// GET /api/auth/me
  Future<Map<String, dynamic>?> getMe() async {
    if (_token == null) return null;
    final url = Uri.parse('$baseUrl/api/auth/me');
    final response = await http.get(url, headers: _headers(withAuth: true));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _currentUser = data['data'] as Map<String, dynamic>?;
      if (_currentUser != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyUser, jsonEncode(_currentUser));
      }
      return _currentUser;
    }
    return null;
  }

  /// Logout
  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ANNOUNCEMENTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// GET /api/announcements
  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    final url = Uri.parse('$baseUrl/api/announcements');
    final response = await http.get(url, headers: _headers(withAuth: false));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>? ?? [];
      return list.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PAYMENTS & BILLS
  // ═══════════════════════════════════════════════════════════════════════════

  /// GET /api/payments/my-bill
  Future<Map<String, dynamic>?> getMyBill() async {
    final url = Uri.parse('$baseUrl/api/payments/my-bill');
    final response = await http.get(url, headers: _headers(withAuth: true));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['data'] as Map<String, dynamic>?;
    }
    return null;
  }

  /// POST /api/payments/create-qris
  Future<Map<String, dynamic>> createQrisTransaction({
    int? billId,
    int? amount,
    String? residentName,
    String? unit,
  }) async {
    final url = Uri.parse('$baseUrl/api/payments/create-qris');
    final Map<String, dynamic> body = {};
    if (billId != null) body['billId'] = billId;
    if (amount != null) body['amount'] = amount;
    if (residentName != null) body['residentName'] = residentName;
    if (unit != null) body['unit'] = unit;

    final response = await http.post(
      url,
      headers: _headers(withAuth: true),
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data['data'] as Map<String, dynamic>;
    } else {
      throw Exception(data['message'] ?? 'Gagal membuat QRIS.');
    }
  }

  /// POST /api/payments/simulate-pay
  Future<Map<String, dynamic>> simulatePayQris([String? transactionId]) async {
    final url = Uri.parse('$baseUrl/api/payments/simulate-pay');
    final response = await http.post(
      url,
      headers: _headers(withAuth: false),
      body: jsonEncode({
        'transactionId': transactionId ?? 'TRX-QRIS-DEMO',
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Simulasi pembayaran gagal.');
    }
  }

  /// GET /api/payments/status/:id
  Future<Map<String, dynamic>> checkPaymentStatus(String transactionId) async {
    final url = Uri.parse('$baseUrl/api/payments/status/$transactionId');
    final response = await http.get(url, headers: _headers(withAuth: false));

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Gagal mengecek status pembayaran.');
    }
  }

  /// GET /api/payments/my-history
  Future<List<Map<String, dynamic>>> getMyPaymentHistory() async {
    final url = Uri.parse('$baseUrl/api/payments/my-history');
    final response = await http.get(url, headers: _headers(withAuth: true));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>? ?? [];
      return list.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// POST /api/payments/manual-transfer
  Future<Map<String, dynamic>> submitManualTransfer({
    int? billId,
    required int amount,
    String? residentName,
    String? unit,
    String bankName = 'BCA',
    String? senderAccount,
    String? notes,
  }) async {
    final url = Uri.parse('$baseUrl/api/payments/manual-transfer');
    final Map<String, dynamic> body = {
      'amount': amount,
      'residentName': residentName ?? _currentUser?['name'] ?? 'Warga',
      'unit': unit ?? _currentUser?['address'] ?? '-',
      'bankName': bankName,
      'senderAccount': senderAccount,
      'notes': notes,
    };
    if (billId != null) {
      body['billId'] = billId;
    }
    final response = await http.post(
      url,
      headers: _headers(withAuth: true),
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw _buildApiException(response, 'Gagal mengirim konfirmasi transfer.');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // OTP — LUPA KATA SANDI
  // ═══════════════════════════════════════════════════════════════════════════

  /// POST /api/otp/send — Kirim kode OTP via Email atau WhatsApp (Fonnte)
  Future<Map<String, dynamic>> sendOtp(
    String target, {
    String method = 'email',
  }) async {
    final url = Uri.parse('$baseUrl/api/otp/send');
    final response = await http.post(
      url,
      headers: _headers(withAuth: false),
      body: jsonEncode({
        'method': method,
        'target': target.trim(),
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Gagal mengirim kode OTP.');
    }
  }

  /// Alias untuk kirim OTP via Email
  Future<Map<String, dynamic>> sendOtpEmail(String email) =>
      sendOtp(email, method: 'email');

  /// POST /api/otp/verify — Verifikasi OTP dan reset kata sandi
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final url = Uri.parse('$baseUrl/api/otp/verify');
    final response = await http.post(
      url,
      headers: _headers(withAuth: false),
      body: jsonEncode({
        'email': email.trim().toLowerCase(),
        'code': code.trim(),
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } else {
      throw _buildApiException(response, 'Gagal memverifikasi OTP.');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GITA AI ASSISTANT CHATBOT
  // ═══════════════════════════════════════════════════════════════════════════

  /// POST /api/gita/chat
  Future<String> chatWithGita(
    String message, {
    List<Map<String, String>> history = const [],
  }) async {
    final url = Uri.parse('$baseUrl/api/gita/chat');
    final response = await http
        .post(
          url,
          headers: _headers(withAuth: true),
          body: jsonEncode({
            'message': message,
            'userName': _currentUser?['name'] ?? 'Warga',
            'history': history,
          }),
        )
        .timeout(const Duration(seconds: 25));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['data']?['reply'] as String?) ?? 'Terima kasih telah menghubungi Gita.';
    } else {
      throw Exception('Gita sedang offline sejenak.');
    }
  }
}
