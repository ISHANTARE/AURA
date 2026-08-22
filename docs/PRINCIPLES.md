# AURA — Core Principles

> These are the non-negotiable design principles that guide every decision in AURA.
> When in doubt, come back here.

---

## 1. Privacy First

**Your data belongs to you. Always.**

- All core data is stored locally on-device by default
- No external account required to use AURA
- Cloud sync, Google Calendar, Outlook — all opt-in, never forced
- AURA never reads from external apps (WhatsApp, Gmail) without explicit user permission
- When sync is enabled, AURA remains the source of truth

> If we ever have to choose between a convenient feature and user privacy, we choose privacy.

---

## 2. Offline First

**AURA must work without internet.**

- Core features: task creation, reminders, voice capture, calendar view — all work offline
- AI features gracefully degrade when offline (queue for later, or use on-device models)
- No feature may be gated behind internet connectivity unless absolutely unavoidable
- Data is never lost because of a network failure

> A productivity app that fails when you're in a building with bad WiFi is not a productivity app.

---

## 3. Voice First

**One tap. You speak. Done.**

- The fastest path from thought to task must always be voice
- Voice input must work in under 2 seconds from button press
- AI must understand natural language with context ("that assignment I mentioned earlier", "remind me before that")
- Text input is secondary — available, but not the primary interface

> If it takes more effort to capture something in AURA than to write it in a notes app, we have failed.

---

## 4. Human in the Loop

**AURA suggests. You decide.**

- AI should never silently modify, delete, or reschedule things without confirmation
- Every AI action should be reviewable and reversible
- AURA gives you a summary of what it did and lets you edit before confirming
- Automated actions (morning briefing, AI scheduling) should be clearly marked as AI-generated

> We're building an assistant, not an autopilot. The user is always in control.

---

## 5. Workspaces Over Chaos

**Everything belongs somewhere.**

- Every task, event, note, and reminder lives inside a workspace
- Default workspaces reflect real-life contexts: College, IIT Prep, Internship, Personal, Health
- Nothing is in a "global inbox" forever — AURA helps route things to the right place
- Workspaces are visual, colorful, and feel distinct from each other

> Productivity without context is just a longer to-do list.

---

## 6. Data Model Ownership

**AURA is the brain. External services are limbs.**

- AURA's internal data model is the canonical source of truth
- Google Calendar, Outlook, iCal — these are sync targets, not masters
- If a sync fails, AURA still works perfectly
- Imports from external services are one-time conversions, not live dependencies

> Don't build on sand. Own the foundation.

---

## 7. Premium Feel, Always

**AURA should feel like it costs $20/month even when it's free.**

- UI must be polished, animated, and visually intentional
- No placeholder screens, no skeleton UIs left indefinitely, no "coming soon" ghost features
- Every interaction should have feedback (haptics, animations, sound where appropriate)
- Dark mode is the default. Light mode is available.

> First impressions determine whether people give an app a second chance.

---

## 8. Simplicity Over Features

**The best feature is the one that doesn't need to be explained.**

- If a feature requires a tutorial to use, redesign it
- Add features slowly and deliberately — don't bloat
- Every feature must earn its place by solving a real problem for the primary user
- MVP is not an excuse for bad design

> A feature list is not a product.

---

## 9. Build for Yourself First

**Ishan T is User #1. Build what you would actually use every day.**

- If you wouldn't use a feature yourself, don't build it
- Test everything in real daily usage before marking it complete
- Friction you feel as the builder is friction every user will feel
- The feedback loop is: build → use → feel friction → fix

> The best products are built by people who desperately needed them.

---

## 10. Document Everything

**Future-you and future-collaborators deserve clarity.**

- Every significant architecture decision gets an ADR (Architecture Decision Record)
- Every feature starts with a PRD section before any code is written
- Code is readable without comments, comments explain *why* not *what*
- The repository should be navigable by someone new in under 30 minutes

> A codebase without documentation is a liability, not an asset.

---

*Created: 2026-07-23*
*Status: Living document — principles may be added, never removed without team consensus*
