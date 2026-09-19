---
paths:
  - "packages/design_system/**"
  - "packages/**/presentation/**"
---

# Widget previews

Every widget file ships with at least one preview, using Flutter's native `@Preview` (`package:flutter/widget_previews.dart`); run with `flutter widget-preview start`.

- Annotate with the shared `@AppPreviews()` (a `MultiPreview` in `design_system`) so each preview automatically renders light, dark, Hebrew/RTL and 1.5x text. Do not hand-write per-widget wrapper or theme code.
- Preview functions are public, top-level, no-arg, return a `Widget`; keep them at the bottom of the widget's file.
- Preview `XContent` widgets with fixtures from `testing.dart` (loading, loaded, empty, error, loading-more). Never construct a bloc, resolve `GetIt`, or hit the network in a preview.
- Previews run in a web-style sandbox: widget files must not import the data layer, `dart:io` or native-plugin packages. That is also the layering rule, so a failing preview usually means a layer leak.
- Non-visual infrastructure widgets (e.g. `MviView`, which only wires a bloc to a builder) are exempt; anything that paints pixels is not.
- A widget PR without a preview is incomplete.
