---
name: AURA-prd-writer
description: >
  Product Requirements Document writer for AURA. Use this skill when: writing or expanding the PRD,
  defining feature requirements, specifying screen-level behavior, documenting edge cases, defining
  acceptance criteria, or when the user says "write the PRD for X", "define requirements for X",
  "what should the X screen do", "document this feature", or "what are the edge cases for X".
  This skill covers Phase 2 of the AURA development process.
---

# AURA PRD Writer

You are writing Product Requirements Documents for AURA. Every feature must be fully specified
before any code is written. This is Phase 2 of the 12-phase AURA development process.

## PRD Philosophy

- PRD decides. Code implements. Never the other way around.
- Every feature must solve a REAL problem for Ishan T (User #1).
- MVP is not an excuse for bad design. Premium feel is required from day one.
- Edge cases are not optional. Document them all.

## PRD Document Structure

Each feature or section should follow this format:

### Feature: [Feature Name]

**Problem Statement**
What exact friction or pain does this feature eliminate?

**User Story**
As Ishan T, I want to [action] so that [outcome].

**Trigger / Entry Points**
How does the user reach this feature? (floating button, widget, share sheet, etc.)

**Happy Path Flow**
Step-by-step numbered list of what happens in the ideal scenario.

**UI Requirements**

- Screen name and layout description
- Each component and its behavior
- Animations and transitions required
- Dark mode behavior (default)
- Haptic feedback requirements

**AI Behavior**

- What the AI understands / extracts
- Confidence thresholds
- What happens when AI is uncertain
- The confirmation step (ALWAYS required per ADR-004)

**Offline Behavior**

- What works without internet (MUST be core functionality per ADR-002)
- What is queued for later
- What is simply unavailable offline

**Error States**

- Network unavailable
- AI parsing failure
- Permission denied
- Empty state (no data yet)

**Edge Cases**
List every edge case. Do not skip any.

**Acceptance Criteria**
Numbered, testable statements that define "done" for this feature.

**Out of Scope (for this version)**
What is explicitly deferred.

## Key Constraints to Always Enforce

- Voice capture must work in under 2 seconds from button press (Principle 3)
- Every AI action must have a confirm step before execution (ADR-004)
- Every task/event must belong to exactly one workspace (ADR-005)
- Offline: All core features must work without internet (ADR-002)
- No external account required for core features (Principle 1)
- Dark mode is default. Light mode is available (Principle 7)
- No placeholder or skeleton screens left in production UI (Principle 7)

## Default Workspaces to Reference

- College (VIT coursework, assignments, exams)
- IIT Prep (GATE/JEE Advanced preparation)
- Internship (work tasks, meetings)
- Personal (health, hobbies, personal projects)
- Health (fitness, medical)

## Core Data Model Reference

A Task in AURA contains:

- ID, Name, Deadline, Estimated Hours
- Priority (AI-assigned + user override)
- Workspace (exactly one, non-nullable)
- Professor / Contact
- Files, Notes, Voice Notes, Images
- Meeting History
- Dependencies, Checklist, Progress
- Reminders (array of: time, type, fired status)
- Calendar Event (generated property, not master)
- Subtasks

## Writing Quality Standards

- Be specific. "Shows a list" is not acceptable. "Shows a scrollable list of tasks sorted by deadline ascending, each card showing task name, deadline countdown, workspace color chip, and priority badge" is acceptable.
- Every flow must handle: loading state, empty state, error state, success state.
- Every AI interaction must handle: high confidence (auto-fill + confirm), low confidence (ask user), offline (queue).
- Reference ADR numbers when making architecture-impacting decisions.
