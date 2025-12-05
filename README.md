# maliks_tasks

This repository contains a Flutter application scaffolded for a small
project that integrates Supabase authentication and uses a simple
MVVM (Provider + ChangeNotifier) pattern for the auth flows.

## What we implemented (summary)

- Custom native launch splash using `MaliksLogo.png` (assets registered
	and `flutter_native_splash` used to generate platform drawables).
- A welcoming `WelcomeScreen` with a wavy top, centered logo, and an
	action button to cycle images.
- Designed authentication screens:
	- `SignInPage` (red/grey themed) with email/password, "Remember me",
		forgot-password flow and social sign-in placeholders.
	- `LoginPage` (signup) with fields: full name, email, password,
		confirm password, branch dropdown, position dropdown, and shift
		(Day/Night).
- MVVM refactor for auth flows:
	- `lib/viewmodels/sign_in_viewmodel.dart`
	- `lib/viewmodels/login_viewmodel.dart`
	Both are `ChangeNotifier` classes used via `provider` in the views.
- Supabase integration (`supabase_flutter`) for auth and profile
	management. Sign-in and sign-up flows fetch and pass the user's profile
	(as a `Map<String, dynamic>`) to the Home screen after successful
	authentication.
- Root session handling: `RootPage` (registered as `/`) checks the
	current Supabase session at startup and navigates to Home automatically
	when a session and valid profile are available.
- "Remember me" behavior: when a user checks the checkbox while signing
	in, we persist the choice and user id in `shared_preferences`. On app
	startup, `RootPage` respects that flag and only keeps the session if
	the user opted in. Manual logout clears the saved flags.
- Task creation screen with MVVM architecture:
	- Role-based permissions for task assignment
	- Team members: create tasks assigned to themselves (auto-filled)
	- Managers: can assign tasks to any team member and modify branch/section
	- Auto-fills: assignee (creator), assigned-to (default to self), branch ID, assigned section
	- Validates both assignee and assigned-to emails exist in the system

## Key files and where to look

- `lib/main.dart` — app entrypoint, Supabase initialization, `RootPage`
	startup logic.
- `lib/view/screens/welcome_screen.dart` — welcome UI with wave and
	image switcher.
- `lib/view/auth/sign_in.dart` — sign-in screen wired to
	`SignInViewModel`.
- `lib/view/auth/login.dart` — sign-up screen wired to
	`LoginViewModel`.
- `lib/viewmodels/sign_in_viewmodel.dart` and
	`lib/viewmodels/login_viewmodel.dart` — business logic for auth flows.
- `lib/view/screens/home.dart` — Home screen; currently expects the
	profile Map via `Navigator` route arguments and displays basic fields.
- `lib/view/screens/create_task.dart` — Task creation screen with
	role-based field permissions.
- `lib/viewmodels/create_task_viewmodel.dart` — Business logic for task
	creation with email-to-UUID resolution and validation.

## Dependencies added

- `supabase_flutter` — Supabase client for auth and DB access
- `flutter_dotenv` — environment variables for Supabase credentials
- `provider` — MVVM state management
- `shared_preferences` — persist the "remember me" flag locally
- `flutter_native_splash` (config in `pubspec.yaml`) — generate native
	splash images

## How the "Remember me" flow works

1. User checks "Remember me" on the `SignInPage` and signs in.
2. `SignInViewModel.signIn()` stores `remember_me=true` and
	 `remember_user_id=<user id>` to `SharedPreferences` on successful
	 sign-in.
3. On app startup `RootPage` reads the `remember_me` flag; if it's
	 `false` or the remembered id doesn't match the active session, the
	 app signs out the Supabase session and shows the welcome screen.
4. Manual logout clears the stored flags.

## Task Creation Flow

### Field Behaviors

**For All Users:**
- **Assignee (Creator)**: Auto-filled with current user's email, read-only
- **Title**: Required text field
- **Description**: Optional text area
- **Priority**: Dropdown (low/normal/high), defaults to 'normal'
- **Task Date**: Date picker, defaults to today
- **Shift**: Dropdown (day/night/both), auto-filled from user's profile

**For Team Members (role = 'member'):**
- **Assigned To**: Auto-filled with their own email, read-only (can only create tasks for themselves)
- **Branch ID**: Auto-filled from their profile, read-only
- **Assigned Section**: Auto-filled from their profile, read-only

**For Managers (role = 'manager'):**
- **Assigned To**: Editable - can assign tasks to any team member by email
- **Branch ID**: Editable - can change the branch assignment
- **Assigned Section**: Editable - can assign to any section

### Database Mapping
The form creates a task with these fields:
- `created_by`: UUID of assignee (creator)
- `assigned_to`: UUID of assigned-to person (resolved from email)
- `branch_id`: UUID from profile or manager-specified
- `assigned_section`: Section name from profile or manager-specified
- `status`: Always 'pending' for new tasks
- `priority`: 'low', 'normal', or 'high'
- `task_date`: Date in YYYY-MM-DD format
- `shift`: 'day', 'night', or 'both'

## Known issues & next improvements

- The app currently passes profile data as an untyped `Map<String, dynamic>`.
	Consider adding a `UserProfile` model and using it across viewmodels
	and views.
- OAuth sign-in with Google/Apple is currently a placeholder.
- Static analysis reports a few deprecations (e.g. `withOpacity()` →
	`.withValues()`, `Dropdown` `value` deprecation); these are non-blocking
	but should be cleaned up.
- Consider providing a centralized `AuthProvider` to hold the signed-in
	user's profile and reduce passing route arguments.

## How to run & test

1. Create a `.env` file in the project root with your Supabase values:

```text
project_url=YOUR_SUPABASE_URL
anon_api_key=YOUR_SUPABASE_ANON_KEY
```

2. Get packages:

```powershell
flutter pub get
```

3. Run the app on an emulator or device:

```powershell
flutter run
```

4. Testing remember-me:
	- Sign in with "Remember me" checked, close the app, reopen: you
		should be navigated directly to Home.
	- Sign in without "Remember me" checked, close and reopen: you should
		be asked to sign in again.

## Questions or next steps

- Would you like me to fix the deprecations reported by the analyzer
	now, or add a typed `UserProfile` and an `AuthProvider` for global
	user state?

---

If you'd like I can also open a small checklist PR-style set of
follow-ups and implement items incrementally.

