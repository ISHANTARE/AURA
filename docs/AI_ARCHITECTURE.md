# AURA — AI Architecture

> **Version:** 1.0
> **Phase:** 5 — AI Design
> **Status:** Final
> **Last Updated:** 2026-07-24
> **References:** ADR-004, ADR-006, ADR-007, PRD Appendix B, ARCHITECTURE.md

This document defines every AI agent, prompt template, JSON schema, confidence logic,
and failure path in AURA's AI system. During Phase 8, implement exactly from this spec.

---

## AI Design Principles (Non-Negotiable)

1. **AI suggests. Ishan T decides.** (ADR-004) — Every AI output goes to a confirm screen. No silent writes.
2. **Speed over perfection.** — 2 second response target. Use streaming where the API supports it.
3. **Graceful degradation.** — If AI fails, the app still works. Manual entry is always available.
4. **Minimal data sent.** — Never send more than needed. No full task history in every call.
5. **Transparent.** — Every AI call is logged in `ai_actions_log`. Users can audit it in Settings.
6. **Indian English aware.** — Prompts and examples are tuned for Indian English phrasing.

---

## AI Stack (Per ADR-006)

| Component | Provider | Cost | Fallback |
| ----------- | ---------- | ------ | --------- |
| Intent extraction | Gemini 2.0 Flash | Free (15 req/min) | Manual entry form |
| Workspace classifier | Built into intent extraction call | — | Prompt user to select |
| Morning briefing line | Gemini 2.0 Flash | Free | Static template |
| Link summarization | Gemini 2.0 Flash | Free | Show raw extracted text |
| OCR | Google ML Kit (on-device) | Free, offline | Show "couldn't read image" |
| STT | Android SpeechRecognizer | Free, built-in | Text input keyboard |

---

## Agent 1: Intent Extractor

**Purpose:** Convert voice transcript to structured AURA data.  
**Trigger:** Every voice capture or text input.  
**Model:** Gemini 2.0 Flash  
**Timeout:** 8 seconds  
**Max retries:** 1

### System Prompt

```
You are AURA's intent extraction engine for an AI life management app.
Your job is to parse a voice transcript and extract structured task or event data.

RULES:
1. Return ONLY valid JSON — no markdown, no explanation, no surrounding text.
2. Never invent data the user did not mention. Set unknown fields to null.
3. Include a confidence score (0.0 to 1.0) for the overall parse.
4. Per-field confidence: include a "_conf" float for fields you are uncertain about.
5. Understand Indian English: "toh", "na", "yaar", colloquial date references.
6. Date references: resolve relative to the current_datetime in context.
   "today" = current date, "tomorrow" = +1 day, "next Friday" = next occurrence of Friday.
7. Time references without AM/PM: assume context (morning = AM, afternoon/evening = PM).
8. "remind me before" = set a reminder N time before deadline.

OUTPUT SCHEMA:
{
  "intent_type": "create_task" | "create_event" | "set_reminder" | "add_note" | "query" | "ambiguous",
  "title": string | null,
  "deadline_iso": string | null,           // ISO 8601: "2026-08-01T23:59:00"
  "event_start_iso": string | null,        // For events: start time ISO 8601
  "event_end_iso": string | null,          // For events: end time ISO 8601 (assume +1hr if not stated)
  "event_location": string | null,
  "workspace_hint": string | null,         // Detected workspace keyword (not full name)
  "section_hint": string | null,           // Detected section keyword (if mentioned)
  "priority": "high" | "medium" | "low" | null,
  "is_recurring": boolean,
  "recurrence_type": "daily" | "weekly" | "custom" | null,
  "recurrence_days": [string] | null,      // ["MON","WED","FRI"] for weekly
  "reminders": [
    {
      "offset_value": integer,             // e.g., 1
      "offset_unit": "minutes" | "hours" | "days",  // e.g., "days"
      "type": "notification" | "alarm"
    }
  ],
  "notes": string | null,
  "contact": string | null,               // Mentioned person/professor name
  "confidence": float,                    // 0.0–1.0 overall
  "title_conf": float | null,             // Only present if < 0.85
  "deadline_conf": float | null,
  "workspace_conf": float | null
}
```

