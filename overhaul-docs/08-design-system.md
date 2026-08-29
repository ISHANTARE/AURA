# Design System — Forensic Token Specification

> **Forensic Rebuild Specification**  
> Complete specification for AURA's neo-brutalist design system: verified color tokens, typography, spacing grid, component primitives, glassmorphism patterns, and animation contracts.

---

## 1. Color Palette (Verified from `lib/core/constants/colors.dart`)

### 1.1 Background Layers (Fixed OLED Dark Theme)

```dart
abstract final class AuraColors {
  // Background Hierarchy
  static const Color bgBase    = Color(0xFF0D0D11);  // OLED Black - deepest background
  static const Color bgCard    = Color(0xFF16161E);  // Card/surface layer
  static const Color bgElevated = Color(0xFF1F1F2C); // Elevated modals/sheets
  static const Color bgSubtle  = Color(0xFF252534);  // Input fields / hover states

  // Borders & Dividers
  static const Color border     = Color(0xFF2A2A3C);  // Standard border
  static const Color borderMuted = Color(0xFF1E1E2C); // Subtle dividers
}
```

### 1.2 Text Colors

```dart
  // Typography Hierarchy
  static const Color textPrimary   = Color(0xFFE8E8F0);  // Main text, headings
  static const Color textSecondary = Color(0xFF9898B0);  // Labels, metadata
  static const Color textMuted     = Color(0xFF585870);  // Timestamps, hints, placeholders
  static const Color textInverse   = Color(0xFF0D0D11);  // Text on light/colored backgrounds
```

### 1.3 Theme Accent Variants (User-Selectable via Settings)

The user selects one of 6 accent identifiers persisted in `SharedPreferences['THEME_ACCENT']`:

| Identifier | Display Name | Primary Hex | Description |
|---|---|---|---|
| `Indigo` | Neon Indigo | `#7B6FF0` | Default accent — AURA's identity color. |
| `Cyan` | Cyber Cyan | `#22D3EE` | Neon cyan-teal variant. |
| `Purple` | Electric Purple | `#C084FC` | Soft violet accent. |
| `Orange` | Sunset Orange | `#FF9966` | Warm sunset gradient. |
| `Rose` | Rose Gold | `#F472B6` | Feminine pink-rose. |
| `Lime` | Acid Lime | `#C8FF00` | Stark high-contrast lime. |

Each theme accent produces a `ThemeData` with `colorScheme.primary = Color(hexValue)`.

### 1.4 Semantic Status Colors

```dart
  static const Color accentGreen  = Color(0xFF34D399);  // Success, completed
  static const Color accentAmber  = Color(0xFFFBBF24);  // Warning, upcoming
  static const Color accentRed    = Color(0xFFF87171);  // Error, overdue, urgent
  static const Color accentLime   = Color(0xFFC8FF00);  // Active / Lime theme
```

### 1.5 Priority Color Mapping

```dart
priority_high   → Color(0xFFFF6B6B)  // Red-coral — urgent and time-critical
priority_medium → Color(0xFFFBBF24)  // Amber — important but flexible
priority_low    → Color(0xFF34D399)  // Green — tracked but non-urgent
```

### 1.6 Light Theme Overrides

```dart
// Light Theme (Only activated when THEME_MODE = 'light')
bgBase     = Color(0xFFF5F5F7)
bgCard     = Color(0xFFFFFFFF)
bgElevated = Color(0xFFE8E8EF)
textPrimary    = Color(0xFF1A1A2E)
textSecondary  = Color(0xFF4A4A6A)
textMuted      = Color(0xFF9898B0)
border         = Color(0xFFE0E0EE)
```

---

## 2. Typography (Verified from `lib/core/constants/typography.dart`)

**Primary Font**: `Inter` — loaded via `google_fonts` package.  
**Monospace Font**: `JetBrains Mono` — used for timestamps, IDs, code sections.

