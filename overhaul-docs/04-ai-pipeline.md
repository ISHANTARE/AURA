# AI Intent Extraction & Intelligence Pipeline

> **Forensic Rebuild Specification**  
> Complete specification for AURA's Natural Language Processing, LLM integration, rate limiting, offline NLP parser, workspace taxonomy routing, and action dispatching engine.

---

## 1. AI Pipeline Overview

AURA processes spoken voice transcripts and text inputs through a unified intent extraction pipeline that outputs structured action metadata:

```
                  ┌───────────────────────────────┐
                  │ Spoken Transcript / Raw Input │
                  └───────────────┬───────────────┘
                                  │
                                  ▼
                  ┌───────────────────────────────┐
                  │   LlmApiDataSource (Online)   │
                  │   - Sliding-Window Rate Limit │
                  │   - 30s HTTP Timeout          │
                  │   - Error Classification      │
                  └───────┬───────────────┬───────┘
                          │               │
      Config/Auth Error   │               │ Transient Network / Rate Limit / No Key
      (Never masked)      │               │
            ▼             │               ▼
 ┌─────────────────────┐  │    ┌───────────────────────────────┐
 │ Throw LlmApiException│  │    │      LocalIntentParser        │
 │ (Actionable UI Msg) │  │    │  (Offline Rule-Based Regex)   │
 └─────────────────────┘  │    └───────────────┬───────────────┘
                          │                    │
                          ▼                    ▼
                  ┌───────────────────────────────┐
                  │    ExtractOutcome / Result    │
                  └───────────────┬───────────────┘
                                  │
                                  ▼
                  ┌───────────────────────────────┐
                  │    WorkspaceRouterUseCase     │
                  │ (Exact → Fuzzy → Taxonomy)    │
                  └───────────────┬───────────────┘
                                  │
                                  ▼
                  ┌───────────────────────────────┐
                  │     Confirmation UI Box       │
                  │    (Human-in-the-Loop)        │
                  └───────────────┬───────────────┘
                                  │
                                  ▼
                  ┌───────────────────────────────┐
                  │    ExecuteAiActionUseCase     │
                  │ (Single Action Dispatcher)    │
                  └───────────────────────────────┘
```

---

## 2. LLM Configuration & Provider Presets

AURA communicates with any OpenAI-compatible chat completions endpoint (`/v1/chat/completions` or `/v1beta/openai/chat/completions`).

### 2.1 Provider Presets Table

| Preset Name | Base URL (`LLM_BASE_URL`) | Default Model (`LLM_MODEL`) | Auth Format |
|---|---|---|---|
| **Google Gemini (Recommended)** | `https://generativelanguage.googleapis.com/v1beta/openai/` | `gemini-2.0-flash` | `Bearer AIza...` |
| **NVIDIA NIM** | `https://integrate.api.nvidia.com/v1` | `meta/llama-3.3-70b-instruct` | `Bearer nvapi-...` |
| **Groq Cloud** | `https://api.groq.com/openai/v1` | `llama-3.3-70b-versatile` | `Bearer gsk_...` |
| **OpenRouter** | `https://openrouter.ai/api/v1` | `google/gemini-2.0-flash-001` | `Bearer sk-or-...` |
| **Local LLM (Ollama / LM Studio)** | `http://10.0.2.2:11434/v1` | `llama3.2` | `Bearer ollama` |
| **Custom Provider** | User configurable | User configurable | `Bearer <custom>` |

### 2.2 Rate Limiter (`RateLimiter`)

- **Algorithm**: Sliding-window queue of timestamps.
- **Limits**: Maximum **12 requests** per rolling **60-second window**.
- **Behavior**: When limit is reached, calling thread awaits until the oldest timestamp ages out (`window.difference(now)`). Requests are never dropped or rejected.

---

## 3. System Prompt & JSON Grammar

### 3.1 Verbatim System Prompt

