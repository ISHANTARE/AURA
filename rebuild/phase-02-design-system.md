# Phase 2: Design System & Core Constants

> **Authority Document:** [`overhaul-docs/08-design-system.md`](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/08-design-system.md)  
> **Status:** Complete (Verified)  

---

## Phase Overview

Phase 2 codifies AURA's neo-brutalist OLED visual identity into immutable Dart constants, typography scales, layout dimensions, and Riverpod theme notifiers. Every component across the app builds directly on these tokens.

---

## Sprint Breakdown

### Sprint 2.1: OLED Palette, Semantic Tokens & 6 Accent Variants
**Objective:** Implement `lib/core/constants/colors.dart` with verified hex values.

#### Tasks:
- [x] **Task 2.1.1: Background & Surface Hierarchy**
  ```dart
  static const Color bgBase     = Color(0xFF0D0D11); // OLED Black
  static const Color bgCard     = Color(0xFF16161E); // Surface layer
  static const Color bgElevated = Color(0xFF1F1F2C); // Modals / sheets
  static const Color bgSubtle   = Color(0xFF252534); // Input fields
  static const Color border     = Color(0xFF2A2A3C); // Standard border
  static const Color borderMuted = Color(0xFF1E1E2C); // Subtle dividers
  ```
- [x] **Task 2.1.2: Typography Color Tokens**
  ```dart
  static const Color textPrimary   = Color(0xFFE8E8F0);
  static const Color textSecondary = Color(0xFF9898B0);
  static const Color textMuted     = Color(0xFF585870);
  static const Color textInverse   = Color(0xFF0D0D11);
  ```
- [x] **Task 2.1.3: 6 Selectable Accent Variants**
  - `Indigo`: `#7B6FF0` (Default identity)
  - `Cyan`: `#22D3EE` (Cyber cyan)
  - `Purple`: `#C084FC` (Electric violet)
  - `Orange`: `#FF9966` (Sunset orange)
  - `Rose`: `#F472B6` (Rose gold)
  - `Lime`: `#C8FF00` (Acid lime)
- [x] **Task 2.1.4: Status & Priority Color Tokens**
  - `accentGreen` (`#34D399`), `accentAmber` (`#FBBF24`), `accentRed` (`#F87171`), `accentLime` (`#C8FF00`).
  - Priority maps: High (`#FF6B6B`), Medium (`#FBBF24`), Low (`#34D399`).

---

### Sprint 2.2: Typography Scale, Spacing Grid & Border Radii
**Objective:** Implement `lib/core/constants/typography.dart` and `lib/core/constants/spacing.dart`.

#### Tasks:
- [x] **Task 2.2.1: Inter & JetBrains Mono Typography Scale**
  - Implement `AuraTypography.display` (36pt, w800, -0.5 ls).
  - Implement `AuraTypography.displayMedium` (28pt, w700, -0.3 ls).
  - Implement `AuraTypography.sectionHeader` (22pt, w700, -0.2 ls).
  - Implement `AuraTypography.cardTitle` (16pt, w600).
  - Implement `AuraTypography.body` (14pt, w400) and `bodySmall` (13pt, w400).
  - Implement `AuraTypography.label` (12pt, w500, +0.4 ls) and `caption` (11pt, w400).
  - Implement `AuraTypography.mono` (13pt, JetBrainsMono) and `orbLabel` (18pt, w900, +2.0 ls).
- [x] **Task 2.2.2: Spacing Scale (`AuraSpacing`)**
  - `xs = 4.0`, `sm = 8.0`, `md = 12.0`, `lg = 16.0`, `xl = 20.0`, `xxl = 24.0`, `xxxl = 32.0`.
- [x] **Task 2.2.3: Border Radii Scale (`AuraRadius`)**
  - `sm = 8.0`, `md = 12.0`, `lg = 16.0`, `xl = 24.0`, `pill = 999.0`.

---

### Sprint 2.3: Theme Provider & Persistence Notifiers
**Objective:** Implement `lib/core/theme/theme_provider.dart` with `SharedPreferences` backing.

#### Tasks:
- [x] **Task 2.3.1: ThemeAccentNotifier**
  - Manages active accent color enum (`ThemeAccent.indigo`, etc.).
  - Reads and persists key `THEME_ACCENT` via `shared_preferences`.
- [x] **Task 2.3.2: ThemeModeNotifier**
  - Manages `ThemeMode.dark` (default) and `ThemeMode.light`.
  - Reads and persists key `THEME_MODE`.
- [x] **Task 2.3.3: Dynamic ThemeData Builder**
  - Constructs `ThemeData.dark()` / `ThemeData.light()` with custom `ColorScheme`, `ScaffoldBackgroundColor`, and typography bindings.
- [x] **Task 2.3.4: Theme Unit Tests**
  - Create `test/core/theme_test.dart` verifying all 6 accents resolve to correct hex colors and dark mode is default.

---

## Phase 2 Acceptance Criteria & Verification

1. All color tokens, typography styles, spacing, and radii match `overhaul-docs/08-design-system.md` verbatim.
2. `theme_test.dart` passes with 100% assertions.
3. No hardcoded magic colors or sizes in the core design layer.
