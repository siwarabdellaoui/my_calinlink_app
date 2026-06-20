import 'dart:io';

class Env {
  // Use 10.0.2.2 for Android Emulator connecting to local server
  // Use localhost or 127.0.0.1 for iOS Simulator
  static String get apiUrl {
    // Basic platform check
    if (Platform.isAndroid) {
      return 'http://192.168.1.17:5000/api';
    } else {
      return 'http://127.0.0.1:5000/api';
    }
  }

  // Clé pour le Shared Preferences
  static const String tokenKey = 'jwt_token';
}
