import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/home/presentation/providers/home_providers.dart';

void main() {
  group('Day Cockpit & Agenda Partitioning Tests', () {
    final now = DateTime(2026, 8, 27, 10, 0);

    Item createItem({
      required String id,
      required String title,
      int? startTime,
      int? deadline,
      int? fireAt,
      String kind = 'task',
      String category = 'work',
      String status = 'pending',
    }) {
      return Item(
        id: id,
        workspaceId: 'ws-1',
        title: title,
        kind: kind,
        category: category,
        status: status,
        priority: 'medium',
        isRecurring: false,
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
        startTime: startTime,
        deadline: deadline,
        fireAt: fireAt,
      );
    }

    test('DayAgendaModel properly counts pending and completed tasks', () {
      final timed = [
        createItem(
          id: 't-1',
          title: 'Morning Meeting',
          startTime: DateTime(2026, 8, 27, 9, 30).millisecondsSinceEpoch,
          kind: 'event',
        ),
      ];

      final anytime = [
        createItem(id: 'a-1', title: 'Buy milk', status: 'completed'),
        createItem(id: 'a-2', title: 'Read paper', status: 'pending'),
      ];

      final agenda = DayAgendaModel(
        timedItems: timed,
        anytimeItems: anytime,
        totalPending: 2,
        totalCompleted: 1,
      );

      expect(agenda.isEmpty, isFalse);
      expect(agenda.timedItems.length, 1);
      expect(agenda.anytimeItems.length, 2);
      expect(agenda.totalPending, 2);
      expect(agenda.totalCompleted, 1);
    });

    test('TodayStats holds independent pending and done counts', () {
      const stats = TodayStats(pending: 4, completed: 3);
      expect(stats.pending, 4);
      expect(stats.completed, 3);
    });
  });
}