```
You are AURA's intent extraction & command intelligence engine for an AI life management app.
Your job is to parse a voice transcript, identify the core action/intent, and extract structured metadata.

ACTIONS & INTENTS:
- "create_task": Task (something to do, title, deadline, priority, workspace, notes).
- "create_reminder": Timed reminder/deadline to alert before submission.
- "create_event": Event (meetings, interview, placement talk, with start time, end time, location).
- "create_alarm": General time-of-day alarm (e.g. "add an alarm for 1.45pm today", "set alarm for 7am").
- "create_workspace": Requests to create a workspace/folder (e.g. "Create a workspace for Placement Prep").
- "delete_task": Requests to remove or cancel a task.
- "delete_workspace": Requests to remove a workspace.
- "add_note": Pure freeform thoughts or ideas without a task/alarm.

CRITICAL RULES:
1. Return ONLY valid JSON — no markdown backticks, no text explanations.
2. NOTES CATCH-ALL RULE: Put any extra details, subtasks, instructions, or descriptions inside "notes".
3. ALARM RULE: If the user says "add an alarm", "set alarm", or mentions a specific wake-up/alert time without task context, set intent_type to "create_alarm".
4. Relative dates: Resolve relative to current_datetime in context.

EXAMPLES:
- "Add an alarm for 1.45pm today"
  → {"intent_type": "create_alarm", "title": "Alarm 1:45 PM", "deadline_iso": "2026-07-27T13:45:00"}

- "Create a new workspace named IIT Prep with blue color"
  → {"intent_type": "create_workspace", "title": "IIT Prep", "workspace_color_hex": "#3B82F6"}

- "Remind me tomorrow at 5pm to call doctor and ask about prescription"
  → {"intent_type": "create_reminder", "title": "Call doctor", "deadline_iso": "<tomorrow 17:00>", "notes": "ask about prescription"}

- "Just note down project submission portal opens on Friday"
  → {"intent_type": "add_note", "title": "Project submission portal opens on Friday", "notes": "project submission portal opens on Friday"}

OUTPUT SCHEMA:
{
  "intent_type": "create_task" | "create_reminder" | "create_event" | "create_alarm" | "create_workspace" | "delete_task" | "delete_workspace" | "add_note",
  "title": string | null,                  // Core task title or workspace name
  "target_name": string | null,            // Item name to delete/update if intent is delete_task or delete_workspace
  "deadline_iso": string | null,           // ISO 8601 e.g. "2026-08-01T23:59:00"
  "event_start_iso": string | null,
  "event_end_iso": string | null,
  "event_location": string | null,
  "workspace_hint": string | null,         // Target workspace name
  "workspace_color_hex": string | null,    // Hex color if creating workspace e.g. "#FF5733"
  "workspace_icon_key": string | null,     // Icon key if creating workspace e.g. "folder", "book", "code", "briefcase"
  "priority": "high" | "medium" | "low" | null,
  "is_recurring": boolean,
  "recurrence_type": "daily" | "weekly" | "custom" | null,
  "reminders": [
    {
      "offset_value": integer,
      "offset_unit": "minutes" | "hours" | "days",
      "type": "notification" | "alarm"
    }
  ],
  "notes": string | null,                  // ALL extra spoken details, context, or sub-points
  "confidence": float
}
```

### 3.2 Dynamic Context Prompt Construction

```
Context:
- Current datetime: 2026-08-29T14:30:00+05:30 (Saturday)
- User timezone offset: 5:30:00.000000
- User's existing workspaces: Work, Personal, IIT Prep

Voice transcript:
"<user spoken text>"

Extract the intent and return JSON only. Ensure deadline_iso is correctly resolved relative to Current datetime.
```

---

## 4. Robust Response Cleaning & Error Hierarchy

### 4.1 JSON Extraction Strategies (`_cleanJsonString`)

1. **Strategy 1 (Bracket Slicing)**: Scans for first `{` and last `}` and substrings the JSON object. Handles prose wrapping and conversational AI preambles.
2. **Strategy 2 (Code Fence Stripping)**: Trims leading and trailing ```json / ``` fences if brackets fail.

### 4.2 Error Handling & Fallback Contract

```dart
enum LlmFailureKind { auth, modelNotFound, rateLimited, network, badResponse, noApiKey }
```

- **Config Errors (HTTP 401, 403, 400, 404)**: Throws `LlmApiException`. Never masked. Displays actionable guidance in the UI: *"Invalid API key. Update your key in Settings → AI Engine."*
- **Transient Failures (HTTP 429, 5xx, SocketException, TimeoutException, FormatException)**: Automatically degrades to `LocalIntentParser` and sets `ExtractOutcome.fallbackNotice`: *"AI rate limit reached — parsed offline."*
- **Missing API Key**: Immediately routes to `LocalIntentParser` with notice: *"No API key set — using offline parser."*

---

## 5. Offline Rule-Based NLP Parser (`LocalIntentParser`)

`LocalIntentParser` operates locally using regular expressions and date arithmetic:

