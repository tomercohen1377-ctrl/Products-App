# Mylo Products

A small products app on the [Platzi Fake Store API](https://api.escuelajs.co/api/v1): email/password login with a persisted session and transparent token refresh, a paged product list, detail, create / edit / delete (with optional photo upload), and a **hand-built, physics-driven swipe deck** for browsing.

Flutter 3.47.0 · BLoC/Cubit + Equatable · Dio · go_router · English + Hebrew (RTL).

## Run it

Requirements: Flutter 3.47.0 (`.fvmrc`), Xcode (iOS) or the Android SDK.

```bash
flutter pub get
flutter run                      # pick an iOS simulator or an Android device
```

Test user: **`john@mail.com` / `changeme`** (pre-filled on the login form in debug builds).

Other useful commands:

```bash
tool/check.sh                    # format check + analyze + all package tests (556 tests)
flutter widget-preview start     # every widget in light, dark, Hebrew (RTL) and 1.5x text
flutter test integration_test -d <device>   # end-to-end against the live API and real keychain
```

Android release builds work too (`flutter build apk --release`); the INTERNET permission is declared in the main manifest.

### Developer tools

In debug builds (or any build run with `--dart-define=DEV_TOOLS=true`) a small bug button appears bottom-start once you're signed in. It opens a sheet with:

- **Expire access token**: corrupts the stored access token so the next protected call gets a *real* 401 from the server.
- **Kill session**: corrupts both tokens, so the refresh is rejected as well.
- **Call profile now**: calls `GET /auth/profile` and reports whether a refresh happened.
- **Language**: System / English / עברית, to see the RTL layout without changing the device language.

## Architecture

A Dart pub workspace: the app in `lib/` is only the composition root; everything else is a small package.

```
lib/                app shell: bootstrap (DI), router + session redirect, theming, dev tools
packages/
  core/             Result<T>/Failure, MVI base (MviBloc, MviView), validators, logger, copyWith helper
  network/          Dio clients, interceptors (auth, retry, error mapping, logging), fake HTTP adapter for tests
  l10n/             ARB files (en, he) and generated AppLocalizations
  design_system/    tokens, theme, shared widgets, previews, the SwipeDeck animation
  auth/             login, session persistence, token refresh
  products/         list, detail, form, deck integration
```

Dependencies only point down, and the pubspecs enforce it:

```
app  ->  auth, products, design_system, network, l10n, core
auth, products  ->  design_system, network, l10n, core     (features never depend on each other)
design_system   ->  core, l10n
network         ->  core                                   (it knows nothing about auth)
```

`network` needs a token and a way to refresh it but must not depend on `auth`, so it declares two small interfaces (`TokenProvider`, `SessionRefresher`) that `auth` implements. Features stay independent too: the products screen takes app-bar actions from the app, which is how the account button appears there.

### Inside a feature

```
domain/        entities, repository interfaces, use cases (only where there is logic)
data/          DTOs, mappers, remote sources, repository implementations
presentation/  one folder per screen: intent, state, effect, bloc, screen, content, widgets
```

### MVI on top of BLoC

Every screen has the same five pieces, on a shared `MviBloc`:

- **Intent** (sealed, Equatable): what the user or system wants.
- **State** (one immutable Equatable snapshot): derived values are getters on the state, so widgets compute nothing.
- **Effect** (sealed): one-shot side effects (navigate, snackbar, dialog), emitted on a separate stream so a rebuild never replays them.
- **Bloc**: `on<Intent>` handlers with a deliberate `bloc_concurrency` transformer (`droppable` for submit and load-more, `restartable` for refresh).
- **Screen / Content**: the screen (container) provides the bloc and handles effects; `XContent` is pure (state in, intents out). That split is what makes every widget previewable and testable without a bloc, DI or network.

Blocs never touch `BuildContext`, `GoRouter` or `GetIt`. Repositories return `Result<T>`; there is no `try/catch` in presentation code.

## Auth and networking

**Approach.** Tokens live in the platform keystore (`flutter_secure_storage`) behind `TokenStorage`, fronted by an in-memory `TokenStore` so the interceptor never hits the keystore per request.

- **Protected requests** get `Authorization: Bearer <access>` from `AuthInterceptor`. Login and refresh opt out (`extra['auth'] = false`).
- **A rejected token** (401) is recovered transparently: one **single-flight** refresh (concurrent 401s share one refresh `Future`), then the original request is replayed **once**. A 401 for a request that was sent with an already-superseded token is replayed with the current token without refreshing again.
- **Refresh uses a separate, bare Dio** with no auth interceptor, so it can never recurse.
- **If recovery fails** the outcome depends on why: a definitive rejection (the refresh endpoint answers 4xx) clears the session and logs the user out through one path (`SessionBloc` -> router redirect -> login, with an explanation); a transient failure (offline, timeout, 5xx) surfaces that error and **keeps the session**, so being offline never logs anyone out.
- **On cold start** the stored session is verified with `GET /auth/profile` (which itself exercises the refresh path); offline it stays signed in.
- **Retry**: idempotent GETs only, on timeouts/connection errors/502-504, with capped exponential backoff. POST/PUT/DELETE are never retried automatically.
- **Errors**: every `DioException` becomes a typed `Failure`; a single function maps a `Failure` to localized text.

### Demonstrating and verifying the refresh

The API's tokens don't expire during a short demo, so:

1. Sign in, open the developer tools, tap **Expire access token**, then **Call profile now**. The server really answers 401; the app refreshes and replays; the sheet reports "recovered transparently".
2. Tap **Kill session** then **Call profile now**: the refresh is rejected and you land on the login screen with "Your session has expired."

Automated: `network/test/src/auth_interceptor_test.dart` (single flight, late 401s, no loops, transient vs definitive), `auth/test/src/session_recovery_test.dart` (the whole stack over a scripted transport), `test/app_auth_flow_test.dart` (through the real app), and `integration_test/live_auth_test.dart` (real API + real keychain, on a simulator). I also broke the single-flight and stale-token logic on purpose to confirm the tests fail.

## The animation: a physics swipe deck

`design_system/lib/src/swipe_deck/`, generic over the item type, no package. It is the browse mode of the products screen (toggle List / Deck).

- **Drag**: the top card follows the finger from the touch-down point and tilts around where it was grabbed.
- **Release**: `SwipeDecider` (pure, table-tested) projects where the card is heading (position plus a short look-ahead along its velocity). Heading past the threshold: the card is thrown on a critically damped spring carrying the release velocity. Otherwise it **snaps back on an under-damped spring seeded with that velocity**, so it overshoots the centre and settles.
- **Pile parallax**: the cards behind advance continuously with the drag (scale and offset interpolate toward the slot in front), so the pile reacts to the finger instead of jumping when a card leaves.
- Stamps ("LIKE"/"SKIP") fade in toward each side, haptics tick at the threshold, screen readers get throw-left/right actions, reduced motion skips the animation. Every tunable (springs, threshold, tilt, pile step, visible cards) is in one `SwipeDeckConfig`.

**The one performance decision:** per-frame work is limited to a matrix update. Cards are built once and cached; while one moves, only a `Transform` (driven by a single `ValueNotifier<Offset>`) changes, with no rebuild, layout or repaint of the card content, and each card sits in its own `RepaintBoundary`. A widget test asserts that 30 drag frames cause zero card rebuilds. Product images are also decoded at display size (`cacheWidth`) rather than full resolution.

**Not measured on a device.** I only had a simulator (no profile mode), so I did not measure real frame times, and I'm not claiming 60/120 fps from data. `integration_test/deck_performance_test.dart` + `test_driver/perf_driver.dart` record a frame timeline while the deck is thrown around (`flutter drive --profile -d <device> ...`, see the file); I ran it end to end on the simulator, but those debug-mode numbers mean nothing.

## Key decisions and tradeoffs

- **Six small packages** rather than one, so the dependency rules are compiler-enforced. That's more ceremony than a 5-screen app strictly needs; the payoff is that `network` provably knows nothing about `auth`.
- **Use cases only where there is logic** (`RestoreSession`). Blocs call repository interfaces directly elsewhere; one-line pass-through use cases would be noise.
- **Hand-written `get_it` modules** instead of `injectable` codegen: about 25 registrations across the packages did not justify a generator in each.
- **Native `@Preview`** (Flutter 3.47) instead of Widgetbook: no dependency, no codegen, and one shared `AppPreviews` annotation renders every widget in light, dark, Hebrew (RTL) and 1.5x text. Preview widgets must not import the data layer or `dart:io`, which reinforces the layering.
- **`Image.network` instead of `cached_network_image`**: the package pulled in `path_provider` and `sqflite`, which broke every widget test that rendered a product image, for a marginal disk-cache gain. Trade-off: no persistent image cache across launches.
- **Products paging tracks the server offset separately from the visible list.** A product created here is shown on top but sits at the end of the server's order, so counting it would make the next page skip a real product. Next-page responses made stale by a successful refresh are discarded.
- **Swipe directions are physical** (right = like in every locale) and the deck's buttons keep their left/right order, so the gesture and its buttons always agree. The alternative (mirror in RTL) is a one-line change in the decider.
- **The pre-filled demo login and the developer tools are debug-only**; likes are session-only.

## Testing

556 tests: `core` 39, `network` 44, `auth` 81, `design_system` 116, `products` 237, app 39, plus live integration tests (`integration_test/`, 4 tests) that run the real app on a simulator against the real API and keychain (login, forced-401 refresh, restart persistence, dead session, product create/edit/delete, deck, photo upload). The live tests create a throwaway product and delete it; they read `GET /categories` first because this shared API's data changes.

Beyond the usual cases, several behaviours were **mutation-checked** (I broke the code and confirmed a test failed): single-flight refresh, stale-token replay, stale next-page discard, offset math after deletes, the snap-back bounce, the pile parallax, and the touch-down drag behaviour.

## AI usage

<!-- REVIEW BEFORE SUBMITTING: this section is about your own judgment; edit it so it is true to what you did. -->

_Draft for the author to review._ I used Claude Code (Claude Sonnet 5) to plan and write most of this code and its tests, working from the assignment PDF and my direction: clean architecture and modularization, MVI on BLoC, repositories and a networking layer, a preview for every widget, and no duplicated code. The plan (package layout, native previews, the swipe deck as the animation) was proposed by the AI and approved by me before implementation.

Places the AI's first attempt was wrong, and how it was caught (all fixed):

- A scripted version-pinning step rewrote `sdk: ^3.13.0` to an exact `3.13.0` in two pubspecs (caught in review).
- `cached_network_image` made widget tests that show product images fail (missing plugins); replaced with `Image.network`.
- The dev-tools button sat above the Navigator with no `Overlay`, which would have crashed in debug builds (caught by an app-level test).
- The deck lagged the finger by the touch slop when a card was both draggable and tappable (found by a widget test; fixed with `DragStartBehavior.down`).
- The deck's "put the card back if the parent didn't remove it" safety net used post-frame callbacks without scheduling a frame.
- The main Android manifest had no INTERNET permission (only debug/profile), so a release build could not have reached the API.
- Many first-pass tests passed suspiciously; mutation checks on the critical logic found which of them were actually asserting something.

<!-- TODO(author): add the places where you overrode or rejected the AI's suggestions. -->

## Not finished / with more time

- **Profile-mode measurements on a physical device** for the deck (harness is in place, see above).
- **Likes are session-only**; persisting them (and the dismissed set) would be a small local repository.
- **Offline cache** for the product list, and a persistent image cache.
- **iOS keychain items survive an uninstall**, so a reinstall can restore the previous session; the usual fix is to clear tokens on first launch.
- **Proactive refresh** from the JWT `exp` claim, to avoid the one wasted 401.
- **Shared-element transition** from card/tile to detail (the deck is the hand-built animation; a Hero would be a cheap extra).
- **A screen-reader pass with VoiceOver/TalkBack** on a device (semantics actions and labels are in, but only tested with the Flutter semantics tree).
- **Android end-to-end run**: the app builds (debug and release) but I ran the live tests on an iOS simulator only.
- The Platzi API is shared and resets; its data can be empty or junk (the list handles no products, no categories, dead image URLs and absurd prices, but only what I saw is covered).
