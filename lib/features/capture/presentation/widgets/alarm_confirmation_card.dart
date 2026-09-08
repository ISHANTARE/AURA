import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../alarms/presentation/widgets/edit_alarm_modal.dart';
import '../../domain/entities/intent_result.dart';

/// Dedicated Confirmation Card for Alarms
/// Reuses the exact same EditAlarmModal screen as manual alarm creation/editing.
///
/// Closes via `isCaptureFlow: true` so the modal uses its *own* BuildContext
/// for the close call — this is always valid since it runs inside an
/// onPressed handler, not after an async gap from a parent widget.
class AlarmConfirmationCard extends ConsumerWidget {
  final IntentResult intent;

  const AlarmConfirmationCard({super.key, required this.intent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EditAlarmModal(
      initialTime: intent.deadline,
      initialTitle: (intent.title != null && intent.title!.isNotEmpty) ? intent.title! : 'Alarm',
      isCaptureFlow: true,
      // No onSaved — let isCaptureFlow path in EditAlarmModal handle the close
      // using the modal's own context, which is guaranteed to be mounted.
    );
  }
}
