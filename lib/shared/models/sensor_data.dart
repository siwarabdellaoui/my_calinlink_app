class SensorData {
  final double temperature;
  final double humidity;
  final String movement; // 'calme', 'agité' (traduit depuis bool/int/string)
  final bool babyPresent;
  final DateTime timestamp;

  // Nouveaux champs IoT réels du lit intelligent
  final String? deviceId;
  final String? zonePrincipale;
  final Map<String, int>? pression;
  final bool? pleursSimules;
  final int? pressionTotale;
  final bool? ventilateurActif;
  final int? nombreZonesActives;
  final List<String>? zonesActives;

  const SensorData({
    required this.temperature,
    required this.humidity,
    required this.movement,
    required this.babyPresent,
    required this.timestamp,
    this.deviceId,
    this.zonePrincipale,
    this.pression,
    this.pleursSimules,
    this.pressionTotale,
    this.ventilateurActif,
    this.nombreZonesActives,
    this.zonesActives,
  });

  bool get isTemperatureNormal => temperature >= 18 && temperature <= 24;
  bool get isHumidityIdeal => humidity >= 40 && humidity <= 60;

  SensorData copyWith({
    double? temperature,
    double? humidity,
    String? movement,
    bool? babyPresent,
    DateTime? timestamp,
    String? deviceId,
    String? zonePrincipale,
    Map<String, int>? pression,
    bool? pleursSimules,
    int? pressionTotale,
    bool? ventilateurActif,
    int? nombreZonesActives,
    List<String>? zonesActives,
  }) {
    return SensorData(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      movement: movement ?? this.movement,
      babyPresent: babyPresent ?? this.babyPresent,
      timestamp: timestamp ?? this.timestamp,
      deviceId: deviceId ?? this.deviceId,
      zonePrincipale: zonePrincipale ?? this.zonePrincipale,
      pression: pression ?? this.pression,
      pleursSimules: pleursSimules ?? this.pleursSimules,
      pressionTotale: pressionTotale ?? this.pressionTotale,
      ventilateurActif: ventilateurActif ?? this.ventilateurActif,
      nombreZonesActives: nombreZonesActives ?? this.nombreZonesActives,
      zonesActives: zonesActives ?? this.zonesActives,
    );
  }

  factory SensorData.fromJson(Map<String, dynamic> json) {
    // Map des clés JSON (gère le JSON local simulé et le JSON réel du broker)
    final tempVal = json['temperature'] ?? json['temperature_ambient'] ?? 21.0;
    final humVal = json['humidite'] ?? json['humidity'] ?? 55.0;

    // Parsing robuste du mouvement (gère bool, int/num, string)
    String movVal = 'calme';
    final rawMov = json['mouvement'] ?? json['movement'];
    if (rawMov is bool) {
      movVal = rawMov ? 'agité' : 'calme';
    } else if (rawMov is num) {
      movVal = rawMov.toInt() != 0 ? 'agité' : 'calme';
    } else if (rawMov is String) {
      final s = rawMov.trim().toLowerCase();
      if (s == 'true' || s == '1' || s == 'agité' || s == 'agite' || s == 'actif' || s == 'présent' || s == 'present') {
        movVal = 'agité';
      } else {
        movVal = 'calme';
      }
    }

    // Parsing robuste de la présence (gère bool, int/num, string)
    bool presenceVal = true;
    final rawPresence = json['presence_bebe'] ?? json['babyPresent'];
    if (rawPresence is bool) {
      presenceVal = rawPresence;
    } else if (rawPresence is num) {
      presenceVal = rawPresence.toInt() != 0;
    } else if (rawPresence is String) {
      final s = rawPresence.trim().toLowerCase();
      presenceVal = (s == 'true' || s == '1' || s == 'présent' || s == 'present');
    }

    DateTime timeVal;
    final rawTime = json['timestamp'];
    if (rawTime is String) {
      timeVal = DateTime.tryParse(rawTime) ?? DateTime.now();
    } else if (rawTime is int) {
      if (rawTime > 1000000000) {
        timeVal = DateTime.fromMillisecondsSinceEpoch(
            rawTime.toString().length == 10 ? rawTime * 1000 : rawTime);
      } else {
        timeVal = DateTime.now();
      }
    } else {
      timeVal = DateTime.now();
    }

    // Récupération sécurisée de la pression des zones
    Map<String, int>? pressionMap;
    if (json['pression'] != null) {
      pressionMap = {};
      (json['pression'] as Map).forEach((k, v) {
        pressionMap![k.toString()] = (v as num).toInt();
      });
    }

    // Parsing robuste du ventilateur actif
    bool? ventActifVal;
    final rawVent = json['ventilateur_actif'];
    if (rawVent is bool) {
      ventActifVal = rawVent;
    } else if (rawVent is num) {
      ventActifVal = rawVent.toInt() != 0;
    }

    // Parsing robuste des pleurs simulés
    bool? pleursSimVal;
    final rawPleurs = json['pleurs_simules'];
    if (rawPleurs is bool) {
      pleursSimVal = rawPleurs;
    } else if (rawPleurs is num) {
      pleursSimVal = rawPleurs.toInt() != 0;
    }

    return SensorData(
      temperature: (tempVal as num).toDouble(),
      humidity: (humVal as num).toDouble(),
      movement: movVal,
      babyPresent: presenceVal,
      timestamp: timeVal,
      deviceId: json['device_id'] as String?,
      zonePrincipale: json['zone_principale'] as String?,
      pression: pressionMap,
      pleursSimules: pleursSimVal,
      pressionTotale: (json['pression_totale'] as num?)?.toInt(),
      ventilateurActif: ventActifVal,
      nombreZonesActives: (json['nombre_zones_actives'] as num?)?.toInt(),
      zonesActives: json['zones_actives'] != null
          ? List<String>.from(json['zones_actives'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'temperature': temperature,
        'humidity': humidity,
        'movement': movement,
        'babyPresent': babyPresent,
        'timestamp': timestamp.toIso8601String(),
        'device_id': deviceId,
        'zone_principale': zonePrincipale,
        'pression': pression,
        'pleurs_simules': pleursSimules,
        'pression_totale': pressionTotale,
        'ventilateur_actif': ventilateurActif,
        'nombre_zones_actives': nombreZonesActives,
        'zones_actives': zonesActives,
      };
}
