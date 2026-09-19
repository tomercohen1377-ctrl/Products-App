---
paths:
  - "packages/design_system/**"
  - "packages/**/presentation/**"
---

# Design system

Source of truth: `packages/design_system/lib/`.

- Never hardcode colors, spacing, padding, radii, elevations or text styles. Use tokens: `context.dsColors.<semantic>`, `context.dsTypography.<style>(...)`, `DSSpacing`, `DSPadding`, `DSCornerRadius`, `DSDimensions`.
- Text styles come from the theme, so any helper that builds text takes a `BuildContext`.
- Check `packages/design_system/lib/` for an existing widget before creating a new one (`AppButton`, `AppTextField`, `AsyncContent`, `AppNetworkImage`, `PriceLabel`, `ErrorView`, `AppLoader`, `PaginatedList`). Add new shared widgets there, not in a feature.
- Every user-visible string comes from `context.l10n`; no string literals in widgets. Errors map through the single `Failure` -> message function in `design_system`.
- The developer-tools sheet (`lib/app/dev/`) is debug-only and intentionally not localized; nothing else is exempt.
- Layout must work in RTL (English and Hebrew ship): `EdgeInsetsDirectional`, `AlignmentDirectional`, `BorderRadiusDirectional`, `start`/`end` instead of `left`/`right`, and icons that imply direction must mirror.
- Support dark theme and large text: no fixed-height text containers; verify at 1.5x scale.
- Images always go through `AppNetworkImage` (size-aware decode, fade-in, error fallback); the API returns some dead image URLs.
