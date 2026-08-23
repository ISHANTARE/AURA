import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aura/platform/dnd_channel.dart';
import 'package:aura/features/reminders/domain/entities/reminder_models.dart';
// snoozeReminderUseCaseProvider is the single canonical definition in
// core/providers/providers.dart — do not re-declare it here.
import '../../../../core/providers/providers.dart';

// Platform channel provider
final dndChannelProvider = Provider<DndChannel>((ref) => DndChannel());

// Stream of real-time DND state toggles
final dndStatusStreamProvider = StreamProvider<bool>((ref) {
  return ref.watch(dndChannelProvider).dndStateStream;
});

// Current DND status future provider
final isDndActiveProvider = FutureProvider<bool>((ref) async {
  return ref.watch(dndChannelProvider).isDndActive();
});

// StateNotifier for executing reminder actions
class ReminderActionNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  ReminderActionNotifier(this._ref) : super(const AsyncData(null));

  Future<void> snoozeReminder({
    required String reminderId,
    required String taskId,
    required String taskTitle,
    required SnoozePreset preset,
    DateTime? customDateTime,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = _ref.read(snoozeReminderUseCaseProvider);
      await useCase.execute(
        reminderId: reminderId,
        taskId: taskId,
        taskTitle: taskTitle,
        preset: preset,
        customDateTime: customDateTime,
      );
    });
  }
}

final reminderActionProvider =
    StateNotifierProvider<ReminderActionNotifier, AsyncValue<void>>((ref) {
  return ReminderActionNotifier(ref);
});
