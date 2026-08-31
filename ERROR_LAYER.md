# Stream Core — Error Layer

How failures are modeled, produced, and handled across every Stream SDK (Chat, Video, Feeds).

## The four exceptions

Every failure a Stream SDK reports is a `StreamException`. There are exactly four kinds, named for
what the caller should do about them:

```
StreamException  (sealed)                     message · cause · stackTrace
├── StreamApiException                        the server answered, and the answer was an error
├── StreamNetworkException                    the server was never heard from — outcome unknown
├── StreamAuthenticationException             credentials could not be produced or sent
└── StreamClientException                     the SDK itself failed
```

```dart
sealed class StreamException implements Exception {
  final String message;        // always present, developer-readable; for user-facing UI,
                               // key your own strings off `code` (see localization note below)
  final Object? cause;         // the error underneath, when this wraps another
  final StackTrace? stackTrace;
}

base class StreamApiException extends StreamException {
  final int statusCode;         // HTTP status — independent of `code`; never derive one from the other
  final StreamErrorCode? code;  // Stream's stable error code — branch on this, never on message.
                                // Null when the verdict never reached Stream (a proxy's bare status)
  final String? moreInfo;      // docs URL; populated on REST errors, empty on WebSocket errors
  final bool unrecoverable;    // when true, the server says retrying will not help — authoritative.
                               // Absence means nothing: only Video sets it deliberately (plus the
                               // shared permission-denied path); most errors never carry it.
  final Duration? retryAfter;  // from the Retry-After header on HTTP 429; absent on WS rate limits

  bool get isTokenExpired;       // code 40 — a fresh token fixes it
  bool get isTokenNotYetValid;   // codes 41, 42 — clock skew (nbf/iat); waiting fixes it, a fresh
                                 // token from the same skewed clock does not
  bool get isTokenSignatureInvalid; // code 43 — configuration problem; no token or wait fixes it
  bool get isApiKeyInvalid;      // code 2 — wrong key, or product not enabled on the app
  bool get isRateLimited;        // statusCode 429
  bool get isRequestTimeout;     // statusCode 408 — ran out of time before a verdict; worth retrying
}

base class StreamNetworkException extends StreamException {
  final bool isCancelled;      // the caller cancelled the request
  final bool isTimeout;
  final int? closeCode;        // WebSocket close code, when the failure was a socket closure
}

base class StreamAuthenticationException extends StreamException {}

base class StreamClientException extends StreamException {}
```

## Which one? Three questions, asked in order

```
Did the Stream server answer with an error?            → StreamApiException
  no ↓
Did credentials fail before anything reached it?       → StreamAuthenticationException
  no ↓
Did the network / socket / timeout eat the request?    → StreamNetworkException
  no ↓
It's our own code's fault                              → StreamClientException
```

One rule resolves the classic overlap: **a server that rejects your token has answered** — that is a
`StreamApiException` (check `isTokenExpired` / `isTokenSignatureInvalid`). `StreamAuthenticationException` is
only for credentials that never went out: the `TokenProvider` threw or returned nothing usable, no
user is configured, or the WebSocket auth message could not be sent. Whatever the provider threw is
preserved in `cause`.

You will rarely see `isTokenExpired` yourself: the SDK refreshes expired tokens automatically — a
REST call refused with code 40 is retried once with a fresh token, and a reconnect passes the
refusal to the authenticator so it can send a fresh one. It surfaces only when refresh cannot help:
your provider is static, or the fresh token was refused too.

## For app developers: catch by what you'd do

| You caught | It means | You typically... |
|---|---|---|
| `StreamApiException` | the server said no; `message`/`code`/`moreInfo` say why | show your own copy keyed off `code`; branch on it for special cases |
| `StreamNetworkException` | the server was never heard from — the outcome is **unknown** | show offline UI, retry on connectivity; ignore if `isCancelled` |
| `StreamAuthenticationException` | your token provider / login setup is broken | send the user through your auth flow again |
| `StreamClientException` | the SDK (or a callback you gave it) hit an unexpected error | report to your crash tracker — not the end user's problem |

`message` always describes the failure, but it is developer-facing English straight from the server
(REST errors even carry an internal controller-name prefix) — never show it verbatim as product UI.
For localized, user-worthy text, key your own strings off `code`. Core owns the code registry as
`StreamErrorCode` — an extension type over `int` with a named constant per known code, shared by
every product because the backend's registry is one shared space; a code the SDK does not know yet
still carries its number. `statusCode` and `code` are independent facts: the backend maps some
codes to more than one status, so never infer one from the other.

