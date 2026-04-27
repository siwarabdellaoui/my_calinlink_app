import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/theme_provider.dart';

class NightModeScreen extends ConsumerWidget {
  const NightModeScreen({super.key});

  Future<void> _selectTime(BuildContext context, WidgetRef ref, bool isStart,
      TimeOfDay initialTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).cardColor,
              onSurface:
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final state = ref.read(themeProvider);
      if (isStart) {
        ref
            .read(themeProvider.notifier)
            .setNightModeTimes(picked, state.nightModeEndTime);
      } else {
        ref
            .read(themeProvider.notifier)
            .setNightModeTimes(state.nightModeStartTime, picked);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    final isSystemMode = themeState.themeMode == ThemeMode.system;
    final isDarkMode = themeState.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Mode Nuit & Thème',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            const Text(
              'Apparence',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildThemeOptionTile(
              context,
              title: 'Système',
              subtitle: 'S\'adapte aux préférences de votre appareil',
              icon: Icons.brightness_auto_rounded,
              isSelected: isSystemMode && !themeState.isAutoNightMode,
              onTap: () {
                themeNotifier.setAutoNightMode(false);
                themeNotifier.setThemeMode(ThemeMode.system);
              },
            ),
            const SizedBox(height: 12),
            _buildThemeOptionTile(
              context,
              title: 'Clair',
              subtitle: 'Thème par défaut',
              icon: Icons.light_mode_rounded,
              isSelected: themeState.themeMode == ThemeMode.light &&
                  !themeState.isAutoNightMode,
              onTap: () {
                themeNotifier.setAutoNightMode(false);
                themeNotifier.setThemeMode(ThemeMode.light);
              },
            ),
            const SizedBox(height: 12),
            _buildThemeOptionTile(
              context,
              title: 'Sombre',
              subtitle: 'Idéal pour la nuit, réduit l\'éblouissement',
              icon: Icons.dark_mode_rounded,
              isSelected: isDarkMode && !themeState.isAutoNightMode,
              onTap: () {
                themeNotifier.setAutoNightMode(false);
                themeNotifier.setThemeMode(ThemeMode.dark);
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Planification',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: themeState.isAutoNightMode
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Activer automatiquement',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Bascule en mode sombre pendant ces heures',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: themeState.isAutoNightMode,
                    activeColor: AppColors.primary,
                    onChanged: (bool value) {
                      themeNotifier.setAutoNightMode(value);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  if (themeState.isAutoNightMode) ...[
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Heure de début'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          themeState.nightModeStartTime.format(context),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      onTap: () => _selectTime(
                          context, ref, true, themeState.nightModeStartTime),
                    ),
                    ListTile(
                      title: const Text('Heure de fin'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          themeState.nightModeEndTime.format(context),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      onTap: () => _selectTime(
                          context, ref, false, themeState.nightModeEndTime),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOptionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final borderColor = isSelected
        ? AppColors.primary
        : Theme.of(context).dividerColor.withValues(alpha: 0.1);
    final bgColor = Theme.of(context).cardColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.textSecondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
