# AURA — Project Context & Background

> This document captures the full backstory, conversations, decisions, and context
> that led to AURA. It is the "memory" of the project — read this before anything else
> if you're returning after a break or starting a new conversation with an AI tool.

---

## Origin Story

**Date:** July 22, 2026 (11:43 PM)

The idea started with a simple frustration:

> "Is there a reminder + calendar + voice input + AI tool which I can use on the go on my phone and laptop so that when I see any notification or mail or message of a meeting or submission or deadline, I can just press a button on my phone, speak what I want, AI understands it and does the needed — schedule reminders, alarms, meeting notifications, 1-2 day prior notices, or tell me what all I need to complete?"

A conversation with ChatGPT explored existing options (ChatGPT + Google Calendar, Gemini, Copilot, Motion AI, Reclaim AI, TickTick, Todoist) but concluded that **none of them solve this end-to-end in a seamless, voice-first, privacy-respecting way**.

The conversation then evolved into designing AURA from scratch.

**ChatGPT conversation reference:** <https://chatgpt.com/share/6a613942-5c78-83e8-8067-76007b3a648d>

---

## Key Design Decisions Made in the Origin Conversation

### Decision 1: Build from scratch, not integrate

Rather than patching together 4-5 existing apps, AURA should be built as a unified product.

**Rationale:** Existing apps require you to do the organizing. AURA should do it for you.

### Decision 2: AURA is not an actual OS — it's a life OS on top of Android

AURA is an Android app that becomes your **primary interface** for organizing your life. It lives alongside WhatsApp, Gmail, Chrome — but becomes the brain that coordinates all of it.

Android capabilities being leveraged:

- Floating button (Overlay/Accessibility permission)
- Home screen widget
- Background service
- Local notifications and alarms
- Voice recording and speech recognition
- Share menu integration (share a screenshot → AURA)
- Quick Settings tile

Android limitations respected:

- Cannot secretly monitor WhatsApp or Gmail
- Cannot bypass Android permissions
- Cannot control other apps without explicit permission
- (This is by design — matches privacy philosophy)

### Decision 3: No Google Calendar required — AURA builds its own

The calendar view is just **one view** of the underlying AURA data model.

The model-first thinking:

```
Task object in AURA:
- Name
- Deadline
- Estimated Hours
- Priority
- Workspace
- Professor / Contact
- Files, Notes, Voice Notes, Images
- Meeting History
- Dependencies, Checklist, Progress
- Reminders (array)
- Calendar Event (generated property, not the master)
- Subtasks
```

The calendar event is **one property** of the task, not the task itself.

Google Calendar integration is a later, optional sync layer:

```
AURA Database → Sync Engine → Google Calendar (compatibility layer)
```

### Decision 4: Multiple views of the same data

The same underlying data should be viewable as:

- Daily (Google Calendar style)
- Weekly (Outlook style)
- Monthly (traditional calendar)
- Timeline (chronological, everything)
- Workspace-filtered view
- Deadline View (sorted by urgency)
- Priority View (sorted by AI)
- Kanban (Todo / Doing / Done)

### Decision 5: Offline and cloud-independent MVP

The MVP works with:

- No Google account
- No Microsoft account
- No internet connection for core features
- Local encrypted database on device

Cloud sync, cross-device, Google Calendar sync — all opt-in features added later.

### Decision 6: AURA owns the data model
>
> "External services are merely mirrors when you choose to sync."

This is a product and technical principle that affects every architectural decision.

---

## 12-Phase Development Process

The development methodology agreed upon in the origin conversation:

| Phase | Name | Description |
| ------- | ------ | ------------- |
| 0 | Vision | Why AURA exists. Core principles. What's out of scope. |
| 1 | Product Discovery | Map user's actual daily life, workflow, friction points |
| 2 | Product Requirements | Full PRD — every feature, screen, button, workflow, edge case |
| 3 | UX Design | Wireframes, user flows, design system — draw before coding |
| 4 | System Design | Architecture — modules, dependencies, tech stack |
| 5 | AI Design | Voice agent, scheduler agent, reminder agent, parser, memory |
| 6 | Database Design | ER diagram, SQL schema — most critical technical phase |
| 7 | Development Roadmap | GitHub issues, milestones, sprints, kanban |
| 8 | AI Coding | Implementation using Antigravity IDE from the specs |
| 9 | Testing | Real-world usage testing, not just unit tests |
| 10 | Daily Driver | Living with AURA daily, building the feedback backlog |
| 11 | Public Release | Generalize for multi-user, auth, cloud, premium |

