import 'package:flutter/widgets.dart';

import '../../theme.dart';
import '../common/stream_flex.dart';
import '../message_layout/stream_message_layout.dart';

/// A composite layout container that arranges message primitives into the
/// full message content structure.
///
/// [StreamMessageContent] composes three vertical sections — [header],
/// [child], and [footer] — stacked in a [Column]. It does not render any
/// visual decoration itself; each section is an opaque widget slot that
/// the caller fills with pre-composed primitives.
///
/// The typical composition is:
///
///  * **[header]** — annotation rows (pinned, saved, reminder, etc.)
///  * **[child]** — the message bubble and reply indicator, optionally
///    wrapped with reactions
///  * **[footer]** — metadata (timestamp, delivery status, etc.)
///
/// {@tool snippet}
///
/// Incoming message with annotation, reactions, replies, and metadata:
///
/// ```dart
/// StreamMessageContent(
///   header: StreamMessageAnnotation(
///     leading: Icon(StreamIcons.pin),
///     label: Text('Pinned'),
///   ),
///   footer: StreamMessageMetadata(timestamp: Text('09:41')),
///   child: StreamReactions.clustered(
///     items: [StreamReactionsItem(emoji: Text('😂'))],
///     child: Column(
///       crossAxisAlignment: CrossAxisAlignment.start,
///       children: [
///         StreamMessageBubble(child: Text('Hello, world!')),
///         StreamMessageReplies(label: Text('3 replies')),
///       ],
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Multiple annotations using [StreamMessageAnnotation.list]:
///
/// ```dart
/// StreamMessageContent(
///   header: StreamMessageAnnotation.list(
///     children: [
///       StreamMessageAnnotation(
///         leading: Icon(StreamIcons.pin),
///         label: Text('Pinned'),
///       ),
///       StreamMessageAnnotation(
///         leading: Icon(StreamIcons.bellNotification),
///         label: Text('Reminder set'),
///       ),
///     ],
///   ),
///   child: StreamMessageBubble(child: Text('Hello, world!')),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Minimal message with just a bubble:
///
/// ```dart
/// StreamMessageContent(
///   child: StreamMessageBubble(child: Text('Hey!')),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageBubble], the visual shell of a message.
///  * [StreamMessageAnnotation], for annotation rows.
///  * [StreamMessageReplies], for thread reply indicators.
///  * [StreamMessageMetadata], for timestamp and delivery status.
///  * [StreamReactions], for wrapping content with reaction chips.
class StreamMessageContent extends StatelessWidget {
  /// Creates a message content layout.
  ///
  /// The [child] is required; [header] and [footer] are optional and
  /// omitted from the layout when null.
  StreamMessageContent({
    super.key,
    Widget? header,
    required Widget child,
    Widget? footer,
    double? spacing,
  }) : props = .new(
         header: header,
         child: child,
         footer: footer,
         spacing: spacing,
       );

  /// The properties that configure this content layout.
  final StreamMessageContentProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).messageContent;
    if (builder != null) return builder(context, props);
    return DefaultStreamMessageContent(props: props);
  }
}

/// Properties for configuring a [StreamMessageContent].
///
/// See also:
///
///  * [StreamMessageContent], which uses these properties.
class StreamMessageContentProps {
  /// Creates properties for a message content layout.
  const StreamMessageContentProps({
    this.header,
    required this.child,
    this.footer,
    this.spacing,
  });

  /// Content displayed above the body.
  ///
  /// Typically a [StreamMessageAnnotation] for a single annotation, or
  /// [StreamMessageAnnotation.list] for multiple annotations (e.g. pinned
  /// and reminded, pinned and translated).
  ///
  /// When null, no header is shown.
  final Widget? header;

  /// The body content of the message.
  ///
  /// Typically a [StreamMessageBubble] and [StreamMessageReplies] composed
  /// in a [Column] and optionally wrapped with [StreamReactions].
  final Widget child;

  /// Content displayed below the body.
  ///
  /// Typically a [StreamMessageMetadata] widget showing timestamp and
  /// delivery status.
  ///
  /// When null, no footer is shown.
  final Widget? footer;

  /// The vertical spacing between the header, child, and footer sections.
  ///
  /// If null, defaults to [StreamSpacing.xxs].
  final double? spacing;
}

/// The default implementation of [StreamMessageContent].
///
/// See also:
///
///  * [StreamMessageContent], the public API widget.
///  * [StreamMessageContentProps], which configures this widget.
class DefaultStreamMessageContent extends StatelessWidget {
  /// Creates a default message content layout with the given [props].
  const DefaultStreamMessageContent({super.key, required this.props});

  /// The properties that configure this content layout.
  final StreamMessageContentProps props;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    final effectiveSpacing = props.spacing ?? spacing.xxs;
    final crossAxisAlignment = StreamMessageLayout.crossAxisAlignmentOf(context);

    return SizedBox(
      width: double.infinity,
      child: StreamColumn(
        spacing: effectiveSpacing,
        crossAxisAlignment: crossAxisAlignment,
        children: [?props.header, props.child, ?props.footer],
      ),
    );
  }
}
