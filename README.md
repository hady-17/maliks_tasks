# maliks_tasks

This repository contains a Flutter application that integrates Supabase for
authentication and a small MVVM-style architecture using `provider` and
`ChangeNotifier` for state management. The app supports role-based task
creation and manager workflows.

## Recent updates (most important first)

- Visual / UI polish
  - Header gradients show under a transparent AppBar; create-task screens
    extend their gradient/background behind the app bar and nav bar.
  - Redesigned `ManagerCreateTask` with a modern gradient background,
    rounded elevated card, animated priority chips, section chips, and
    responsive scrolling to avoid overflow on small windows.

- Filters & Calendar
  - Added a `FilterPopup` widget to filter tasks by status and priority.
  - Integrated `CalendarTimeline` selection with the task provider so
    selecting a date updates the task stream/filter.

- Role and routing
  - Signup maps `supervisor`/`manager` positions to role `'manager'`.
  - Sign-in / root routing checks user role and navigates managers to
    `/manager_home` while members go to the regular home screen.

- Manager features
  - Added `ManagerHomescreen` to view, edit, delete, and toggle tasks
    for a branch.
  - Introduced `ManagerTaskProvider` (ChangeNotifier) with methods to
    watch all tasks, update, delete, and toggle done state.

- Manager Create Task (VM)
  - Added `ManagerCreateTaskVM` (in `lib/viewmodels/manager_create_task_vm.dart`)
    that holds controllers and state for the manager create flow, fetches
    members, and provides a `createTask()` method. The VM sanitizes the
    payload by removing null/empty-string fields before sending to
    Supabase to avoid DB check-constraint failures.

- Lifecycle & dialog fixes
  - Fixed "Looking up a deactivated widget's ancestor is unsafe" by
    using dialog-builder contexts, capturing `ScaffoldMessenger` via
    `maybeOf` before awaiting, and avoiding unsafe `BuildContext`
    lookups across async gaps.

- DB / payload fixes
  - `createTask()` and other insert paths remove empty string values to
    prevent PostgREST check-constraint failures (e.g. `tasks_shift_check`).
```markdown
# maliks_tasks

Lightweight Flutter task management app using Supabase for backend
services (auth + database). The project follows a simple MVVM-style
approach using `provider`/`ChangeNotifier` for state management and has
separate flows for regular users and managers.

This README is a concise, up-to-date guide for getting the project
running locally and where to look for the important pieces of code.

## Key features

- Task creation, edit, delete and status toggle
- Role-aware routing (manager vs member)
- Calendar-based filtering and task search
- Realtime updates using Supabase realtime streams
- Notes on tasks with author metadata

## Requirements

- Flutter 3.0+ (stable) or newer
- Dart SDK matching your Flutter version
- A Supabase project (URL + anon key) with the app's DB schema

## Quick setup

1. Add Supabase credentials to a `.env` file at the project root (used by
   the app at runtime). Example `.env`:

```text
SUPABASE_URL=your-supabase-url
SUPABASE_ANON_KEY=your-anon-key
```

2. Install dependencies:

```powershell
flutter pub get
```

3. Run the app (choose device):

```powershell
# Windows desktop
flutter run -d windows

# Android device / emulator
flutter run -d android

# iOS simulator (macOS only)
flutter run -d ios

# Web
flutter run -d chrome
```

If you use CI or local scripts, expose the `SUPABASE_URL` and
`SUPABASE_ANON_KEY` environment variables to the runner.

## Structure / Where to look

- `lib/main.dart` — app entrypoint, provider registration, and routes
- `lib/view/screens` — UI screens (home, manager flows, orders)
- `lib/view/widgets` — reusable widgets such as the filter popup and
  task card
- `lib/viewmodels` — view models / providers that hold controllers and
  business logic
- `lib/model` — data models used across the app

## Running tests & common developer commands

- Run unit/widget tests:

```powershell
flutter test
```

- Run the analyzer:

```powershell
flutter analyze
```

- Format Dart files:

```powershell
flutter format .
```

## Common issues / notes

- Database constraints: some insert/update endpoints strip empty-string
  values to avoid PostgREST check-constraint failures (e.g. `tasks_shift_check`).
- Dialog lifecycle: dialogs were refactored to avoid using a disposed
  `BuildContext` after async operations — use builder contexts or
  `ScaffoldMessenger.maybeOf` before awaiting.

## Contributing

If you'd like to contribute:

1. Fork the repo and create a feature branch
2. Run `flutter test` and `flutter analyze` locally
3. Open a PR with a clear description and screenshots (if UI changes)

## Need help or want specific changes?

If you want, I can:
- Run a focused analyzer pass and fix a set of warnings
- Update the UI spacing/colors for a specific screen
- Create a short guide for seeding the Supabase DB schema locally

Open [README.md](README.md) with changes you'd like me to apply next,
or tell me which area you want updated and I'll prepare a PR.

``` 

