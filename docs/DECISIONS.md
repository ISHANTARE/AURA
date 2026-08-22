# AURA — Architecture Decision Records (ADRs)

> Every significant technical or product decision is documented here.
> Format: ADR-{number} | Date | Status | Decision | Rationale | Consequences

---

## ADR-001 — AURA owns the data model

**Date:** 2026-07-23
**Status:** Accepted

### Decision

AURA maintains its own internal data model as the single source of truth.
External services (Google Calendar, Outlook, iCal) are sync targets, not masters.

### Context

Most productivity apps are built around Google Calendar or Microsoft Outlook as the primary data store. This creates a dependency that limits offline usage, privacy, and customization.

### Rationale

- Full control over data schema — we can add fields (workspace, AI metadata, voice notes, dependencies) that no external calendar supports
- Works offline without degradation
- Privacy: no external service has primary access to user data
- Enables richer data model (a task has a deadline AND reminders AND subtasks AND voice notes — not just a calendar event)

### Consequences

- We must build our own calendar views (daily, weekly, monthly) — more work upfront
- Sync engine must be built carefully to handle conflicts
- Users cannot start with Google Calendar data without an import step

---

## ADR-002 — Offline-first architecture for MVP

**Date:** 2026-07-23
**Status:** Accepted

### Decision

The MVP works with no internet connection for all core features.
Cloud features are opt-in, added after the local experience is solid.

### What "Offline-First" Actually Means

> All your data lives on your phone (SQLite database). The app works 100% — tasks, reminders, calendar, voice capture — without any internet connection. When you go online, AURA can optionally sync to cloud or Google Calendar, but it never *needs* internet to function.

In simple terms:

- Google Docs without WiFi = broken
- AURA without WiFi = works perfectly

### Context

Many AI productivity apps require cloud connectivity for even basic features. This is a friction point for users in areas with poor connectivity and a privacy concern.

### Rationale

- Aligns with privacy-first principle (data stays on device by default)
- Forces clean architecture: local DB → optional sync layer
- Stronger product story: "works offline" is a differentiator
- Allows building and testing without cloud infrastructure in early phases

### Consequences

- Local database (SQLite via Drift ORM) must be designed carefully from the start
- AI/NLP features gracefully degrade when offline (queue voice input, process when online)
- Cross-device sync is a deliberate feature to design later, not assumed infrastructure

---

## ADR-003 — Voice is the primary input method

**Date:** 2026-07-23
**Status:** Accepted

### Decision

The entire product is designed voice-first. Text input is secondary and always available, but voice is the default and optimized path.

### Context

The core use case is: see something (email/notification/message) → one tap → speak → AURA handles it. This requires voice to be fast, reliable, and the shortest path.

### Rationale

- Captures natural language with full context in seconds
- Works in more situations (walking, multitasking, hands-full)
- Enables richer input: "remind me about this tomorrow, it's related to the ML project, priority high"
- Differentiates AURA from text-first task managers

### Consequences

- Voice pipeline must be designed carefully (speed, accuracy, offline fallback)
- NLP/AI must understand natural language intent reliably
- Need to handle: background noise, accent variations, mumbling, incomplete sentences

---

## ADR-004 — Human-in-the-loop for all AI actions

**Date:** 2026-07-23
**Status:** Accepted

### Decision

AURA's AI never silently modifies, deletes, or creates important items without presenting a confirmation step.

### Context

Fully automated AI can create anxiety and distrust — "what did it do while I wasn't looking?" Users need to feel in control of their life data.

### Rationale

- Trust: users must be able to trust AURA with their deadlines and reminders
- Reversibility: mistakes can be caught before they happen
- Transparency: user always knows what AI did and why
- Aligns with principle of AURA as an assistant, not autopilot

### Consequences

- Every AI-generated action needs a review/confirm UI step
- This adds a tap in the flow but increases trust significantly
- AI should make the confirmation fast (show what it understood, let user approve in one tap)

---

## ADR-005 — Workspace as the primary organizational unit

**Date:** 2026-07-23
**Status:** Accepted

### Decision

Every object in AURA (task, event, note, reminder) belongs to exactly one workspace. Workspaces are the primary way users navigate and filter their life.

### Context

A university student with internship + IIT prep + college projects + personal life has completely different contexts. Mixing them creates cognitive overload.

