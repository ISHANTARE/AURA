import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:drift/drift.dart' hide Column;

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../reminders/data/services/notification_service.dart';

/// Alarms Screen — AURA v2 Dedicated Alarms & Time Alerts Screen
class AlarmsScreen extends ConsumerWidget {
  const AlarmsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarmsAsync = ref.watch(alarmsListProvider);
    final itemDao = ref.watch(itemDaoProvider);

    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      appBar: AppBar(
        title: Text('ALARMS', style: AuraTypography.screenHeader),
        backgroundColor: AuraColors.bgBase,
        elevation: 0,
      ),
      body: alarmsAsync.when(
        data: (alarms) {
          if (alarms.isEmpty) {
            return const AuraEmptyState(
              icon: LucideIcons.alarmClock,
              title: 'No Active Alarms',
              subtitle:
                  'Tap the AURA orb or say "Set an alarm for 7 AM" to create one.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AuraSpacing.md),
            itemCount: alarms.length,
            separatorBuilder: (_, __) => const SizedBox(height: AuraSpacing.sm),
            itemBuilder: (context, index) {
              final alarm = alarms[index];
              final fireAtDt = alarm.fireAt != null
                  ? DateTime.fromMillisecondsSinceEpoch(alarm.fireAt!)
                  : null;

              final timeStr = fireAtDt != null
                  ? DateFormat('h:mm a').format(fireAtDt)
                  : 'Daily Alarm';

              final dateStr = fireAtDt != null
                  ? DateFormat('EEE, MMM d').format(fireAtDt)
                  : 'Active';

              return Container(
                padding: const EdgeInsets.all(AuraSpacing.md),
                decoration: BoxDecoration(
                  color: AuraColors.bgCard,
                  border: Border.all(
                      color: AuraColors.border, width: AuraSpacing.borderWidth),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AuraSpacing.xs + 2),
                      decoration: BoxDecoration(
                        color: AuraColors.accentLime.withValues(alpha: 0.15),
                        border: Border.all(color: AuraColors.accentLime),
                      ),
                      child: const Icon(LucideIcons.alarmClock,
                          color: AuraColors.accentLime, size: 24),
                    ),
                    const SizedBox(width: AuraSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            timeStr,
                            style: AuraTypography.cardTitle.copyWith(
                              fontSize: 22,
                              color: AuraColors.accentLime,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${alarm.title} · $dateStr',
                            style: AuraTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.trash2,
                          color: AuraColors.textSecondary, size: 20),
                      onPressed: () async {
                        HapticFeedback.mediumImpact();
                        await itemDao.softDelete(alarm.id);
                        await NotificationService().cancel(alarm.id.hashCode.abs());
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Alarm deleted'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AuraColors.accentLime),
          ),
        ),
        error: (err, _) =>
            Center(child: Text('Error: $err', style: AuraTypography.body)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AuraColors.accentLime,
        foregroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Colors.black, width: 2),
        ),
        elevation: 0,
        onPressed: () => _showCreateAlarmModal(context, ref),
        child: const Icon(LucideIcons.plus, size: 24),
      ),
    );
  }

  void _showCreateAlarmModal(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController(text: 'Alarm');
    TimeOfDay selectedTime = TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      backgroundColor: AuraColors.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final now = DateTime.now();
            final alarmDt = DateTime(
              now.year,
              now.month,
              now.day,
              selectedTime.hour,
              selectedTime.minute,
            );

            return Padding(
              padding: EdgeInsets.only(
                left: AuraSpacing.md,
                right: AuraSpacing.md,
                top: AuraSpacing.md,
                bottom: MediaQuery.of(context).viewInsets.bottom + AuraSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NEW ALARM', style: AuraTypography.cardTitle),
                  const SizedBox(height: AuraSpacing.md),
                  TextField(
                    controller: titleCtrl,
                    style: AuraTypography.body,
                    decoration: InputDecoration(
                      labelText: 'ALARM LABEL',
                      labelStyle: AuraTypography.labelLime,
                      filled: true,
                      fillColor: AuraColors.bgBase,
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: AuraColors.border, width: 2),
                        borderRadius: BorderRadius.zero,
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: AuraColors.accentLime, width: 2),
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                  const SizedBox(height: AuraSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Time: ${selectedTime.format(context)}',
                        style: AuraTypography.cardTitle.copyWith(color: AuraColors.accentLime),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AuraColors.bgBase,
                          foregroundColor: AuraColors.textPrimary,
                          side: const BorderSide(color: AuraColors.border, width: 1),
                        ),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (picked != null) {
                            setModalState(() => selectedTime = picked);
                          }
                        },
                        child: const Text('PICK TIME'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AuraSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AuraColors.accentLime,
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black, width: 2),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      onPressed: () async {
                        final title = titleCtrl.text.trim().isEmpty ? 'Alarm' : titleCtrl.text.trim();
                        final itemDao = ref.read(itemDaoProvider);

                        final targetDt = alarmDt.isBefore(now)
                            ? alarmDt.add(const Duration(days: 1))
                            : alarmDt;
                        final nowEpoch = DateTime.now().millisecondsSinceEpoch;

                        final alarmId = 'alarm_$nowEpoch';

                        await itemDao.insertItem(
                          ItemsCompanion.insert(
                            id: alarmId,
                            title: title,
                            category: 'alarm',
                            kind: 'alarm',
                            fireAt: Value(targetDt.millisecondsSinceEpoch),
                            createdAt: nowEpoch,
                            updatedAt: nowEpoch,
                          ),
                        );

                        await NotificationService().scheduleAlarm(
                          id: alarmId.hashCode.abs(),
                          title: title,
                          body: 'Alarm: ${DateFormat('h:mm a').format(targetDt)}',
                          scheduledDate: targetDt,
                          payload: alarmId,
                        );

                        if (context.mounted) Navigator.pop(context);
                      },
                      child: Text('SET ALARM', style: AuraTypography.label.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
