---
paths:
  - "packages/**"
  - "lib/**"
---

# Architecture

## Dependency rules (enforced by pubspecs)

```
app            -> auth, products, design_system, network, l10n, core
auth, products -> design_system, network, l10n, core     (features never depend on each other)
design_system  -> core, l10n
network        -> core                                   (knows nothing about auth)
core           -> flutter, bloc, equatable only
```

If a change needs a dependency that points the other way, introduce a small interface in the lower package and implement it in the higher one (e.g. `network` declares `TokenProvider`, `auth` implements it).

## Layers inside a feature package

```
lib/<feature>.dart      public API only (routes, register function, few exports)
lib/src/domain/         entities (Equatable), repository interfaces, use cases
lib/src/data/           DTOs, mappers, remote data sources, repository implementations
lib/src/presentation/   one folder per screen: intent, state, effect, bloc, screen, content, widgets
lib/testing.dart        fixtures shared by previews and tests
```

- `domain` imports nothing from `data` or `presentation`, and no Flutter UI or Dio.
- Use cases exist only where they carry logic (compose calls, apply rules). Do not add one-line pass-through use cases; blocs may call repository interfaces directly.
- DTOs never leave `data`. Mappers convert DTO -> entity, and are where input is sanitised.
- Repositories return `Result<T>` built with `guard()` from `core`. No `try/catch` in blocs or widgets; `switch` exhaustively on `Result`/`Failure`.

## MVI contract (per screen)

- `XIntent` (sealed, Equatable): what the user or system wants.
- `XState` (Equatable, immutable, `copyWith`): the single source of truth for the UI. Derived values are getters on the state, never computed in widgets.
- `XEffect` (sealed, Equatable): one-shot events (navigate, snackbar, dialog) emitted with `emitEffect`. Blocs never touch `BuildContext`, `GoRouter` or `GetIt.I`.
- `XBloc extends MviBloc<XIntent, XState, XEffect>`: handlers registered with `on<T>`; pick a `bloc_concurrency` transformer deliberately (`droppable` for submit and load-more, `restartable` for refresh).
- `XScreen` (container): creates/provides the bloc and handles effects via `MviView`. `XContent` (pure): takes `state` and `onIntent`, no bloc, no DI, no I/O.

## Dependency injection

`get_it`, registered by hand in one `register<Feature>Module(GetIt)` function per package, called from the app's bootstrap. Resolve dependencies only at composition roots (screen containers, router, bootstrap), never inside blocs, repositories or widgets that could take a constructor argument.

## Tests

Every bloc has `bloc_test` coverage (happy path, failure, edge). Repositories and interceptors are tested against fakes (`network/testing.dart`, `*/testing.dart`), not by mocking Dio internals. Pure logic (validators, `SwipeDecider`, mappers) gets table-driven tests.
