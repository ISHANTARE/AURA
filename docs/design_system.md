# AURA — Design System

> **Version:** 1.0
> **Status:** Final (confirmed 2026-07-24)
> **Source of truth for:** all visual implementation decisions in Phase 8

This document is extracted and expanded from PRD F-17. During coding (Phase 8),
reference this file for every color, spacing, font, shadow, and component decision.

---

## Design Language

**Pure Dark Neubrutalism + Bento Grid**

AURA's visual identity is deliberate and opinionated:
- Raw, honest, confident personality
- High contrast, sharp borders, bold typography
- Dense information in scannable bento grid blocks
- Anti-generic — stands out immediately
- Matches AURA's "direct and unfiltered" tone

---

## Color System

### Base Palette (Dark — Default Theme)

| Token | Hex Value | Usage |
|-------|-----------|-------|
| `color-bg-base` | `#0D0D0D` | Main app background |
| `color-bg-card` | `#141414` | Card / bento cell background |
| `color-bg-elevated` | `#1C1C1C` | Modals, overlays, bottom sheets |
| `color-border` | `#FFFFFF` | All card borders — pure white, full opacity |
| `color-border-muted` | `rgba(255,255,255,0.15)` | Subtle dividers, inactive states |
| `color-shadow` | `#FFFFFF` | Neubrutalist box-shadow color |

### Accent Palette

| Token | Hex Value | Usage |
|-------|-----------|-------|
| `color-accent-primary` | `#C8FF00` | Primary CTAs, active states, orb color, AURA brand |
| `color-accent-blue` | `#4DFFFF` | Events, calendar items |
| `color-accent-orange` | `#FF7A29` | Warnings, medium priority |
| `color-accent-red` | `#FF3B3B` | Overdue, high priority, urgent |
| `color-accent-green` | `#39FF88` | Success states, completed tasks |
| `color-accent-purple` | `#B57BFF` | Recurring tasks, habits |

### Text

