/// Convenience barrel that re-exports both [core] and [chat] entry points.
///
/// **Prefer the narrow barrels in new code:**
///
/// - `package:stream_core_flutter/core.dart` — shared UI primitives, theme
///   tokens, and the component factory. Safe to import from any Stream SDK.
/// - `package:stream_core_flutter/chat.dart` — chat-specific widgets such as
///   the message bubble, composer attachments, and reactions.
///
/// Importing this file pulls in chat code regardless of whether the consumer
/// uses it, which is undesirable for non-chat SDKs (video, feeds, ...). Use
/// `core.dart` directly in those cases.
@Deprecated('Use core.dart or chat.dart instead.')
library;

export 'chat.dart';
export 'core.dart';