```dart
abstract final class AuraTypography {
  static const display       = TextStyle(fontFamily: 'Inter', fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -0.5);
  static const displayMedium = TextStyle(fontFamily: 'Inter', fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.3);
  static const sectionHeader = TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.2);
  static const cardTitle     = TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.0);
  static const body          = TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w400);
  static const bodySmall     = TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w400);
  static const label         = TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.4);
  static const caption       = TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w400, letterSpacing: 0.2);
  static const mono          = TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13, fontWeight: FontWeight.w400);
  static const orbLabel      = TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2.0);
}
```

---

## 3. Spacing Grid (8-Point Base)

```dart
abstract final class AuraSpacing {
  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 16.0;
  static const double lg  = 24.0;
  static const double xl  = 32.0;
  static const double xxl = 48.0;
}
```

---

## 4. Border Radius Scale

```dart
abstract final class AuraRadius {
  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 24.0;
  static const double full = 999.0; // Pills, orb, circular chips
}
```

---

## 5. Core UI Components

### 5.1 BentoCard (Primary Container)

```dart
BentoCard({
  required Widget child,
  EdgeInsets? padding,        // Default: EdgeInsets.all(AuraSpacing.md)
  Color? backgroundColor,     // Default: AuraColors.bgCard
  Color? borderColor,         // Default: AuraColors.border
  double? borderRadius,       // Default: AuraRadius.lg
  VoidCallback? onTap,
})
```

Visual properties:
- Border: `1px solid AuraColors.border`
- Background: `AuraColors.bgCard`
- Hover/tap state: `InkWell` with splash color `accentColor.withOpacity(0.08)`

### 5.2 Glassmorphism Overlay (Modals, Capture Overlay)

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(AuraRadius.xl),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
    child: Container(
      decoration: BoxDecoration(
        color: AuraColors.bgBase.withOpacity(0.85),
        borderRadius: BorderRadius.circular(AuraRadius.xl),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: ...,
    ),
  ),
)
```

### 5.3 Floating Assistant Orb

- **Size**: 56 × 56 logical pixels.
- **Shape**: Circle with `BoxShape.circle`.
- **States**:
  - Idle: Radial gradient fill `[accentColor, accentColor.darken(20%)]`, micro-pulse animation scaling `[1.0 → 1.08 → 1.0]` every 1200ms.
  - Listening: Expanding ring ripples driven by `audioLevelStream`. Ring radius = `28 + (level * 24)`.
  - Processing: `CircularProgressIndicator` arc, accentColor stroke, 2px width.

### 5.4 Bottom Navigation Bar (`AuraBottomNav`)

Five destinations with verified identifiers:
1. `id="nav_home"` — Home icon (LucideIcons.home)
2. `id="nav_alarms"` — Alarms icon (LucideIcons.alarm)
3. `id="nav_workspaces"` — Workspaces icon (LucideIcons.layoutGrid)
4. `id="nav_notes"` — Notes icon (LucideIcons.fileText)
5. `id="nav_settings"` — Settings icon (LucideIcons.settings)

- Background: `AuraColors.bgBase`
- Selected indicator: Accent-colored pill behind icon
- Unselected: `AuraColors.textMuted`

---

## 6. Animation Contracts

All animations must be gated behind `MediaQuery.of(context).disableAnimations`:

| Animation | Type | Duration | Easing |
|---|---|---|---|
| Route Enter | Fade | 200ms | `Curves.easeOut` |
| Bottom Sheet Slide | Slide Up | 300ms | `Curves.easeInOut` |
| Card Expand | Scale + Fade | 200ms | `Curves.easeOut` |
| Orb Micro-Pulse | Scale Repeat | 1200ms cycle | `Curves.easeInOut` |
| Waveform Bar | Height Lerp | Continuous | Driven by `audioLevelStream` |
| Confirmation Card Appear | Slide Up + Fade | 350ms | `Curves.easeOutCubic` |
| Dot Indicator | Width | 200ms | Linear |
