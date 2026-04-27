import 'package:dio/dio.dart';
import 'api_client.dart';

class DeviceService {
  static final Dio _dio = ApiClient.client;

  // Obtenir ses lits
  static Future<List<dynamic>> getMyDevices() async {
    try {
      final response = await _dio.get('/devices');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Modifier le statut du lit (Berceuse, Douce nuit)
  static Future<Map<String, dynamic>> updateDeviceStatus(String deviceId,
      {bool? isBerceuseEnabled, bool? isDouceNuitEnabled}) async {
    try {
      final Map<String, dynamic> data = {};
      if (isBerceuseEnabled != null)
        data['isBerceuseEnabled'] = isBerceuseEnabled;
      if (isDouceNuitEnabled != null)
        data['isDouceNuitEnabled'] = isDouceNuitEnabled;

      final response = await _dio.put('/devices/$deviceId/status', data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Link un device
  static Future<Map<String, dynamic>> linkDevice(String code) async {
    try {
      final response = await _dio.post('/devices',
          data: {'deviceId': code, 'name': 'Mon lit principal'});
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Partager l'accès
  static Future<Map<String, dynamic>> shareDevice(String email) async {
    try {
      final response =
          await _dio.post('/devices/share', data: {'email': email});
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
