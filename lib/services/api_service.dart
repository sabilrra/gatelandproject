import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Catatan:
  // - Android Emulator: 10.0.2.2:3000
  // - iOS Simulator / macOS / Web: localhost:3000
  // - Real Device Android/iOS: IP Lokal Komputer (misal 192.168.1.x:3000)
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  static const String tokenKey = 'gateland_jwt_token';

  // ─── Token Management ────────────────────────────────────
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  static Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (withAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // ─── AUTH APIS ───────────────────────────────────────────
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: await _headers(withAuth: false),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200 && body['status'] == 'success') {
        final token = body['data']['token'];
        if (token != null) {
          await saveToken(token);
        }
      }
      return body;
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Gagal terhubung ke backend: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: await _headers(withAuth: false),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Gagal terhubung ke backend: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/me'),
        headers: await _headers(withAuth: true),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Gagal mengambil data user: $e',
      };
    }
  }

  // ─── GATES APIS ──────────────────────────────────────────
  static Future<Map<String, dynamic>> getGates() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/gates'),
        headers: await _headers(withAuth: true),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Gagal mengambil data gerbang: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> triggerGateAction(int gateId, String action) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/gates/$gateId/action'),
        headers: await _headers(withAuth: true),
        body: jsonEncode({'action': action}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Gagal menjalankan aksi gerbang: $e',
      };
    }
  }
}
