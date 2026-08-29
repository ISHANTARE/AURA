import 'package:flutter_test/flutter_test.dart';

import 'package:aura/features/capture/domain/local_intent_parser.dart';

void main() {
  final testNow = DateTime(2026, 8, 29, 10, 0, 0); // 10:00 AM

  group('LocalIntentParser Unit Tests', () {
    test('parses alarm intent with 12-hour PM time', () {
      final intent = LocalIntentParser.parse('set an alarm for 7:30 pm', now: testNow);
      expect(intent.intentType, 'create_alarm');
      expect(intent.title, 'Alarm 7:30 PM');
      expect(intent.deadlineIso, isNotNull);
      expect(intent.confidence, 0.85);
    });

    test('parses alarm intent with dot notation e.g. 1.45pm', () {
      final intent = LocalIntentParser.parse('add an alarm for 1.45pm', now: testNow);
      expect(intent.intentType, 'create_alarm');
      expect(intent.title, 'Alarm 1:45 PM');
      expect(intent.confidence, 0.85);
    });

    test('parses create_workspace intent', () {
      final intent = LocalIntentParser.parse('create a workspace named Placement Prep', now: testNow);
      expect(intent.intentType, 'create_workspace');
      expect(intent.title, 'Placement prep');
      expect(intent.workspaceColorHex, '#C8FF00');
      expect(intent.confidence, 0.90);
    });

    test('parses delete_task intent', () {
      final intent = LocalIntentParser.parse('delete task Mathematics Assignment', now: testNow);
      expect(intent.intentType, 'delete_task');
      expect(intent.targetName, 'mathematics assignment');
      expect(intent.confidence, 0.85);
    });

    test('parses delete_workspace intent', () {
      final intent = LocalIntentParser.parse('delete workspace Old Archive', now: testNow);
      expect(intent.intentType, 'delete_workspace');
      expect(intent.targetName, 'old archive');
      expect(intent.confidence, 0.85);
    });

    test('parses add_note intent and populates notes body', () {
      final intent = LocalIntentParser.parse('note down project submission portal opens Friday', now: testNow);
      expect(intent.intentType, 'add_note');
      expect(intent.notes, 'project submission portal opens Friday');
      expect(intent.confidence, 0.85);
    });

    test('parses create_task with urgent priority and workspace hint', () {
      final intent = LocalIntentParser.parse('urgent task submit resume in workspace Career', now: testNow);
      expect(intent.intentType, 'create_task');
      expect(intent.priority, 'high');
      expect(intent.workspaceHint, 'Career');
      expect(intent.confidence, 0.75);
    });

    test('parses create_reminder with tomorrow time and auto-attaches 30m offset', () {
      final intent = LocalIntentParser.parse('remind me to call doctor tomorrow at 5pm', now: testNow);
      expect(intent.intentType, 'create_reminder');
      expect(intent.deadlineIso, isNotNull);
      expect(intent.reminders.length, 1);
      expect(intent.reminders.first.offsetValue, 30);
    });
  });
}
