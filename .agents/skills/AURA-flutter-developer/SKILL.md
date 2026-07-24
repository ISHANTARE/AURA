---
name: AURA-flutter-developer
description: >
  Expert Flutter/Dart developer for the AURA app. Use this skill when: writing Flutter code,
  implementing UI components, working with Drift ORM, implementing Android platform channels,
  building the voice capture pipeline, implementing notifications, adding animations, fixing
  Flutter-specific bugs, or when the user says "write the Flutter code for X", "implement X in Flutter",
  "fix this Dart error", "how do I do X in Flutter", "implement the Drift schema", or "add X widget".
  This skill covers Phase 8 implementation work.
---

# AURA Flutter Developer

You are implementing AURA in Flutter/Dart. Always implement from the spec — the PRD and ADRs must exist
before you write code. If they don't exist, tell the user to document first.

## Tech Stack (Per ADR-006 and ADR-011)

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (latest stable) |
| Language | Dart |
| Local DB | Drift ORM on SQLite |
| State Management | Riverpod (preferred) or BLoC |
| AI/NLP | Gemini 2.0 Flash via REST API |
| STT | Android SpeechRecognizer via platform channel |
| OCR | Google ML Kit Text Recognition |
| Notifications | flutter_local_notifications |
| Platform channels | MethodChannel for Android-specific features |
| **Icons** | **`lucide_icons` — ONLY icon set. No emojis. No Material Icons. (ADR-012)** |

## Architecture Pattern

Use Clean Architecture with these layers:
```
presentation/     <- Flutter widgets and screens
  screens/
  widgets/
  providers/      <- Riverpod providers

domain/           <- Business logic
  entities/       <- Pure Dart models (Task, Workspace, Reminder...)
  repositories/   <- Abstract interfaces
  usecases/       <- Single-purpose use case classes

data/             <- Data sources
  local/          <- Drift database, DAOs
  remote/         <- Gemini API client, future cloud sync
  repositories/   <- Concrete implementations
```

## Core Data Models

```dart
// Task entity
class Task {
  final String id;
  final String name;
  final DateTime? deadline;
  final int estimatedHours;
  final Priority priority;
  final String workspaceId;  // non-nullable, ADR-005
  final String? contact;
  final List<Reminder> reminders;
  final List<Subtask> subtasks;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
}

// Workspace entity
class Workspace {
  final String id;
  final String name;
  final Color color;
  final String emoji;
  final DateTime createdAt;
}

// Reminder entity
class Reminder {
  final String id;
  final String taskId;
  final DateTime fireAt;
  final ReminderType type;
  final bool hasFired;
  final bool missedDueToDND;  // ADR-009
}
```

## Drift Database Guidelines

- Every table must have a non-nullable workspaceId foreign key (ADR-005)
- Always write migrations for schema changes
- Use DAOs for data access, never query directly from UI
- Add indexes on frequently filtered columns (deadline, workspaceId, priority)

```dart
// Example DAO pattern
@DriftAccessor(tables: [Tasks, Workspaces, Reminders])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(AppDatabase db) : super(db);
  
  Stream<List<Task>> watchTasksByWorkspace(String workspaceId) =>
    (select(tasks)..where((t) => t.workspaceId.equals(workspaceId))
      ..orderBy([(t) => OrderingTerm(expression: t.deadline)])).watch();
}
```

## Voice Pipeline Implementation

```
User taps floating button
  -> Start Android SpeechRecognizer (via MethodChannel)
  -> Stream audio -> Display live transcription
  -> User stops speaking (silence detection or tap)
  -> Send transcript to Gemini API
  -> Parse intent JSON response
  -> Show confirmation card with parsed data
  -> User approves -> Write to Drift DB
  -> Trigger notifications setup
  -> Show success feedback
```

## UI Standards

- Dark mode default. Use ThemeData with darkTheme as primary.
- Color system: use workspace colors as accent colors throughout.
- Typography: Use Google Fonts (Inter or Plus Jakarta Sans).
- Animations: Always use AnimationController with curved animations.
- Minimum tap target: 48x48dp.
- Use Hero transitions for navigation between related screens.
- Haptic feedback on all primary actions: HapticFeedback.mediumImpact().

## Key UI Components to Build

- FloatingCaptureButton — persistent overlay, Android Accessibility/Overlay permission
- WorkspaceCard — colorful card with emoji, task count, deadline summary
- TaskCard — task name, deadline countdown chip, workspace color indicator, priority badge
- ConfirmationCard — AI parsed result with edit fields, approve/reject buttons
- MorningBriefingScreen — daily AI summary, timeline for the day
- UnifiedTimeline — all tasks + events in chronological order
- CalendarViews — Daily, Weekly, Monthly, Kanban, Priority, Deadline

## Offline Behavior Rules

Per ADR-002, implement these patterns:
- Check connectivity before every AI/network call
- Queue voice inputs to a local queue table when offline
- Process queue automatically when connectivity returns
- Show subtle offline indicator (not disruptive, not blocking)
- NEVER show an error that says "please connect to internet" for core features

## Android Platform Channels Required

```dart
// Channels to implement
static const overlayChannel = MethodChannel('aura/overlay');
static const dndChannel = MethodChannel('aura/dnd');
static const speechChannel = MethodChannel('aura/speech');
static const shareChannel = MethodChannel('aura/share');
```

## Gemini API Integration

```dart
// Intent extraction prompt pattern
const systemPrompt = """
You are AURA's intent parser. Extract structured data from the user's voice input.
Return ONLY valid JSON matching the schema below. If uncertain about a field, set it to null.
Never invent data the user did not mention.

Schema: { task_name, deadline_iso, reminders: [{offset_minutes, type}], workspace_hint, priority, notes }
""";
```

Always handle:
- API timeout (5 second max)
- Rate limit errors (Gemini free tier: 15 req/min)
- Malformed JSON response (retry once, then show manual entry)
- Offline state (queue for later processing)

## Code Quality Rules

- Every public function must have a doc comment
- No magic numbers — use named constants
- No hardcoded strings — use l10n or constants file
- No print() in production — use a Logger class
- Every async function must handle errors with try/catch
- Use const constructors wherever possible for performance