```dart
// 1. Alarm Pattern: e.g. "set alarm for 7:30 am", "add alarm at 8pm"
RegExp(r'(?:set\s+an?\s+alarm|add\s+an?\s+alarm|set\s+alarm|alarm)\s+(?:for|at)?\s*(\d{1,2})(?::(\d{2}))?\s*(am|pm)?')
// -> intent_type: 'create_alarm', title: 'Alarm 7:30 AM', confidence: 0.85

// 2. Workspace Creation Pattern: "create a workspace named Placement Prep"
RegExp(r'(?:create|add|new)\s+(?:a\s+)?workspace\s+(?:named|called|for)?\s+(.+)')
// -> intent_type: 'create_workspace', color: '#C8FF00', confidence: 0.90

// 3. Deletion Patterns: "delete task assignment", "remove workspace test"
// -> intent_type: 'delete_task' / 'delete_workspace', target_name: '...', confidence: 0.85

// 4. Quick Note Pattern: "note down project ideas", "take a note buy milk"
RegExp(r'^(?:just\s+)?(?:note\s+down|add\s+note|quick\s+note|take\s+a\s+note)\s+(.+)')
// -> intent_type: 'add_note', title: truncated <= 30 chars, confidence: 0.85

// 5. Task & Reminder Pattern: "remind me to call doctor tomorrow at 5pm"
// - Strips prefixes: "remind me (to)?", "add a task (to)?", "create task"
// - Parses dates: "today", "tomorrow", "at H(:M)? (am/pm)?"
// - Sets priority: 'high' if contains "urgent" or "important", else 'medium'
// - Auto-schedules: 30 minutes before notification if deadline resolved. Confidence: 0.75
```

---

## 6. Workspace Routing Engine (`WorkspaceRouterUseCase`)

Routes `workspace_hint` to actual user workspaces using a 4-tier resolution hierarchy:

```
Tier 1: Exact Name Match (Case-Insensitive)
  - w.name.toLowerCase() == hint.toLowerCase() → Confidence: 1.0 (Exact)

Tier 2: Fuzzy Containment & Token Overlap
  - w.name.contains(hint) || hint.contains(w.name) → Confidence: 0.9 / 0.8
  - Significant token match (excluding 'the', 'and', 'for', 'my', 'of') → Confidence: 0.75

Tier 3: Generic Taxonomy Fallback
  - Matches hint against WorkspaceTaxonomy categories:
    • 'work': ['work', 'office', 'standup', 'sprint', 'deploy', 'client', 'meeting', 'project', 'deadline', 'report']
    • 'personal': ['personal', 'home', 'family', 'hobby', 'errand', 'shopping']
    • 'health': ['gym', 'exercise', 'medicine', 'doctor', 'workout', 'fitness', 'run']
    • 'finance': ['finance', 'budget', 'bank', 'tax', 'invoice', 'payment', 'rent']
    • 'learning': ['study', 'learn', 'course', 'exam', 'assignment', 'class', 'school', 'college', 'university', 'reading']
  - If user has a workspace matching the category name → Confidence: 0.70

Tier 4: Suggest New Workspace
  - Returns WorkspaceMatchResult.newWorkspace(hint)
```

---

## 7. Action Dispatcher (`ExecuteAiActionUseCase`)

Single dispatcher routing confirmed intents:

| Intent Type | Dispatch Execution | Return Confirmation Message |
|---|---|---|
| `create_alarm` | Inserts `Item` (`category: 'alarm', kind: 'alarm'`), calls `ReminderSchedulingService.syncForItem(item)`. | `"Set alarm for <time>"` |
| `create_workspace` | Inserts `Workspace` into `workspaces` table. | `"Created workspace \"<name>\""` |
| `delete_task` | Searches active tasks by title. Cancels OS alarms via `ReminderSchedulingService.cancelForItem(id)` and soft-deletes item. | `"Deleted task \"<title>\""` |
| `delete_workspace` | Matches workspace by name. Soft-deletes workspace. | `"Deleted workspace \"<name>\""` |
| `create_task` | Dispatches to `CreateTaskUseCase.execute(...)` | `"Saved task \"<title>\""` |
| `create_reminder` | Dispatches to `CreateTaskUseCase.execute(...)` | `"Reminder set \"<title>\" for <time>"` |
| `create_event` | Dispatches to `CreateTaskUseCase.execute(...)` | `"Event scheduled \"<title>\" for <time>"` |
| `add_note` | Dispatches to `CreateTaskUseCase.execute(...)` (`kind: 'note'`) | `"Saved task \"<title>\""` |
