---
name: AURA-rebuild-orchestrator
description: >
  Master reconstruction and build orchestrator for AURA. Use this skill when: rebuilding the AURA
  app from scratch using overhaul-docs/, bootstrapping a clean project, coordinating the multi-phase
  rebuild workflow, verifying build steps, running code generators (build_runner / drift_dev),
  or when the user says "rebuild the app", "start rebuilding", "scaffold the project", "execute rebuild",
  or "what is the next rebuild step".
---

# AURA Rebuild Orchestrator

You are the master coordinator for rebuilding AURA from scratch using the specifications in `overhaul-docs/`.
Your mission is to guide and execute the reconstruction systematically, ensuring zero regressions,
zero architectural violations, and 100% compliance with the verified design system, database schema,
and 81/81 test suite.

---

## 1. Golden Rule of Reconstruction

> **Document Decides. Code Follows.**  
> Every file, class, table, token, and channel must be implemented strictly from `overhaul-docs/`.
> Never invent ad-hoc patterns or deviate from the established architecture.

---

## 2. Rebuild Phase Order (Strict Dependency Flow)

```
┌─────────────────────────────────────────────────────────────┐
│ Phase 1: Project Scaffolding & Dependencies                 │
│ - Flutter create com.aura.aura (org: com.aura, project: aura)│
│ - pubspec.yaml (exact pinned dependencies)                  │
│ - analysis_options.yaml (strict linting)                    │
│ - .gitignore & assets/ & fonts setup                        │
├─────────────────────────────────────────────────────────────┤
│ Phase 2: Design System & Core Constants                     │
│ - AuraColors (OLED dark theme tokens + 6 theme accents)     │
│ - AuraTypography (Inter + JetBrains Mono)                   │
│ - AuraSpacing & AuraRadius scales                           │
│ - ThemeProvider & ThemeModeNotifier                         │
├─────────────────────────────────────────────────────────────┤
│ Phase 3: Drift Database & Persistence Layer                 │
│ - 11 Drift table definitions (schema v4)                    │
│ - MigrationStrategy (v1 -> v2 -> v3 -> v4)                  │
│ - 5 DAOs (ItemDao, WorkspaceDao, NotificationDao, etc.)     │
│ - Run `dart run build_runner build --delete-conflicting-outputs`
│ - Pass `test/database/app_database_test.dart`               │
├─────────────────────────────────────────────────────────────┤
│ Phase 4: Core Infrastructure & Navigation                   │
│ - SecretStore (Android Keystore via FlutterSecureStorage)   │
│ - NotificationIds (FNV-1a 32-bit positive hash)             │
│ - RecurrenceResolver & DndService                           │
│ - NotificationService (channels, permissions, background)   │
│ - GoRouter configuration & OnboardingGateNotifier           │
├─────────────────────────────────────────────────────────────┤
│ Phase 5: AI & NLP Intent Pipeline                           │
│ - RateLimiter (12 req / 60s sliding window)                 │
│ - LlmApiDataSource (6 provider presets, JSON extraction)    │
│ - LocalIntentParser (5 regex offline patterns)              │
│ - WorkspaceRouterUseCase (4-tier taxonomy engine)           │
│ - ExecuteAiActionUseCase (Action dispatcher)                │
│ - OfflineQueueProcessor (Connectivity-driven FIFO drain)    │
├─────────────────────────────────────────────────────────────┤
│ Phase 6: Native Android Subsystem (Kotlin)                  │
│ - AndroidManifest.xml permissions & component declarations  │
│ - build.gradle.kts (NDK, Java 11, desugaring)               │
│ - MainActivity (dual engine prewarming)                     │
│ - AuraOverlayService (Canvas floating orb)                  │
│ - AuraSpeechChannel (SpeechRecognizer + EventChannels)      │
│ - AuraShareActivity, AuraTileService, AuraBootReceiver      │
├─────────────────────────────────────────────────────────────┤
│ Phase 7: Presentation & Feature UI Screens                  │
│ - Core primitives: BentoCard, Glassmorphism, AuraBottomNav  │
│ - Home Screen (Bento Grid, Date Navigator, Day Agenda)      │
│ - Voice Capture Overlay & Confirmation Cards                │
│ - Workspaces Screen & Kanban Detail                         │
│ - Alarms & Reminders Screens + Snooze Sheets                │
│ - Morning Briefing & Notes Screens                          │
│ - Settings Screen & Onboarding 5-step wizard                │
├─────────────────────────────────────────────────────────────┤
│ Phase 8: Lifecycle & Background Synchronization             │
│ - AuraApp WidgetsBindingObserver implementation             │
│ - _onAppActive() 6-job chain with error isolation           │
│ - Background notification action handler entry point        │
├─────────────────────────────────────────────────────────────┤
│ Phase 9: Test Suite Verification (81/81)                    │
│ - Implement all 17 test files                               │
│ - Run `flutter test` -> 81 passed, 0 failures               │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. Pre-Rebuild Verification Checklist

Before starting Phase 1, verify:
- [x] Workspace directory is clean on branch `Ver3`
- [x] `overhaul-docs/` is intact with all 11 documents
- [x] Flutter SDK is available on path (`flutter --version`)
- [x] Target application namespace is `com.aura.aura`

---

## 4. Key Tooling Commands Reference

```bash
# Code generation for Drift & Riverpod
dart run build_runner build --delete-conflicting-outputs

# Static analysis
flutter analyze

# Run full test suite
flutter test --reporter expanded

# Build Android APK (debug validation)
flutter build apk --debug
```
