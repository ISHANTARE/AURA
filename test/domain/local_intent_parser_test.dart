import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/capture/domain/services/local_intent_parser.dart';

void main() {
  group('LocalIntentParser Unit Tests', () {
    test('Parses create_alarm intent correctly', () {
      final result = LocalIntentParser.parse('set an alarm for 7:30 am');
      expect(result.intentType, equals('create_alarm'));
      expect(result.title, contains('7:30 AM'));
      expect(result.deadline, isNotNull);
    });

    test('Parses create_workspace intent correctly', () {
      final result = LocalIntentParser.parse('create a workspace named Placement Prep');
      expect(result.intentType, equals('create_workspace'));
      expect(result.title, equals('Placement Prep'));
      expect(result.workspaceHint, equals('Placement Prep'));
    });

    test('Parses delete_task intent correctly', () {
      final result = LocalIntentParser.parse('delete task submit report');
      expect(result.intentType, equals('delete_task'));
      expect(result.targetName, equals('submit report'));
    });

    test('Parses delete_workspace intent correctly', () {
      final result = LocalIntentParser.parse('delete workspace TestSpace');
      expect(result.intentType, equals('delete_workspace'));
      expect(result.targetName, equals('TestSpace'));
    });

    test('Parses add_note intent correctly', () {
      final result = LocalIntentParser.parse('note down meeting discussion points');
      expect(result.intentType, equals('add_note'));
      expect(result.notes, equals('meeting discussion points'));
    });

    test('Parses create_reminder / task intent with relative date', () {
      final result = LocalIntentParser.parse(
        'remind me to call doctor tomorrow at 5pm',
        userWorkspaces: ['Personal', 'Academics'],
      );
      expect(result.intentType, equals('create_reminder'));
      expect(result.title, contains('Call doctor'));
      expect(result.deadline, isNotNull);
      expect(result.reminders, isNotEmpty);
    });

    test('Safely handles empty and whitespace-only transcripts without crashing', () {
      final resultEmpty = LocalIntentParser.parse('');
      expect(resultEmpty.title, equals('Untitled Voice Task'));
      expect(resultEmpty.intentType, equals('create_task'));

      final resultSpaces = LocalIntentParser.parse('   ');
      expect(resultSpaces.title, equals('Untitled Voice Task'));
      expect(resultSpaces.intentType, equals('create_task'));
    });
  });
}
