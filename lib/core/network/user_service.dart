import 'package:dio/dio.dart';
import 'api_client.dart';

class UserService {
  static final Dio _dio = ApiClient.client;

  // Récupérer le Profil
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/users/profile');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Mettre à jour le Profil
  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put('/users/profile', data: data);
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Demander changement de mot de passe
  static Future<void> requestPasswordChange(String oldPassword) async {
    try {
      await _dio.post('/users/change-password-request', data: {
        'oldPassword': oldPassword,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Vérifier OTP et appliquer nouveau mot de passe
  static Future<void> verifyPasswordChange(
    String code,
    String newPassword,
  ) async {
    try {
      await _dio.post('/users/change-password-verify', data: {
        'code': code,
        'newPassword': newPassword,
      });
    } catch (e) {
      rethrow;
    }
  }
}
