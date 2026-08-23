import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/utils/greeting.dart';

void main() {
  group('timeAwareGreeting', () {
    test('morning / afternoon / evening buckets', () {
      expect(timeAwareGreeting(6, userName: 'Ishan'),
          'Good morning, Ishan.');
      expect(timeAwareGreeting(11, userName: 'Ishan'),
          'Good morning, Ishan.');
      expect(timeAwareGreeting(12, userName: 'Ishan'),
          'Good afternoon, Ishan.');
      expect(timeAwareGreeting(16, userName: 'Ishan'),
          'Good afternoon, Ishan.');
      expect(timeAwareGreeting(17, userName: 'Ishan'),
          'Good evening, Ishan.');
      expect(timeAwareGreeting(23, userName: 'Ishan'),
          'Good evening, Ishan.');
    });

    test('uses only the first name', () {
      expect(timeAwareGreeting(9, userName: 'Ada Lovelace'),
          'Good morning, Ada.');
    });

    test('blank names never leak placeholders or developer names', () {
      expect(timeAwareGreeting(9, userName: ''), 'Good morning, there.');
      expect(timeAwareGreeting(9, userName: '   '), 'Good morning, there.');
      // Regression guard for the audit's hardcoded-name class of bug.
      expect(timeAwareGreeting(9, userName: ''), isNot(contains('Ishant')));
      expect(timeAwareGreeting(9, userName: ''), isNot(contains('Ishan T')));
      expect(timeAwareGreeting(9, userName: ''), isNot(contains('your name')));
    });
  });
}