### Rationale

- Context separation reduces cognitive load
- Allows focus mode: "show me only VIT work right now"
- Enables per-workspace colors, themes, notification rules
- Natural mental model: people already organize life into domains

### Consequences

- Every object must have a workspace field (non-nullable in DB)
- Voice capture must auto-detect workspace or prompt user to select
- Need a smart workspace router in the AI pipeline

---

## ADR-006 — Tech stack decision

**Date:** 2026-07-23
**Status:** Decided (v1)

### Mobile Frontend

**Decision: Flutter**

| Option                  | Pros                                                                  | Cons                                         |
| ------------------------- | ----------------------------------------------------------------------- | ---------------------------------------------- |
| Flutter                 | Single codebase (Android + iOS + Desktop), excellent UI control, fast | Dart has a learning curve                    |
| React Native            | Huge JS ecosystem                                                     | Bridge overhead, more complex native modules |
| Native Android (Kotlin) | Best Android performance                                              | Android-only, most complex                   |

### Backend

**Decision: No backend for MVP (local-only). FastAPI added later when cloud sync is needed.**

### Local Database

**Decision: Drift ORM on top of SQLite**

| Option                       | Decision                                                                |
| ------------------------------ | ------------------------------------------------------------------------- |
| SQLite raw                   | Too manual                                                              |
| Hive                         | NoSQL, weak querying                                                    |
| **Drift (Flutter + SQLite)** | **Selected — type-safe, migration support, great Flutter integration** |

### Speech-to-Text

**Decision: Android built-in SpeechRecognizer API (free, no API key needed)**

| Option                       | Cost           | Offline?                       | Quality                  |
| ------------------------------ | ---------------- | -------------------------------- | -------------------------- |
| **Android SpeechRecognizer** | **Free**       | Partial (Gboard offline model) | Great for Indian English |
| Google ML Kit STT            | Free           | Yes, fully offline             | Good                     |
| Whisper API (OpenAI)         | ~$0.006/min    | No                             | Excellent                |
| Whisper local                | Free but heavy | Yes                            | Slow on phone            |

Rationale: Built-in Android STT is free, fast, handles Indian English well, and requires zero API setup. We revisit only if quality is insufficient.

### AI / NLP Provider

**Decision: Gemini 2.0 Flash (free tier) as primary. OpenAI trial credit as fallback.**

**Important note:** ChatGPT Plus subscription ≠ OpenAI API access. These are separate products.

- ChatGPT Plus ($20/mo) → access to chatgpt.com only, no API
- OpenAI API → separate account at platform.openai.com, ~$5 free trial credit

| Use Case                     | Provider                     | Cost                        |
| ------------------------------ | ------------------------------ | ----------------------------- |
| NLP / intent extraction      | Gemini 2.0 Flash             | Free (15 req/min free tier) |
| Speech-to-text               | Android built-in             | Free                        |
| Complex reasoning / fallback | OpenAI (trial credit)        | ~$5 free then pay-per-token |
| Alternative free LLM         | Groq API (Llama 3 / Mixtral) | Free tier available         |

Rationale: Gemini free tier is sufficient for MVP-scale NLP. No credit card needed for free tier. Groq is kept as backup option for fast, free inference.

---

## ADR-007 — Workspaces are dynamic, not predefined

**Date:** 2026-07-23
**Status:** Accepted

### Decision

AURA does not ship with a fixed list of workspaces. Workspaces are created
on-the-fly from user conversation and voice input.

### Context

It's impossible to predefine every context of a person's life. A student's life
includes VIT, IIT prep, internship, placements, health, personal projects, and more
— and this changes every semester.

### Rationale

- Flexible: adapts to any user's life without manual setup
- AI-native: AURA detects context from language ("I'm preparing for GATE" → creates GATE workspace)
- Less friction: no onboarding wizard asking you to set up workspaces

### Consequences

- Workspace creation logic must be in the AI pipeline (not just CRUD)
- Need a smart keyword → workspace classifier
- Workspace names must be fuzzy-searchable ("IIT" and "GATE" might be the same workspace)
- Database schema must support dynamic workspace creation

---

## ADR-008 — Share-to-AURA is a first-class input mode

**Date:** 2026-07-23
**Status:** Accepted

### Decision

