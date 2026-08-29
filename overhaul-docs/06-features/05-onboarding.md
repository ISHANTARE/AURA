# Feature Specification: First-Run Onboarding & Gate System

> **Forensic Rebuild Specification**  
> Complete specification for AURA's 4-step onboarding carousel, hardware permission requests, starter workspace seeding, and Riverpod route gating.

---

## 1. Onboarding Gate Architecture (`OnboardingGateNotifier`)

To prevent users from landing on an unconfigured, empty dashboard, AURA enforces an onboarding route guard in `app_router.dart`:

```dart
class OnboardingGateNotifier extends StateNotifier<bool> {
  OnboardingGateNotifier() : super(false) {
    _hydrate();
  }

  Future<void> _hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('onboarding_complete') ?? false;
  }

  Future<void> complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    state = true;
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', false);
    state = false;
  }
}
```

### Route Whitelist Exceptions
- `/onboarding` (Wizard)
- `/capture-overlay` (Voice capture overlay can still be triggered externally)
- `/share` (Share target receiver)
- All other routes (`/`, `/alarms`, `/workspaces`, `/notes`, `/settings`, etc.) redirect to `/onboarding` if `state == false`.

---

## 2. Onboarding Carousel Flow (`OnboardingScreen`)

A 4-step interactive carousel driven by `PageController`:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ [● ● ○ ○]                                                           [Skip →]│
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                                ( Glowing Orb )                              │
│                                                                             │
│                                     AURA                                    │
│                         AI-Unified Reality Assistant                        │
│                                                                             │
│                     One tap. You speak. Life organizes.                     │
│                                                                             │
│ ┌─────────────────────────────────────────────────────────────────────────┐ │
│ │ What should AURA call you?                                              │ │
│ │ [ Ishan T                                                             ] │ │
│ └─────────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
│ [                              CONTINUE →                                 ] │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Slide 1: Welcome & Name Input
- **Visuals**: Pulsing AURA Orb, title, tagline.
- **Name Input**: Text field pre-filled or user typed.
- **Validation**: Name must be >= 2 characters and not equal to `"your name"`.
- **Persistence**: Sets `userNameProvider` and persists to `SharedPreferences['USER_NAME']`.

### Slide 2: Hardware Permissions
Interactive permission cards requesting Android OS capabilities with clear user rationales:
1. **Microphone Access**: Required for on-device voice capture and speech recognition (`Permission.microphone.request()`).
2. **Notifications & Alarms**: Required for high-priority reminders and exact wake-up alarms (`NotificationService().requestPermissions()`).
3. **Floating Orb (Draw Over Apps)**: Required to display the floating assistant orb over other Android apps (`OverlayChannel.requestPermission()`).

### Slide 3: Suggested Workspaces Seeding
- Presents selectable workspace chips: `College`, `Academics`, `Personal`, `Work`, `IIT Prep`.
- Pre-selected defaults: `{'College', 'Academics'}`.
- On completion, inserts selected workspaces into SQLite `workspaces` table with UUID v4 IDs and cycled color palette: `['#C8FF00', '#00D4FF', '#FF6B6B', '#A78BFA', '#34D399', '#FBBF24']`.

### Slide 4: Try It Now & Finish
- Explains floating orb touch gestures: Single tap for quick capture, 600ms long-press for quick actions menu.
- **`[ GET STARTED → ]`**:
  - Invokes `onboardingGateProvider.notifier.complete()`.
  - Navigates immediately to `Routes.home`.
