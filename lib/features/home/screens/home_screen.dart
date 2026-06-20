import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/providers/sensor_provider.dart';
import '../../../shared/providers/user_provider.dart';
export 'home_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProfileProvider.notifier).fetchProfile();
    });
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
              _buildHeader(context),

              const SizedBox(height: 20),

              // Carte device
              _buildDeviceCard(),

              const SizedBox(height: 20),

              // Grille métriques
              _buildMetricsGrid(context),

              const SizedBox(height: 20),

              // Boutons raccourcis
              _buildShortcuts(context),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  // Header avec avatar et notification
  Widget _buildHeader(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);

    return Row(
      children: [
        // Avatar
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            shape: BoxShape.circle,
            image: userProfile.avatar.isNotEmpty && userProfile.avatar.contains(',')
                ? DecorationImage(
                    image: MemoryImage(base64Decode(userProfile.avatar.split(',').last)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: userProfile.avatar.isEmpty
              ? Center(
                  child: Text(
                    '${userProfile.firstName.isNotEmpty ? userProfile.firstName[0] : ''}${userProfile.lastName.isNotEmpty ? userProfile.lastName[0] : ''}'.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),

        // Bonjour
        Expanded(
          child: Text(
            userProfile.firstName.isNotEmpty
                ? 'Bonjour, ${_capitalize(userProfile.firstName)}'
                : 'Bonjour',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
            ),
          ),
        ),

        // Cloche notification
        GestureDetector(
          onTap: () => context.go(AppRoutes.alerts),
          child: Container(
            width: 44,
            height: 44,
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
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Carte device en ligne
  Widget _buildDeviceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 16,
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
                // Statut en ligne
                Row(
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
                      'EN LIGNE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'CâlinLink —\nLit de Léa',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                // Ligne de signal
                Container(
                  height: 2,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.3),
                        AppColors.primary.withOpacity(0.1),
                        AppColors.primary.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Image lit bébé
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.bedroom_baby_rounded,
              size: 52,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // Grille des 4 métriques
  Widget _buildMetricsGrid(BuildContext context) {
    final sensorData = ref.watch(sensorProvider);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        // Température
        _MetricCard(
          icon: Icons.thermostat_rounded,
          iconColor: AppColors.warning,
          label: 'Température',
          value: '${sensorData.temperature}°C',
          badge: 'IDÉAL',
          badgeColor: AppColors.success,
          onTap: () => context.go(AppRoutes.surveillance),
        ),

        // Humidité
        _MetricCard(
          icon: Icons.water_drop_rounded,
          iconColor: AppColors.secondary,
          label: 'Humidité',
          value: '${sensorData.humidity}%',
          onTap: () => context.go(AppRoutes.surveillance),
        ),

        // Mouvement
        _MetricCard(
          icon: Icons.directions_run_rounded,
          iconColor: AppColors.primary,
          label: 'Mouvement',
          value: 'Calme',
          onTap: () => context.go(AppRoutes.surveillance),
        ),

        // Présence
        _MetricCard(
          icon: Icons.favorite_rounded,
          iconColor: AppColors.primary,
          label: 'Présence',
          value: 'Bébé\nprésent',
          onTap: () => context.go(AppRoutes.surveillance),
        ),
      ],
    );
  }

  // Boutons raccourcis en bas
  Widget _buildShortcuts(BuildContext context) {
    final shortcuts = [
      (Icons.videocam_rounded, 'Caméra', AppRoutes.camera),
      (Icons.tune_rounded, 'Contrôle', AppRoutes.control),
      (Icons.notifications_rounded, 'Alertes', AppRoutes.alerts),
      (Icons.bar_chart_rounded, 'Stats', AppRoutes.stats),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: shortcuts.map((s) {
          return GestureDetector(
            onTap: () => context.push(s.$3),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(s.$1, color: AppColors.primary, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  s.$2,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Widget carte métrique
class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.badge,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône + badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: iconColor, size: 26),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor!.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: badgeColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),

            const Spacer(),

            // Valeur
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: context.textPrimary,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 4),

            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: context.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

