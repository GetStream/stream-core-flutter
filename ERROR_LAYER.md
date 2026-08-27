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
  final int statusCode;        // HTTP status — independent of `code`; never derive one from the other
  final int code;              // Stream's stable error code — branch on this, never on message
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
`StreamApiException` (check `isTokenExpired` / `isTokenInvalid`). `StreamAuthenticationException` is
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
| `StreamApiException` | the server said no; `message`/`code`/`moreInfo` say why | show `message`; branch on `code` for special cases |
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

- **Operations** return `Result<T>`; a `Failure` always holds a `StreamException` — enforced by the
  type system (`Failure.error` is typed `StreamException`), not by convention. Nothing is thrown.
- **Connection lifecycle** failures arrive as state: `connectionState` emits
  `Disconnected(source)`, where `source` says who ended the connection and carries the error when
  there was one:

```dart
client.connectionState.listen((state) {
  if (state case Disconnected(:final source)) {
    switch (source) {
      case UserInitiated():            break;               // you called disconnect()
      case ServerRefused(:final error): _onError(error);    // StreamApiException — server said no
      case ConnectionLost(:final error): _showReconnecting(); // StreamNetworkException — SDK retries
      case AuthenticationFailed(:final error): _reLogin();  // StreamAuthenticationException
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
      case StreamApiException(:final message):     showError(message);
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
disposed client, passing another user's token — throws Dart's own `StateError`/`ArgumentError`.
Those mean *fix your code*, not *handle at runtime*, and they never appear inside a `Result`.

## For SDK developers: you rarely construct one

Only **boundaries** create `StreamException`s. Everything above a boundary propagates `Result`s that
already carry the right type — if you are not writing a boundary, you never pick an exception.

| Boundary | Produces |
|---|---|
| HTTP error mapper (the only file that reads Dio) | `StreamApiException` from a server error body or bare status; `StreamNetworkException` from timeout / cancel / socket errors |
| Response/event decoding | `StreamClientException` when wire data will not decode, whatever the decoder threw (see the seam rule below) |
| WebSocket engine + auth handler | `StreamNetworkException` for transport failures; `StreamAuthenticationException` when credentials couldn't be sent; server error events become `StreamApiException` — the inner error object is the same as REST, but it arrives in two envelopes (`{"type":"connection.error",...}` from the monolith, bare `{"error":{...}}` from the edge) and the decoder must accept both |
| `TokenManager` | `StreamAuthenticationException` when the `TokenProvider` fails (its error preserved as `cause`), when no user is configured, or when a reset raced the load |
| `runSafely` (the normalization seam) | passes an existing `StreamException` through untouched; wraps any other `Exception` (an app callback no boundary owns) into `StreamClientException`, preserving `cause`. Does **not** catch `Error` — bugs propagate and crash loudly |

There are two kinds of seams, and they treat `Error` differently:

- **Propagation seams** (`runSafely`, everything that moves `Result`s around) never catch `Error` —
  a `StateError` or `TypeError` there is a bug in the program, and it should crash loudly.
- **Interpretation seams** (decoding a response body, decoding a WS event) catch **everything**,
  `Error` included, and wrap it into `StreamClientException`. A `TypeError` thrown while decoding
  wire data indicts the data, not the program — a server that renamed a field must surface as a
  handleable failure, not a crash.

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
   or a `code`. Context (like "which attachment failed") travels in the data channel
   (`(attachmentId, Result)`), never by wrapping one category inside another. When a whole batch
   fails before any item starts, every item reports the same failure — per-item results are the
   contract, and a pre-flight failure is every item failing the same way.

Product SDKs (Chat, Video, Feeds) may extend a category — `StreamChatApiException extends
StreamApiException` — but never add a fifth top-level kind and never re-map a core exception into an
unrelated type.

## Retrying

The exception carries **facts** (`statusCode`, `code`, `unrecoverable`, `retryAfter`, `isTimeout`,
`closeCode`); whether to retry is **policy** the caller owns. Honor `unrecoverable` first — it is
the server saying retrying will not help — then apply your own rules:

```dart
abstract interface class RetryPolicy {
  bool shouldRetry(StreamException error, int attempt);
}
```

Core ships `RetryPolicy.standard()` — honors `unrecoverable`, waits `retryAfter` on rate limits,
exponential backoff with jitter on network failures — so most callers configure, not implement.

One honesty rule about retrying writes: a `StreamNetworkException` means the outcome is **unknown**
— the server may have performed the operation. Retry a write only through an idempotent path
(product SDKs use client-generated ids for this: re-sending a message with the same id cannot
duplicate it).