### User Prompt Template

```
Context:
- Current datetime: {current_datetime}
- User's workspaces: {workspace_names_list}
- Recent task titles (for context references): {recent_task_titles}

Voice transcript:
"{transcript}"

Extract the intent and return JSON only.
```

### Few-Shot Examples (included in system prompt)

**Example 1 — Simple task with layered reminders:**

```
Input: "ML assignment due Friday at 11:59 PM, remind me day before and 6 hours before"
Output: {
  "intent_type": "create_task",
  "title": "ML Assignment",
  "deadline_iso": "2026-08-01T23:59:00",
  "workspace_hint": "ML",
  "priority": "medium",
  "is_recurring": false,
  "reminders": [
    {"offset_value": 1, "offset_unit": "days", "type": "notification"},
    {"offset_value": 6, "offset_unit": "hours", "type": "notification"}
  ],
  "confidence": 0.95
}
```

**Example 2 — Event with location:**

```
Input: "Interview at TCS tomorrow at 3 PM at VIT placement cell"
Output: {
  "intent_type": "create_event",
  "title": "TCS Interview",
  "event_start_iso": "2026-07-25T15:00:00",
  "event_end_iso": "2026-07-25T16:00:00",
  "event_location": "VIT Placement Cell",
  "workspace_hint": "placement",
  "priority": "high",
  "is_recurring": false,
  "reminders": [
    {"offset_value": 1, "offset_unit": "days", "type": "notification"},
    {"offset_value": 60, "offset_unit": "minutes", "type": "alarm"},
    {"offset_value": 15, "offset_unit": "minutes", "type": "alarm"}
  ],
  "confidence": 0.97
}
```

**Example 3 — Recurring task:**

```
Input: "Add daily DSA practice, every day, remind me at 9 PM"
Output: {
  "intent_type": "create_task",
  "title": "DSA Practice",
  "deadline_iso": null,
  "priority": "medium",
  "is_recurring": true,
  "recurrence_type": "daily",
  "reminders": [
    {"offset_value": 0, "offset_unit": "minutes", "type": "notification"}
  ],
  "notes": "Reminder at 9 PM daily",
  "confidence": 0.93
}
```

**Example 4 — Ambiguous / low confidence:**

```
Input: "Remind me about that thing Rahul mentioned"
Output: {
  "intent_type": "set_reminder",
  "title": "Follow up with Rahul",
  "deadline_iso": null,
  "contact": "Rahul",
  "workspace_hint": null,
  "confidence": 0.42,
  "title_conf": 0.38
}
```

---

## Agent 2: Workspace Router

**Purpose:** Map workspace_hint from intent extraction to an actual workspace ID.  
**Implementation:** Local logic only — NO additional API call.  
**Speed:** < 10ms (synchronous, runs in isolate if needed)

### Algorithm

```dart
WorkspaceMatchResult routeWorkspace(
  String? workspaceHint,
  double? workspaceConf,
  List<Workspace> existingWorkspaces,
) {
  if (workspaceHint == null) {
    return WorkspaceMatchResult.noMatch();
  }

  // Step 1: Exact name match (case-insensitive)
  final exactMatch = existingWorkspaces.firstWhere(
    (w) => w.name.toLowerCase() == workspaceHint.toLowerCase(),
    orElse: () => null,
  );
  if (exactMatch != null) return WorkspaceMatchResult.match(exactMatch, 1.0);

  // Step 2: Keyword → workspace mapping
  final keywordMap = {
    'vit': ['vit', 'college', 'vtop', 'professor', 'assignment', 'lab', 'exam', 'submission'],
    'gate': ['gate', 'iit', 'pyq', 'aptitude', 'algo', 'algorithm', 'mock test'],
    'internship': ['internship', 'standup', 'sprint', 'pr', 'deploy', 'client', 'work'],
    'placement': ['placement', 'interview', 'resume', 'oa', 'coding round', 'offer'],
    'personal': ['personal', 'home', 'family', 'hobby'],
    'health': ['gym', 'exercise', 'medicine', 'doctor', 'workout', 'health'],
  };

  double bestScore = 0.0;
  Workspace? bestMatch;
  for (final workspace in existingWorkspaces) {
    final keywords = keywordMap[workspace.name.toLowerCase()] ?? [];
    if (keywords.any((k) => workspaceHint.toLowerCase().contains(k))) {
      final score = 0.75;  // keyword match confidence
      if (score > bestScore) { bestScore = score; bestMatch = workspace; }
    }
  }

  if (bestMatch != null) return WorkspaceMatchResult.match(bestMatch, bestScore);

  // Step 3: Fuzzy match on workspace names
  // (use string similarity — Levenshtein distance)
  // If similarity > 0.6 → consider a match at 0.6 confidence

  // Step 4: No match → suggest creating new workspace
  return WorkspaceMatchResult.newWorkspace(workspaceHint);
}
```

