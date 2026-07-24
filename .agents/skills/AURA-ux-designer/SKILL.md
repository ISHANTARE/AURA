---
name: AURA-ux-designer
description: >
  UX and design system specialist for AURA. Use this skill when: designing screens, creating user flows,
  defining the design system, reviewing UI decisions, planning navigation, designing the voice capture
  experience, designing the workspace UI, designing calendar views, planning onboarding,
  or when the user says "design the X screen", "how should X look", "what should the flow be for X",
  "design the onboarding", "what color should X be", "design the design system", or "review this UI".
  This skill covers Phase 3 UX Design work.
---

# AURA UX Designer

You are designing the user experience for AURA — a premium, voice-first, AI-native life OS.
AURA must feel like it costs $20/month from day one. Premium feel is non-negotiable (Principle 7).

## Design Philosophy

- **Voice is primary.** Every screen should be reachable in one tap from the floating button.
- **Dark mode is default.** Light mode is available but dark is the identity.
- **No emojis. Ever. (ADR-012)** — Not in UI, empty states, onboarding, notifications, or labels. Use Lucide Icons exclusively.
- **One icon set: Lucide Icons.** `lucide_icons` Flutter package. 2px stroke, geometric, consistent. Never mix with Material Icons or any other set.
- **Workspaces are colorful.** Each workspace has a distinct color that bleeds into the UI.
- **AI is visible but not in the way.** AI features are prominent but never blocking.
- **Animations are purposeful.** Every animation communicates state, not just decoration.
- **Simplicity wins.** If a feature needs a tutorial, redesign it.

## Design System

### Color Palette

**Base (Dark Mode)**
```
Background:    #0A0A0F   (near-black with blue tint)
Surface:       #131320   (card background)
Surface 2:     #1C1C2E   (elevated elements)
Border:        #2A2A40   (subtle borders)
```

**Accent / Brand**
```
Primary:       #6C63FF   (purple — AURA's identity color)
Primary Light: #8B85FF
Primary Dark:  #4D45CC
Glow:          #6C63FF33 (purple with 20% opacity for glow effects)
```

**Semantic Colors**
```
Success:       #22C55E
Warning:       #F59E0B
Error:         #EF4444
Info:          #3B82F6
```

**Workspace Default Colors**
```
College:       #6C63FF   (purple)
IIT Prep:      #F59E0B   (amber)
Internship:    #22C55E   (green)
Personal:      #3B82F6   (blue)
Health:        #EF4444   (red)
```

**Text**
```
Primary:       #FFFFFF
Secondary:     #94A3B8
Tertiary:      #475569
```

### Typography (Google Fonts: Plus Jakarta Sans)

```
Display:    32sp, Bold, letter-spacing -0.5
Headline:   24sp, SemiBold, letter-spacing -0.3
Title:      18sp, SemiBold
Body:       15sp, Regular
Caption:    13sp, Regular, Secondary color
Label:      12sp, Medium, letter-spacing 0.5 (ALL CAPS for labels)
```

### Spacing System (8px base grid)
```
xs: 4px
sm: 8px
md: 16px
lg: 24px
xl: 32px
2xl: 48px
3xl: 64px
```

### Corner Radius
```
Card:         16px
Chip/Badge:   20px (pill)
Button:       12px
FAB:          28px (floating action)
Modal:        24px (top corners only)
```

### Shadows / Glow Effects
```
Card shadow: 0 4px 24px rgba(0,0,0,0.4)
Glow (active): 0 0 20px rgba(108,99,255,0.3)
Purple glow on active workspace: box-shadow with workspace color
```

## Core Screens

### 1. Home Screen
- Top: Greeting + date + workspace filter chips (horizontal scroll)
- Middle: Today's timeline (tasks + events chronological)
- Floating: Capture button (bottom center, pulsing glow animation)
- Quick stats: tasks due today, overdue count
- Workspace-colored hero section matching active filter

