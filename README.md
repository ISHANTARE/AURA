# AURA

> **AI-Unified Reality Assistant**
> *One tap. You speak. Life organizes itself.*

---

## What is AURA?

AURA is a voice-first, AI-native life management system. It acts as your personal executive assistant — capturing anything you say, understanding context, and automatically creating tasks, reminders, calendar events, and daily plans.

Built with privacy and offline-first principles: your data lives on your device.

---

## Core Features (Planned)

- **One-tap voice capture** — press a button, speak, AURA handles the rest
- **AI-powered intent extraction** — understands natural language with full context
- **Layered reminders** — "remind me 3 days before, 1 day before, and 2 hours before"
- **Morning briefing** — daily AI-generated plan based on your tasks and deadlines
- **Workspace system** — separate contexts (College, IIT Prep, Internship, Personal)
- **Unified timeline** — every task, event, and deadline in one view
- **Multiple calendar views** — Daily, Weekly, Monthly, Kanban, Priority, Deadline
- **Offline-first** — works without internet for all core features
- **Privacy-first** — no cloud account required, local encrypted storage

---

## Documentation

| File | Description |
|------|-------------|
| [VISION.md](./VISION.md) | Why AURA exists — the core purpose and long-term ambition |
| [PRINCIPLES.md](./PRINCIPLES.md) | Non-negotiable design and product principles |
| [CONTEXT.md](./CONTEXT.md) | Full project backstory, decisions, and AI context memory |
| [DECISIONS.md](./DECISIONS.md) | Architecture Decision Records (ADRs) |
| [ROADMAP.md](./ROADMAP.md) | Phase-by-phase development plan |
| [CHANGELOG.md](./CHANGELOG.md) | Version and update history |

---

## Project Structure

```
AURA/
├── VISION.md
├── PRINCIPLES.md
├── CONTEXT.md
├── DECISIONS.md
├── ROADMAP.md
├── CHANGELOG.md
├── 01_Product/         ← User research, discovery, friction mapping
├── 02_PRD/             ← Product Requirements Document
├── 03_UX/              ← Wireframes, flows, design system
├── 04_Architecture/    ← System architecture and tech decisions
├── 05_AI/              ← AI agents, prompts, memory design
├── 06_Database/        ← ER diagram and SQL schema
├── 07_API/             ← API contracts
├── 08_Frontend/        ← Mobile app (Flutter)
├── 09_Backend/         ← Backend services (FastAPI)
├── 10_Testing/         ← Test plans and results
├── 11_Docs/            ← Public documentation
├── 12_Roadmap/         ← Sprint planning
└── 13_Research/        ← Competitive analysis and research
```

---

## Current Phase

**Phase 0 — Vision** (Complete)
**Next: Phase 1 — Product Discovery**

See [ROADMAP.md](./ROADMAP.md) for full breakdown.

---

## Development Philosophy

> Antigravity IDE implements. Documentation decides.

Every feature starts as a documented requirement before any code is written.
AI tools are used to implement from specs, not to invent the product.

---

## Tech Stack (Tentative)

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter (Android + iOS + Desktop) |
| Local DB | SQLite via Drift ORM |
| Backend | FastAPI (Python) — when needed |
| AI / NLP | OpenAI GPT-4o + Whisper |
| Voice | Device speech recognition (offline) + Whisper (online) |

---

*Personal project by Ishant — BTech CSE*
*Started: July 2026*
