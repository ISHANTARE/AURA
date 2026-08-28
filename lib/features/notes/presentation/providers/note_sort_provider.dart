import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/providers/providers.dart';

enum NoteSortOrder {
  lastEdited('Last Edited'),
  dateCreated('Date Created'),
  alphabetical('A – Z');

  final String label;
  const NoteSortOrder(this.label);
}

class NoteSortNotifier extends StateNotifier<NoteSortOrder> {
  NoteSortNotifier() : super(NoteSortOrder.lastEdited) {
    _loadSortOrder();
  }

  Future<void> _loadSortOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('NOTES_SORT_ORDER');
    if (saved != null) {
      final match = NoteSortOrder.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => NoteSortOrder.lastEdited,
      );
      state = match;
    }
  }

  Future<void> setSortOrder(NoteSortOrder order) async {
    state = order;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('NOTES_SORT_ORDER', order.name);
  }
}

final noteSortOrderProvider =
    StateNotifierProvider<NoteSortNotifier, NoteSortOrder>((ref) {
  return NoteSortNotifier();
});

/// Provider for sorted notes list based on the active NoteSortOrder.
final sortedNotesProvider = Provider<AsyncValue<List<Item>>>((ref) {
  final notesAsync = ref.watch(notesListProvider);
  final sortOrder = ref.watch(noteSortOrderProvider);

  return notesAsync.whenData((notes) {
    final list = List<Item>.from(notes);
    switch (sortOrder) {
      case NoteSortOrder.lastEdited:
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      case NoteSortOrder.dateCreated:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case NoteSortOrder.alphabetical:
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }
    return list;
  });
});
