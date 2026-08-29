# Phase 1: Project Scaffolding & Dependencies

> **Authority Document:** [`overhaul-docs/01-tech-stack.md`](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/01-tech-stack.md)  
> **Status:** Pending Execution  

---

## Phase Overview

Phase 1 establishes the clean project foundation, ensuring the exact Dart SDK constraints, Android namespace (`com.aura.aura`), strict linter configuration, and all 19 production and 4 dev dependencies are properly configured without version conflicts.

---

## Sprint Breakdown

### Sprint 1.1: Project Initialization & Namespace Configuration
**Objective:** Bootstrap clean Flutter project with target Android package structure and Java 11 setup.

#### Tasks:
- [ ] **Task 1.1.1: Flutter Project Creation**
  - Initialize project with organization `com.aura` and application name `aura`.
  - Verify package identifier `com.aura.aura` across `android/app/build.gradle.kts` and `AndroidManifest.xml`.
- [ ] **Task 1.1.2: Gradle & SDK Constraints**
  - Set `minSdkVersion = 26` (Android 8.0 Oreo minimum for overlay window & exact alarms).
  - Set `targetSdkVersion` and `compileSdkVersion` to API 34/35.
  - Configure `JavaVersion.VERSION_11` for JVM target and enable `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")`.
  - Set NDK Version `27.0.12077973` for SQLite native compilation via `sqlite3_flutter_libs`.

#### Deliverables:
- `pubspec.yaml` baseline
- `android/app/build.gradle.kts`
- `android/app/src/main/AndroidManifest.xml`

---

### Sprint 1.2: Exact Dependency Specification & Resolution
**Objective:** Lock in all verified production and developer dependencies.

#### Tasks:
- [ ] **Task 1.2.1: Production Dependencies Configuration**
  ```yaml
  dependencies:
    flutter:
      sdk: flutter
    # State Management & Routing
    flutter_riverpod: ^2.5.1
    go_router: ^14.2.0
    # Database & Storage
    drift: ^2.18.0
    sqlite3_flutter_libs: ^0.5.24
    path_provider: ^2.1.3
    path: ^1.9.0
    # Environment & Security
    flutter_dotenv: ^5.2.1
    flutter_secure_storage: ^9.2.2
    # Networking & AI
    http: ^1.2.1
    connectivity_plus: ^6.0.3
    url_launcher: ^6.3.0
    # Notifications & Timezones
    flutter_local_notifications: ^17.2.2
    timezone: ^0.9.2
    flutter_timezone: ^3.0.1
    # Permissions & Hardware
    permission_handler: ^11.3.1
    # ML & OCR
    google_mlkit_text_recognition: ^0.13.0
    # Design & Typography
    google_fonts: ^6.2.1
    lucide_icons: ^0.257.0
    # Utilities
    uuid: ^4.4.0
    shared_preferences: ^2.2.3
    intl: ^0.19.0
    share_plus: ^10.1.4
  ```
- [ ] **Task 1.2.2: Dev Dependencies Configuration**
  ```yaml
  dev_dependencies:
    flutter_test:
      sdk: flutter
    build_runner: ^2.4.11
    drift_dev: ^2.18.0
    flutter_lints: ^4.0.0
  ```
- [ ] **Task 1.2.3: Dependency Resolution & Lock**
  - Run `flutter pub get` and verify zero dependency resolution errors or downgrade warnings.

---

### Sprint 1.3: Static Analysis, Assets Directory & Environment Setup
**Objective:** Configure strict lint rules, asset directories, and environment templates.

#### Tasks:
- [ ] **Task 1.3.1: Analysis Options Configuration**
  - Create `analysis_options.yaml` including `package:flutter_lints/flutter.yaml`.
  - Enable strict rules: `always_declare_return_types`, `avoid_print`, `prefer_const_constructors`, `prefer_final_locals`, `unawaited_futures`.
- [ ] **Task 1.3.2: Environment Template & Gitignore**
  - Create `.env.example` defining `LLM_API_KEY`, `LLM_BASE_URL`, `LLM_MODEL`, `APP_ENV`.
  - Update `.gitignore` ensuring `.env`, `.flutter-plugins`, generated `*.g.dart`, build artifacts, and SQLite DB files are ignored.
- [ ] **Task 1.3.3: Asset Directory Structure**
  - Create `assets/sounds/` for custom alarm/reminder ringtones.
  - Create `assets/icons/` for app icons and overlay drawables.
  - Register assets in `pubspec.yaml`.

---

## Phase 1 Acceptance Criteria & Verification

1. `flutter pub get` completes with exit code `0`.
2. `flutter analyze` runs without errors.
3. `android/app/build.gradle.kts` targets SDK 34/35 with min SDK 26 and Java 11.
