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

- Orders, Search & Realtime improvements
  - Added an `Orders` screen matching the home/tasks layout, with
    `CreateOrder` flow and `OrderProvider` for CRUD + realtime streaming.
  - Status toggle now updates a `done_at` (and `done_by_user` where
    appropriate) and uses in-flight tracking so the UI shows a loading
    indicator while the update is processing.
  - Realtime streams are deduped and the UI avoids double-refreshes by
    comparing last-emitted lists and relying on the stream rather than
    local double-notifies.
  - Filters support `scope` (branch-wide `all` vs `yours`) and role-based
    defaults/disable (members locked to `yours`). `OrderFilter` widget
    added to the codebase.
  - Search improvements:
    - `searchTasks` and `searchOrders` perform server-side ILIKE queries
      (title, description, status, priority) while respecting RLS and
      branch/section scope.
    - The search field was moved above the "Today's" heading in both
      `home.dart` and `orderScreen.dart` and the search toggle was made
      more reliable by switching `_showSearch` to a `ValueNotifier`.


## Key files (where to look)

- `lib/main.dart` — app entrypoint, providers registration, and routes.
- `lib/view/screens/home.dart` — home screen with calendar + task list.
- `lib/view/widgets/filter_popup.dart` — popup filter UI (status + priority).
- `lib/view/screens/manager_homeScreen.dart` — manager dashboard with
  edit/delete dialogs.
- `lib/view/screens/managerCreateTask.dart` — redesigned manager create
  task screen (uses `ManagerCreateTaskVM`).
- `lib/viewmodels/manager_create_task_vm.dart` — manager create task VM.
- `lib/viewmodels/managerProvider.dart` — manager task provider (watch/update/delete).


## How to run

1. Create `.env` in the project root with Supabase keys:

```text
project_url=YOUR_SUPABASE_URL
anon_api_key=YOUR_SUPABASE_ANON_KEY
```

2. Install packages:

```powershell
flutter pub get
```

3. Run the app (example for Windows desktop):

```powershell
flutter run -d windows
```


## Notes about testing and common issues

- If you previously saw a PostgrestException complaining about
  a failing check constraint (e.g. `tasks_shift_check`) that was caused
  by an empty `shift` value — the VM and create-task paths now remove
  empty strings from the payload before inserting.
- If you see "Looking up a deactivated widget's ancestor is unsafe" or
  similar lifecycle errors, they usually come from using `BuildContext`
  after an `await` inside dialogs. The manager screens were refactored to
  use dialog builder contexts and `maybeOf` lookups to fix this.
- The redesigned `ManagerCreateTask` prevents overflow by constraining
  the card height and wrapping content in a scroll view.


## Next steps / suggestions

- Run analyzer and fix remaining warnings/deprecations:

```powershell
flutter analyze
```

- Run and test the manager create task flow and the manager home
  screen. If you see runtime errors or DB insertion failures, paste the
  console output and I will patch quickly.

- Consider adding a typed `UserProfile` model and an `AuthProvider`
  to avoid passing untyped `Map<String,dynamic>` around the app.


If you'd like, I can create a small PR with the remaining analyzer
fixes, or iterate on the UI colors and spacing in `managerCreateTask`.

