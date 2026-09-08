# AURA — AI-Unified Reality Assistant

<div align="center">

**One tap. You speak. Life organizes itself.**

*A voice-first, AI-native personal life OS for Android. Built in Flutter.*

[![Made by Ishan Tare](https://img.shields.io/badge/Author-Ishan%20Tare-7C3AED?style=flat-square)](https://github.com/ISHANTARE)
[![License](https://img.shields.io/badge/License-Proprietary-red?style=flat-square)](./LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?style=flat-square&logo=android)](https://flutter.dev)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter)](https://flutter.dev)

</div>

---

> **© 2026 Ishan Tare. All rights reserved.**  
> This is proprietary software. See [LICENSE](./LICENSE) before doing anything with this code.

---

## What Is AURA?

AURA is not a productivity app. It's a personal assistant that eliminates the friction between a thought in your head and that thought being captured, scheduled, and acted upon — without you ever opening a note-taking app, a calendar, or a task manager.

**The single promise:**
> *Tap the floating orb → speak a thought → AURA understands it → it is captured, scheduled, and remembered — even offline, even when your screen is off.*

---

## Core Features

| Feature | What It Does |
|---|---|
| 🎙️ **Voice Capture** | One-tap floating orb. Speak anything. AI extracts tasks, reminders, events. |
| 🧠 **AI Intent Parser** | Gemini 2.0 Flash + local regex fallback. Works fully offline. |
| 📅 **Daily Cockpit** | Bento-grid home screen. Date navigator. Agenda timeline. Overdue triage. |
| 🌅 **Morning Briefing** | 7 AM daily summary. NudgeEngine. Smart scheduling. |
| 🗂️ **Workspaces** | Every item belongs to a workspace. AI routes automatically. |
| 🔔 **DND-Aware Notifications** | No notification is ever silently dropped. FNV-1a ID codec. |
| 📷 **Share-to-AURA** | Share any image/link → on-device OCR (ML Kit) → captured as item. |
| ⚙️ **Settings & Task Detail** | Full editing model. FK-safe reset. 10 configurable sections. |

---

## Design Principles (Non-Negotiable)

1. **Privacy First** — No analytics. No remote telemetry. Audio stays on-device.
2. **Offline First** — Core features work with zero internet.
3. **Voice First** — One tap, speak, done. Text is always secondary.
4. **Human in the Loop** — AI suggests. You approve. Nothing happens silently.
5. **Premium Feel Always** — OLED dark theme. Glassmorphism. Haptic feedback.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart) |
| State Management | Riverpod 2.x |
| Navigation | GoRouter 14.x |
| Database | Drift ORM v4 + SQLite |
| AI / NLP | Gemini 2.0 Flash (free tier) + local regex fallback |
| Speech-to-Text | Android SpeechRecognizer API (on-device, free) |
| OCR | Google ML Kit Text Recognition (on-device) |
| Notifications | flutter_local_notifications + Android exact alarms |
| Platform Channels | 5 Kotlin native components (Orb, Speech, DND, Share, Alarm) |
| Icons | Lucide Icons only — no emoji, no Material Icons |

---

## Project Structure

```
aura/
├── lib/
│   ├── main.dart               # App entry point
│   ├── app.dart                # Root widget, router, providers
│   ├── core/
│   │   ├── constants/
│   │   │   └── aura_identity.dart   # Project identity & integrity constants
│   │   └── ...
│   ├── database/               # Drift ORM schema + DAOs
│   ├── features/               # Feature modules (home, capture, workspaces…)
│   └── platform/               # Flutter↔Kotlin platform channels
├── android/                    # Kotlin native layer
│   └── app/src/main/kotlin/
│       ├── AuraOverlayService  # Floating orb
│       ├── AuraSpeechChannel   # SpeechRecognizer bridge
│       ├── AuraDndChannel      # Do-Not-Disturb bridge
│       └── AuraShareActivity   # Share target
├── overhaul-docs/              # Complete architecture & rebuild documentation
│   ├── 00-overview/README.md   # Master index — start here
│   ├── 01-tech-stack.md
│   ├── 02-architecture.md
│   ├── 03-database-schema.md
│   ├── 04-ai-pipeline.md
│   ├── 05-platform-channels.md
│   ├── 06-features/            # Per-feature forensic specs
│   ├── 07-known-bugs.md
│   ├── 08-design-system.md
│   ├── 09-startup-sequence.md
│   └── 10-testing-strategy.md
├── aura-visuals/               # SVG screen mockups + design index
├── screenshots-by-ishan/       # Real device screenshots
├── docs/
│   └── security_threat_model.md
├── LICENSE                     # Proprietary — read before using
└── pubspec.yaml
```

---

## Documentation

All architecture, design decisions, and implementation specs live in [`overhaul-docs/`](./overhaul-docs/).

> Start with [`overhaul-docs/00-overview/README.md`](./overhaul-docs/00-overview/README.md) — it is the master index.

Key documents:
- **[Architecture](./overhaul-docs/02-architecture.md)** — Dual engine, Riverpod DI graph, clean layers
- **[Database Schema](./overhaul-docs/03-database-schema.md)** — All 11 Drift tables, migrations
- **[AI Pipeline](./overhaul-docs/04-ai-pipeline.md)** — System prompt, intent parser, workspace router
- **[Design System](./overhaul-docs/08-design-system.md)** — Color tokens, typography, animations

---

## Screenshots

<div align="center">
<i>Real device screenshots from active development builds.</i>
</div>

> See [`screenshots-by-ishan/`](./screenshots-by-ishan/) for full-resolution captures.

---

## Building (Authorized Contributors Only)

Prerequisites:
- Flutter 3.x SDK
- Android SDK (API 34+)
- JDK 17+
- A `.env` file with your Gemini API key (see `.env.example`)

```bash
# Get dependencies
flutter pub get

# Run code generation (Drift ORM)
dart run build_runner build --delete-conflicting-outputs

# Run on connected Android device
flutter run --release
```

> ⚠️ **You need explicit written permission from the author to build, modify, or distribute this project. See [LICENSE](./LICENSE).**

---

## Test Suite

AURA maintains an 81-test suite covering domain logic, database, and UI layers.

```bash
flutter test
```

See [`overhaul-docs/10-testing-strategy.md`](./overhaul-docs/10-testing-strategy.md) for the full inventory.

---

## Author

**Ishan Tare**  
GitHub: [@ISHANTARE](https://github.com/ISHANTARE)  
Email: ishan.tare2005@gmail.com

*"Common Sense is Uncommon."*

---

© 2026 Ishan Tare. All rights reserved. See [LICENSE](./LICENSE).
