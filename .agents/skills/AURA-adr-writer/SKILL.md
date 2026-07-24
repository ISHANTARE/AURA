---
name: AURA-adr-writer
description: >
  Architecture Decision Record writer for AURA. Use this skill when: making any new technical decision,
  choosing between technology options, changing an existing architectural decision, documenting a tradeoff,
  or when the user says "write an ADR for X", "document the decision for X", "what are the tradeoffs of X",
  "should I use X or Y", "update ADR-N", "record this decision", or "we decided to use X".
  This skill ensures every significant decision is documented before implementation.
---

# AURA ADR Writer

You write Architecture Decision Records (ADRs) for AURA. Every significant technical or product decision
must be documented in DECISIONS.md BEFORE implementation begins. This is non-negotiable (Principle 10).

## When to Write an ADR

Write an ADR when:
- Choosing between two or more technology options
- Making a decision that affects the data model
- Making a decision that affects offline behavior
- Making a decision that affects privacy
- Changing or overriding a previous ADR
- Making any decision that will be hard to reverse

Do NOT write an ADR for:
- Trivial implementation details (which variable name to use)
- Style choices covered by the design system
- Decisions that are obviously correct and have no real alternatives

## ADR Format (Strict)

All ADRs go into `DECISIONS.md`. Append new ADRs at the bottom. Never delete old ones.

```markdown
## ADR-NNN — [Short Decision Title]

**Date:** YYYY-MM-DD
**Status:** Proposed | Accepted | Deprecated | Superseded by ADR-NNN

### Decision
[One paragraph describing what was decided. Be specific. State the decision clearly.]

### Context
[Why did this decision need to be made? What was the situation or problem?]

### Options Considered

| Option | Pros | Cons |
|--------|------|------|
| Option A | ... | ... |
| Option B | ... | ... |

### Rationale
- Bullet points explaining WHY this option was chosen over alternatives
- Reference relevant AURA principles (e.g., "Aligns with offline-first principle")
- Reference user needs (e.g., "Ishant needs this to work without internet")

### Consequences
- What becomes easier because of this decision
- What becomes harder because of this decision
- What is deferred or out of scope because of this decision
- Any follow-up ADRs that may be needed

### Related ADRs
- ADR-NNN: [related decision]
```

## ADR Numbering

Current highest ADR number: **ADR-011** (Flutter cross-platform foundation)
Next new ADR should be: **ADR-012**

## Existing ADRs Summary (Do Not Contradict Without New ADR)

| ADR | Decision | Status |
|-----|----------|--------|
| ADR-001 | AURA owns data model. External services are sync targets. | Accepted |
| ADR-002 | Offline-first architecture. Cloud is opt-in. | Accepted |
| ADR-003 | Voice is primary input method. | Accepted |
| ADR-004 | Human-in-the-loop for all AI actions. | Accepted |
| ADR-005 | Workspace as primary organizational unit. | Accepted |
| ADR-006 | Flutter + Drift ORM + Android STT + Gemini 2.0 Flash | Decided v1 |
| ADR-007 | Workspaces are dynamic, created from user voice. | Accepted |
| ADR-008 | Share-to-AURA is first-class input mode. | Accepted |
| ADR-009 | DND-aware notification replay. No silent drops. | Accepted |
| ADR-010 | ML Kit for OCR. Smart length-based link reading. | Accepted |
| ADR-011 | Flutter is single codebase for all platforms. | Accepted |

## How to Handle a Decision That Conflicts With Existing ADR

1. Do NOT just change the existing ADR text
2. Write a NEW ADR: "ADR-NNN — Supersedes ADR-MMM: [new decision]"
3. In the new ADR, explain why the old decision is being revised
4. Update the old ADR's status to "Superseded by ADR-NNN"
5. Update CHANGELOG.md to record the change

## Decision Evaluation Framework

When evaluating options for an ADR, always ask:

1. **Privacy**: Does this option keep data on device by default? (Principle 1)
2. **Offline**: Does this option work without internet? (Principle 2)
3. **Speed**: Does this option meet the 2-second voice-to-action requirement? (Principle 3)
4. **Cost**: What does this cost at MVP scale? At 1000 users? At 100k users?
5. **Complexity**: How much implementation effort does this add?
6. **Reversibility**: How hard is it to change this decision later?
7. **Ishant's life**: Does this actually solve Ishant's real-world problem?

## Writing Quality Standards

- Be specific. "Better performance" is not acceptable. "50ms faster than alternative X in benchmarks" is.
- Include actual numbers and benchmarks where possible.
- State the consequences honestly — including the downsides.
- Write for future-you who will read this in 6 months with no memory of the context.
- End every ADR with "Related ADRs" even if the list is empty.
