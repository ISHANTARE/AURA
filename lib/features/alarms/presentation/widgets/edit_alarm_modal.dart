import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/providers/providers.dart';
import '../../../../platform/overlay_channel.dart';
import '../../../reminders/domain/services/reminder_scheduling_service.dart';

enum AlarmRepeatType { repeatDays, specificDate }

class EditAlarmModal extends ConsumerStatefulWidget {
  const EditAlarmModal({
    super.key,
    this.alarm,
  });

  final Item? alarm;

  static Future<void> show(BuildContext context, WidgetRef ref, Item alarm) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AuraColors.bgElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => EditAlarmModal(alarm: alarm),
    );
  }

  static Future<void> showCreate(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AuraColors.bgElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const EditAlarmModal(alarm: null),
    );
  }

  @override
  ConsumerState<EditAlarmModal> createState() => _EditAlarmModalState();
}

class _EditAlarmModalState extends ConsumerState<EditAlarmModal> {
  late TextEditingController _titleCtrl;
  late TimeOfDay _selectedTime;
  late AlarmRepeatType _repeatType;
  late DateTime _selectedDate;
  late Set<int> _selectedWeekdays; // 1 = Mon, 7 = Sun
  String _selectedSoundTitle = 'System Default Alarm';
  String _selectedSoundUri = '';

  final List<String> _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    final alarm = widget.alarm;
    _titleCtrl = TextEditingController(text: alarm?.title ?? 'Alarm');

    final initialDt = alarm?.fireAt != null
        ? DateTime.fromMillisecondsSinceEpoch(alarm!.fireAt!)
        : DateTime.now().add(const Duration(minutes: 5));

    _selectedTime = TimeOfDay.fromDateTime(initialDt);
    _selectedDate = DateTime(initialDt.year, initialDt.month, initialDt.day);

    // Restore saved ringtone for editing mode, or load user default
    if (alarm?.soundUri != null && alarm!.soundUri!.isNotEmpty) {
      _selectedSoundUri = alarm.soundUri!;
      // Derive a human-friendly title from the URI (last path segment)
      final segments = _selectedSoundUri.split('/');
      _selectedSoundTitle = segments.isNotEmpty ? segments.last : 'Custom Sound';
    } else {
      _loadDefaultSound();
    }

