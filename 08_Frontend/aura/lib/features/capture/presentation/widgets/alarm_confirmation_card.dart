import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../domain/entities/intent_result.dart';
import '../providers/capture_provider.dart';

/// Dedicated Confirmation Card for Alarms (Sprint 8)
class AlarmConfirmationCard extends ConsumerStatefulWidget {
  final IntentResult intent;

  const AlarmConfirmationCard({super.key, required this.intent});

  @override
  ConsumerState<AlarmConfirmationCard> createState() =>
      _AlarmConfirmationCardState();
}

class _AlarmConfirmationCardState extends ConsumerState<AlarmConfirmationCard> {
  late DateTime _fireAt;
  int _snoozeMinutes = 10;

  @override
  void initState() {
    super.initState();
    _fireAt = widget.intent.deadline ?? DateTime.now().add(const Duration(minutes: 30));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AuraSpacing.md),
      decoration: BoxDecoration(
        color: AuraColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AuraColors.accentLime, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AuraColors.accentLime.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AuraColors.accentLime, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.alarmClock, size: 14, color: AuraColors.accentLime),
                    const SizedBox(width: 6),
                    Text(
                      'SET ALARM',
                      style: AuraTypography.label.copyWith(
                        color: AuraColors.accentLime,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  HapticFeedback.selectionClick();
                  await ref.read(captureProvider.notifier).cancelCapture();
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Icon(LucideIcons.x, size: 20, color: AuraColors.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: AuraSpacing.md),

          // Big Time Display
          Center(
            child: GestureDetector(
              onTap: () async {
                final selectedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_fireAt),
                );
                if (selectedTime != null) {
                  final now = DateTime.now();
                  final newDt = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );
                  setState(() => _fireAt = newDt);
                  ref.read(captureProvider.notifier).updateIntent(
                        widget.intent.copyWith(deadline: newDt),
                      );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AuraColors.bgElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AuraColors.accentLime, width: 1),
                ),
                child: Text(
                  _formatTime(_fireAt),
                  style: AuraTypography.display.copyWith(
                    fontSize: 36,
                    color: AuraColors.accentLime,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AuraSpacing.md),

          // Snooze Setting
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Snooze Duration', style: AuraTypography.overline),
              DropdownButton<int>(
                value: _snoozeMinutes,
                dropdownColor: AuraColors.bgElevated,
                style: AuraTypography.body.copyWith(color: AuraColors.textPrimary),
                items: const [
                  DropdownMenuItem(value: 5, child: Text('5 minutes')),
                  DropdownMenuItem(value: 10, child: Text('10 minutes (Default)')),
                  DropdownMenuItem(value: 15, child: Text('15 minutes')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _snoozeMinutes = val);
                },
              ),
            ],
          ),

          const SizedBox(height: AuraSpacing.lg),

          // Save Alarm CTA
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AuraColors.accentLime,
                foregroundColor: Colors.black,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                ref.read(captureProvider.notifier).confirmAndSave();
                Navigator.of(context).pop();
              },
              child: Text(
                'SET ALARM NOW',
                style: AuraTypography.label.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minuteStr $ampm';
  }
}
