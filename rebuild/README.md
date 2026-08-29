# AURA Rebuild Master Plan & Sprint Index

> **Sole Truth Reference:** [`overhaul-docs/`](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/)  
> **Target Package:** `com.aura.aura`  
> **Platform Target:** Android 8.0+ (API 26+)  
> **UI Framework:** Flutter 3.22+ (Material 3) with Dual FlutterEngine Android Native Integration  

---

## 1. Reconstruction Master Phase & Sprint Map

```
Phase 1: Project Scaffolding & Dependencies (Sprints 1.1 – 1.3)
   │
Phase 2: Design System & Core Tokens (Sprints 2.1 – 2.3)
   │
Phase 3: Drift Database & Persistence Layer (Sprints 3.1 – 3.4)
   │
Phase 4: Core Infrastructure, Security & Routing (Sprints 4.1 – 4.4)
   │
Phase 5: AI Pipeline, BYOK & Offline Intent NLP (Sprints 5.1 – 5.4)
   │
Phase 6: Android Native Subsystem in Kotlin (Sprints 6.1 – 6.4)
   │
Phase 7: Presentation & Feature UI Screens (Sprints 7.1 – 7.6)
   │
Phase 8: App Lifecycle, Job Chain & Background Sync (Sprints 8.1 – 8.3)
   │
Phase 9: Comprehensive 81/81 Test Suite Verification (Sprints 9.1 – 9.3)
```

---

## 2. Sprint Documents Directory

| Phase Document | Phase Name | Sprints Covered | Primary Overhaul Docs |
|---|---|---|---|
| [`phase-01-scaffolding.md`](file:///c:/Users/Admin/VIT_Projects/AURA/rebuild/phase-01-scaffolding.md) | Project Scaffolding & Dependencies | Sprint 1.1: Project Init & Namespace<br>Sprint 1.2: Dependency Configuration<br>Sprint 1.3: Static Analysis & Assets | [`01-tech-stack.md`](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/01-tech-stack.md) |
| [`phase-02-design-system.md`](file:///c:/Users/Admin/VIT_Projects/AURA/rebuild/phase-02-design-system.md) | Design System & Tokens | Sprint 2.1: OLED Palette & 6 Accents<br>Sprint 2.2: Typography & Spacing Scales<br>Sprint 2.3: Theme Provider & Notifiers | [`08-design-system.md`](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/08-design-system.md) |
| [`phase-03-database.md`](file:///c:/Users/Admin/VIT_Projects/AURA/rebuild/phase-03-database.md) | Drift Database & Persistence | Sprint 3.1: 11 Drift Table Schemas<br>Sprint 3.2: v1→v4 Migration Strategy<br>Sprint 3.3: 5 Type-Safe DAOs<br>Sprint 3.4: CodeGen & DB Test Pass | [`03-database-schema.md`](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/03-database-schema.md) |
| [`phase-04-core-infrastructure.md`](file:///c:/Users/Admin/VIT_Projects/AURA/rebuild/phase-04-core-infrastructure.md) | Core Infrastructure & Routing | Sprint 4.1: Keystore SecretStore & Prefs<br>Sprint 4.2: FNV-1a Notification IDs<br>Sprint 4.3: Recurrence, DND & Notifications<br>Sprint 4.4: GoRouter & Gate Notifier | [`02-architecture.md`](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/02-architecture.md)<br>[`02-reminders-alarms.md`](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/06-features/02-reminders-alarms.md) |
| [`phase-05-ai-pipeline.md`](file:///c:/Users/Admin/VIT_Projects/AURA/rebuild/phase-05-ai-pipeline.md) | AI Intent & Offline NLP | Sprint 5.1: Sliding-Window RateLimiter<br>Sprint 5.2: LLM Client & 6 BYOK Presets<br>Sprint 5.3: LocalIntentParser Regexes<br>Sprint 5.4: WorkspaceRouter & Actions | [`04-ai-pipeline.md`](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/04-ai-pipeline.md) |
| [`phase-06-native-android.md`](file:///c:/Users/Admin/VIT_Projects/AURA/rebuild/phase-06-native-android.md) | Native Kotlin Subsystems | Sprint 6.1: Gradle, Manifest & Permissions<br>Sprint 6.2: Dual Engine & Floating Orb Service<br>Sprint 6.3: SpeechRecognizer & RMS Stream<br>Sprint 6.4: Share, Tile & Boot Receiver | [`05-platform-channels.md`](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/05-platform-channels.md) |
| [`phase-07-features-ui.md`](file:///c:/Users/Admin/VIT_Projects/AURA/rebuild/phase-07-features-ui.md) | Presentation & Feature UI | Sprint 7.1: UI Primitives & Navigation<br>Sprint 7.2: Home Screen Bento Cockpit<br>Sprint 7.3: Voice Capture & Overlay<br>Sprint 7.4: Workspaces & Kanban<br>Sprint 7.5: Alarms, Reminders & Sheets<br>Sprint 7.6: Briefing, Settings & Onboarding | [`06-features/`](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/06-features/) |
| [`phase-08-lifecycle-background.md`](file:///c:/Users/Admin/VIT_Projects/AURA/rebuild/phase-08-lifecycle-background.md) | Lifecycle & Background Sync | Sprint 8.1: App Lifecycle Observer<br>Sprint 8.2: `_onAppActive()` 6-Job Chain<br>Sprint 8.3: Background Actions & Queue Drain | [`09-startup-sequence.md`](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/09-startup-sequence.md) |
| [`phase-09-testing-verification.md`](file:///c:/Users/Admin/VIT_Projects/AURA/rebuild/phase-09-testing-verification.md) | Test Suite Verification (81/81) | Sprint 9.1: Database, Scheduler & Intent Tests<br>Sprint 9.2: Domain UseCase & Notifier Tests<br>Sprint 9.3: Widget & Full Suite (81/81) | [`10-testing-strategy.md`](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/10-testing-strategy.md) |

---

## 3. Progress Tracking Dashboard

- [x] **Phase 1: Project Scaffolding & Dependencies** (3/3 Sprints Complete)
- [x] **Phase 2: Design System & Core Constants** (3/3 Sprints Complete)
- [x] **Phase 3: Drift Database & Persistence Layer** (4/4 Sprints Complete)
- [x] **Phase 4: Core Infrastructure, Security & Routing** (4/4 Sprints Complete)
- [x] **Phase 5: AI Intent Pipeline & Offline NLP** (4/4 Sprints Complete)
- [ ] **Phase 6: Native Android Subsystem (Kotlin)** (0/4 Sprints Complete)
- [ ] **Phase 7: Presentation & Feature UI Screens** (0/6 Sprints Complete)
- [ ] **Phase 8: App Lifecycle & Background Synchronization** (0/3 Sprints Complete)
- [ ] **Phase 9: Comprehensive 81/81 Test Suite Verification** (0/3 Sprints Complete)



