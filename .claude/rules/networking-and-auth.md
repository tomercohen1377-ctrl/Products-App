---
paths:
  - "packages/network/**"
  - "packages/auth/**"
---

# Networking and auth invariants

These are deliberate behaviours; changing one means updating its tests and the README.

- **`AuthInterceptor` lives in `network`** and talks to `auth` only through `TokenProvider` / `SessionRefresher` (implemented in `auth`).
- **Two Dio instances.** The main one has the auth interceptor; a bare one (no interceptors) is used only for `POST /auth/refresh-token`, so refresh can never recurse.
- **Single-flight refresh.** Concurrent 401s share one in-flight refresh `Future`; the original request is replayed **once** (`extra['retriedAfterRefresh']`), never in a loop. A 401 for a request sent with an already-superseded token is replayed with the current token without refreshing again.
- **Logout policy.** Log the user out only on a definitive refresh rejection (4xx from the refresh endpoint). A transient network failure during refresh surfaces the original error and keeps the session.
- **Opt-out of auth.** Login and refresh requests set `extra['auth'] = false` and never carry a Bearer header.
- **Retry policy.** `RetryInterceptor` retries idempotent GETs on timeouts/connection errors with capped exponential backoff. POST/PUT/DELETE are never retried automatically.
- **Error mapping.** `DioException` never escapes `network`/repositories; it becomes a typed `Failure`.
- **Secrets.** Tokens live only in `TokenStorage` (secure storage). Request logging records method, path and status only, never headers or bodies, so tokens and passwords cannot leak. Never log token values.
- **Dev tools.** "Expire access token" and "Kill session" exist to demonstrate refresh and are enabled only when `kDebugMode` or `--dart-define=DEV_TOOLS=true`.
- **API quirks.** Refresh request body key is `refreshToken`; token responses use `access_token` / `refresh_token`. `/products` has no total count (end of list = page shorter than `limit`). `categoryId` must come from `GET /categories`.