> **Critical insight:** Coding is Phase 8. Most developers fail by jumping to Phase 8 immediately.

---

## AI-First Development Workflow

```
ChatGPT / Antigravity (Product Architect)
         |
         | Defines the "what" and "why"
         v
Product Documents (Markdown in this repo)
         |
         | Become the source of truth
         v
Antigravity IDE (Implementation)
         |
         | Builds modules from the specifications
         v
GitHub
         |
         v
Phone Testing
         |
         v
Feedback
         |
         +-----------> Back to top
```

**Key rule:** Antigravity IDE implements. It does not decide the product.
Decisions are made in documentation first, then implemented.

---

## Roles

**Ishan T (you):**

- Founder (decides vision)
- Product Owner (decides priorities)
- User #1 (provides real-world feedback)
- Engineer (integrates and tests)

**AI assistant (Antigravity / ChatGPT):**

- Product Manager (requirements and roadmap)
- Solutions Architect (system design)
- AI Architect (LLM workflows and prompt design)
- UX Reviewer (flows and usability)
- Technical Reviewer (trade-offs and code reviews)
- Documentation Writer (PRD, ADRs, API docs)

---

## Repository Structure (Planned)

```
AURA/
├── VISION.md                  ← Why AURA exists
├── PRINCIPLES.md              ← Non-negotiable design principles
├── CONTEXT.md                 ← This file — project memory and backstory
├── DECISIONS.md               ← Architecture Decision Records (ADRs)
├── ROADMAP.md                 ← Development phases and milestones
├── CHANGELOG.md               ← Version history
│
├── 01_Product/
│   └── discovery.md           ← User life mapping, friction points
│
├── 02_PRD/
│   └── PRD.md                 ← Full Product Requirements Document
│
├── 03_UX/
│   ├── wireframes/            ← Screen wireframes (images or Figma links)
│   ├── flows/                 ← User flow diagrams
│   └── design_system.md      ← Colors, typography, components
│
├── 04_Architecture/
│   └── ARCHITECTURE.md        ← System architecture, modules, tech stack
│
├── 05_AI/
│   └── AI_ARCHITECTURE.md     ← AI agents, prompts, memory design
│
├── 06_Database/
│   ├── ER_DIAGRAM.md          ← Entity relationship diagram
│   └── SCHEMA.sql             ← Full database schema
│
├── 07_API/
│   └── API.md                 ← API contracts between frontend and backend
│
├── 08_Frontend/               ← Flutter/React Native app code
│
├── 09_Backend/                ← FastAPI / backend services
│
├── 10_Testing/
│   └── test_plans.md          ← Test scenarios and results
│
├── 11_Docs/
│   └── README.md              ← Public-facing documentation
│
├── 12_Roadmap/
│   └── SPRINTS.md             ← Sprint breakdown and status
│
└── 13_Research/
    └── competitive_analysis.md ← What exists, what's missing, what AURA does differently
```

---

## Current Status

**Phase 0** — Vision (Complete)
**Phase 1** — Product Discovery (Complete)
**Next: Phase 2** — Product Requirements Document (PRD)

**Completed:**

- VISION.md
- PRINCIPLES.md
- CONTEXT.md (this file)
- DECISIONS.md (ADRs 001–009)
- ROADMAP.md
- 01_Product/discovery.md (full Phase 1 output)

---

## Resolved Decisions (from Phase 1)

| # | Question | Decision |
| --- | ---------- | ---------- |
| 1 | Task vs Event distinction | Both supported architecturally in DB and UI |
| 2 | Morning briefing timing | Auto-detect from phone unlock pattern + manual override |
| 3 | OCR provider | Google ML Kit — free, on-device, offline, Android-native |
| 4 | Link reading depth | Smart: short content = read full; long content = extract key parts only |
| 5 | Workspace concept | A workspace is a directory/folder — simple named container. No merging logic. |
| 6 | Desktop future-proofing | Flutter compiles to Android, iOS, Windows, macOS, Linux, Web. Zero extra cost. |

---

*Created: 2026-07-23*
*Last Updated: 2026-07-23*
*Status: Living document — update after every significant conversation or decision*
