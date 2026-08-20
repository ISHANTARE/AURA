# AURA — Development Roadmap
> Solo developer + AI tools (Antigravity IDE / ChatGPT)
> Realistic, lean, and actionable.

---

## The Honest Process

> For a solo dev with AI tools, the goal of pre-work is simple:
> **write enough that when you open Antigravity and say "build this",
> it builds the right thing — not a guess.**

Too little planning → AI builds the wrong thing, you rebuild constantly.
Too much planning → you never ship, docs become the product.

The sweet spot is what's defined below.

---

## Process Overview

```
┌─────────────────────────────────────────────────────────┐
│  MUST DO (non-negotiable, in order)                      │
│                                                          │
│  Stage 1  [DONE]  Foundation (Vision + Discovery)        │
│  Stage 2  [DONE]  PRD  — what to build                   │
│  Stage 3  [NEXT]  Sketch — how it looks                  │
│  Stage 4  [ ]     Schema — how data is stored            │
│  Stage 5  [ ]     Build — code with Antigravity          │
│  Stage 6  [ ]     Live — use it daily, improve           │
│  Stage 7  [ ]     Ship — release to others               │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  DONE ALONGSIDE STAGE 5 (not separate stages)            │
│                                                          │
│  Architecture     — designed as each module is built     │
│  AI Pipeline      — designed as AI features are built    │
│  Sprint Planning  — just a simple list, updated weekly   │
└─────────────────────────────────────────────────────────┘
```

---

## Stage 1 — Foundation ✅ DONE

**What it is:** The "why" and the "what kind of product" — before any features.

**Completed:**
- [x] docs/VISION.md — why AURA exists
- [x] docs/PRINCIPLES.md — 10 non-negotiable principles
- [x] docs/CONTEXT.md — full project memory for AI tools
- [x] docs/DECISIONS.md — 11 Architecture Decision Records
- [x] docs/PRD.md — Master Product Requirements Document

**AI tool role in this stage:**
- ChatGPT / Antigravity: asked deep questions, synthesized answers into docs
- You: answered honestly, corrected wrong assumptions

---

## Stage 2 — PRD (Product Requirements Document) ⏭️ NEXT

**What it is:** Every feature defined in plain English before any code.
Not a 100-page enterprise doc. A clear, specific feature list with behaviors.

**Rule:** If a feature isn't in the PRD, it doesn't get built.
If the PRD says X, Antigravity builds X — not its interpretation of X.

**How to work on it:**
1. Open `02_PRD/PRD.md` with Antigravity
2. Go feature by feature — discuss, decide, write
3. Each feature gets: description, inputs, outputs, edge cases, AI behavior

**Deliverables:**
- [x] `02_PRD/PRD.md` — master requirements document (16 features, all P0 + P1 covered)

**What goes in it (feature list):**
- [ ] Floating orb button (entry point)
- [ ] Voice capture flow (end-to-end)
- [ ] Share-to-AURA (screenshot, link, document)
- [ ] Confirmation box UI
- [ ] Task creation and metadata
- [ ] Event creation and metadata
- [ ] Reminder system (defaults + overrides + snooze + DND replay)
- [ ] Workspace system (dynamic creation, auto-detect, multi-assign)
- [ ] Morning briefing (smart timing + content format)
- [ ] Proactive nudges (push-to-work system)
- [ ] Timeline / Calendar views
- [ ] Recurring tasks (check-off, missed, roast)
- [ ] Search (find any task/event/file by description)
- [ ] Settings and privacy controls
- [ ] Onboarding (first launch experience)

**AI tool role in this stage:**
- Antigravity: asks edge case questions, writes PRD sections from discussion
- You: approve, correct, add things Antigravity missed

**Estimated time: 3–5 focused sessions**

---

## Stage 3 — Sketch (UX Design, lean version)

**What it is:** Draw key screens before coding them.
Not Figma. Not pixel-perfect. Rough is fine — the point is to think through layout before implementing it.

**How to work on it:**
- Paper sketch OR use Antigravity to generate a visual wireframe mockup
- Focus on: main home screen, voice capture overlay, confirmation box, task detail, workspace view
- Establish: color palette, font, dark mode first

**Deliverables:**
- [ ] `03_UX/design_system.md` — color palette, typography, spacing tokens
- [ ] `03_UX/wireframes/` — key screen sketches (image or described layout)
- [ ] `03_UX/flows/` — 3–4 key user flow diagrams

**Key screens to design (in priority order):**
1. Floating orb (always-on)
2. Voice capture overlay (what appears after you tap)
3. Confirmation box
4. Home / Today screen
5. Task detail
6. Workspace view
7. Morning briefing card
8. Settings (later)

**AI tool role in this stage:**
- Antigravity: generates visual mockups, proposes design systems
- You: choose what feels right, reject what doesn't

**Estimated time: 2–3 sessions**

---

## Stage 4 — Schema (Database Design)

**What it is:** The data model. The most critical technical decision.
A bad schema means refactoring everything later.
This must be done BEFORE Stage 5.

**How to work on it:**
- Go entity by entity with Antigravity
- Define every table, every field, every relationship
- Think about: what queries will AURA run? (search, filter by workspace, get reminders due today)

