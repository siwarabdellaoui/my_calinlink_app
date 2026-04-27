import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeController, ThemeState>((ref) {
  return ThemeController();
});

class ThemeState {
  final ThemeMode themeMode;
  final bool isAutoNightMode;
  final TimeOfDay nightModeStartTime;
  final TimeOfDay nightModeEndTime;
  final ThemeMode currentEffectiveTheme;

  ThemeState({
    required this.themeMode,
    required this.isAutoNightMode,
    required this.nightModeStartTime,
    required this.nightModeEndTime,
    required this.currentEffectiveTheme,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? isAutoNightMode,
    TimeOfDay? nightModeStartTime,
    TimeOfDay? nightModeEndTime,
    ThemeMode? currentEffectiveTheme,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isAutoNightMode: isAutoNightMode ?? this.isAutoNightMode,
      nightModeStartTime: nightModeStartTime ?? this.nightModeStartTime,
      nightModeEndTime: nightModeEndTime ?? this.nightModeEndTime,
      currentEffectiveTheme:
          currentEffectiveTheme ?? this.currentEffectiveTheme,
    );
  }
}

class ThemeController extends StateNotifier<ThemeState> {
  Timer? _timer;

  ThemeController()
      : super(ThemeState(
          themeMode: ThemeMode.system,
          isAutoNightMode: false,
          nightModeStartTime: const TimeOfDay(hour: 20, minute: 0),
          nightModeEndTime: const TimeOfDay(hour: 7, minute: 0),
          currentEffectiveTheme: ThemeMode.system,
        )) {
    _loadSettings();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final themeIndex = prefs.getInt('themeMode') ?? 0;
    final isAuto = prefs.getBool('isAutoNightMode') ?? false;
    final startMins = prefs.getInt('nightModeStartTime') ?? (20 * 60);
    final endMins = prefs.getInt('nightModeEndTime') ?? (7 * 60);

    final stateLoaded = ThemeState(
      themeMode: ThemeMode.values[themeIndex],
      isAutoNightMode: isAuto,
      nightModeStartTime:
          TimeOfDay(hour: startMins ~/ 60, minute: startMins % 60),
      nightModeEndTime: TimeOfDay(hour: endMins ~/ 60, minute: endMins % 60),
      currentEffectiveTheme: ThemeMode.values[themeIndex],
    );

    state = stateLoaded.copyWith(
      currentEffectiveTheme: _calculateEffectiveTheme(stateLoaded),
    );

    _manageTimer();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);

    // Disable auto mode if user manually chooses a mode
    if (mode != ThemeMode.system && state.isAutoNightMode) {
      await prefs.setBool('isAutoNightMode', false);
      state = state.copyWith(themeMode: mode, isAutoNightMode: false);
    } else {
      state = state.copyWith(themeMode: mode);
    }

    _updateEffectiveTheme();
    _manageTimer();
  }

  Future<void> setAutoNightMode(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAutoNightMode', isEnabled);

    state = state.copyWith(isAutoNightMode: isEnabled);
    _updateEffectiveTheme();
    _manageTimer();
  }

  Future<void> setNightModeTimes(TimeOfDay start, TimeOfDay end) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('nightModeStartTime', start.hour * 60 + start.minute);
    await prefs.setInt('nightModeEndTime', end.hour * 60 + end.minute);

    state = state.copyWith(
      nightModeStartTime: start,
      nightModeEndTime: end,
    );
    _updateEffectiveTheme();
  }

  void _manageTimer() {
    _timer?.cancel();
    if (state.isAutoNightMode) {
      // Check every minute
      _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
        _updateEffectiveTheme();
      });
    }
  }

  void _updateEffectiveTheme() {
    final effective = _calculateEffectiveTheme(state);
    if (effective != state.currentEffectiveTheme) {
      state = state.copyWith(currentEffectiveTheme: effective);
    }
  }

  ThemeMode _calculateEffectiveTheme(ThemeState current) {
    if (!current.isAutoNightMode) {
      return current.themeMode;
    }

    final now = TimeOfDay.now();
    final nowMins = now.hour * 60 + now.minute;
    final startMins = current.nightModeStartTime.hour * 60 +
        current.nightModeStartTime.minute;
    final endMins =
        current.nightModeEndTime.hour * 60 + current.nightModeEndTime.minute;

    bool isNight = false;
    if (startMins < endMins) {
      // Example: 01:00 to 05:00
      isNight = nowMins >= startMins && nowMins < endMins;
    } else {
      // Example: 20:00 to 07:00 (crosses midnight)
      isNight = nowMins >= startMins || nowMins < endMins;
    }

    return isNight ? ThemeMode.dark : ThemeMode.light;
  }
}
