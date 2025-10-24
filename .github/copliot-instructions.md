# IronDex Flutter Copilot Instructions

This document outlines the architecture, data flow, and coding standards for the IronDex Flutter project. Adhere to these guidelines to maintain code consistency and quality.

## 1. Product & Technology Stack

### 1.1. Product Snapshot
A Flutter app for discovering gym machines, tracking workout routines, and managing reviews.

### 1.2. Technology Stack
* **Frontend**: Flutter
* **Backend**: Supabase (handles Auth, Database, Storage)
* **State Management**: `provider` (pragmatic, feature-driven, not Bloc/Riverpod)
* **Data Layer**: Repository pattern encapsulating Supabase calls.

---

## 2. Core Architecture & State Management

### 2.1. Entry Point & Provider Registration
* The app's entry point is `lib/main.dart`.
* This file initializes `MultiProvider` to register all global services (e.g., `AuthProvider`, `ReviewRepository`) and feature providers (e.g., `MachineFavoriteProvider`).
* New global providers **MUST** be registered here.

### 2.2. Provider Dependency Management
* The codebase uses `ProxyProvider` and an `updateDependencies` method to manage services that depend on `AuthProvider` (or other providers).
* **RULE**: When creating a new provider that depends on `AuthProvider`, do not pass it in the constructor. Instead, expose an `updateDependencies` method and call it from the `ProxyProvider`'s `update` callback.

### 2.3. State & Error Handling
* **State Propagation**: Use `ChangeNotifier` to push state updates from providers to the UI.
* **UI Feedback**: User-facing failures (network errors, auth failures) **MUST** be surfaced using a `SnackBar`.
* **Error Handling (IMPROVED)**: **DO NOT** `throw` generic `StateError`s.
    * **MUST**: Define and throw custom exceptions (e.g., `lib/exceptions/auth_exceptions.dart`) for specific failure modes.
    * **Example**: `MachineFavoriteProvider` **MUST** `throw const NotLoggedInException();` instead of a `StateError`.
    * The UI layer **MUST** `catch (e is NotLoggedInException)` and show the relevant `SnackBar` message.

---

## 3. Data Layer & Supabase

### 3.1. Repository Pattern (The Golden Rule)
* **DO NOT** call Supabase directly from widgets or providers.
* **MUST**: All Supabase queries (DB and Storage) **MUST** be encapsulated within a Repository (e.g., `services/review_repository.dart`, `services/planner_repository.dart`).
* This centralizes data logic and makes UI components reusable and testable.

### 3.2. Type Safety (IMPROVED)
* **DO NOT** pass raw `Map<String, dynamic>` payloads from Repositories to the UI.
* **MUST**: Define strongly-typed data models for all Supabase tables (e.g., `MachineReview`, `PlannerWorkout`) in the `lib/models/` directory.
* Repositories **MUST** use `fromJson` factories on these models to parse the Supabase response and **MUST** return typed objects (e.g., `Future<List<MachineReview>>`).
* UI components **MUST** consume these models, not `Map`s. This enables compile-time safety and easier refactoring.

### 3.3. Supabase Schema & Scripts
* The database is organized into schemas: `catalog` (machines, brands), `reviews` (user reviews, likes), and `planner` (user workouts).
* Backend data seeding scripts are located in `scripts/data_setup/`. Use the Python scripts to refresh catalog data.

---

## 4. Core Feature Implementation

### 4.1. Authentication (Auth)
* `AuthProvider` wraps Supabase OAuth (Google, Kakao, Naver) and email/password flows.
* The mobile redirect URI is `ai.smartfitness.irondex://login-callback`.
* Providers that depend on the user's login state consume `AuthProvider`.

