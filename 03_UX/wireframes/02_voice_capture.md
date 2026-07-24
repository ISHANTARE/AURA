# Wireframe: Voice Capture Popup

> **Feature:** F-02 — Voice Capture Flow
> **Trigger:** Tap floating orb from any app / any AURA screen
> **Design:** Compact bottom popup (~35% height). Background app stays fully visible.

---

## Screen Layout (Popup Overlay)

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  📧 Gmail — Prof. Sharma                            │ ← Background app (65% visible)
│                                                     │
│  "ML Assignment deadline is Friday,                 │ ← User is READING this
│  August 1st at 11:59 PM. Please submit              │
│  via VTOP portal only..."                           │
│                                                     │
│  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  │ ← Dim scrim rgba(0,0,0,0.4)
│                                                     │   (dims but does NOT hide)
├─────────────────────────────────────────────────────┤ ← 2px solid white border (top+sides)
│                                                     │
│  ◉A  LISTENING...  ▁▃▅▇▅▃▁▄▆▇▆▄▁▃▅▃   [✕]         │ ← Top row (48dp)
│                                                     │
│  "...ML assignment deadline Friday August            │ ← Live transcript (italic white)
│  first 11:59 PM, remind me day before..."           │
│                                                     │
│  Speaking about: ML Assignment · VIT  🤖            │ ← Context hint (13sp secondary)
│                                                     │
│  [Type instead]          [STOP & PROCESS →]         │ ← Bottom row (48dp)
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## Popup Specifications

```
Position:     Bottom of screen, full width
Height:       ~35% screen height (~295dp on standard phone)
Background:   #141414 — flat dark fill (NOT glassmorphism)
Border:       2px solid #FFFFFF — top, left, right edges only (no bottom border — extends to screen edge)
Scrim:        rgba(0,0,0,0.4) applied over background area only
Slide-in:     Slides up from bottom edge, 250ms ease-out
```

---

## Component Breakdown

### Top Row (Status Bar inside popup)

**Mini Orb**
```
Size:      32dp circle
Style:     Lime #C8FF00 fill, "A" 14sp ExtraBold black, 2px black border
Glow:      0 0 16px 6px rgba(200,255,0,0.06) — ONLY glow allowed (per design system)
Animation: Slow ambient pulse (scale 1.0 → 1.05 → 1.0, 2s loop)
```

**LISTENING label**
```
Text:      "LISTENING..." — 13sp Medium, #C8FF00 (lime), ALL CAPS
Animation: Fade in/out to signal active state
```

**Waveform Visualization**
```
Style:     Vertical bars, lime colored (#C8FF00)
Width:     ~120dp, right-aligned in top row
Bars:      12–16 bars, heights driven by audio amplitude
Animation: Real-time, driven by SpeechRecognizer audio level callbacks
No audio:  Flat line animation (bars at minimal height)
```

**Cancel (✕) Button**
```
Size:      32dp tap target
Style:     White outlined small square, ✕ inside, 2px white border
Position:  Far right of top row
Tap:       Dismiss popup, no save. Shows "Discard?" confirm toast.
```

---

### Middle Section (Transcript + Context)

**Live Transcript**
```
Font:      15sp Regular, white, italic
Alignment: Left
Updates:   Real-time as user speaks (from SpeechRecognizer partial results)
Overflow:  Scrollable if text exceeds 3 lines
Empty:     "Listening... speak now" — secondary, non-italic
```

**Context Hint**
```
Font:      13sp Regular, rgba(255,255,255,0.5)
Format:    "Speaking about: [detected topic] · [workspace]  🤖"
Source:    AI real-time context detection (lightweight, keyword-based for speed)
Hidden:    If no context detected yet
```

---

### Bottom Row (Actions)

**"Type instead" Link**
```
Style:     Text link — 14sp, rgba(255,255,255,0.5)
Tap:       Keyboard opens. Text field replaces waveform area.
           Voice capture stops.
           User types input, taps send.
           Same AI processing applies.
```

**"STOP & PROCESS →" Button**
```
Style:     Lime #C8FF00 background
           Black #000000 bold text — "STOP & PROCESS →"
           2px solid black border
           3px 3px 0px black hard shadow (slightly smaller than standard 4px)
Height:    44dp
Width:     ~180dp
Pressed:   Shadow shrinks to 1px 1px
Tap:       Stops recording → transitions to processing state → shows confirmation box
```

---

## States

### State 1: Starting (0–500ms after orb tap)
```
Popup slides up from bottom
Top row shows: mini orb + "STARTING..." (gray, not lime yet)
Transcript area: "Listening... speak now" (placeholder)
Android SpeechRecognizer initializing
```

### State 2: Listening (active)
```
Top row: lime "LISTENING..." + live waveform
Transcript updates in real time
Context hint appears after ~2 seconds of speaking
```

### State 3: Auto-stopped (1.5s silence detected)
```
Waveform stops
"STOP & PROCESS" button flashes lime for 300ms
Automatically transitions to processing state
No user tap required
```

### State 4: Processing (after stop)
```
Popup STAYS in same position
Content replaces with:
  - Mini orb: spinning processing animation (lime rotation indicator)
  - "Thinking..." text — 15sp, lime, pulsing
  - Transcript fades to secondary (still visible)
Duration: Until Gemini API responds (typically 1–3 seconds)
Timeout:  After 8 seconds → show "Taking longer than expected..."
```

### State 5: Error
```
STT failed:  "Couldn't hear clearly — try again or type"
AI failed:   "Couldn't understand — try rephrasing or type manually"
Offline:     "No connection — saved as draft, AI will process when connected"

Error display: Red #FF3B3B border on popup top, error message in center
Action button: "Try Again" (lime) | "Type Manually" (secondary)
```

### State 6: Text Input Mode (fallback)
```
Waveform area → replaced with text input field:
  Background: #1C1C1C
  Border: 2px solid white
  Font: 15sp white
  Placeholder: "Type what you want to capture..."
  Keyboard: opens automatically
Send button: lime → same AI processing flow
```

---

## Interactions & Animations

| Trigger | Animation |
|---------|-----------|
| Popup appears | Slide up 295dp in 250ms ease-out |
| Popup dismiss | Slide down 295dp in 200ms ease-in |
| Processing begins | Waveform fade out, spinner fade in (200ms cross-fade) |
| Confirmation ready | Popup CONTENT transitions to confirmation box content (morph, not new sheet) |
| Error state | Red border color animate in (200ms) |
| Orb processing pulse | Scale 0.95 → 1.05 loop while waiting |

---

## Offline Behavior

When Gemini API is unavailable (no internet):
1. Recording still works (Android STT is local)
2. Transcript is captured
3. On stop: popup shows "Offline — saved as draft. Will process when connected."
4. Draft is saved to `offline_queue` table with raw transcript
5. Background service processes queue when connectivity returns
6. User gets notification: "AURA processed your offline capture — tap to review"
