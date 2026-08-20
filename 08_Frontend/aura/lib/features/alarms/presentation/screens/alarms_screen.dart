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
import '../../../../platform/overlay_channel.dart';
import '../../../reminders/data/services/notification_service.dart';

/// Alarms Screen — AURA v2 Redesigned Alarms Screen
class AlarmsScreen extends ConsumerWidget {
  const AlarmsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarmsAsync = ref.watch(alarmsListProvider);
    final itemDao = ref.watch(itemDaoProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

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

              return InkWell(
                onTap: () => _showEditAlarmModal(context, ref, alarm),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AuraColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AuraColors.border, width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: AuraColors.shadow,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.md, vertical: 16),
                    child: Row(
                      children: [
                        // Circular icon container
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(LucideIcons.alarmClock, color: primaryColor, size: 26),
                        ),
                        const SizedBox(width: AuraSpacing.md),
                        // Time + label
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                timeStr,
                                style: AuraTypography.display.copyWith(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: AuraColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${alarm.title} · $dateStr',
                                style: AuraTypography.caption,
                              ),
                            ],
                          ),
                        ),
                        // Edit button
                        IconButton(
                          icon: Icon(LucideIcons.edit2, color: primaryColor, size: 18),
                          onPressed: () => _showEditAlarmModal(context, ref, alarm),
                        ),
                        // Delete button
                        IconButton(
                          icon: const Icon(LucideIcons.trash2,
                              color: AuraColors.textMuted, size: 20),
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
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text('Error: $err', style: AuraTypography.body)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => _showCreateAlarmModal(context, ref),
        child: const Icon(LucideIcons.plus, size: 24),
      ),
    );
  }

  void _showCreateAlarmModal(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController(text: 'Alarm');
    TimeOfDay selectedTime = TimeOfDay.now();
    String selectedSoundTitle = 'System Default Alarm';
    String selectedSoundUri = '';
    final primaryColor = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      backgroundColor: AuraColors.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                top: AuraSpacing.lg,
                bottom: MediaQuery.of(context).viewInsets.bottom + AuraSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: AuraSpacing.md),
                      decoration: BoxDecoration(
                        color: AuraColors.borderMuted,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text('NEW ALARM', style: AuraTypography.cardTitle),
                  const SizedBox(height: AuraSpacing.md),
                  TextField(
                    controller: titleCtrl,
                    style: AuraTypography.body,
                    decoration: InputDecoration(
                      labelText: 'Alarm label',
                      filled: true,
                      fillColor: AuraColors.bgCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AuraColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: AuraSpacing.md),
                  // Time display + picker row
                  Container(
                    padding: const EdgeInsets.all(AuraSpacing.md),
                    decoration: BoxDecoration(
                      color: AuraColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AuraColors.border, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Time', style: AuraTypography.caption),
                            Text(
                              selectedTime.format(context),
                              style: AuraTypography.display.copyWith(
                                fontSize: 28,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(LucideIcons.clock, size: 16),
                          label: const Text('CHANGE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor.withValues(alpha: 0.15),
                            foregroundColor: primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AuraSpacing.md),

                  // Alarm Sound Picker Row
                  Container(
                    padding: const EdgeInsets.all(AuraSpacing.md),
                    decoration: BoxDecoration(
                      color: AuraColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AuraColors.border, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ringtone Audio', style: AuraTypography.caption),
                              const SizedBox(height: 2),
                              Text(
                                selectedSoundTitle,
                                style: AuraTypography.bodyPrimary.copyWith(fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          icon: const Icon(LucideIcons.music, size: 16),
                          label: const Text('PICK SOUND'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: BorderSide(color: primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            final soundMap = await OverlayChannel.pickAlarmSound(
                              currentUri: selectedSoundUri,
                            );
                            if (soundMap != null) {
                              setModalState(() {
                                selectedSoundTitle = soundMap['title'] ?? 'Custom Audio';
                                selectedSoundUri = soundMap['uri'] ?? '';
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AuraSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
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
                          soundUri: selectedSoundUri,
                        );

                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('SET ALARM'),
                    ),
                  ),
                  const SizedBox(height: AuraSpacing.sm),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditAlarmModal(BuildContext context, WidgetRef ref, Item alarm) {
    final titleCtrl = TextEditingController(text: alarm.title);
    final initialDt = alarm.fireAt != null
        ? DateTime.fromMillisecondsSinceEpoch(alarm.fireAt!)
        : DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(initialDt);
    String selectedSoundTitle = 'System Default Alarm';
    String selectedSoundUri = '';
    final primaryColor = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      backgroundColor: AuraColors.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                top: AuraSpacing.lg,
                bottom: MediaQuery.of(context).viewInsets.bottom + AuraSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: AuraSpacing.md),
                      decoration: BoxDecoration(
                        color: AuraColors.borderMuted,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text('EDIT ALARM', style: AuraTypography.cardTitle),
                  const SizedBox(height: AuraSpacing.md),
                  TextField(
                    controller: titleCtrl,
                    style: AuraTypography.body,
                    decoration: InputDecoration(
                      labelText: 'Alarm label',
                      filled: true,
                      fillColor: AuraColors.bgCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AuraColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: AuraSpacing.md),
                  // Time display + picker row
                  Container(
                    padding: const EdgeInsets.all(AuraSpacing.md),
                    decoration: BoxDecoration(
                      color: AuraColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AuraColors.border, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Time', style: AuraTypography.caption),
                            Text(
                              selectedTime.format(context),
                              style: AuraTypography.display.copyWith(
                                fontSize: 28,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(LucideIcons.clock, size: 16),
                          label: const Text('CHANGE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor.withValues(alpha: 0.15),
                            foregroundColor: primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AuraSpacing.md),

                  // Alarm Sound Picker Row
                  Container(
                    padding: const EdgeInsets.all(AuraSpacing.md),
                    decoration: BoxDecoration(
                      color: AuraColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AuraColors.border, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ringtone Audio', style: AuraTypography.caption),
                              const SizedBox(height: 2),
                              Text(
                                selectedSoundTitle,
                                style: AuraTypography.bodyPrimary.copyWith(fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          icon: const Icon(LucideIcons.music, size: 16),
                          label: const Text('PICK SOUND'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: BorderSide(color: primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            final soundMap = await OverlayChannel.pickAlarmSound(
                              currentUri: selectedSoundUri,
                            );
                            if (soundMap != null) {
                              setModalState(() {
                                selectedSoundTitle = soundMap['title'] ?? 'Custom Audio';
                                selectedSoundUri = soundMap['uri'] ?? '';
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AuraSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        final title = titleCtrl.text.trim().isEmpty ? 'Alarm' : titleCtrl.text.trim();
                        final itemDao = ref.read(itemDaoProvider);

                        final targetDt = alarmDt.isBefore(now)
                            ? alarmDt.add(const Duration(days: 1))
                            : alarmDt;
                        final nowEpoch = DateTime.now().millisecondsSinceEpoch;

                        await itemDao.upsertItem(
                          ItemsCompanion.insert(
                            id: alarm.id,
                            title: title,
                            category: 'alarm',
                            kind: 'alarm',
                            fireAt: Value(targetDt.millisecondsSinceEpoch),
                            createdAt: alarm.createdAt,
                            updatedAt: nowEpoch,
                          ),
                        );

                        await NotificationService().cancel(alarm.id.hashCode.abs());
                        await NotificationService().scheduleAlarm(
                          id: alarm.id.hashCode.abs(),
                          title: title,
                          body: 'Alarm: ${DateFormat('h:mm a').format(targetDt)}',
                          scheduledDate: targetDt,
                          payload: alarm.id,
                          soundUri: selectedSoundUri,
                        );

                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('UPDATE ALARM'),
                    ),
                  ),
                  const SizedBox(height: AuraSpacing.sm),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
