---
name: AURA-ai-architect
description: >
  AI pipeline architect for AURA. Use this skill when: designing AI agents, writing Gemini prompts,
  designing the intent extraction pipeline, designing the workspace classifier, designing the morning
  briefing agent, designing the scheduling intelligence, working on the voice-to-task pipeline,
  or when the user says "design the AI for X", "write the prompt for X", "how should the AI handle X",
  "design the intent parser", "what model should I use for X", or "how does the AI decide X".
  This skill covers Phase 5 AI Architecture work and Phase 8 AI implementation.
---

# AURA AI Architect

You are designing and implementing the AI system inside AURA. AI in AURA serves one purpose:
eliminate the manual work of organizing a human life. Every AI component must be fast, transparent,
and always require human confirmation before acting (ADR-004).

## Core AI Design Principles

1. **AI suggests. Human decides.** (ADR-004) — No silent actions. Every AI output is reviewable.
2. **Fast over perfect.** — 2 second response or less. Use streaming where possible.
3. **Graceful degradation.** — When offline or API fails, the app still works (queue for later).
4. **Privacy.** — Minimize what is sent to external APIs. Prefer on-device processing.
5. **Transparency.** — Show confidence levels. Show what the AI understood. Let user edit.

## AI Providers (Per ADR-006)

| Use Case | Provider | Cost | Notes |
|----------|----------|------|-------|
| Intent extraction (primary) | Gemini 2.0 Flash | Free (15 req/min) | Main NLP engine |
| Complex reasoning / fallback | OpenAI GPT-4o mini | Pay-per-token | Trial credit available |
| Alternative free inference | Groq (Llama 3.1) | Free tier | Fast, no rate limit issues |
| STT | Android SpeechRecognizer | Free | Built-in, no API key |
| OCR | Google ML Kit | Free, on-device | Screenshot text extraction |

## AURA AI Agents

### Agent 1: Intent Extractor (Core — Phase 5)

**Purpose:** Convert voice transcript to structured task/event data.

**Input:** Raw voice transcript string
**Output:** Structured JSON

```json
{
  "intent_type": "create_task | create_event | set_reminder | add_note | query",
  "task_name": "ML assignment",
  "deadline": "2026-08-03T23:59:00",
  "estimated_hours": null,
  "priority": "high | medium | low | null",
  "workspace_hint": "VIT | IIT | internship | personal | null",
  "reminders": [
    {"offset_days": 3, "type": "notification"},
    {"offset_days": 1, "type": "notification"},
    {"offset_hours": 2, "type": "alarm"}
  ],
  "notes": "Complete EDA section first",
  "subtasks": ["Complete EDA"],
  "contact": null,
  "confidence": 0.95
}
```

**Prompt Pattern:**
```
System: You are AURA's intent extraction engine. Parse the user's voice input and extract
structured task data. Return ONLY valid JSON. Never invent data not mentioned.
If uncertain about a field, return null. Include a confidence score 0-1.

User: [voice transcript]
```

### Agent 2: Workspace Router (Phase 5)

**Purpose:** Assign incoming tasks/events to the correct workspace.

**Input:** Task name, notes, context keywords
**Output:** Workspace name + confidence

**Logic:**
- High confidence (>0.85): Auto-select but show in confirm card
- Medium confidence (0.5-0.85): Show top 2 options for user to pick
- Low confidence (<0.5): Ask user to select workspace explicitly

**Keyword Signals:**
- "assignment", "exam", "professor", "submission", "VIT", "subject" → College
- "GATE", "JEE", "IIT", "mock test", "concept", "chapter" → IIT Prep
- "meeting", "client", "PR", "deploy", "standup", "sprint" → Internship
- "gym", "workout", "doctor", "health", "medicine" → Health

### Agent 3: Morning Briefing Generator (Phase 5)

**Purpose:** Generate a personalized daily plan and summary every morning.

**Input:** Today's tasks (sorted by deadline), pending reminders, calendar events
**Output:** Structured briefing

**Briefing Format:**
- Greeting with personalized context
- Critical deadlines (due today or within 48 hours)
- Recommended task order (AI-prioritized)
- Quick wins (tasks < 30 min)
- Reminders that fired during DND overnight (ADR-009)

**Timing:** Auto-detect from phone unlock pattern OR manual override by user.

### Agent 4: Share Content Processor (Phase 5)

**Purpose:** Process content shared to AURA from other apps (ADR-008).

**By Content Type:**
- Screenshot → ML Kit OCR → extract text → Intent Extractor → confirm
- Link → Fetch HTML → Smart length check → Gemini summarize → extract action items → confirm
- Document/PDF → Extract text → classify → attach to workspace → confirm
- Plain text → Intent Extractor directly → confirm

**Link Reading Strategy (ADR-010):**
```
Fetch page
  -> Measure content length
  -> If < 2000 tokens: send full content to Gemini
  -> If >= 2000 tokens: extract title, dates, deadlines, key action verbs only
  -> Parse into task/event structure
  -> Show confirmation
```

### Agent 5: Scheduling Intelligence (Phase 5 - Later)

**Purpose:** Suggest optimal time slots for tasks based on deadlines and estimated hours.

**Input:** Task list with deadlines and estimated hours
**Output:** Suggested daily schedule

**Rules:**
- Never auto-schedule without user approval
- Respect user-defined work hours (configurable)
- Factor in deadlines: work backwards from due date
- Surface conflicts: overlapping time blocks

## Voice Pipeline State Machine

```
IDLE
  -> user taps button
LISTENING
  -> Android SpeechRecognizer active
  -> Live transcript displayed
  -> user stops speaking or taps stop
PROCESSING (AI)
  -> Gemini API called (show spinner)
  -> Parse JSON response
CONFIRMING
  -> Show parsed data as editable card
  -> User reviews each field
  -> User approves / edits / rejects
SAVING
  -> Write to Drift DB
  -> Schedule notifications
  -> Update UI
SUCCESS
  -> Haptic feedback + animation
  -> Return to IDLE
```

## Error Handling for All Agents

| Error | Behavior |
|-------|---------|
| API timeout (>5s) | Show "AI is slow, try again" + manual entry option |
| Rate limit hit | Queue request, process in 60 seconds |
| Malformed JSON | Retry once, then fall back to manual entry |
| Offline | Queue transcript locally, process when online |
| Low confidence | Show uncertainty indicator, ask user to confirm each field |

## Prompt Engineering Standards

- Always specify output format explicitly (JSON schema)
- Always say "Never invent data the user did not mention"
- Always include a confidence score request
- Keep system prompts under 500 tokens for speed
- Use few-shot examples for complex extractions
- Test prompts with Indian English accent variations

## Privacy Rules for AI Calls

- Never send more context than necessary to the API
- Do not send full task history in every API call
- Summarize context, do not dump raw data
- Store all AI call inputs/outputs locally for transparency (user can review)
- Clearly label all AI-generated content in the UI
