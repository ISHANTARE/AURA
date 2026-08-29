# AURA Rebuild Documentation — Master Index

> **This is the single source of truth for reconstructing the AURA application from scratch.**  
> If you have only this `overhaul-docs/` folder and nothing else, you have everything needed to rebuild AURA without guessing.

---

## What Is AURA?

**AURA** (AI-Unified Reality Assistant) is Ishan T's personal, voice-first, AI-native personal assistant for Android, built in Flutter. It is not a productivity tool — it is a personal assistant that removes friction from the human-to-intent pipeline.

### The Single User-Facing Promise

> *Tap the orb → Speak a thought → AURA understands it → It is captured, scheduled, and remembered, even when you are offline or your screen is off.*

Every technical decision, every architectural trade-off, and every line of documentation must serve this promise.

---

## 10 Non-Negotiable Principles

These override any "but the code says X" argument:

| # | Principle | Concrete Enforcement |
|---|---|---|
| 1 | **Privacy First** | No analytics, no remote telemetry, no third-party SDKs that phone home. Audio stays on-device before submission. |
| 2 | **Offline First** | Voice captures while offline queue to SQLite and drain automatically when connectivity returns. The queue processor must be kept alive — not just initialized. |
| 3 | **Voice First** | The floating orb must always be reachable. Voice capture route (`/capture-overlay`) is whitelisted pre-onboarding. |
| 4 | **Human in the Loop** | Every AI interpretation is shown to the user in an editable confirmation card before any DB write. Destructive offline actions are NEVER executed silently. |
| 5 | **Workspaces Over Chaos** | Every item must have a workspace. AI workspace routing must offer a "create?" fallback. |
| 6 | **Data Model Ownership** | Drift v4 is the only ORM. Schema migrations must be additive and versioned. `items` is the universal entity table — events, tasks, reminders, and alarms are differentiated by `kind` + `category`. |
| 7 | **Premium Feel Always** | OLED dark theme, accent micro-animations, glassmorphism overlays, and haptic feedback on confirmations. |
| 8 | **Simplicity Over Features** | No feature is added until the core capture→confirm→schedule pipeline is solid. |
| 9 | **Build for Yourself First** | Ishan T is the primary user. All UX defaults, sample data, and timezone handling reflect India Standard Time and VIT Vellore context. |
| 10 | **Document Everything** | This folder is the product. If a behavior is not here, it does not exist. |

---

## Document Map

| Doc | File | Contents |
|---|---|---|
| **01** | [01-tech-stack.md](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/01-tech-stack.md) | Exact versions of all production + dev dependencies, Android SDK config, Proguard rules, manifest permissions. |
| **02** | [02-architecture.md](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/02-architecture.md) | Dual FlutterEngine caching, Riverpod DI graph, clean architecture layers, GoRouter whitelist, and lifecycle hooks. |
| **03** | [03-database-schema.md](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/03-database-schema.md) | All 11 Drift v4 table schemas (exact column types + defaults), v1→v4 migration code, and all DAOs. |
| **04** | [04-ai-pipeline.md](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/04-ai-pipeline.md) | Provider presets, config hierarchy, verbatim system prompt, JSON extraction strategies, LocalIntentParser regexes, workspace taxonomy router. |
| **05** | [05-platform-channels.md](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/05-platform-channels.md) | All Kotlin native components with MethodChannel/EventChannel signatures, Orb gestures, Speech streams, DND broadcast, Share payload. |
| **06** | [06-features/](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/06-features/) | Per-feature forensic specs (see table below). |
| **07** | [07-known-bugs.md](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/07-known-bugs.md) | Forensic bug registry with root causes and verified resolution invariants. |
| **08** | [08-design-system.md](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/08-design-system.md) | Complete color token table (exact hex values), 6 accent variants, typography, spacing grid, component primitives, animations. |
| **09** | [09-startup-sequence.md](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/09-startup-sequence.md) | Cold start steps, `initState()` hooks, `_onAppActive()` job chain, background action dispatch, boot recovery. |
| **10** | [10-testing-strategy.md](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/10-testing-strategy.md) | Verified 81/81 test suite inventory, testability requirements, coverage targets. |

### Feature Files (`06-features/`)

| File | Feature |
|---|---|
| [00-home-screen.md](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/06-features/00-home-screen.md) | Daily Cockpit Bento Grid, Date Navigator, Agenda Timeline, Overdue Triage. |
| [01-voice-capture.md](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/06-features/01-voice-capture.md) | Voice Capture state machine, silence detection, waveform, confirmation cards, offline queuing. |
| [02-reminders-alarms.md](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/06-features/02-reminders-alarms.md) | Android notification channels, FNV-1a ID codec, scheduling authoritative path, recurrence grammar, DND replay, snooze presets. |
| [03-morning-briefing.md](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/06-features/03-morning-briefing.md) | Briefing scheduler logic (7 AM default, 9 AM fallback, 1×/day guard), screen layout, NudgeEngine rules. |
| [04-workspaces.md](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/06-features/04-workspaces.md) | Workspace CRUD, section grouping, archiving, cascading soft-delete, AI taxonomy routing (4-tier). |
| [05-onboarding.md](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/06-features/05-onboarding.md) | 4-slide carousel, permission requests, workspace seeding, OnboardingGateNotifier route guard. |
| [06-settings-and-task-detail.md](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/06-features/06-settings-and-task-detail.md) | All 10 settings sections (exact keys + defaults), FK-safe cascading Reset, Task Detail full editing model. |
| [07-share-and-offline-queue.md](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/06-features/07-share-and-offline-queue.md) | Share target MIME types, 24h cache purge, on-device OCR, link scraper, offline queue drain with destructive-action safeguard. |

---

## Reconstruction Verdict

**A developer or AI agent with ONLY this `overhaul-docs/` folder CAN reconstruct AURA without meaningful guessing.**

The documentation specifies:
- Exact Dart/Kotlin class names and file paths for all components.
- Exact column definitions and types for all 11 database tables, including migration steps.
- The verbatim system prompt sent to the LLM.
- Exact regex patterns used by `LocalIntentParser` for offline intent extraction.
- The exact FNV-1a hash algorithm with seed values used for collision-resistant notification IDs.
- The exact MethodChannel names, method names, argument keys, and return types for all 5 platform channels.
- Exact `SharedPreferences` keys and their defaults for every user-configurable setting.
- The exact 6-step `_onAppActive()` job chain and their execution order.
- All 81 passing test cases categorized by domain.
