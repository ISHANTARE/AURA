import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aura/platform/dnd_channel.dart';
import 'package:aura/features/reminders/domain/entities/reminder_models.dart';
import 'package:aura/features/reminders/domain/usecases/snooze_reminder_usecase.dart';
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

final snoozeReminderUseCaseProvider = Provider<SnoozeReminderUseCase>((ref) {
  return SnoozeReminderUseCase(db: ref.watch(databaseProvider));
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