**Deliverables:**
- [ ] `06_Database/ER_DIAGRAM.md` — entity relationship diagram
- [ ] `06_Database/SCHEMA.sql` — complete SQL schema

**Key entities to design:**
- `workspaces` — id, name, color, icon, created_at
- `tasks` — id, title, workspace_id, deadline, priority, type (task/event), status, notes
- `reminders` — id, task_id, fire_at, type, status, snoozed_until
- `attachments` — id, task_id, type (screenshot/link/doc/audio), content, summary
- `ai_context` — conversation memory, user patterns, recurring preferences
- `notification_log` — fired reminders, DND queue, replay status
- `daily_log` — completed tasks per day, missed recurring tasks

**AI tool role in this stage:**
- Antigravity: proposes schema, identifies missing fields, spots design flaws
- You: approve, add what's missing based on your life

**Estimated time: 1–2 sessions**

---

## Stage 5 — Build (AI-Assisted Coding)

**What it is:** The actual implementation using Flutter + Antigravity IDE.
By this stage, docs are complete — Antigravity codes FROM them, not around them.

**How to work on it:**
- One module at a time, in dependency order
- Each session: "Implement [module] according to PRD section X and schema table Y"
- Commit after each working module — never code 3 modules before committing

**Build order (dependency-driven):**
```
Sprint 1   Flutter project setup + Drift DB + schema implementation
Sprint 2   Floating orb button (Android overlay service)
Sprint 3   Voice capture UI + Android STT integration
Sprint 4   Confirmation box UI + task creation (no AI yet)
Sprint 5   Reminder engine + DND-aware notification system
Sprint 6   Home / Today screen + basic task list
Sprint 7   Workspace system (CRUD + auto-detection placeholder)
Sprint 8   AI integration — Gemini for NLP + workspace auto-detect
Sprint 9   Share-to-AURA (Sharesheet + ML Kit OCR + link reader)
Sprint 10  Morning briefing (smart timing + content engine)
Sprint 11  Proactive nudges
Sprint 12  Calendar / Timeline views
Sprint 13  Recurring tasks + missed task logic
Sprint 14  Search
Sprint 15  Polish — animations, dark mode, haptics, UX details
```

**AI tool role in this stage:**
- Antigravity: writes code for each sprint from PRD + schema specs
- You: test on phone, report friction, approve or redirect

**Estimated time: 8–14 weeks (depending on session frequency)**

---

## Stage 6 — Live (Daily Driver)

**What it is:** You use AURA as your only productivity tool.
Every friction point becomes a GitHub issue.
Every missing feature becomes a backlog item.

**How to work on it:**
- Use it for everything: classes, internship, IIT prep, placements
- At end of each week: note what annoyed you
- Prioritize fixes by how often the pain occurs

**Deliverables:**
- Running backlog of improvements
- Updated PRD sections for v1.1 features

**AI tool role in this stage:**
- Antigravity: implements fixes and improvements from the backlog
- You: live with the product, feel what's wrong

**Estimated time: 4–6 weeks minimum before moving to Stage 7**

---

## Stage 7 — Ship (Public Release)

**What it is:** Generalize AURA for other users.
Only start this after Stage 6 — never before.

**What gets added:**
- [ ] User accounts / authentication
- [ ] Cloud backup and sync
- [ ] Cross-device (same Flutter codebase, different platform targets)
- [ ] Onboarding for new users (not just you)
- [ ] Play Store / App Store release
- [ ] Premium features / monetization (if desired)

**AI tool role in this stage:**
- Antigravity: implements multi-user features, cloud integration
- You: decide pricing, positioning, feature gating

**Estimated time: TBD — months after Stage 6**

---

## Timeline (Realistic)

| Stage | What | Time |
|-------|------|------|
| 1 | Foundation | ✅ Done |
| 2 | PRD | 1–2 weeks |
| 3 | Sketch | 1 week |
| 4 | Schema | 3–5 days |
| 5 | Build | 8–14 weeks |
| 6 | Live | 4–6 weeks |
| 7 | Ship | TBD |

> **Total to working personal app: ~4–6 months**
> **Total to public release: ~8–10 months**
>
> These assume consistent but not full-time sessions — a few hours per week
> alongside college, internship, and IIT prep.

---

## How AI Tools Fit In — The Mental Model

```
You                          AI Tools (Antigravity / ChatGPT)
────────────────────────     ────────────────────────────────
Decide what to build    →    Write the docs and code from decisions
Approve or reject       →    Propose, generate, implement
Feel the friction       →    Diagnose and fix
Own the product         →    Execute the product
```

**One rule that matters most:**

> Never say "build me an app."
> Always say "implement [specific thing] from [specific doc section]."

The more precise your prompt, the better the output.
These docs are what make your prompts precise.

---

## How to Use These Docs With Antigravity

At the start of every coding session, tell Antigravity:
```
"Read CONTEXT.md, DECISIONS.md, and 02_PRD/PRD.md.
We are implementing Sprint [N]: [sprint name].
The relevant PRD section is [X].
The relevant schema tables are [Y, Z].
Let's start."
```

That one instruction gives Antigravity full context —
and the output will be dramatically better than starting from scratch.

---

*Created: 2026-07-23*
*Revised: 2026-07-23 — updated from 12-phase team process to solo developer + AI tools workflow*
*Status: Living document*
