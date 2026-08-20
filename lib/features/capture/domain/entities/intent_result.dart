/// Parsed reminder structure from AI extraction.
class ExtractedReminder {
  final int offsetValue;
  final String offsetUnit; // "minutes" | "hours" | "days"
  final String type; // "notification" | "alarm"

  const ExtractedReminder({
    required this.offsetValue,
    required this.offsetUnit,
    required this.type,
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

/// Structured AI intent extraction result from Agent 1 (Gemini / NVIDIA NIM).
class IntentResult {
  final String intentType; // "create_task" | "create_event" | "set_reminder" | "add_note" | "query" | "ambiguous"
  final String? title;
  final DateTime? deadline;
  final DateTime? eventStart;
  final DateTime? eventEnd;
  final String? eventLocation;
  final String? workspaceHint;
  final String? sectionHint;
  final String? priority; // "high" | "medium" | "low"
  final bool isRecurring;
  final String? recurrenceType; // "daily" | "weekly" | "custom"
  final List<String>? recurrenceDays;
  final List<ExtractedReminder> reminders;
  final String? notes;
  final String? contact;
  final String? targetTaskId;
  final String? targetWorkspaceId;
  final String? targetName;
  final String? workspaceColorHex;
  final String? workspaceIconKey;
  final double confidence; // 0.0 – 1.0 overall
  final double? titleConf;
  final double? deadlineConf;
  final double? workspaceConf;

  const IntentResult({
    required this.intentType,
    this.title,
    this.deadline,
    this.eventStart,
    this.eventEnd,
    this.eventLocation,
    this.workspaceHint,
    this.sectionHint,
    this.priority,
    this.isRecurring = false,
    this.recurrenceType,
    this.recurrenceDays,
    this.reminders = const [],
    this.notes,
    this.contact,
    this.targetTaskId,
    this.targetWorkspaceId,
    this.targetName,
    this.workspaceColorHex,
    this.workspaceIconKey,
    this.confidence = 1.0,
    this.titleConf,
    this.deadlineConf,
    this.workspaceConf,
  });

  factory IntentResult.fromJson(Map<String, dynamic> json) {
    DateTime? parseIso(dynamic value) {
      if (value == null || value is! String || value.isEmpty) return null;
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }

    final remindersList = (json['reminders'] as List<dynamic>?)
            ?.map((e) => ExtractedReminder.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final daysList = (json['recurrence_days'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList();

    return IntentResult(
      intentType: json['intent_type'] as String? ?? 'create_task',
      title: json['title'] as String?,
      deadline: parseIso(json['deadline_iso']),
      eventStart: parseIso(json['event_start_iso']),
      eventEnd: parseIso(json['event_end_iso']),
      eventLocation: json['event_location'] as String?,
      workspaceHint: json['workspace_hint'] as String?,
      sectionHint: json['section_hint'] as String?,
      priority: json['priority'] as String?,
      isRecurring: json['is_recurring'] as bool? ?? false,
      recurrenceType: json['recurrence_type'] as String?,
      recurrenceDays: daysList,
      reminders: remindersList,
      notes: json['notes'] as String?,
      contact: json['contact'] as String?,
      targetTaskId: json['target_task_id'] as String?,
      targetWorkspaceId: json['target_workspace_id'] as String?,
      targetName: json['target_name'] as String?,
      workspaceColorHex: json['workspace_color_hex'] as String?,
      workspaceIconKey: json['workspace_icon_key'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.8,
      titleConf: (json['title_conf'] as num?)?.toDouble(),
      deadlineConf: (json['deadline_conf'] as num?)?.toDouble(),
      workspaceConf: (json['workspace_conf'] as num?)?.toDouble(),
    );
  }

  IntentResult copyWith({
    String? intentType,
    String? title,
    DateTime? deadline,
    DateTime? eventStart,
    DateTime? eventEnd,
    String? eventLocation,
    String? workspaceHint,
    String? sectionHint,
    String? priority,
    bool? isRecurring,
    String? recurrenceType,
    List<String>? recurrenceDays,
    List<ExtractedReminder>? reminders,
    String? notes,
    String? contact,
    String? targetTaskId,
    String? targetWorkspaceId,
    String? targetName,
    String? workspaceColorHex,
    String? workspaceIconKey,
    double? confidence,
    double? titleConf,
    double? deadlineConf,
    double? workspaceConf,
  }) {
    return IntentResult(
      intentType: intentType ?? this.intentType,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      eventStart: eventStart ?? this.eventStart,
      eventEnd: eventEnd ?? this.eventEnd,
      eventLocation: eventLocation ?? this.eventLocation,
      workspaceHint: workspaceHint ?? this.workspaceHint,
      sectionHint: sectionHint ?? this.sectionHint,
      priority: priority ?? this.priority,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceDays: recurrenceDays ?? this.recurrenceDays,
      reminders: reminders ?? this.reminders,
      notes: notes ?? this.notes,
      contact: contact ?? this.contact,
      targetTaskId: targetTaskId ?? this.targetTaskId,
      targetWorkspaceId: targetWorkspaceId ?? this.targetWorkspaceId,
      targetName: targetName ?? this.targetName,
      workspaceColorHex: workspaceColorHex ?? this.workspaceColorHex,
      workspaceIconKey: workspaceIconKey ?? this.workspaceIconKey,
      confidence: confidence ?? this.confidence,
      titleConf: titleConf ?? this.titleConf,
      deadlineConf: deadlineConf ?? this.deadlineConf,
      workspaceConf: workspaceConf ?? this.workspaceConf,
    );
  }
}
