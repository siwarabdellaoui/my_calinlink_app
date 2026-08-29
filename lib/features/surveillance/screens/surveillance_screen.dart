import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/providers/sensor_provider.dart';
import '../../../shared/models/sensor_data.dart';

export 'surveillance_screen.dart';

class SurveillanceScreen extends ConsumerStatefulWidget {
  const SurveillanceScreen({super.key});

  @override
  ConsumerState<SurveillanceScreen> createState() => _SurveillanceScreenState();
}

class _SurveillanceScreenState extends ConsumerState<SurveillanceScreen> {
  String _getTempStatus(double temperature) {
    if (temperature >= 18 && temperature <= 24) return 'NORMAL';
    if (temperature > 24) return 'ÉLEVÉ';
    return 'BAS';
  }

  Color _getTempStatusColor(double temperature) {
    if (temperature >= 18 && temperature <= 24) return AppColors.success;
    return AppColors.error;
  }

  String _getHumidityStatus(double humidity) {
    if (humidity >= 40 && humidity <= 60) return 'IDÉAL';
    if (humidity > 60) return 'HUMIDE';
    return 'SEC';
  }

  Color _getHumidityStatusColor(double humidity) {
    if (humidity >= 40 && humidity <= 60) return AppColors.success;
    return AppColors.warning;
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final sensorData = ref.watch(sensorProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Header
              _buildHeader(),

              const SizedBox(height: 24),

              // Titre + statut
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Surveillance\nen direct',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                        height: 1.2,
                      ),
                    ),
                  ),
                  // Badge système actif
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'ACTIF',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              const Text(
                'SYSTÈME EN DIRECT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // Carte Température
              _buildTemperatureCard(sensorData),

              const SizedBox(height: 16),

              // Carte Humidité
              _buildHumidityCard(sensorData),

              const SizedBox(height: 16),

              // Carte Mouvement
              _buildMovementCard(sensorData),

              const SizedBox(height: 16),

              // Carte Présence
              _buildPresenceCard(sensorData),

              const SizedBox(height: 16),

              // Carte Matelas de Pression (IoT)
              _buildPressureMatCard(sensorData),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Header
  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.push(AppRoutes.profile),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'CâlinLink',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            // Force refresh simulated state (or notify interface)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mise à jour de l\'interface en direct'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(
              Icons.refresh_rounded,
              color: context.textSecondary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  // Carte Température
  Widget _buildTemperatureCard(SensorData sensorData) {
    final temp = sensorData.temperature;
    final status = _getTempStatus(temp);
    final statusColor = _getTempStatusColor(temp);
    final normalizedTemp = ((temp - 18) / (28 - 18)).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Température',
                style: TextStyle(
                  fontSize: 14,
                  color: context.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${temp.toStringAsFixed(1)}°C',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(8, (i) {
              final active = i <= (normalizedTemp * 7).round();
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: active ? 20 : 14,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Carte Humidité
  Widget _buildHumidityCard(SensorData sensorData) {
    final hum = sensorData.humidity;
    final status = _getHumidityStatus(hum);
    final statusColor = _getHumidityStatusColor(hum);
    final progress = (hum / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Humidité',
                style: TextStyle(
                  fontSize: 14,
                  color: context.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${hum.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.primary.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SEC',
                style: TextStyle(
                  fontSize: 10,
                  color: context.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'HUMIDE',
                style: TextStyle(
                  fontSize: 10,
                  color: context.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Carte Mouvement
  Widget _buildMovementCard(SensorData sensorData) {
    final movement = sensorData.movement;
    Color movementColor;
    IconData movementIcon;

    switch (movement.toLowerCase()) {
      case 'agité':
      case 'actif':
        movementColor = AppColors.error;
        movementIcon = Icons.directions_run_rounded;
        break;
      case 'léger':
      case 'moyen':
        movementColor = AppColors.warning;
        movementIcon = Icons.directions_walk_rounded;
        break;
      default:
        movementColor = AppColors.success;
        movementIcon = Icons.self_improvement_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mouvements',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  movement.toLowerCase() == 'agité' ? 'Présent' : 'Vide',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: movementColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              movementIcon,
              color: movementColor,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  // Carte Présence
  Widget _buildPresenceCard(SensorData sensorData) {
    final isPresent = sensorData.babyPresent;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Présence',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isPresent ? 'Présent' : 'Vide',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isPresent
                  ? AppColors.primary.withOpacity(0.12)
                  : Colors.grey.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isPresent ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isPresent ? AppColors.primary : Colors.grey,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  // Carte Matelas de Pression (IoT réel)
  Widget _buildPressureMatCard(SensorData sensorData) {
    final pressure = sensorData.pression ?? {
      'zone_1': 0,
      'zone_2': 0,
      'zone_3': 0,
      'zone_4': 0,
    };

    final zone1 = pressure['zone_1'] ?? 0;
    final zone2 = pressure['zone_2'] ?? 0;
    final zone3 = pressure['zone_3'] ?? 0;
    final zone4 = pressure['zone_4'] ?? 0;
    final zonePrincipale = sensorData.zonePrincipale ?? 'Aucune';
    final pressionTotale = sensorData.pressionTotale ?? (zone1 + zone2 + zone3 + zone4);
    final activeZones = sensorData.zonesActives ?? [];

    Widget buildZoneBox(String zoneName, int pressureValue) {
      final isPrincipal = zonePrincipale == zoneName;
      final isActive = activeZones.contains(zoneName) || pressureValue > 500;

      // Intensité de couleur basée sur la pression
      final double intensity = (pressureValue / 4000).clamp(0.05, 0.9);
      final boxColor = isActive
          ? AppColors.primary.withOpacity(intensity)
          : Colors.grey.withOpacity(0.05);

      return Expanded(
        child: Container(
          height: 100,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: boxColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPrincipal
                  ? AppColors.primary
                  : (isActive ? AppColors.primary.withOpacity(0.5) : Colors.grey.shade300),
              width: isPrincipal ? 3.0 : 1.0,
            ),
          ),
          child: Stack(
            children: [
              if (isPrincipal)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'MAIN',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      zoneName.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isActive ? (intensity > 0.4 ? Colors.white : AppColors.primaryDark) : context.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$pressureValue g',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isActive ? (intensity > 0.4 ? Colors.white : AppColors.primaryDark) : context.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Matelas de Pression',
                style: TextStyle(
                  fontSize: 16,
                  color: context.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${sensorData.nombreZonesActives ?? activeZones.length} ACTIVE(S)',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Répartition du poids et position de bébé',
            style: TextStyle(
              fontSize: 12,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Row(
                children: [
                  buildZoneBox('zone_1', zone1),
                  buildZoneBox('zone_2', zone2),
                ],
              ),
              Row(
                children: [
                  buildZoneBox('zone_3', zone3),
                  buildZoneBox('zone_4', zone4),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pression Totale',
                    style: TextStyle(fontSize: 12, color: context.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$pressionTotale g',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Zone Principale',
                    style: TextStyle(fontSize: 12, color: context.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    zonePrincipale.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
