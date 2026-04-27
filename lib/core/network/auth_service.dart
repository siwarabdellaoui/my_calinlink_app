import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/env.dart';
import 'api_client.dart';

class AuthService {
  static final Dio _dio = ApiClient.client;

  // S'inscrire
  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
      });

      // Stockage local du token après inscription
      if (response.data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(Env.tokenKey, response.data['token']);
      }

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Se connecter
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      // Stockage local du token
      if (response.data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(Env.tokenKey, response.data['token']);
      }

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Se déconnecter (Local)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Env.tokenKey);
  }

  // Déconnecter tous les appareils
  static Future<void> logoutAllDevices() async {
    try {
      await _dio.post('/users/logout-all');
      await logout(); // Clear local token
    } catch (e) {
      rethrow;
    }
  }

  // Vérifier si connecté
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(Env.tokenKey);
    return token != null && token.isNotEmpty;
  }

  // Mot de passe oublié
  static Future<void> forgotPassword(String email) async {
    try {
      await _dio.post('/auth/forgot-password', data: {'email': email});
    } catch (e) {
      rethrow;
    }
  }

  // Vérifier le code de réinitialisation
  static Future<String> verifyResetCode(String email, String code) async {
    try {
      final response = await _dio.post('/auth/verify-reset-code', data: {
        'email': email,
        'code': code,
      });
      return response.data['resetToken'];
    } catch (e) {
      rethrow;
    }
  }

  // Changer le mot de passe
  static Future<void> resetPassword(
      String resetToken, String newPassword) async {
    try {
      await _dio.post('/auth/reset-password', data: {
        'resetToken': resetToken,
        'newPassword': newPassword,
      });
    } catch (e) {
      rethrow;
    }
  }
}