AURA registers as a share target on Android. Any content — screenshots, links,
documents, media — can be shared into AURA from any app.

### Behavior by content type

| Content | Behavior |
| --------- | ---------- |
| Screenshot | Show image, ask "What do you want to do with this?" → voice response |
| Link | AURA opens and reads it, saves full context, searchable later |
| Document/PDF | Extract key info, classify, attach to workspace |
| Media | Classify and store with description |

### Rationale

- Screenshots are Ishan T's current primary capture method
- Many deadlines arrive via WhatsApp images, portal screenshots, social media
- Links to forms/events carry more info than a manually typed task
- Everything shared to AURA must be organized and searchable later

### Consequences

- Requires Android Sharesheet integration
- Requires OCR for screenshots (ML Kit Document Scanner or similar, free)
- Requires link reading/scraping capability
- All shared content must be classified and indexed in the local database
- Search must work on content descriptions, not just task names

---

## ADR-009 — DND-aware notification replay

**Date:** 2026-07-23
**Status:** Accepted

### Decision

AURA respects Android's Do Not Disturb mode. When DND is lifted,
all AURA notifications that fired during DND are replayed immediately.
No notification is ever silently dropped.

### Context

Ishan T uses DND during interviews, coding assessments, strict classes.
These are exactly the moments when important reminders might fire.
Silently dropping them defeats the purpose of the reminder.

### Rationale

- A missed reminder during DND is worse than no reminder — you think it fired
- Replay-on-lift ensures guaranteed delivery
- Matches user mental model: "I'll check when I'm free"

### Consequences

- Need a notification queue/log in the database
- Must monitor DND state changes (Android BroadcastReceiver for DND change)
- Replay should be batched (one summary notification listing all missed, not spam)
- Time-sensitive replays ("interview in 15 min" that fired 2 hours ago) should
  be contextually reworded ("You had a reminder 2 hours ago about...")

---

## ADR-010 — OCR and link reading strategy

**Date:** 2026-07-23
**Status:** Accepted

### Screenshot OCR

**Decision: Google ML Kit Document Scanner / Text Recognition (free, on-device)**

| Option | Cost | Offline | Quality |
| -------- | ------ | --------- | --------- |
| Google ML Kit | Free | Yes | Excellent for Android |
| Tesseract (open source) | Free | Yes | Lower quality |
| Cloud Vision API | Paid | No | Overkill |

Rationale: ML Kit is built for Android, works entirely on-device, free, no API key,
handles screenshots including handwriting and printed text.

### Link Reading

**Decision: Smart length-based strategy**

```
Shared link arrives
       ↓
Fetch page content
       ↓
Measure content size
       ↓
Short content  → Read fully
Long content   → Extract: title, dates, deadlines, key action items
```

Implementation: Use a lightweight HTML parser (html package in Dart) + Gemini for
summarization of long content (one free API call per link).

---

## ADR-011 — Flutter as the cross-platform foundation

**Date:** 2026-07-23
**Status:** Accepted

### Decision

Flutter is the single codebase for all current and future platforms.

| Platform | Support | Timeline |
| ---------- | --------- | ---------- |
| Android | Primary | Phase 8 (now) |
| iOS | Secondary | After Android MVP |
| Windows | Future | Post-launch |
| macOS | Future | Post-launch |
| Web | Future | Post-launch |

### Rationale

- One codebase, all platforms — zero extra cost for desktop later
- Dart is learnable and well-documented
- Flutter's rendering engine gives full UI control (no native component constraints)
- Drift ORM (SQLite) works on all Flutter platforms
- Flutter has mature Android overlay/accessibility support needed for floating button

### Consequence

- All architecture decisions must be platform-agnostic from day one
- Native Android code (Accessibility Service for floating button, BroadcastReceiver for DND)
  will be in a thin platform channel layer, keeping core logic in Dart

## ADR-012 — No emojis. Lucide Icons as the single icon system

**Date:** 2026-07-24
**Status:** Accepted

### Decision

AURA uses zero emojis anywhere in the UI.
All icons throughout the app use **Lucide Icons** as the single, uniform icon set.

### Context

Emojis are OS-rendered glyphs. They look different on every device, every Android version, every OEM skin (Samsung, OnePlus, stock Android all render emojis differently). They carry an inherently casual, consumer-app personality that conflicts with AURA's sharp, premium, neubrutalist identity.

