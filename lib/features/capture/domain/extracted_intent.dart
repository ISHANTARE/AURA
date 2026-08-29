/// Model for a reminder offset extracted by the intent parser.
class ExtractedReminder {
  final int offsetValue;
  final String offsetUnit; // 'minutes' | 'hours' | 'days'
  final String type; // 'notification' | 'alarm'

  const ExtractedReminder({
    required this.offsetValue,
    this.offsetUnit = 'minutes',
    this.type = 'notification',
  });

  factory ExtractedReminder.fromJson(Map<String, dynamic> json) {
    return ExtractedReminder(
      offsetValue: (json['offset_value'] as num?)?.toInt() ?? 0,
      offsetUnit: json['offset_unit'] as String? ?? 'minutes',
      type: json['type'] as String? ?? 'notification',
    );
  }

  Map<String, dynamic> toJson() => {
        'offset_value': offsetValue,
        'offset_unit': offsetUnit,
        'type': type,
      };
}

/// Structured AI intent metadata extracted from spoken voice or text transcript.
class ExtractedIntent {
  final String intentType; // 'create_task' | 'create_reminder' | 'create_event' | 'create_alarm' | 'create_workspace' | 'delete_task' | 'delete_workspace' | 'add_note'
  final String? title;
  final String? targetName;
  final String? deadlineIso;
  final String? eventStartIso;
  final String? eventEndIso;
  final String? eventLocation;
  final String? workspaceHint;
  final String? workspaceColorHex;
  final String? workspaceIconKey;
  final String? priority; // 'high' | 'medium' | 'low'
  final bool isRecurring;
  final String? recurrenceType; // 'daily' | 'weekly' | 'custom'
  final List<ExtractedReminder> reminders;
  final String? notes;
  final double confidence;

  const ExtractedIntent({
    required this.intentType,
    this.title,
    this.targetName,
    this.deadlineIso,
    this.eventStartIso,
    this.eventEndIso,
    this.eventLocation,
    this.workspaceHint,
    this.workspaceColorHex,
    this.workspaceIconKey,
    this.priority,
    this.isRecurring = false,
    this.recurrenceType,
    this.reminders = const [],
    this.notes,
    this.confidence = 1.0,
  });

  factory ExtractedIntent.fromJson(Map<String, dynamic> json) {
    final remindersList = (json['reminders'] as List<dynamic>?)
            ?.map((e) => ExtractedReminder.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return ExtractedIntent(
      intentType: json['intent_type'] as String? ?? 'create_task',
      title: json['title'] as String?,
      targetName: json['target_name'] as String?,
      deadlineIso: json['deadline_iso'] as String?,
      eventStartIso: json['event_start_iso'] as String?,
      eventEndIso: json['event_end_iso'] as String?,
      eventLocation: json['event_location'] as String?,
      workspaceHint: json['workspace_hint'] as String?,
      workspaceColorHex: json['workspace_color_hex'] as String?,
      workspaceIconKey: json['workspace_icon_key'] as String?,
      priority: json['priority'] as String?,
      isRecurring: json['is_recurring'] as bool? ?? false,
      recurrenceType: json['recurrence_type'] as String?,
      reminders: remindersList,
      notes: json['notes'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'intent_type': intentType,
        'title': title,
        'target_name': targetName,
        'deadline_iso': deadlineIso,
        'event_start_iso': eventStartIso,
        'event_end_iso': eventEndIso,
        'event_location': eventLocation,
        'workspace_hint': workspaceHint,
        'workspace_color_hex': workspaceColorHex,
        'workspace_icon_key': workspaceIconKey,
        'priority': priority,
        'is_recurring': isRecurring,
        'recurrence_type': recurrenceType,
        'reminders': reminders.map((e) => e.toJson()).toList(),
        'notes': notes,
        'confidence': confidence,
      };

  ExtractedIntent copyWith({
    String? intentType,
    String? title,
    String? targetName,
    String? deadlineIso,
    String? eventStartIso,
    String? eventEndIso,
    String? eventLocation,
    String? workspaceHint,
    String? workspaceColorHex,
    String? workspaceIconKey,
    String? priority,
    bool? isRecurring,
    String? recurrenceType,
    List<ExtractedReminder>? reminders,
    String? notes,
    double? confidence,
  }) {
    return ExtractedIntent(
      intentType: intentType ?? this.intentType,
      title: title ?? this.title,
      targetName: targetName ?? this.targetName,
      deadlineIso: deadlineIso ?? this.deadlineIso,
      eventStartIso: eventStartIso ?? this.eventStartIso,
      eventEndIso: eventEndIso ?? this.eventEndIso,
      eventLocation: eventLocation ?? this.eventLocation,
      workspaceHint: workspaceHint ?? this.workspaceHint,
      workspaceColorHex: workspaceColorHex ?? this.workspaceColorHex,
      workspaceIconKey: workspaceIconKey ?? this.workspaceIconKey,
      priority: priority ?? this.priority,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      reminders: reminders ?? this.reminders,
      notes: notes ?? this.notes,
      confidence: confidence ?? this.confidence,
    );
  }
}

/// The result returned by intent extraction (either online LLM or offline fallback).
class ExtractOutcome {
  final ExtractedIntent intent;
  final String rawTranscript;
  final bool isOffline;
  final String? fallbackNotice;

  const ExtractOutcome({
    required this.intent,
    required this.rawTranscript,
    this.isOffline = false,
    this.fallbackNotice,
  });
}