Failures arrive on two channels, carrying the same four types:

- **Operations** return `Result<T>`; a `Failure` from an SDK operation always holds a
  `StreamException` — every call runs through the seam that guarantees it (`runApiSafely`, below).
  Nothing is thrown.
- **Connection lifecycle** failures arrive as state: `connectionState` emits
  `Disconnected(source)`, where `source` says who ended the connection and carries the error when
  there was one:

```dart
client.connectionState.listen((state) {
  if (state case Disconnected(:final source)) {
    switch (source) {
      case UserInitiated():               break;                   // you called disconnect()
      case AuthenticationFailed():        _reLogin();              // credentials could not be produced or sent
      case ServerInitiated(:final error): _onServerClosed(error);  // the server ended it; the error (if any) says why
      case _:                             _showReconnecting();     // transport trouble — the SDK retries
    }
  }
});
```

```dart
final result = await client.sendMessage(...);
switch (result) {
  case Success(:final data):
    render(data);
  case Failure(:final error):
    switch (error) {
      case StreamApiException(isRateLimited: true): scheduleRetry();
      case StreamApiException(:final code?):       showError(copyFor(code));
      case StreamApiException():                   showError(genericFailureCopy); // no Stream code: a proxy's bare status
      case StreamNetworkException(isCancelled: true): break; // user navigated away
      case StreamNetworkException():               showOfflineBanner();
      case StreamAuthenticationException():        redirectToLogin();
      case StreamClientException():                reportToCrashTracker(error);
    }
}
```

The root is `sealed`, so a `switch` that misses a category does not compile. If you don't want to
branch, `error.message` is always displayable and `on StreamException` always catches everything
Stream.

**Bugs are not in this hierarchy.** Misusing the SDK — calling `send()` before `connect()`, using a
disposed client — throws Dart's own `StateError`/`ArgumentError`.
Those mean *fix your code*, not *handle at runtime*, and they never appear inside a `Result`.

