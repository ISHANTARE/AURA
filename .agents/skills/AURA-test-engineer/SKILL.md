---
name: AURA-test-engineer
description: >
  Test engineer and verification specialist for AURA. Use this skill when: writing or updating unit,
  domain, database, or widget tests, running flutter test, configuring in-memory Drift test databases,
  mocking platform channels, testing Riverpod state notifiers, verifying the 81/81 test suite,
  or when the user says "run the tests", "write a test for X", "verify test suite", "fix test failure",
  or "mock platform channel".
---

# AURA Test Engineer

You are responsible for writing, maintaining, and verifying the complete test suite for AURA.
Every domain use case, database DAO, NLP parser, rate limiter, ID codec, and scheduler must
have automated, deterministic unit tests.

> **Source of truth**: `overhaul-docs/10-testing-strategy.md`

---

## 1. Test Suite Invariant: 81 Verified Tests

AURA has **81 verified unit and integration tests across 17 test files**. All 81 tests must pass with zero warnings and zero failures:

```bash
flutter test --reporter expanded
```

---

## 2. Test Suite Architecture

```
test/
├── core/
│   └── phase2_sorting_theme_test.dart       # Priority sorting and theme defaults
├── database/
│   └── app_database_test.dart               # In-memory SQLite, 11 tables, WAL, FK cascades
└── features/
    ├── capture/
    │   ├── llm_api_datasource_test.dart     # Provider hierarchy, JSON extraction, fallbacks
    │   ├── rate_limiter_test.dart           # 12 req / 60s sliding window, clock injection
    │   ├── local_intent_parser_test.dart    # Regex patterns (alarm, task, ws, note, delete)
    │   ├── workspace_router_test.dart       # 4-tier match (exact, fuzzy, taxonomy, suggest)
    │   ├── offline_queue_processor_test.dart# FIFO queue, connectivity drain, 5 retry cap
    │   ├── execute_ai_action_usecase_test.dart # Action dispatching & DB persistence
    │   └── execute_ai_action_timed_test.dart# Timed actions, events, alarms
    ├── home/
    │   ├── day_cockpit_test.dart            # Day agenda timed vs checklist separation
    │   └── greeting_test.dart               # Time-aware personalized greeting
    ├── onboarding/
    │   └── onboarding_gate_test.dart        # Route guard state & reset behavior
    ├── reminders/
    │   ├── notification_ids_test.dart       # FNV-1a positive int31 hash & reserved slots
    │   ├── reminder_scheduling_service_test.dart # syncForItem, cancelForItem, grace window
    │   ├── recurrence_resolver_test.dart    # DAYS:1,3,5, daily, weekly, specific date
    │   └── exact_alarm_diagnostics_test.dart# Exact vs inexact scheduling capabilities
    └── widget_test.dart                     # App rendering, BottomNav 5 tabs
```

---

## 3. Dependency Injection & Mock Patterns

### 3.1 In-Memory Drift Database for Tests
```dart
import 'package:drift/native.dart';
import 'package:aura/database/app_database.dart';

AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(
    NativeDatabase.memory(
      setup: (db) {
        db.execute('PRAGMA foreign_keys = ON');
      },
    ),
  );
}
```

### 3.2 Injectable Clock for Deterministic Time
```dart
DateTime fakeNow = DateTime(2026, 8, 29, 14, 30);
final scheduler = ReminderSchedulingService(
  database: testDb,
  notifications: mockNotificationService,
  clock: () => fakeNow,
);
```

### 3.3 Mocking Platform Channels in Tests
```dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void setupMockPlatformChannels() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock overlay channel
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('aura/overlay'),
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'isOverlayRunning':
          return false;
        case 'checkOverlayPermission':
          return true;
        default:
          return null;
      }
    },
  );

  // Mock DND channel
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('com.aura.aura/dnd'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'isDndActive') return false;
      return null;
    },
  );
}
```

### 3.4 Riverpod ProviderContainer Testing
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final container = ProviderContainer(
  overrides: [
    databaseProvider.overrideWithValue(testDb),
    clockProvider.overrideWithValue(() => fakeNow),
  ],
);
addTearDown(container.dispose);
```

---

## 4. Test Verification Checklist

Before reporting any feature or refactor as complete, execute:
1. `flutter test test/database/` — Ensure zero DB schema/migration/FK regressions.
2. `flutter test test/features/capture/` — Verify AI JSON extraction, regex parser, and rate limiter.
3. `flutter test test/features/reminders/` — Verify FNV-1a IDs, scheduling grace window, and recurrence.
4. `flutter test` — Run full suite; verify 81/81 pass.