We need one icon set that:

- Looks identical on every device
- Matches the visual weight of neubrutalism's 2px borders
- Has consistent stroke width across all icons (no mixing filled + outline + rounded + flat)
- Covers every use case in AURA without needing a second icon set

### Options Considered

| Option | Stroke | Consistency | Flutter package | Notes |
| -------- | -------- | ------------- | ----------------- | ------- |
| **Lucide Icons** | 2px, consistent | Excellent | lucide_icons | Geometric, modern, 1500+ icons |
| Phosphor Icons | Variable weights | Good | phosphor_flutter | Multiple weight options — good but overkill |
| Material Icons | Variable | Moderate | built-in Flutter | Mix of filled/outlined styles |
| Material Symbols | Variable | Moderate | material_symbols_icons | Better than Material Icons, still not neubrutalist |
| Heroicons | 1.5px / 2px | Good | manual TTF | Tailwind-adjacent feel |
| Feather Icons | 2px | Good | eather_icons | Fewer icons, older |

### Rationale

- **Lucide Icons wins** because its 2px uniform stroke width is the exact visual weight of AURA's neubrutalist 2px white borders — the icons feel like part of the same visual language, not pasted on top.
- 1500+ icons covers everything AURA needs without ever reaching for a second set.
- lucide_icons Flutter package is actively maintained, null-safe, and works as standard Flutter Icon widgets.
- Fully vector — renders crisply at every size and pixel density.
- Zero emoji anywhere, ever. Not in UI. Not in empty states. Not in onboarding. Not in notifications.

### Icon Usage Spec

All icons in AURA:

- Color: white (#FFFFFF) for primary,
gba(255,255,255,0.6) for secondary
- Size: 20dp standard UI, 24dp app bar / nav bar, 16dp inline / labels, 32dp empty states
- Stroke: always rendered as lucide_icons provides — do not scale icon weight artificially
- Never mix with emojis or other icon sets
- Workspace identifiers: use Lucide icons (not emojis). Map:
  - VIT / College         → LucideIcons.graduationCap
  - GATE Prep             → LucideIcons.target
  - Internship            → LucideIcons.briefcase
  - Personal              → LucideIcons.user
  - Health                → LucideIcons.heart
  - Finance               → LucideIcons.creditCard
  - Projects              → LucideIcons.layoutGrid
  - Custom (user-created) → LucideIcons.folder

### Consequences

- All wireframe docs that use emojis (📚🎯💼👤❤️📋📅🔔🗂️) must be treated as semantic placeholders — replace with Lucide equivalents during Phase 8 implementation.
- design_system.md updated with full icon system spec.
- The AURA-ux-designer skill updated with this rule.
- No visual impact on design language — Lucide stroke style is a natural extension of the neubrutalist border system.

### Related ADRs

- ADR-006: Tech stack — Flutter confirmed (Lucide package is Flutter-native)
- ADR-011: Flutter cross-platform — Lucide renders identically on all Flutter platforms

---

## ADR-013 — No preloaded test data in production release

**Date:** 2026-07-25  
**Status:** Accepted  

### Decision

Production builds of AURA will contain zero preloaded, hardcoded, or mock data.
Mock tasks, sample workspaces, and example habits are strictly for development/testing phases and MUST be completely excluded from release builds.
On clean install, AURA starts completely blank with empty states that guide the user to perform their first capture.

### Context

During development and sprint testing, hardcoded sample tasks (e.g. "ML Assignment", "DBMS Quiz", "DSA Practice") were populated into UI screens to test layout, spacing, and animations. The user explicitly requested that all preloaded test data be removed for the actual production application. User name default is set to "Ishan".

### Rationale

- User privacy and ownership: The user's life OS must start as a clean slate reflecting only their real-world data.
- Testing clarity: Clearly separates dev/test fixtures from real production behavior.
- Clean onboarding experience: Empty states encourage active engagement (tapping the floating orb to create their first task).

### Consequences

- All sample data in UI widgets must be gated behind development build flags or wired to real Drift database queries.
- Onboarding flow will handle initial user setup (user name: "Ishan").
- Production release build (Sprint 12 final) will execute against an empty Drift DB database.

---

*Created: 2026-07-23*
*Living document — add new ADRs as decisions are made*
