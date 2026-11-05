import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
        'email': email.trim(),
        'password': password,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
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
      throw Exception(data['message'] ?? 'Login gagal.');
    }
  }

  /// POST /api/auth/register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String role = 'USER',
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/register');
    final response = await http.post(
      url,
      headers: _headers(withAuth: false),
      body: jsonEncode({
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'role': role,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
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
      throw Exception(data['message'] ?? 'Registrasi gagal.');
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
    required int amount,
    String? residentName,
    String? unit,
    String bankName = 'BCA',
    String? senderAccount,
    String? notes,
  }) async {
    final url = Uri.parse('$baseUrl/api/payments/manual-transfer');
    final response = await http.post(
      url,
      headers: _headers(withAuth: true),
      body: jsonEncode({
        'amount': amount,
        'residentName': residentName ?? _currentUser?['name'] ?? 'Sabila Aulia',
        'unit': unit ?? 'Unit 1',
        'bankName': bankName,
        'senderAccount': senderAccount,
        'notes': notes,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Gagal mengirim konfirmasi transfer.');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GITA AI ASSISTANT CHATBOT
  // ═══════════════════════════════════════════════════════════════════════════

  /// POST /api/gita/chat
  Future<String> chatWithGita(String message) async {
    final url = Uri.parse('$baseUrl/api/gita/chat');
    final response = await http.post(
      url,
      headers: _headers(withAuth: false),
      body: jsonEncode({
        'message': message,
        'userName': _currentUser?['name'] ?? 'Sabila',
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['data']?['reply'] as String?) ?? 'Terima kasih telah menghubungi Gita.';
    } else {
      throw Exception('Gita sedang offline sejenak.');
    }
  }
}
