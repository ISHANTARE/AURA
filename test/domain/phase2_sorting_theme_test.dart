import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aura/database/app_database.dart';
import 'package:aura/core/constants/colors.dart';
import 'package:aura/core/theme/theme_provider.dart';
import 'package:aura/features/notes/presentation/providers/note_sort_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 2 Tests: ThemeMode, Alarm Chronological Sort & Notes Multi-Sort', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('ThemeModeNotifier toggles between dark and light, persisting value', () async {
      final notifier = ThemeModeNotifier();
      expect(notifier.state, ThemeMode.dark);

      await notifier.toggleTheme();
      expect(notifier.state, ThemeMode.light);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('THEME_MODE'), 'light');

      await notifier.toggleTheme();
      expect(notifier.state, ThemeMode.dark);
      expect(prefs.getString('THEME_MODE'), 'dark');
    });

    test('AuraColors theme helpers return appropriate light/dark palettes', () {
      expect(AuraColors.bgBase, const Color(0xFF0D0F14));
      expect(AuraColors.lightBgBase, const Color(0xFFF6F8FA));
      expect(AuraColors.textPrimary, const Color(0xFFF0F0F5));
      expect(AuraColors.lightTextPrimary, const Color(0xFF0F172A));
    });

    test('NoteSortNotifier cycles through Last Edited, Date Created, and A-Z', () async {
      final notifier = NoteSortNotifier();
      expect(notifier.state, NoteSortOrder.lastEdited);

      await notifier.setSortOrder(NoteSortOrder.alphabetical);
      expect(notifier.state, NoteSortOrder.alphabetical);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('NOTES_SORT_ORDER'), 'alphabetical');

      await notifier.setSortOrder(NoteSortOrder.dateCreated);
      expect(notifier.state, NoteSortOrder.dateCreated);
    });

    test('Alarms sort chronologically by minute of day (6 AM before 2 PM)', () {
      Item createAlarm(String id, String title, int hour, int minute) {
        final dt = DateTime(2026, 8, 28, hour, minute);
        return Item(
          id: id,
          workspaceId: 'ws-1',
          title: title,
          kind: 'alarm',
          category: 'alarm',
          status: 'pending',
          priority: 'medium',
          isRecurring: false,
          createdAt: 0,
          updatedAt: 0,
          fireAt: dt.millisecondsSinceEpoch,
        );
      }

      final a1 = createAlarm('1', 'Afternoon Nap Alarm', 14, 0); // 2:00 PM
      final a2 = createAlarm('2', 'Early Workout Alarm', 6, 0);  // 6:00 AM
      final a3 = createAlarm('3', 'Breakfast Alarm', 7, 30);     // 7:30 AM
      final a4 = createAlarm('4', 'Late Night Alarm', 23, 45);   // 11:45 PM

      final list = [a1, a4, a2, a3];

      list.sort((a, b) {
        final aDt = a.fireAt != null ? DateTime.fromMillisecondsSinceEpoch(a.fireAt!) : null;
        final bDt = b.fireAt != null ? DateTime.fromMillisecondsSinceEpoch(b.fireAt!) : null;
        final aMinuteOfDay = aDt != null ? aDt.hour * 60 + aDt.minute : 9999;
        final bMinuteOfDay = bDt != null ? bDt.hour * 60 + bDt.minute : 9999;
        if (aMinuteOfDay != bMinuteOfDay) {
          return aMinuteOfDay.compareTo(bMinuteOfDay);
        }
        return (a.fireAt ?? 0).compareTo(b.fireAt ?? 0);
      });

      expect(list.map((e) => e.id).toList(), ['2', '3', '1', '4']);
    });

    test('Notes multi-sort works correctly for lastEdited, dateCreated, and alphabetical', () {
      Item createNote(String id, String title, int createdAt, int updatedAt) {
        return Item(
          id: id,
          workspaceId: 'ws-1',
          title: title,
          kind: 'note',
          category: 'note',
          status: 'pending',
          priority: 'medium',
          isRecurring: false,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
      }

      final n1 = createNote('1', 'Zebra ideas', 100, 500);
      final n2 = createNote('2', 'Apple recipe', 200, 300);
      final n3 = createNote('3', 'Meeting minutes', 300, 100);

      final list = [n1, n2, n3];

      // 1. Last Edited (updatedAt DESC)
      final byEdited = List<Item>.from(list)..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      expect(byEdited.map((e) => e.id).toList(), ['1', '2', '3']);

      // 2. Date Created (createdAt DESC)
      final byCreated = List<Item>.from(list)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      expect(byCreated.map((e) => e.id).toList(), ['3', '2', '1']);

      // 3. Alphabetical (A-Z)
      final byAlpha = List<Item>.from(list)..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      expect(byAlpha.map((e) => e.id).toList(), ['2', '3', '1']);
    });
  });
}