### Confidence → UI Mapping

| Workspace confidence | UI treatment |
| --------------------- | ------------- |
| ≥ 0.85 | Pre-filled with `[auto]` badge — user can change |
| 0.5–0.84 | Pre-filled with amber `[auto?]` badge — prompt to verify |
| < 0.5 | Empty — "Select workspace" prompt (mandatory before save) |
| No match | "New: [name]" badge — will be created on confirm |

---

## Agent 3: Morning Briefing Generator

**Purpose:** Generate the daily personalized summary line.  
**Trigger:** Background service at calculated briefing time.  
**Model:** Gemini 2.0 Flash  
**Timeout:** 10 seconds (less time-critical than capture)  
**Fallback:** Static template if API fails.

### System Prompt

```
You are AURA's morning briefing writer. Generate a single short, honest, direct
motivational or accountability line for the user's morning briefing.

RULES:
1. Maximum 2 sentences.
2. Be specific to the data provided — reference actual tasks or counts.
3. Tone: direct, honest, slightly encouraging. Not preachy. Not generic.
4. Reflect reality: if they missed things yesterday, acknowledge it directly.
5. Avoid: "You've got this!", "Great job!", "Remember to..." — these are canned.
6. Return ONLY the text. No JSON. No quotes. No markdown.
```

### User Prompt Template

```
User data for today:
- Tasks due today: {urgent_count}
- Tasks due this week: {week_count}
- Yesterday: completed {done_yesterday} of {total_yesterday} tasks
- Missed recurring tasks yesterday: {missed_recurring_names}
- Current streak (days with all recurring done): {streak_days}

Generate the morning briefing summary line.
```

### Fallback Templates (used when API unavailable)

```dart
final staticTemplates = [
  "{urgent_count} deadline{s} today. Stay sharp.",
  "{week_count} things due this week. Start with the hardest.",
  "Yesterday: {done}/{total}. Today's another shot.",
  "{missed_count} habits missed yesterday. Make up for it today.",
];
```

---

## Agent 4: Link Content Processor

**Purpose:** Summarize web page content shared to AURA.  
**Trigger:** Share-to-AURA with a URL.  
**Model:** Gemini 2.0 Flash  
**Timeout:** 12 seconds (network fetch + AI)

### Processing Logic (ADR-010)

```dart
Future<LinkSummary> processLink(String url) async {
  // Step 1: Fetch HTML
  final html = await linkReaderDataSource.fetchHtml(url);
  final text = htmlToText(html);  // strip tags, scripts, styles
  final wordCount = text.split(' ').length;

  // Step 2: Size-based strategy
  if (wordCount < 500) {
    // Short content: send full text
    return await gemini.summarizeLink(text, strategy: 'full');
  } else {
    // Long content: extract key parts only
    final extracted = extractKeyParts(text);  // title + dates + action verbs + deadlines
    return await gemini.summarizeLink(extracted, strategy: 'extract');
  }
}
```

### System Prompt (Link Summarizer)

```
You are AURA's link content processor. Extract task/event-relevant information
from web page content for a productivity app.

RULES:
1. Extract: deadlines, dates, event names, action items, submission requirements.
2. Ignore: ads, navigation, boilerplate, unrelated content.
3. Return JSON only.

OUTPUT SCHEMA:
{
  "page_title": string,
  "summary": string,                  // 1-2 sentence plain English summary
  "detected_deadlines": [
    {"description": string, "date_iso": string | null}
  ],
  "detected_events": [
    {"name": string, "date_iso": string | null, "location": string | null}
  ],
  "suggested_task_title": string | null,  // Best single task name for this content
  "key_action": string | null             // What the user probably needs to do
}
```

