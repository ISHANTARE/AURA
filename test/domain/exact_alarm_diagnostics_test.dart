import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/alarms/presentation/providers/alarm_diagnostics_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Alarm Diagnostics Provider Tests', () {
    test('AlarmDiagnosticsNotifier initializes with safe default state', () {
      final notifier = AlarmDiagnosticsNotifier();
      expect(notifier.state, isTrue);
    });
  });
}
