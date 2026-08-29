import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/models/sensor_data.dart';
import '../shared/providers/alerts_provider.dart';
import '../shared/providers/sensor_provider.dart';

class SocketService {
  // Singleton pattern
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  ProviderContainer? _container;

  // =========================================================
  // CONNEXION AU BACKEND
  // =========================================================

  void connect(ProviderContainer container) {
    _container = container;
    print('Tentative de connexion au backend...');

    _socket = IO.io(
      'http://10.0.2.2:5000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(2000)
          .build(),
    );

    // =======================================================
    // CONNEXION
    // =======================================================

    _socket!.onConnect((_) {
      print('');
      print('========================================');
      print('Socket.IO connecté au backend');
      print('Socket ID : ${_socket!.id}');
      print('========================================');
    });

    // =======================================================
    // DONNÉES DU LIT
    // =======================================================

    _socket!.on('calinlink:data', (data) {
      print('');
      print('========================================');
      print('DONNÉES CÂLINLINK REÇUES DANS FLUTTER');
      print('========================================');

      print('Données complètes :');
      print(data);

      if (data is Map) {
        final Map<String, dynamic> dataMap = Map<String, dynamic>.from(data);
        final sensorData = SensorData.fromJson(dataMap);

        // Mettre à jour l'état Riverpod
        _container?.read(sensorProvider.notifier).updateData(sensorData);

        print('');
        print('--- INFORMATIONS DU LIT (PARSÉES) ---');
        print('Device ID : ${sensorData.deviceId}');
        print('Température : ${sensorData.temperature} °C');
        print('Humidité : ${sensorData.humidity} %');
        print('Mouvement : ${sensorData.movement}');
        print('Présence bébé : ${sensorData.babyPresent}');
        print('Zone principale : ${sensorData.zonePrincipale}');
        print('Pression totale : ${sensorData.pressionTotale}');
        print('Nombre de zones actives : ${sensorData.nombreZonesActives}');
        print('Zones actives : ${sensorData.zonesActives}');
        print('Ventilateur actif : ${sensorData.ventilateurActif}');
        print('Pleurs simulés : ${sensorData.pleursSimules}');

        if (sensorData.pression != null) {
          print('');
          print('--- PRESSION PAR ZONE ---');
          sensorData.pression!.forEach((zone, pression) {
            print('$zone : $pression');
          });
        }
      }

      print('========================================');
    });

    // =======================================================
    // ALERTES
    // =======================================================

    _socket!.on('calinlink:alert', (data) {
      print('');
      print('========================================');
      print('ALERTE CÂLINLINK REÇUE DANS FLUTTER');
      print('========================================');

      print('Alerte brute :');
      print(data);

      String alertMessage = 'Alerte inconnue';
      int timestampVal = DateTime.now().millisecondsSinceEpoch;

      if (data is Map) {
        final mapData = Map<String, dynamic>.from(data);
        alertMessage = mapData['message'] as String? ?? 'Alerte inconnue';
        final ts = mapData['timestamp'];
        if (ts is int) {
          timestampVal = ts;
        }
      } else if (data is String) {
        alertMessage = data;
      }

      String title = 'Alerte Lit';
      String severity = 'warning';

      final msgLower = alertMessage.toLowerCase();
      if (msgLower.contains('mouvement') || msgLower.contains('bouge') || msgLower.contains('agite')) {
        title = 'Alerte Mouvement';
        severity = 'warning';
      } else if (msgLower.contains('température') || msgLower.contains('temperature') || msgLower.contains('trop elevee') || msgLower.contains('trop basse')) {
        title = 'Alerte Température';
        severity = msgLower.contains('trop') || msgLower.contains('danger') ? 'critical' : 'warning';
      } else if (msgLower.contains('pleurs') || msgLower.contains('bruit') || msgLower.contains('crie')) {
        title = 'Alerte Sonore';
        severity = 'critical';
      }

      DateTime alertTime = DateTime.now();
      if (timestampVal > 1000000000) {
        alertTime = DateTime.fromMillisecondsSinceEpoch(
            timestampVal.toString().length == 10 ? timestampVal * 1000 : timestampVal);
      }

      final alert = AlertModel(
        id: alertTime.millisecondsSinceEpoch.toString(),
        title: title,
        description: alertMessage,
        time: 'MAINTENANT',
        severity: severity,
        createdAt: alertTime,
      );

      // Mettre à jour l'état Riverpod pour ajouter l'alerte
      _container?.read(alertsProvider.notifier).addAlert(alert);

      print('Message : $alertMessage');
      print('Timestamp : $timestampVal');
      print('========================================');
    });

    // =======================================================
    // ERREUR CONNEXION
    // =======================================================

    _socket!.onConnectError((error) {
      print('');
      print('ERREUR CONNEXION SOCKET.IO');
      print(error);
    });

    // =======================================================
    // ERREUR SOCKET
    // =======================================================

    _socket!.onError((error) {
      print('');
      print('ERREUR SOCKET.IO');
      print(error);
    });

    // =======================================================
    // DÉCONNEXION
    // =======================================================

    _socket!.onDisconnect((_) {
      print('');
      print('========================================');
      print('Socket.IO déconnecté du backend');
      print('========================================');
    });

    // =======================================================
    // RECONNEXION
    // =======================================================

    _socket!.onReconnect((attempt) {
      print('Socket.IO reconnecté après $attempt tentative(s)');
    });
  }

  // =========================================================
  // DÉCONNEXION
  // =========================================================

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _container = null;

    print('SocketService arrêté');
  }

  // =========================================================
  // SOCKET
  // =========================================================

  IO.Socket? get socket => _socket;
}

// Provider Riverpod pour le service Socket.IO
final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService();
});