### 2. Voice Capture Screen (Overlay / Full Screen)
- Dark overlay on top of any screen
- Large animated waveform while listening
- Live transcript text below waveform
- Cancel button top-left
- Stop/Send button bottom-center
- Workspace context shown (AI's current guess)

### 3. Confirmation Card (Post-Voice)
- Slide up from bottom (modal sheet, 80% height)
- Shows parsed fields: Task Name, Deadline, Workspace, Reminders, Priority
- Each field is editable inline (tap to edit)
- Confidence indicator for AI-uncertain fields (subtle amber dot)
- Primary CTA: "Save to AURA" (purple, full width)
- Secondary: "Start Over" (text button)
- Haptic on confirm

### 4. Task Detail Screen
- Full screen with workspace color header
- Task name (large, editable)
- Deadline countdown chip (days remaining, color-coded: green/amber/red)
- Reminder timeline (visual list of upcoming reminders)
- Notes tab, Subtasks tab, Files tab
- AI activity log (what AURA understood and did)
- Edit/Delete in top-right menu

### 5. Workspace Screen
- Card grid of workspaces
- Each card: emoji, name, task count, color gradient background
- Long-press to reorder
- Tap to filter timeline/tasks by workspace
- "+" card to create new workspace

### 6. Calendar View (Tabbed)
Tabs: Daily | Weekly | Monthly | Kanban | Priority | Deadline
- Each view shows same data differently
- Workspace color indicators on every task chip
- Swipe left/right to navigate dates

### 7. Morning Briefing Screen
- Appears automatically on first unlock (or tap from notification)
- Full screen, immersive
- Personalized greeting
- Critical deadlines highlighted
- Recommended task order
- Dismiss → goes to Home

### 8. Settings Screen
- Profile / Display name
- Workspace management
- Notification preferences
- AI preferences (confidence threshold, auto-workspace)
- Cloud sync settings (Google Calendar, off by default)
- Privacy: what data is sent to AI, view AI log
- Theme: Dark / Light / System

## Navigation Structure

```
BottomNavigationBar (4 tabs):
  Home (timeline)
  Calendar (all views)
  Workspaces
  Settings

FloatingCaptureButton: Always visible, above bottom nav

Modal Sheets: Voice capture, confirmation card, quick-add
Full Screen: Task detail, morning briefing, onboarding
```

## Animation Guidelines

| Interaction | Animation |
|-------------|-----------|
| Screen transition | Shared element hero + slide from right (200ms) |
| FAB tap | Ripple + scale up (150ms) |
| Voice capture active | Waveform pulsing, FAB pulses with glow |
| Card appear | Fade + slide up (300ms, stagger 50ms between cards) |
| Workspace switch | Color transition (400ms) across accent elements |
| Task complete | Checkbox bounce + slide-fade out (250ms) |
| Confirmation card | Slide up from bottom (spring physics) |
| Confirmation approve | Cards collapse + success tick (300ms) |

## Component Specifications

### TaskCard
```
Height: 72dp min
Layout:
  Left: Workspace color indicator bar (4dp wide, full height)
  Content:
    Row 1: Task name (Title style), Priority badge (right)
    Row 2: Deadline chip (countdown), Workspace chip
  Right: Checkbox
```

### WorkspaceChip
```
Height: 28dp
Padding: 8dp horizontal
Background: Workspace color at 20% opacity
Border: Workspace color at 40% opacity
Text: Workspace name, Caption style, workspace color
```

### DeadlineCountdown
```
Green:  > 3 days
Amber:  1-3 days
Red:    < 24 hours
Dark Red + pulse: Overdue
```

## UX Writing Tone

- Clear, direct, friendly — not robotic
- Use "Save" not "Submit". Use "Got it" not "Okay". Use "Start over" not "Cancel".
- AI messages: conversational ("I understood: ML assignment due Aug 3rd. Does that look right?")
- Error messages: empathetic ("Couldn't connect to AI right now. I'll process this when you're back online.")
- Empty states: encouraging ("No tasks yet. Tap the button and tell me what's on your mind.")

## Accessibility Requirements

- Minimum contrast ratio: 4.5:1 for body text, 3:1 for large text
- Minimum tap targets: 48x48dp
- All interactive elements have semantic labels for screen readers
- Support system font size scaling
- Haptic alternatives for every audio cue
