/// Enum representing reminder trigger types
enum ReminderType {
  deadlineReminder,
  eventReminder,
  recurringReminder,
  morningBriefing,
  nudge,
  snoozeReplay,
  dndReplay,
}

extension ReminderTypeX on ReminderType {
  String toValue() {
    switch (this) {
      case ReminderType.deadlineReminder:
        return 'DEADLINE_REMINDER';
      case ReminderType.eventReminder:
        return 'EVENT_REMINDER';
      case ReminderType.recurringReminder:
        return 'RECURRING_REMINDER';
      case ReminderType.morningBriefing:
        return 'MORNING_BRIEFING';
      case ReminderType.nudge:
        return 'NUDGE';
      case ReminderType.snoozeReplay:
        return 'SNOOZE_REPLAY';
      case ReminderType.dndReplay:
        return 'DND_REPLAY';
    }
  }

  static ReminderType fromValue(String val) {
    switch (val.toUpperCase()) {
      case 'DEADLINE_REMINDER':
        return ReminderType.deadlineReminder;
      case 'EVENT_REMINDER':
        return ReminderType.eventReminder;
      case 'RECURRING_REMINDER':
        return ReminderType.recurringReminder;
      case 'MORNING_BRIEFING':
        return ReminderType.morningBriefing;
      case 'NUDGE':
        return ReminderType.nudge;
      case 'SNOOZE_REPLAY':
        return ReminderType.snoozeReplay;
      case 'DND_REPLAY':
        return ReminderType.dndReplay;
      default:
        return ReminderType.deadlineReminder;
    }
  }
}

/// Reminder Status enum
enum ReminderStatus {
  pending,
  fired,
  snoozed,
  dismissed,
  cancelled,
}

/// Preset durations for snoozing notifications
enum SnoozePreset {
  minutes30,
  hour1,
  tonight9pm,
  tomorrow8am,
  custom,
}

extension SnoozePresetX on SnoozePreset {
  String get label {
    switch (this) {
      case SnoozePreset.minutes30:
        return '+30 minutes';
      case SnoozePreset.hour1:
        return '+1 hour';
      case SnoozePreset.tonight9pm:
        return 'Tonight (9 PM)';
      case SnoozePreset.tomorrow8am:
        return 'Tomorrow (8 AM)';
      case SnoozePreset.custom:
        return 'Custom...';
    }
  }

  DateTime calculateTargetTime({DateTime? customTime}) {
    final now = DateTime.now();
    switch (this) {
      case SnoozePreset.minutes30:
        return now.add(const Duration(minutes: 30));
      case SnoozePreset.hour1:
        return now.add(const Duration(hours: 1));
      case SnoozePreset.tonight9pm:
        final tonight = DateTime(now.year, now.month, now.day, 21, 0);
        return tonight.isAfter(now) ? tonight : tonight.add(const Duration(days: 1));
      case SnoozePreset.tomorrow8am:
        final tomorrow = DateTime(now.year, now.month, now.day + 1, 8, 0);
        return tomorrow;
      case SnoozePreset.custom:
        return customTime ?? now.add(const Duration(hours: 1));
    }
  }
}