### 4.2. Catalog, Reviews & Likes
* **Filtering**: `CatalogProvider` manages brand/body-part selections. `ReviewsScreen` consumes this provider.
* **Search**: Search text is debounced within `ReviewsScreen` before being passed to the repository.
* **Infinite Lists**: `MachineList` uses a `ScrollController` to page results (10 at a time). New infinite lists **MUST** follow the `_maybeLoadMore` guard pattern to prevent duplicate fetches.
* **Favorites & Likes**: `MachineFavoriteProvider` and `ReviewLikeProvider` cache a `Set<String>` of IDs. This cache is lazily refreshed after login. UI toggles optimistically update the provider state and then call the repository.

### 4.3. Planner
* **Data Models**: `models/planner_routine.dart` defines the draft objects.
* **Data Sync (IMPERATIVE RULE)**: The `PlannerRepository` saves routines using a **full-replace strategy**.
    * To save a workout, the service **MUST** delete all existing `workout_items` and `workout_item_sets` for that workout and then re-insert all new items from the draft.
    * This ensures `item_order` and `set_order` are always correct and avoids complex diffing logic.
    * Any new edit/save functionality **MUST** follow this full-replace pattern.

---

## 5. Development Standards & Rules

### 5.1. UI, Widgets & Assets
* **Organization**: Widgets are organized by feature under `lib/widgets/`.
* **Imports**: Prefer importing the feature's barrel file (e.g., `lib/widgets/reviews/reviews.dart`) for consistency.
* **Assets**: Icons are in `assets/icon`, logos in `assets/logo`.
* **Navigation**: `MainScreen` is the 4-tab scaffold. Each screen maintains its own `ProviderScope` for feature-specific state.

### 5.2. Localization (IMPROVED)
* **DO NOT** hardcode user-facing strings (e.g., "로그인 실패", "Retry") in widgets.
* **MUST**: All user-facing text **MUST** be added to the `.arb` files in `lib/l10n/` (e.g., `app_ko.arb`).
* **MUST**: Use the `flutter_localizations` package and access strings via `AppLocalizations.of(context)!.myStringKey`.

### 5.3. Config & Secrets (IMPROVED)
* **Local Development**: Use `flutter_dotenv` and an `.env` file for local Supabase keys.
* **Production/Release**: **DO NOT** bundle the `.env` file in release builds.
* **MUST**: Production secrets (`SUPABASE_URL`, `SUPABASE_API_KEY`) **MUST** be injected at build time using `--dart-define` variables in the CI/CD pipeline (e.g., Vercel).

### 5.4. Linting & Testing
* **Linting**: The codebase uses `flutter_lints` via `analysis_options.yaml`. Follow existing styles (double quotes, trailing commas).
* **Testing**: Run `flutter analyze` and `flutter test` before submitting changes. Widget tests are sparse, so new complex widgets **SHOULD** include a new widget test file.

---

## 6. Checklists

### 6.1. New Feature Checklist
1.  [ ] Register new providers in `lib/main.dart`'s `MultiProvider` list.
2.  [ ] Define data models for Supabase tables in `lib/models/`.
3.  [ ] Add new data-fetching logic inside the relevant Repository (e.g., `services/review_repository.dart`).
4.  [ ] Add all new user-facing strings to `lib/l10n/app_ko.arb`.
5.  [ ] Define custom exceptions (e.g., `NotLoggedInException`) for new error states.
6.  [ ] Handle failures in the UI by catching exceptions and showing a `SnackBar`.
7.  [ ] If state is auth-dependent, follow the `ProxyProvider` and `updateDependencies` pattern.

---

## 7. Instruction & Documentation Policy

### 7.1. Language Policy (For Documents & Code)
* **English First**: All new instructions, documentation, and significant code comments **MUST** be written in English first.
* **Korean Translation**: Immediately after the English version is finalized, a corresponding Korean translated version **MUST** also be provided to ensure clarity for all contributors.

### 7.2. AI Interaction Policy (For Copilot/Gemini)
* **MANDATORY KOREAN RESPONSE**: All responses, answers, and interactions with the developer (user) **MUST** be provided in **Korean**. This is a non-negotiable rule to ensure clear and precise communication.