The naming follows the same line, and it is a signal to the catcher: a `…Exception` is a condition
that catching is the right response to; the `Error` suffix is reserved for Dart's bug hierarchy and
for non-throwable data models (`StreamApiError` is the server's wire payload, not a throwable).

## For SDK developers: you rarely construct one

Only **boundaries** create `StreamException`s. Everything above a boundary propagates `Result`s that
already carry the right type — if you are not writing a boundary, you never pick an exception.

| Boundary | Produces |
|---|---|
| HTTP error mapper (the only file that reads Dio) | `StreamApiException` from a server error body or bare status; `StreamNetworkException` from timeout / cancel / socket errors |
| Response/event decoding | `StreamClientException` when wire data will not decode, whatever the decoder threw (see the seam rule below) |
| WebSocket engine + auth handler | `StreamNetworkException` for transport failures; `StreamAuthenticationException` when credentials couldn't be sent; server error events become `StreamApiException` — the inner error object is the same as REST, but it arrives in two envelopes (`{"type":"connection.error",...}` from the monolith, bare `{"error":{...}}` from the edge) and the decoder must accept both |
| `TokenManager` | `StreamAuthenticationException` when no user is configured, when a reset raced the load, or when the `TokenProvider` fails with something unclassified (preserved as `cause`); a provider failure that is already a `StreamException` passes through as itself, so a transient network failure stays retriable |
| `runApiSafely` (the API call seam) | passes an existing `StreamException` through untouched; maps Dio failures to `StreamApiException`/`StreamNetworkException`; wraps anything else — `Exception` or `Error` alike — into `StreamClientException`, preserving `cause` |

Both capture helpers catch **everything**, `Error` included — they differ in what they hand back:

- **`runSafely`** (the generic capture) stores whatever was thrown in the `Failure` untouched — raw
  truth, classified by the boundary above it via `StreamException.tryFrom` plus a kind-specific
  fallback.
- **`runApiSafely`** (the API boundary) delivers only `StreamException`s. A `TypeError` thrown while
  decoding wire data indicts the data, not the program — a server that renamed a field must surface
  as a handleable failure, not a crash — so it arrives as a `StreamClientException` with the
  original `Error` as `cause`. A `StateError` from a bug under the seam arrives the same way; it is
  still a bug, so treat that `StreamClientException` as a crash report, not a condition to handle.

The errors-vs-exceptions rule governs the throw site, not the catch site: SDK guards still throw
`StateError`/`ArgumentError` for misuse. A guard above any seam crashes loudly; one that fires under
a seam surfaces as the `cause` of a `StreamClientException`.

A decode failure on a **live event stream** is the one failure with no operation to fail and no
reason to kill a healthy connection: drop the event, log it through the SDK logger, and count it —
never disconnect. This diagnostics path is the only place a failure is deliberately not delivered.

Two wire facts every WS implementer must know: the server sends the error **text frame first, then
the close frame** — drain pending frames before reacting to a close, or the reason is lost. And the
close code carries almost no signal: auth, token, and permission rejections all close with **1000**
(normal closure); only 1011 (5xx), 1013 (rate limited — reconnect with backoff, no `Retry-After`
exists on WS) and 1012 (server restart) mean anything. Classify from the drained error event's
`code`, never from the close code alone.

The two rules you actually need:

1. **Misuse throws `Error`, conditions become `StreamException`.** Ask: "can this happen to a
   correct program at runtime?" No → `StateError`/`ArgumentError`, never wrapped. Yes → the
   three-question tree above says which exception.
2. **A new exception type needs a new reaction to justify it.** If the catcher of your proposed type
   would do the same thing they'd do for an existing category, it is not a new type — it is a field
   or a `code`. Context (like "which item of a batch failed") travels in the data channel, beside
   the outcome, never by wrapping one category inside another.

Product SDKs (Chat, Video, Feeds) may extend a category — `StreamChatApiException extends
StreamApiException` — but never add a fifth top-level kind and never re-map a core exception into an
unrelated type.

## Retrying

The exception carries **facts** (`statusCode`, `code`, `unrecoverable`, `retryAfter`, `isTimeout`,
`closeCode`); whether to retry is **policy** the caller owns. Retryability is a function of three
inputs — what happened (the exception), what the caller was doing (idempotent or not), and how many
attempts have been spent — which is why no `isRetryable` lives on the exception: it only knows the
first input.

The decision runs in order:

1. **Honor the server's explicit verdicts.** `unrecoverable: true` → never retry. `retryAfter` →
   retry, but only after that wait.
2. **Decide by kind and facts.** Retry what is about *the moment*; never what is about *the request
   or the setup*:

   | Failure | Retry? |
   |---|---|
   | `StreamNetworkException(isCancelled: true)` | No — the caller stopped it. |
   | `StreamNetworkException` otherwise | Yes for reads; writes only through an idempotent path. Prefer a connectivity signal over blind backoff. |
   | `StreamApiException(isRateLimited: true)` | Yes, after `retryAfter` (backoff when absent). |
   | `StreamApiException`, 5xx | Yes, with backoff. |
   | `StreamApiException(isTokenExpired: true)` | No — the SDK already refreshed and retried once; seeing it means refresh could not help. |
   | `StreamApiException(isTokenNotYetValid: true)` | Yes, after waiting — clock skew heals, bounded. |
   | `StreamApiException`, 408 (code 48) | Yes, with backoff — a server-side processing timeout, not a verdict on the request. |
   | `StreamApiException`, any other 4xx | No — the same request gets the same verdict. (A channel cooldown, code 60, does clear on its own, but its wait is not machine-readable — surface it rather than auto-retry.) |
   | `StreamAuthenticationException` | No — fix credentials first, then re-attempt the operation. |
   | `StreamClientException` | No — a bug does not heal on resend; report it. |

3. **Apply the budget**: max attempts, exponential backoff with jitter, a delay cap.

`DisconnectionSource.isReconnectable` is this procedure specialized for the connection (reconnecting
is inherently idempotent), and the interceptor's one-shot token refresh is the code-40 row. What
remains for callers is operation retry: steps 1–2 answer *whether* from the error alone (necessary,
but not sufficient, since the error cannot know the operation's idempotency), *when* comes from
`retryAfter` where the server named a wait and from the caller's backoff otherwise, and the budget
is the caller's. Product SDKs compose this into their retry queues.

One honesty rule about retrying writes: a `StreamNetworkException` means the outcome is **unknown**
— the server may have performed the operation. Retry a write only through an idempotent path
(product SDKs use client-generated ids for this: re-sending a message with the same id cannot
duplicate it).