    final rule = alarm?.recurrenceRule ?? '';
    if (rule.startsWith('SPECIFIC_DATE:')) {
      _repeatType = AlarmRepeatType.specificDate;
      final dateStr = rule.replaceFirst('SPECIFIC_DATE:', '');
      final parsed = DateTime.tryParse(dateStr);
      if (parsed != null) _selectedDate = parsed;
      _selectedWeekdays = {1, 2, 3, 4, 5, 6, 7};
    } else if (rule.startsWith('DAYS:')) {
      _repeatType = AlarmRepeatType.repeatDays;
      final daysStr = rule.replaceFirst('DAYS:', '');
      _selectedWeekdays = daysStr
          .split(',')
          .map((e) => int.tryParse(e.trim()))
          .whereType<int>()
          .toSet();
      if (_selectedWeekdays.isEmpty) _selectedWeekdays = {1, 2, 3, 4, 5, 6, 7};
    } else {
      _repeatType = AlarmRepeatType.repeatDays;
      _selectedWeekdays = {1, 2, 3, 4, 5, 6, 7}; // Default everyday
    }
  }

  Future<void> _loadDefaultSound() async {
    final prefs = await SharedPreferences.getInstance();
    final defaultTitle = prefs.getString('ALARM_SOUND_TITLE');
    final defaultUri = prefs.getString('ALARM_SOUND_URI');
    if (mounted && defaultTitle != null && defaultTitle.isNotEmpty) {
      setState(() {
        _selectedSoundTitle = defaultTitle;
        if (defaultUri != null) _selectedSoundUri = defaultUri;
      });
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  void _applyPreset(String preset) {
    setState(() {
      _repeatType = AlarmRepeatType.repeatDays;
      if (preset == 'everyday') {
        _selectedWeekdays = {1, 2, 3, 4, 5, 6, 7};
      } else if (preset == 'weekdays') {
        _selectedWeekdays = {1, 2, 3, 4, 5};
      } else if (preset == 'weekends') {
        _selectedWeekdays = {6, 7};
      }
    });
  }

  DateTime _calculateNextOccurrence() {
    final now = DateTime.now();

    if (_repeatType == AlarmRepeatType.specificDate) {
      final target = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      return target;
    }

    // Repeat Days logic
    for (int dayOffset = 0; dayOffset <= 7; dayOffset++) {
      final candidateDate = now.add(Duration(days: dayOffset));
      final candidateDt = DateTime(
        candidateDate.year,
        candidateDate.month,
        candidateDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      if (candidateDt.isAfter(now) && _selectedWeekdays.contains(candidateDate.weekday)) {
        return candidateDt;
      }
    }

    return DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    ).add(const Duration(days: 1));
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isEditing = widget.alarm != null;

    return Padding(
      padding: EdgeInsets.only(
        left: AuraSpacing.md,
        right: AuraSpacing.md,
        top: AuraSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AuraSpacing.md,
      ),
      child: SingleChildScrollView(
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
            Text(
              isEditing ? 'EDIT ALARM' : 'NEW ALARM',
              style: AuraTypography.cardTitle,
            ),
            const SizedBox(height: AuraSpacing.md),

            // Alarm label field
            TextField(
              controller: _titleCtrl,
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

            // Time Row
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
                        _selectedTime.format(context),
                        style: AuraTypography.display.copyWith(
                          fontSize: 28,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(LucideIcons.clock, size: 16),
                    label: const Text('CHANGE TIME'),
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
                        initialTime: _selectedTime,
                      );
                      if (picked != null) {
                        setState(() => _selectedTime = picked);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AuraSpacing.md),

            // Schedule Mode Selector: Specific Date vs Repeat Days
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('DAYS OF WEEK')),
                    selected: _repeatType == AlarmRepeatType.repeatDays,
                    selectedColor: primaryColor.withValues(alpha: 0.2),
                    side: BorderSide(
                      color: _repeatType == AlarmRepeatType.repeatDays
                          ? primaryColor
                          : AuraColors.border,
                    ),
                    onSelected: (_) {
                      setState(() => _repeatType = AlarmRepeatType.repeatDays);
                    },
                  ),
                ),
                const SizedBox(width: AuraSpacing.sm),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('SPECIFIC DATE')),
                    selected: _repeatType == AlarmRepeatType.specificDate,
                    selectedColor: primaryColor.withValues(alpha: 0.2),
                    side: BorderSide(
                      color: _repeatType == AlarmRepeatType.specificDate
                          ? primaryColor
                          : AuraColors.border,
                    ),
                    onSelected: (_) {
                      setState(() => _repeatType = AlarmRepeatType.specificDate);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AuraSpacing.sm),

            // Config area based on Mode
            if (_repeatType == AlarmRepeatType.repeatDays) ...[
              // Presets row
              Wrap(
                spacing: 6,
                children: [
                  ActionChip(
                    label: const Text('Everyday', style: TextStyle(fontSize: 12)),
                    onPressed: () => _applyPreset('everyday'),
                  ),
                  ActionChip(
                    label: const Text('Weekdays', style: TextStyle(fontSize: 12)),
                    onPressed: () => _applyPreset('weekdays'),
                  ),
                  ActionChip(
                    label: const Text('Weekends', style: TextStyle(fontSize: 12)),
                    onPressed: () => _applyPreset('weekends'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Day Toggle Buttons Row (Mon = 1 ... Sun = 7)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final weekday = index + 1; // 1-7
                  final isSelected = _selectedWeekdays.contains(weekday);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          if (_selectedWeekdays.length > 1) {
                            _selectedWeekdays.remove(weekday);
                          }
                        } else {
                          _selectedWeekdays.add(weekday);
                        }
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryColor
                            : AuraColors.bgCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? primaryColor : AuraColors.border,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _dayLabels[index],
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : AuraColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ] else ...[
              // Specific Date Picker Button
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
                        Text('Target Date', style: AuraTypography.caption),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                          style: AuraTypography.bodyPrimary.copyWith(fontSize: 15),
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(LucideIcons.calendar, size: 16),
                      label: const Text('PICK DATE'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 1)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
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
                          _selectedSoundTitle,
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
                        currentUri: _selectedSoundUri,
                      );
                      if (soundMap != null) {
                        setState(() {
                          _selectedSoundTitle = soundMap['title'] ?? 'Custom Audio';
                          _selectedSoundUri = soundMap['uri'] ?? '';
                        });
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AuraSpacing.lg),

            // Save CTA Button
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
                  final title = _titleCtrl.text.trim().isEmpty ? 'Alarm' : _titleCtrl.text.trim();
                  final itemDao = ref.read(itemDaoProvider);
                  final nextTargetDt = _calculateNextOccurrence();
                  final nowEpoch = DateTime.now().millisecondsSinceEpoch;
                  // Captured before any awaits — used after the save completes.
                  final messenger = ScaffoldMessenger.of(context);

                  String ruleStr;
                  if (_repeatType == AlarmRepeatType.specificDate) {
                    ruleStr = 'SPECIFIC_DATE:${DateFormat('yyyy-MM-dd').format(_selectedDate)}';
                  } else {
                    final daysSorted = _selectedWeekdays.toList()..sort();
                    ruleStr = 'DAYS:${daysSorted.join(',')}';
                  }

                  final alarmId = widget.alarm?.id ?? 'alarm_$nowEpoch';

                  final companion = ItemsCompanion(
                    id: Value(alarmId),
                    title: Value(title),
                    category: const Value('alarm'),
                    kind: const Value('alarm'),
                    fireAt: Value(nextTargetDt.millisecondsSinceEpoch),
                    isRecurring: Value(_repeatType == AlarmRepeatType.repeatDays),
                    recurrenceRule: Value(ruleStr),
                    // Persist the chosen ringtone URI so it survives restarts
                    soundUri: Value(_selectedSoundUri.isEmpty ? null : _selectedSoundUri),
                    createdAt: Value(widget.alarm?.createdAt ?? nowEpoch),
                    updatedAt: Value(nowEpoch),
                  );

                  await itemDao.upsertItem(companion);

                  // Schedule through the single scheduling path — recurring
                  // weekday alarms become native weekly OS repeats that fire
                  // even when the app process is dead.
                  final savedItem = await itemDao.getById(alarmId);
                  if (savedItem != null) {
                    final outcome = await ref
                        .read(reminderSchedulingServiceProvider)
                        .syncForItem(savedItem, soundUri: _selectedSoundUri);
                    if (outcome.usedInexactFallback && mounted) {
                      messenger.showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Exact alarms unavailable — this alarm may ring a few minutes late.')),
                      );
                    }
                  }

                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(isEditing ? 'SAVE CHANGES' : 'SET ALARM'),
              ),
            ),
            const SizedBox(height: AuraSpacing.sm),
          ],
        ),
      ),
    );
  }
}