---

## Agent 5: OCR + Combined Intent (Share → Screenshot)

**Purpose:** Combine ML Kit OCR text with user voice to create rich task context.  
**Implementation:** Local OCR (ML Kit) + Intent Extractor (Gemini) in sequence.

### Flow

```dart
Future<VoiceCaptureResult> processSharedScreenshot({
  required String ocrText,
  required String userVoiceTranscript,
}) async {
  // Combine context for Gemini
  final combinedInput = '''
    [Screenshot content (OCR)]: $ocrText
    [User instruction]: $userVoiceTranscript
  ''';

  // Run through Intent Extractor (same Agent 1 prompt)
  // OCR gives it rich context: dates, names, deadlines visible in image
  return await intentExtractor.extract(
    transcript: combinedInput,
    context: intentContext,
  );
}
```

---

## Confidence Scoring System

### Overall Confidence Thresholds

| Score | Meaning | UI behavior |
| ------- | --------- | ------------- |
| ≥ 0.85 | High confidence | All fields pre-filled. `[auto]` badges shown. One-tap confirm. |
| 0.65–0.84 | Medium confidence | Most fields pre-filled. Uncertain fields highlighted amber. |
| 0.40–0.64 | Low confidence | Fields filled but flagged. "AURA isn't sure — please review." |
| < 0.40 | Very low / failed | Mostly empty. "Couldn't understand clearly. Fill manually or try again." |

### Per-Field Confidence Visual

```
High (≥ 0.85):    Field shown in white — no indicator
Medium (0.5–0.84): Amber dot (●) left of value + [auto?] badge
Low (< 0.5):       Value in amber (#FF7A29) + "?" suffix + [?] badge
Missing (null):    Secondary italic: "Tap to add [field]"
```

---

## AI Rate Limit Management

Gemini free tier: 15 requests/minute, 1500 requests/day.

```dart
class RateLimiter {
  final _queue = Queue<Completer<void>>();
  int _requestsThisMinute = 0;
  static const _maxPerMinute = 12;  // Keep 3 as buffer

  Future<void> throttle() async {
    if (_requestsThisMinute >= _maxPerMinute) {
      // Wait until next minute window
      final completer = Completer<void>();
      _queue.add(completer);
      await completer.future;
    }
    _requestsThisMinute++;
    // Reset counter after 60 seconds
    Future.delayed(Duration(seconds: 60), () => _requestsThisMinute--);
  }
}
```

When rate limited → show: *"AI is a bit busy right now. Processing in a moment..."*

---

## Error Handling Matrix

| Error | Cause | User sees | System does |
| ------- | ------- | ----------- | ------------- |
| Timeout (>8s) | Slow network / API | "Taking longer than expected. Try again?" | Log failure, offer retry |
| API 429 | Rate limit | "AI is busy. Processing shortly..." | Queue request, retry in 60s |
| Malformed JSON | Gemini hallucination | "Couldn't parse — fill manually" | Log malformed response, retry once |
| Network offline | No internet | "Saved as draft. Will process when connected." | Write to offline_queue |
| API 500 | Gemini server error | "AI is down. Enter manually or try later." | Log error, offer manual entry |
| STT error | Mic issue / noise | "Couldn't hear clearly. Try again or type." | Reset capture state |

---

## AI Transparency Log

Every Gemini API call is logged to `ai_actions_log`:

```
id:            UUID
input_text:    The transcript or content sent (NOT raw audio)
raw_response:  Full Gemini JSON response
parsed_json:   Our parsed result
confidence:    Top-level confidence score
action_taken:  "task_created" | "draft_saved" | "dismissed" | "manual_override"
task_id:       Linked task if created
user_edited:   Boolean — did user change the AI's suggestion?
created_at:    Timestamp
```

This log is **visible to the user** in Settings → Privacy → View AI History.
The user can delete the log at any time.

---

*AI Architecture v1.0 — 2026-07-24*
*Phase 5 complete. Next: Phase 6 — Database Design.*