| Token | Value | Usage |
|-------|-------|-------|
| `color-text-primary` | `#FFFFFF` | Headlines, primary content |
| `color-text-secondary` | `rgba(255,255,255,0.6)` | Subtext, metadata, labels |
| `color-text-disabled` | `rgba(255,255,255,0.3)` | Placeholder, disabled states |
| `color-text-on-accent` | `#000000` | Text on lime (#C8FF00) backgrounds |

---

## Typography

**Typeface:** `Space Grotesk` (Google Fonts)
**Fallback:** `Inter`, `system-ui`

| Role | Size | Weight | Notes |
|------|------|--------|-------|
| Display / Hero | 32–40sp | 800 ExtraBold | Large stats, orb label |
| Section Headers | 20–24sp | 700 Bold | Screen titles, section names |
| Card Titles | 16–18sp | 600 SemiBold | Task names, event titles |
| Body / Metadata | 13–15sp | 400 Regular | Deadlines, descriptions |
| Labels / Tags | 11–12sp | 500 Medium | ALL CAPS — category labels, badges |

```dart
// Flutter TextStyle constants
static const displayStyle = TextStyle(
  fontFamily: 'SpaceGrotesk',
  fontSize: 36,
  fontWeight: FontWeight.w800,
  color: Color(0xFFFFFFFF),
);

static const sectionHeaderStyle = TextStyle(
  fontFamily: 'SpaceGrotesk',
  fontSize: 22,
  fontWeight: FontWeight.w700,
  color: Color(0xFFFFFFFF),
);

static const cardTitleStyle = TextStyle(
  fontFamily: 'SpaceGrotesk',
  fontSize: 17,
  fontWeight: FontWeight.w600,
  color: Color(0xFFFFFFFF),
);

static const bodyStyle = TextStyle(
  fontFamily: 'SpaceGrotesk',
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: Color(0x99FFFFFF),  // 60% white
);

static const labelStyle = TextStyle(
  fontFamily: 'SpaceGrotesk',
  fontSize: 11,
  fontWeight: FontWeight.w500,
  letterSpacing: 1.2,
  color: Color(0x99FFFFFF),
);
```

---

## Spacing System (8dp base grid)

| Token | Value | Usage |
|-------|-------|-------|
| `space-xs` | 4dp | Icon padding, tight gaps |
| `space-sm` | 8dp | Between related elements |
| `space-md` | 16dp | Card internal padding |
| `space-lg` | 24dp | Section gaps |
| `space-xl` | 32dp | Major screen sections |
| `space-2xl` | 48dp | Hero/display spacing |
| `space-3xl` | 64dp | Full-screen spacing |

---

## Neubrutalism Rules (Binding — Do Not Break)

Every card, button, and interactive element must follow ALL of these:

1. **Hard border:** `2px solid #FFFFFF` — no subtle or ghostly borders
2. **Offset shadow:** `4px 4px 0px #FFFFFF` — the neubrutalist hard drop effect
3. **No border-radius:** `0px` on all cards and interactive elements (buttons, inputs, chips)
4. **No blur/glassmorphism:** Neubrutalism is explicitly anti-frosted-glass
5. **Bold text over decorative text:** hierarchy through font weight, not effects
6. **Active/pressed state:** shadow shrinks to `2px 2px 0px` (pushes in effect)
7. **Lime CTAs:** primary confirm button = `bg: #C8FF00`, `text: #000000`, `border: 2px solid #000000`, `shadow: 4px 4px 0px #000000`

```dart
// Flutter BoxDecoration for a standard bento card
BoxDecoration bentoCard = BoxDecoration(
  color: Color(0xFF141414),
  border: Border.all(color: Colors.white, width: 2),
  boxShadow: [
    BoxShadow(
      color: Colors.white,
      offset: Offset(4, 4),
      blurRadius: 0,  // CRITICAL: 0 blur = hard shadow
    ),
  ],
  borderRadius: BorderRadius.zero,  // CRITICAL: no rounding
);
```

---

## The Glow Rule (Binding — Never Override)

| Element | Glow | Spec |
|---------|------|------|
| Cards | ❌ Never | — |
| Text / labels | ❌ Never | — |
| Buttons | ❌ Never | — |
| Priority stripes | ❌ Never | — |
| Background | ❌ Never | — |
| **Floating Orb** | ✅ Only element | `0 0 28px 8px rgba(200,255,0,0.08)` |
| **Mini Orb (in popup)** | ✅ Scaled | `0 0 16px 6px rgba(200,255,0,0.06)` |

> The orb glow is the ONLY atmospheric element in AURA's entire UI.

---

## Component Specifications

### Bento Card

```
Background:   #141414
Border:       2px solid #FFFFFF
Shadow:       4px 4px 0px #FFFFFF
Padding:      16dp
Label:        11sp, ALL CAPS, rgba(255,255,255,0.6), letter-spacing 1.2
Value:        20–24sp, Bold/ExtraBold, #FFFFFF
Border-radius: 0
```

### Task List Item

```
Height:       min 64dp
Left edge:    4dp wide priority color indicator (flush to left edge)
Content:
  Row 1:      Task title — 17sp SemiBold white
              Priority badge — right (HIGH=red, MEDIUM=orange, LOW=gray chip)
  Row 2:      Deadline countdown — 13sp secondary
              Workspace chip — lime or workspace-tinted
Right:        Checkbox — 2px white border, 0 radius
Completed:    opacity 0.5 + strikethrough on title
```

### Primary CTA Button (Confirm / Save)

```
Background:   #C8FF00 (lime)
Text:         #000000, 16sp, Bold
Border:       2px solid #000000
Shadow:       4px 4px 0px #000000
Radius:       0
Pressed:      shadow → 2px 2px 0px #000000
```

### Secondary CTA Button (Cancel / Edit)

```
Background:   transparent
Text:         #FFFFFF, 16sp, SemiBold
Border:       2px solid #FFFFFF
Shadow:       4px 4px 0px rgba(255,255,255,0.3)
Radius:       0
Pressed:      shadow → 2px 2px 0px rgba(255,255,255,0.3)
```

### Section Tab (inside workspace)

```
Selected:
  Background: #C8FF00
  Text:       #000000, Bold
  Border:     2px solid #000000

Unselected:
  Background: transparent
  Text:       rgba(255,255,255,0.6)
  Border:     2px solid rgba(255,255,255,0.15)
```

### Priority Badge / Chip

```
HIGH:   bg rgba(255,59,59,0.2), border 2px solid #FF3B3B, text #FF3B3B
MEDIUM: bg rgba(255,122,41,0.2), border 2px solid #FF7A29, text #FF7A29
LOW:    bg rgba(255,255,255,0.1), border 2px solid rgba(255,255,255,0.3), text rgba(255,255,255,0.6)
```

### Deadline Countdown Chip

```
Green  (>3 days):    border #39FF88, text #39FF88
Amber  (1–3 days):   border #FF7A29, text #FF7A29
Red    (<24 hours):  border #FF3B3B, text #FF3B3B  
Dark Red (overdue):  border #FF3B3B, text #FF3B3B, pulse animation
```

### Floating Orb

```
Shape:        Circle, 56dp diameter
Background:   #C8FF00 solid
Label:        "A", ExtraBold, #000000, 24sp
Border:       3px solid #000000
Shadow:       4px 4px 0px #000000
Glow:         box-shadow: 0 0 28px 8px rgba(200,255,0,0.08) — ONLY glow in system

Listening:    pulse rings expand outward in lime, flat (no glow on rings)
Processing:   circular indicator in lime on black
Success:      brief #39FF88 fill flash (200ms)
```

---

## Motion & Animation

| Interaction | Spec |
|-------------|------|
| Screen / bento load | Cells stagger: slide up 8dp + fade in, 40ms delay each |
| Card tap | Scale to 0.97, shadow shrinks (press feedback), 100ms |
| Task complete | Strike-through animation + #39FF88 flash + haptic medium |
| Confirmation box appear | Slide up from bottom, 300ms ease-out |
| Orb listening | Concentric lime rings expand outward, loop, flat (no glow) |
| Section tab switch | Horizontal content slide, 200ms ease-in-out |
| Modal dismiss | Slide down, 250ms ease-in |
| Success flash | 200ms fill to green → 200ms fade back |

**Flutter animation guidelines:**
- Use `AnimatedContainer` for simple property transitions
- Use `AnimationController` + `CurvedAnimation` for complex sequences
- Curves: `Curves.easeOut` (appear), `Curves.easeIn` (dismiss), `Curves.elasticOut` (pop-in)
- Never use `Future.delayed` as a substitute for proper animation controllers

---

## What to Avoid (Dark Neubrutalism Anti-Patterns)

- ❌ Gradients on backgrounds — flat fills only
- ❌ Rounded corners on cards — 0px strictly
- ❌ Glassmorphism / frosted blur effects
- ❌ Drop shadows that blur — always hard offset (blurRadius: 0)
- ❌ Thin borders — always 2px minimum
- ❌ Generic light sans-serif at regular weight
- ❌ Muted, earthy, or pastel color palettes
- ❌ **Glow on anything except the orb** — most critical rule
- ❌ **Emojis anywhere in the UI** — use Lucide Icons exclusively (ADR-012)

---

## Icon System — Lucide Icons (ADR-012)

**Package:** `lucide_icons` (Flutter pub.dev)
**Why Lucide:** 2px consistent stroke width — the exact visual weight of AURA's neubrutalist borders. Every icon in the set shares the same geometric construction grid. Zero visual inconsistency.

### Icon Usage Rules

1. **No emojis. Ever.** Not in UI, not in empty states, not in onboarding, not in notifications, not in workspace labels.
2. **One icon set only.** Never mix Lucide with Material Icons, Heroicons, or any other set.
3. **Never use filled variants** unless explicitly specified — always use the stroke (outline) variant.
4. **Color follows text color rules:**
   - Primary UI icons: `#FFFFFF`
   - Secondary / inactive icons: `rgba(255,255,255,0.6)`
   - Destructive actions: `#FF3B3B`
   - Success: `#39FF88`
   - Active / selected: `#C8FF00` (lime)
5. **Size is contextual:**

| Context | Size |
|---------|------|
| Inline with body text | 16dp |
| List item icons | 20dp |
| App bar / nav bar | 24dp |
| Empty state illustrations | 32–40dp |
| Large feature icons | 48dp |

### Workspace Icons (canonical mapping)

| Workspace | Lucide Icon | Constant |
|-----------|-------------|----------|
| College / VIT | Graduation cap | `LucideIcons.graduationCap` |
| GATE Prep / IIT | Target / crosshair | `LucideIcons.target` |
| Internship / Work | Briefcase | `LucideIcons.briefcase` |
| Personal | User | `LucideIcons.user` |
| Health | Heart | `LucideIcons.heart` |
| Finance | Credit card | `LucideIcons.creditCard` |
| Projects | Layout grid | `LucideIcons.layoutGrid` |
| Placements | Award | `LucideIcons.award` |
| Research | Flask | `LucideIcons.flask` |
| Custom (user-created) | Folder | `LucideIcons.folder` |

### UI Element Icons (canonical mapping)

| Element | Lucide Icon |
|---------|-------------|
| Task | `LucideIcons.checkSquare` |
| Event / Calendar | `LucideIcons.calendarDays` |
| Reminder / Bell | `LucideIcons.bell` |
| Search | `LucideIcons.search` |
| Settings | `LucideIcons.settings` |
| Add / Create | `LucideIcons.plus` |
| Edit | `LucideIcons.pencil` |
| Delete | `LucideIcons.trash2` |
| Archive | `LucideIcons.archive` |
| Close / Cancel | `LucideIcons.x` |
| Back | `LucideIcons.chevronLeft` |
| Forward / Next | `LucideIcons.chevronRight` |
| More options (⋮) | `LucideIcons.ellipsisVertical` |
| Voice / Mic | `LucideIcons.mic` |
| Attach / Share | `LucideIcons.share2` |
| Link | `LucideIcons.link` |
| Image / Screenshot | `LucideIcons.image` |
| Document | `LucideIcons.fileText` |
| Note | `LucideIcons.stickyNote` |
| Priority HIGH | `LucideIcons.chevronDoubleUp` |
| Priority MEDIUM | `LucideIcons.minus` |
| Priority LOW | `LucideIcons.chevronDown` |
| Recurring | `LucideIcons.refreshCw` |
| Completed / Done | `LucideIcons.circleCheck` |
| Overdue / Urgent | `LucideIcons.triangleAlert` |
| Snooze | `LucideIcons.alarmClock` |
| DND | `LucideIcons.bellOff` |
| Offline | `LucideIcons.wifiOff` |
| AI / Processing | `LucideIcons.sparkles` |
| User / Profile | `LucideIcons.circleUser` |
| Home | `LucideIcons.house` |
| Workspaces | `LucideIcons.layoutDashboard` |
| Subtask | `LucideIcons.cornerDownRight` |
| Move | `LucideIcons.arrowRightLeft` |
| Drag handle | `LucideIcons.gripVertical` |
| Morning briefing | `LucideIcons.sunrise` |
| Section | `LucideIcons.folderOpen` |
| Filter | `LucideIcons.listFilter` |
| Sort | `LucideIcons.arrowUpDown` |
| Export | `LucideIcons.download` |
| Privacy / Lock | `LucideIcons.lock` |
| Source: Voice | `LucideIcons.mic` |
| Source: Text | `LucideIcons.keyboard` |
| Source: Share | `LucideIcons.share` |

### Flutter Usage

```dart
// Import
import 'package:lucide_icons/lucide_icons.dart';

// Standard usage
Icon(
  LucideIcons.checkSquare,
  size: 20,
  color: Colors.white,
)

// Secondary / inactive
Icon(
  LucideIcons.bell,
  size: 20,
  color: Colors.white.withOpacity(0.6),
)

// Active / selected (lime)
Icon(
  LucideIcons.house,
  size: 24,
  color: Color(0xFFC8FF00),
)

// Destructive
Icon(
  LucideIcons.trash2,
  size: 20,
  color: Color(0xFFFF3B3B),
)
```

### Note on Wireframe Documents

All wireframes in `03_UX/wireframes/` use emoji as **semantic placeholders** in ASCII diagrams (e.g., 📋 = task, 📅 = deadline). These are documentation shorthand only. During Phase 8 implementation, replace every emoji placeholder with the corresponding Lucide icon from the table above.

---

*Design System v1.1 — updated 2026-07-24 (ADR-012: Lucide Icons + no emojis)*
*Source: PRD F-17 + design review session + ADR-012*
*Do not modify without updating PRD F-17 and creating an ADR*
