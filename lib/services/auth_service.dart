// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/auth_model.dart';
import '../network/network.dart';
import 'token_interceptor.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _namaKey = 'nama';
  static const String _bprIdKey = 'bpr_id';

  // ── LOGIN ──────────────────────────────────────────────────────────────────
  Future<LoginResponse> login({required String bprId, required String userId, required String password}) async {
    final response = await http.post(
      Uri.parse(NetworkUrl.login()),
      headers: NetworkUrl.jsonHeaders(),
      body: jsonEncode({'bpr_id': bprId, 'user_id': userId.toUpperCase(), 'password': password}),
    );

    final result = LoginResponse.fromJson(jsonDecode(response.body));

    if (result.isSuccess && result.token != null) {
      final resolvedUserId = result.user?.userId ?? userId.toUpperCase();
      final resolvedNama = result.user?.nama ?? userId.toUpperCase();

      await _saveSession(token: result.token!, userId: resolvedUserId, nama: resolvedNama, bprId: bprId);

      try {
        final fcmToken = await getFcmToken();

        if (fcmToken.isNotEmpty) {
          await updateFcmToken(bprId: bprId, userId: resolvedUserId, fcmToken: fcmToken);
        }
      } catch (_) {
        // Login tetap sukses walaupun update FCM token gagal.
      }
    }

    return result;
  }

  Future<String> getFcmToken() async {
    try {
      final messaging = FirebaseMessaging.instance;

      await messaging.requestPermission(alert: true, badge: true, sound: true);

      final token = await messaging.getToken();
      return token ?? '';
    } catch (e) {
      return '';
    }
  }

  Future<AuthResponse> updateFcmToken({required String bprId, required String userId, required String fcmToken}) async {
    final response = await http.post(
      Uri.parse(NetworkUrl.updateFcmToken()),
      headers: NetworkUrl.jsonHeaders(),
      body: jsonEncode({'bpr_id': bprId, 'user_id': userId.toUpperCase(), 'fcm_token': fcmToken}),
    );

    return AuthResponse.fromJson(jsonDecode(response.body));
  }

  // ── LOGOUT ─────────────────────────────────────────────────────────────────
  Future<AuthResponse> logout({required String bprId, required String userId}) async {
    try {
      final response = await TokenInterceptor.post(Uri.parse(NetworkUrl.logout()), body: jsonEncode({'bpr_id': bprId, 'user_id': userId}));

      final result = AuthResponse.fromJson(jsonDecode(response.body));
      await clearSession();
      return result;
    } catch (_) {
      await clearSession();
      return const AuthResponse(code: '000', status: 'success', message: 'Logout berhasil');
    }
  }

  // ── GANTI PASSWORD ─────────────────────────────────────────────────────────
  Future<AuthResponse> changePassword({
    required String bprId,
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    final response = await TokenInterceptor.post(
      Uri.parse(NetworkUrl.changePassword()),
      body: jsonEncode({'bpr_id': bprId, 'user_id': userId, 'old_password': oldPassword, 'new_password': newPassword}),
    );

    return AuthResponse.fromJson(jsonDecode(response.body));
  }

  // ── SESSION ────────────────────────────────────────────────────────────────
  Future<void> _saveSession({required String token, required String userId, required String nama, required String bprId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_namaKey, nama);
    await prefs.setString(_bprIdKey, bprId);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_namaKey);
    await prefs.remove(_bprIdKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, String>> getSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString(_tokenKey) ?? '',
      'user_id': prefs.getString(_userIdKey) ?? '',
      'nama': prefs.getString(_namaKey) ?? '',
      'bpr_id': prefs.getString(_bprIdKey) ?? '',
    };
  }
}
