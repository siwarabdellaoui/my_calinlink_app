import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
export 'control_screen.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  bool _nightModeActive = true;
  bool _nightLightActive = true;
  bool _musicActive = false;
  double _nightLightIntensity = 0.5;
  double _musicVolume = 0.7;
  String _selectedMusic = 'Douce Nuit';
  String _nightModeTime = '20h00';

  final List<String> _musicList = [
    'Douce Nuit',
    'Berceuse de Brahms',
    'Pluie douce',
    'Bruit blanc',
    'Océan calme',
  ];

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
              _buildHeader(context),
              const SizedBox(height: 24),
              Text(
                'Le Lit de\nBébé',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Contrôlez l'environnement de sommeil",
                style: TextStyle(
                  fontSize: 14,
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 28),
              _buildSectionLabel('MODE'),
              const SizedBox(height: 12),
              _buildNightModeCard(),
              const SizedBox(height: 24),
              _buildSectionLabel('CONFORT'),
              const SizedBox(height: 12),
              _buildNightLightCard(),
              const SizedBox(height: 16),
              _buildMusicCard(),
              const SizedBox(height: 16),
              _buildActionSentCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            child: Icon(
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
          onTap: () => context.push(AppRoutes.alerts),
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
              Icons.notifications_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: context.textSecondary,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildNightModeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _nightModeActive
              ? [AppColors.primary, AppColors.primaryDark]
              : [Colors.grey.shade300, Colors.grey.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (_nightModeActive ? AppColors.primary : Colors.grey)
                .withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ACTIF À $_nightModeTime',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(
                  () => _nightModeActive = !_nightModeActive,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 50,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _nightModeActive
                        ? Colors.white.withOpacity(0.3)
                        : Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    alignment: _nightModeActive
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
           Text(
            'Mode Nuit',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
           Text(
            'Optimise la veilleuse et réduit\nles alertes pour un sommeil profond.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _showTimePickerDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Modifier l'horaire",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _nightModeActive ? AppColors.primary : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNightLightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
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
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lightbulb_rounded,
                  color: Colors.amber,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Veilleuse',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                    Text(
                      'Lumière douce pour bébé',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(
                  () => _nightLightActive = !_nightLightActive,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 50,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _nightLightActive
                        ? AppColors.primary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    alignment: _nightLightActive
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_nightLightActive) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(
                  Icons.brightness_low_rounded,
                  color: context.textSecondary,
                  size: 18,
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.primary.withOpacity(0.2),
                      thumbColor: AppColors.primary,
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                    ),
                    child: Slider(
                      value: _nightLightIntensity,
                      onChanged: (v) =>
                          setState(() => _nightLightIntensity = v),
                    ),
                  ),
                ),
                 Icon(
                  Icons.brightness_high_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ],
            ),
            Center(
              child: Text(
                '${(_nightLightIntensity * 100).round()}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMusicCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
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
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.music_note_rounded,
                  color: AppColors.secondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              
               Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Berceuse',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                    Text(
                      'Musique douce pour endormir',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _musicActive = !_musicActive),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 50,
                  height: 28,
                  decoration: BoxDecoration(
                    color:
                        _musicActive ? AppColors.primary : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    alignment: _musicActive
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_musicActive) ...[
            const SizedBox(height: 20),
            ...List.generate(_musicList.length, (i) {
              final isSelected = _musicList[i] == _selectedMusic;
              return GestureDetector(
                onTap: () => setState(() => _selectedMusic = _musicList[i]),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : const Color(0xFFF8F0F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.music_note_rounded
                            : Icons.music_note_outlined,
                        color: isSelected
                            ? AppColors.primary
                            : context.textSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _musicList[i],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primary
                                : context.textPrimary,
                          ),
                        ),
                      ),
                      if (isSelected)
                         Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.volume_down_rounded,
                  color: context.textSecondary,
                  size: 18,
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.secondary,
                      inactiveTrackColor: AppColors.secondary.withOpacity(0.2),
                      thumbColor: AppColors.secondary,
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                    ),
                    child: Slider(
                      value: _musicVolume,
                      onChanged: (v) => setState(() => _musicVolume = v),
                    ),
                  ),
                ),
                 Icon(
                  Icons.volume_up_rounded,
                  color: AppColors.secondary,
                  size: 18,
                ),
              ],
            ),
            Center(
              child: Text(
                'Volume : ${(_musicVolume * 100).round()}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionSentCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child:  Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
           Text(
            'Action envoyée au lit',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showTimePickerDialog() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 20, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _nightModeTime =
            '${picked.hour}h${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }
}

