import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../alarms/presentation/widgets/edit_alarm_modal.dart';
import '../../domain/entities/intent_result.dart';
import '../providers/capture_provider.dart';
import 'voice_capture_overlay.dart';

/// Dedicated Confirmation Card for Alarms
/// Reuses the exact same EditAlarmModal screen as manual alarm creation/editing.
class AlarmConfirmationCard extends ConsumerWidget {
  final IntentResult intent;

  const AlarmConfirmationCard({super.key, required this.intent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EditAlarmModal(
      initialTime: intent.deadline,
      initialTitle: (intent.title != null && intent.title!.isNotEmpty) ? intent.title! : 'Alarm',
      isCaptureFlow: true,
      onSaved: () {
        ref.read(captureProvider.notifier).reset();
        VoiceCaptureOverlay.closeOverlay(context);
      },
    );
  }
}
