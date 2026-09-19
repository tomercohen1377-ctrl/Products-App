---
paths:
  - "packages/network/**"
  - "packages/auth/**"
---

# Networking and auth invariants

These are deliberate behaviours; changing one means updating its tests and the README.

- **Two Dio instances.** The main one has the auth interceptor; a bare one (no interceptors) is used only for `POST /auth/refresh-token`, so refresh can never recurse.
- **Single-flight refresh.** Concurrent 401s share one in-flight refresh `Future`; the original request is retried **once** (`extra['retried']`), never in a loop.
- **Logout policy.** Log the user out only on a definitive refresh rejection (4xx from the refresh endpoint). A transient network failure during refresh surfaces the original error and keeps the session.
- **Opt-out of auth.** Login and refresh requests set `extra['auth'] = false` and never carry a Bearer header.
- **Retry policy.** `RetryInterceptor` retries idempotent GETs on timeouts/connection errors with capped exponential backoff. POST/PUT/DELETE are never retried automatically.
- **Error mapping.** `DioException` never escapes `network`/repositories; it becomes a typed `Failure`.
- **Secrets.** Tokens live only in `TokenStorage` (secure storage). Logs redact `Authorization` and passwords. Never log token values.
- **Dev tools.** "Expire access token" and "Kill session" exist to demonstrate refresh and are enabled only when `kDebugMode` or `--dart-define=DEV_TOOLS=true`.
- **API quirks.** Refresh request body key is `refreshToken`; token responses use `access_token` / `refresh_token`. `/products` has no total count (end of list = page shorter than `limit`). `categoryId` must come from `GET /categories`.
