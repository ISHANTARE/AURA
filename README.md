# AURA — AI-Unified Reality Assistant

> **One tap. You speak. Life organizes itself.**

AURA is a voice-first, AI-native personal executive assistant built for mobile. It captures unstructured voice thoughts, extracts actionable intents (tasks, reminders, alarms, notes, calendar events), automatically routes them into contextual workspaces, and builds an optimal daily focus schedule — all while maintaining an offline-first, local-first privacy architecture.

---

## 🌟 Core Features

### 🎙️ One-Tap Voice Capture & Overlay

- **Floating Overlay / App Bar Button**: Trigger voice recording anywhere within the app or system-wide via Android platform overlay.
- **Natural Language Parsing**: High-accuracy intent extraction converting spoken sentences ("remind me tomorrow at 9am to submit assignment") into structured database records.
- **Confirmation Card**: Interactive confirmation popup allowing inline editing of title, due date, workspace, and reminder priority before finalizing.

### 📱 Bento Grid Home Dashboard

- **Quick Stats Row**: Real-time counters for pending tasks, upcoming alarms, active reminders, and workspaces.
- **Today's Focus**: Chronologically ordered view combining alarms, scheduled tasks, and due reminders for the current day.
- **Quick Actions**: One-touch creation for tasks, notes, alarms, and workspaces.

### ⏰ Advanced Alarm & Reminder System

- **Flexible Scheduling**: Set alarms for specific calendar dates or recurring days of the week (Mon–Sun).
- **Ringtone Picker**: Native Android audio picker integration to choose custom alarm ringtones.
- **Dynamic Theme Integration**: Adapts seamlessly to the active theme primary color.
- **Layered Reminders**: Support for multi-stage alerts (3 days before, 1 day before, 2 hours before).

### 🗂️ Workspace Context System

- **Context Separation**: Keep personal life, college, projects, and work organized in isolated workspaces.
- **Pending vs. Completed Sections**: Clean division between actionable items and completed task history without visually cluttering titles.
- **Workspace Actions**: Archive, edit, or color-code workspaces dynamically.

### 🌅 Morning Briefing

- **AI Daily Briefing**: Smart morning summary outlining top priorities, upcoming deadlines, and recommended focus areas for the day.

### 📝 Task & Subtask Management

- **Hierarchical Subtasks**: Create and track subtasks directly within parent task views.
- **Priority & Status**: Manage task priorities (`high`, `medium`, `low`) and reactive status transitions.

---

## 🛠️ Architecture & Tech Stack

| Layer | Technology | Description |
| ------- | ----------- | ------------- |
| **Frontend Framework** | Flutter (Dart 3.x) | Single codebase targeting Android & cross-platform |
| **State Management** | Riverpod | Reactive state management with code generation |
| **Local Database** | SQLite via Drift ORM | Offline-first relational storage with reactive streams |
| **Platform Channels** | Android MethodChannels | Floating voice overlay, audio picker, and system permissions |
| **Notifications** | Flutter Local Notifications | Exact alarms, notification channels, and DND replay |
| **Routing** | GoRouter | Declarative route management (`/`, `/tasks/:id`, `/alarms`, etc.) |

---

## 📁 Repository Structure

```
AURA/
├── docs/                       ← Product specifications, system architecture, & design docs
│   ├── flows/                  ← User flow diagrams and state transitions
│   │   └── user_flows.md
│   ├── wireframes/             ← Detailed screen-by-screen wireframe specifications
│   ├── AI_ARCHITECTURE.md      ← Intent extraction pipeline & LLM prompt designs
│   ├── ARCHITECTURE.md         ← System architecture, Riverpod providers, & Drift database
│   ├── CHANGELOG.md            ← Version update history and feature log
│   ├── CONTEXT.md              ← Project history, principles, and AI context memory
│   ├── DECISIONS.md            ← Architecture Decision Records (ADRs)
│   ├── PRD.md                  ← Product Requirements Document (PRD v2.0)
│   ├── PRINCIPLES.md           ← Non-negotiable product & design guidelines
│   ├── ROADMAP.md              ← Phase development roadmap
│   ├── SCHEMA.md               ← Database ER model & Drift table schemas
│   ├── VISION.md               ← Core vision and executive summary
│   └── design_system.md        ← Color palette, typography, & component tokens
├── lib/                        ← Main Flutter application source code
│   ├── core/                   ← Constants, theme, router, providers, & global widgets
│   ├── database/               ← Drift database initialization, tables, and DAOs
│   ├── features/               ← Feature modules (home, tasks, alarms, capture, workspaces)
│   ├── platform/               ← Android platform channel implementations
│   └── main.dart               ← Application entry point
├── android/                    ← Android native application shell & platform channels
├── ios/                        ← iOS native application shell
├── assets/                     ← Graphic assets and icons
├── pubspec.yaml                ← Flutter dependencies and package manifest
└── README.md                   ← Master project documentation
```

---

## 📚 Documentation Index

| Document | Purpose |
| ---------- | --------- |
| [VISION.md](./docs/VISION.md) | Executive summary, core purpose, and long-term vision |
| [PRD.md](./docs/PRD.md) | Product Requirements Document — feature specifications & acceptance criteria |
| [ARCHITECTURE.md](./docs/ARCHITECTURE.md) | Technical architecture, data flow, and Flutter module breakdown |
| [SCHEMA.md](./docs/SCHEMA.md) | Database tables, indexes, relationships, and Drift DAO queries |
| [AI_ARCHITECTURE.md](./docs/AI_ARCHITECTURE.md) | Voice pipeline, intent parser, prompt schemas, and briefings |
| [DESIGN_SYSTEM.md](./docs/design_system.md) | Typography, color tokens, dynamic themes, and UI primitives |
| [DECISIONS.md](./docs/DECISIONS.md) | Architectural Decision Records (ADRs) |
| [ROADMAP.md](./docs/ROADMAP.md) | Phase execution roadmap and milestone timeline |
| [CHANGELOG.md](./docs/CHANGELOG.md) | Version history and feature implementation log |

---

## 🚀 Development & Build Instructions

### Prerequisites

- **Flutter SDK**: 3.22.x or higher
- **Dart SDK**: 3.4.x or higher
- **Android SDK**: API 34+ (Build-Tools 34.0.0+)
- **Java JDK**: JDK 17 or JDK 21

### Running Locally

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run static analysis (verify zero warnings/errors)
flutter analyze

# 3. Run on connected Android device
flutter run
```

### Database Code Generation

If you modify Drift table definitions (`lib/database/tables/`):

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

*Personal project by Ishan T — BTech CSE*  
*License: Proprietary / Personal Project*
