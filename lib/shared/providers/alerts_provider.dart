import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlertModel {
  final String id;
  final String title;
  final String description;
  final String time;
  final String severity; // 'critical', 'warning', 'info', 'success'
  final DateTime createdAt;

  AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.severity,
    required this.createdAt,
  });
}

class AlertsNotifier extends StateNotifier<List<AlertModel>> {
  AlertsNotifier() : super([]) {
    _loadInitialAlerts();
    _startSimulatingAlerts();
  }

  void _loadInitialAlerts() {
    state = [
      AlertModel(
        id: '1',
        title: 'Température idéale',
        description:
            'La température de la chambre est configurée à une valeur confortable.',
        time: 'IL Y A 2 HEURES',
        severity: 'success',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AlertModel(
        id: '2',
        title: 'Mouvement détecté',
        description: 'Bébé s\'agite dans son berceau.',
        time: 'IL Y A 1 HEURE',
        severity: 'warning',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  void _startSimulatingAlerts() {
    // Adds a fake critical alert every 30 seconds for demonstration
    Timer.periodic(const Duration(seconds: 30), (timer) {
      final newAlert = AlertModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Bruit détecté',
        description: 'Bébé commence à pleurer ou fait du bruit.',
        time: 'MAINTENANT',
        severity: 'critical',
        createdAt: DateTime.now(),
      );

      // Update state
      state = [newAlert, ...state];
    });
  }

  void clearAlert(String id) {
    state = state.where((alert) => alert.id != id).toList();
  }
}

final alertsProvider =
    StateNotifierProvider<AlertsNotifier, List<AlertModel>>((ref) {
  return AlertsNotifier();
});
