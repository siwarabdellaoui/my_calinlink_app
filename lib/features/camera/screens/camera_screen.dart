import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/device_controls_provider.dart';
import '../../../shared/providers/sensor_provider.dart';
import '../../../shared/providers/user_provider.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  bool _isFullscreen = false;
  bool _isMicOn = true;
  final ScreenshotController _screenshotController = ScreenshotController();

  void _toggleMic() {
    setState(() {
      _isMicOn = !_isMicOn;
    });
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
      if (_isFullscreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      }
    });
  }

  Future<void> _takeScreenshot() async {
    try {
      final Uint8List? imageFile = await _screenshotController.capture();

      if (imageFile == null) {
        return;
      }

      await Gal.putImageBytes(
        imageFile,
        album: 'CalinLink',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Capture enregistrée dans la galerie'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la capture: $e'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131524),
      body: SafeArea(
        child: Column(
          children: [
            if (!_isFullscreen) _buildTopBar(context),
            Expanded(
              child: _buildVideoFeed(ref),
            ),
            if (!_isFullscreen) ...[
              _buildCameraControls(),
              const SizedBox(height: 24),
              _buildBottomInfo(ref),
            ],
            if (_isFullscreen)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCameraControls(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home'); // fallback sécurité
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'FLUX SÉCURISÉ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoFeed(WidgetRef ref) {
    final sensorData = ref.watch(sensorProvider);

    return Screenshot(
      controller: _screenshotController,
      child: Container(
        margin: _isFullscreen
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1E32),
          borderRadius:
              _isFullscreen ? BorderRadius.zero : BorderRadius.circular(32),
          border: _isFullscreen
              ? null
              : Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                  width: 1,
                ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: MobileScanner(
                controller: MobileScannerController(
                  detectionSpeed: DetectionSpeed.noDuplicates,
                  facing: CameraFacing.back,
                ),
                onDetect: (capture) {
                  // Ignore detections, we only want the video feed
                },
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.error,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'EN DIRECT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: Column(
                children: [
                  _buildVideoMetric(
                    Icons.favorite_rounded,
                    '112',
                    AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  _buildVideoMetric(
                    Icons.thermostat_rounded,
                    '${sensorData.temperature}°',
                    AppColors.warning,
                  ),
                  const SizedBox(height: 12),
                  _buildVideoMetric(
                    Icons.water_drop_rounded,
                    '${sensorData.humidity}%',
                    AppColors.secondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoMetric(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraControls() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: _isFullscreen ? 80 : 40, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _takeScreenshot,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                if (!_isFullscreen) ...[
                  const SizedBox(height: 8),
                  Text(
                    'CAPTURE',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: _toggleMic,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _isMicOn ? Colors.white : AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isMicOn ? Icons.mic_none_rounded : Icons.mic_off_rounded,
                    color: _isMicOn ? context.textPrimary : Colors.white,
                    size: 32,
                  ),
                ),
                if (!_isFullscreen) ...[
                  const SizedBox(height: 8),
                  Text(
                    _isMicOn ? 'PARLER' : 'MUET',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: _toggleFullscreen,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isFullscreen
                        ? Icons.fullscreen_exit_rounded
                        : Icons.fullscreen_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                if (!_isFullscreen) ...[
                  const SizedBox(height: 8),
                  Text(
                    'PLEIN ÉCRAN',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInfo(WidgetRef ref) {
    final controls = ref.watch(deviceControlsProvider);
    final userProfile = ref.watch(userProfileProvider);
    final isDouceNuit = controls.isDouceNuitEnabled;
    final isBerceuse = controls.isBerceusePlaying;

    String babyAgeStr = '';
    if (userProfile.babyBirthDate.isNotEmpty) {
      try {
        DateTime birthDate = DateTime.parse(userProfile.babyBirthDate);
        DateTime now = DateTime.now();
        int months =
            (now.year - birthDate.year) * 12 + now.month - birthDate.month;
        if (now.day < birthDate.day) {
          months--;
        }
        if (months < 0) months = 0;

        if (months < 1) {
          babyAgeStr = ' • Nouveau-né';
        } else if (months < 12) {
          babyAgeStr = ' • $months mois';
        } else {
          int years = months ~/ 12;
          babyAgeStr = ' • $years an${years > 1 ? 's' : ''}';
        }
      } catch (e) {
        babyAgeStr = '';
      }
    }
    String displayName =
        userProfile.babyName.isNotEmpty ? userProfile.babyName : "Bébé";

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CâlinLink Cam',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$displayName$babyAgeStr',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'CONNEXION\nSTABLE',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => ref
                        .read(deviceControlsProvider.notifier)
                        .toggleDouceNuit(),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDouceNuit
                            ? AppColors.primary
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                        border: isDouceNuit
                            ? null
                            : Border.all(
                                color:
                                    AppColors.primary.withValues(alpha: 0.15),
                                width: 1.5,
                              ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDouceNuit
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : Theme.of(context).colorScheme.surface,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.mode_night_rounded,
                              color: isDouceNuit
                                  ? Colors.white
                                  : AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Douce\nNuit',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDouceNuit
                                    ? Colors.white
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => ref
                        .read(deviceControlsProvider.notifier)
                        .toggleBerceuse(),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isBerceuse
                            ? AppColors.secondary
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: isBerceuse
                            ? null
                            : Border.all(
                                color:
                                    AppColors.primary.withValues(alpha: 0.15),
                                width: 1.5,
                              ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isBerceuse
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : AppColors.secondary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.music_note_rounded,
                              color: isBerceuse
                                  ? Colors.white
                                  : AppColors.secondary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Jouer\nBerceuse',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isBerceuse
                                    ? Colors.white
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

