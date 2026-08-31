import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class AlarmDiagnosticsNotifier extends StateNotifier<bool> {
  AlarmDiagnosticsNotifier() : super(true) {
    checkPermission();
  }

  Future<void> checkPermission() async {
    try {
      final status = await Permission.scheduleExactAlarm.status;
      // If granted or not denied/restricted, exact alarms work accurately.
      state = status.isGranted || status.isLimited;
    } catch (_) {
      state = true;
    }
  }

  Future<void> requestOrOpenSettings() async {
    try {
      final res = await Permission.scheduleExactAlarm.request();
      if (!res.isGranted) {
        await openAppSettings();
      }
      await checkPermission();
    } catch (_) {
      await openAppSettings();
    }
  }
}

final exactAlarmStatusProvider =
    StateNotifierProvider<AlarmDiagnosticsNotifier, bool>((ref) {
  return AlarmDiagnosticsNotifier();
});
