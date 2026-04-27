import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/device_service.dart';

class DeviceControlsState {
  final bool isDouceNuitEnabled;
  final bool isBerceusePlaying;

  const DeviceControlsState({
    this.isDouceNuitEnabled = false,
    this.isBerceusePlaying = false,
  });

  DeviceControlsState copyWith({
    bool? isDouceNuitEnabled,
    bool? isBerceusePlaying,
  }) {
    return DeviceControlsState(
      isDouceNuitEnabled: isDouceNuitEnabled ?? this.isDouceNuitEnabled,
      isBerceusePlaying: isBerceusePlaying ?? this.isBerceusePlaying,
    );
  }
}

class DeviceControlsNotifier extends StateNotifier<DeviceControlsState> {
  DeviceControlsNotifier() : super(const DeviceControlsState());

  String? _currentDeviceId;

  Future<void> fetchDevices() async {
    try {
      final devices = await DeviceService.getMyDevices();
      if (devices.isNotEmpty) {
        _currentDeviceId = devices[0]['_id'];
        state = state.copyWith(
          isDouceNuitEnabled: devices[0]['status']['isDouceNuitEnabled'],
          isBerceusePlaying: devices[0]['status']['isBerceuseEnabled'],
        );
      }
    } catch (e) {}
  }

  Future<void> toggleDouceNuit() async {
    final newState = !state.isDouceNuitEnabled;
    state = state.copyWith(isDouceNuitEnabled: newState);
    if (_currentDeviceId != null) {
      DeviceService.updateDeviceStatus(_currentDeviceId!,
              isDouceNuitEnabled: newState)
          .catchError((_) {});
    }
  }

  Future<void> toggleBerceuse() async {
    final newState = !state.isBerceusePlaying;
    state = state.copyWith(isBerceusePlaying: newState);
    if (_currentDeviceId != null) {
      DeviceService.updateDeviceStatus(_currentDeviceId!,
              isBerceuseEnabled: newState)
          .catchError((_) {});
    }
  }
}

final deviceControlsProvider =
    StateNotifierProvider<DeviceControlsNotifier, DeviceControlsState>((ref) {
  return DeviceControlsNotifier();
});
