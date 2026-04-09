class SensorData {
  final double temperature;
  final double humidity;
  final String movement;   // 'calme', 'agité', 'endormi'
  final bool babyPresent;
  final DateTime timestamp;

  const SensorData({
    required this.temperature,
    required this.humidity,
    required this.movement,
    required this.babyPresent,
    required this.timestamp,
  });

  bool get isTemperatureNormal => temperature >= 18 && temperature <= 24;
  bool get isHumidityIdeal => humidity >= 40 && humidity <= 60;

  factory SensorData.fromJson(Map<String, dynamic> json) => SensorData(
    temperature: (json['temperature'] as num).toDouble(),
    humidity: (json['humidity'] as num).toDouble(),
    movement: json['movement'] as String,
    babyPresent: json['babyPresent'] as bool,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}