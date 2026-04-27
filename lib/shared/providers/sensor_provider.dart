import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sensor_data.dart';

// État initial des capteurs
final initialSensorState = SensorData(
  temperature: 21.0,
  humidity: 55.0,
  movement: 'calme',
  babyPresent: true,
  timestamp: DateTime.now(),
);

class SensorNotifier extends StateNotifier<SensorData> {
  Timer? _timer;

  SensorNotifier() : super(initialSensorState) {
    _startSimulatedFluctuations();
  }

  void _startSimulatedFluctuations() {
    // Simule un changement de température et d'humidité toutes les 5 secondes
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final now = DateTime.now();

      // Petite variation simulée
      final double tempChange = (now.second % 3 == 0) ? 0.1 : -0.1;
      final double humChange = (now.second % 2 == 0) ? 1.0 : -1.0;

      double newTemp = state.temperature + tempChange;
      if (newTemp > 25) newTemp = 21.0;
      if (newTemp < 18) newTemp = 21.0;

      double newHum = state.humidity + humChange;
      if (newHum > 70) newHum = 55.0;
      if (newHum < 40) newHum = 55.0;

      // Exemple simple de mouvement simulé
      String newMovement = state.movement;
      if (now.second % 15 == 0) {
        newMovement = 'agité';
      } else if (now.second % 10 == 0) {
        newMovement = 'endormi';
      } else {
        newMovement = 'calme';
      }

      state = state.copyWith(
        temperature: double.parse(newTemp.toStringAsFixed(1)),
        humidity: double.parse(newHum.toStringAsFixed(1)),
        movement: newMovement,
        babyPresent: true,
        timestamp: now,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Le Provider que l'interface va écouter
final sensorProvider = StateNotifierProvider<SensorNotifier, SensorData>((ref) {
  return SensorNotifier();
});
