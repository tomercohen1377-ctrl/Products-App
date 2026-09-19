# Mylo Products (take-home)

Flutter products app on the Platzi Fake Store API (`https://api.escuelajs.co/api/v1`). Stack: BLoC + Equatable, Dio, go_router, get_it. Flutter 3.47.0 (`.fvmrc`).

## Commands

| Task | Command |
|------|---------|
| Resolve workspace | `flutter pub get` |
| Analyze + test everything | `tool/check.sh` (`--no-test` for analyze only) |
| Run the app | `flutter run` |
| Widget previews | `flutter widget-preview start` |
| Regenerate code (DTOs) | `dart run build_runner build --delete-conflicting-outputs` (inside the package) |
| Regenerate strings (after editing ARB) | `flutter gen-l10n` then `dart format packages/l10n` (inside `packages/l10n`) |
| Live end-to-end (real API + keychain) | `flutter test integration_test/live_auth_test.dart -d <simulator-or-device>` |
| Test user | `john@mail.com` / `changeme` |

## Layout

Pub workspace: `lib/` is the app shell only; everything else is a package under `packages/` (`core`, `network`, `l10n`, `design_system`, `auth`, `products`). Dependency direction is enforced by each package's `pubspec.yaml`; never add a dependency that points the wrong way (see `architecture.md`).

## Rules

Rules in `.claude/rules/` are path-scoped and load automatically:

| File | Loads when |
|------|-----------|
| `architecture.md` | Any file under `packages/**` or `lib/**` |
| `design-system.md` | `packages/design_system/**` or any `presentation/**` |
| `previews.md` | `packages/design_system/**` or any `presentation/**` |
| `networking-and-auth.md` | `packages/network/**` or `packages/auth/**` |

## Working agreements

- Small, reviewable commits: `type(scope): summary` (e.g. `feat(auth): single-flight token refresh`). Every commit analyzes clean and keeps tests green.
- No duplicated code: before writing a helper, widget or fixture, check `core`, `design_system` and the package's `testing.dart`.
- Prefer a maintained library over hand-rolled code. The one deliberate exception is the swipe-deck animation, which must stay hand-built.
