import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
export 'surveillance_screen.dart';

class SurveillanceScreen extends StatefulWidget {
  const SurveillanceScreen({super.key});

  @override
  State<SurveillanceScreen> createState() => _SurveillanceScreenState();
}

class _SurveillanceScreenState extends State<SurveillanceScreen> {
  // Simulation données en temps réel
  double _temperature = 22.5;
  double _humidity = 55;
  String _movement = 'Calme';
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  void _startSimulation() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() {
          _temperature = 21.5 + (DateTime.now().second % 5);
          _humidity = 50 + (DateTime.now().second % 15).toDouble();
          final movements = ['Calme', 'Léger', 'Agité'];
          _movement = movements[DateTime.now().second % 3];
        });
      }
    }
  }

  String _getTempStatus() {
    if (_temperature >= 18 && _temperature <= 24) return 'NORMAL';
    if (_temperature > 24) return 'ÉLEVÉ';
    return 'BAS';
  }

  Color _getTempStatusColor() {
    if (_temperature >= 18 && _temperature <= 24) return AppColors.success;
    return AppColors.error;
  }

  String _getHumidityStatus() {
    if (_humidity >= 40 && _humidity <= 60) return 'IDÉAL';
    if (_humidity > 60) return 'HUMIDE';
    return 'SEC';
  }

  Color _getHumidityStatusColor() {
    if (_humidity >= 40 && _humidity <= 60) return AppColors.success;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
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
                        Text (
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

               Text(
                'SYSTÈME ACTIF',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // Carte Température
              _buildTemperatureCard(),

              const SizedBox(height: 16),

              // Carte Humidité
              _buildHumidityCard(),

              const SizedBox(height: 16),

              // Carte Mouvement
              _buildMovementCard(),

              const SizedBox(height: 16),

              // Carte Présence
              _buildPresenceCard(),

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
         Text(
          'CâlinLink',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => setState(() {}),
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
  Widget _buildTemperatureCard() {
    final status = _getTempStatus();
    final statusColor = _getTempStatusColor();
    final normalizedTemp = ((_temperature - 18) / (28 - 18)).clamp(0.0, 1.0);

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
          // Label + badge
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

          // Valeur
          Text(
            '${_temperature.toStringAsFixed(1)}°C',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          // Indicateur points
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
  Widget _buildHumidityCard() {
    final status = _getHumidityStatus();
    final statusColor = _getHumidityStatusColor();
    final progress = (_humidity / 100).clamp(0.0, 1.0);

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
          // Label + badge
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

          // Valeur
          Text(
            '${_humidity.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          // Barre de progression
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

          // Labels SEC / HUMIDE
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
  Widget _buildMovementCard() {
    Color movementColor;
    IconData movementIcon;

    switch (_movement) {
      case 'Agité':
        movementColor = AppColors.error;
        movementIcon = Icons.directions_run_rounded;
        break;
      case 'Léger':
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
          // Infos
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
                  _movement,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Icône mouvement
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
  Widget _buildPresenceCard() {
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
          // Infos
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
                SizedBox(height: 8),
                Text(
                  'Bébé présent',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Icône cœur
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

