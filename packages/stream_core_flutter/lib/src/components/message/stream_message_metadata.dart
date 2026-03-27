import 'package:flutter/material.dart';

import '../../theme.dart';
import '../message_layout/stream_message_layout.dart';

/// The bottom metadata row of a chat message bubble.
///
/// Displays a [timestamp], and optional [status] icon, [username], and
/// [edited] indicator in a horizontal row with themed styling.
///
/// All content is provided by the caller via widget slots. The provided
/// widgets are automatically styled according to
/// [StreamMessageMetadataStyle].
///
/// {@tool snippet}
///
/// Incoming message (no delivery status):
///
/// ```dart
/// StreamMessageMetadata(
///   timestamp: Text('09:41'),
///   username: Text('Alice'),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Outgoing message with delivery status and edited indicator:
///
/// ```dart
/// StreamMessageMetadata(
///   timestamp: Text('09:41'),
///   status: Icon(StreamIcons.doupleCheckmark1Small),
///   edited: Text('Edited'),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageMetadataStyle], for customizing metadata appearance.
///  * [StreamMessageItemTheme], for theming via the widget tree.
class StreamMessageMetadata extends StatelessWidget {
  /// Creates a message metadata row.
  ///
  /// The [timestamp] is required; all other slots are optional and omitted
  /// from the row when null.
  StreamMessageMetadata({
    super.key,
    required Widget timestamp,
    Widget? status,
    Widget? username,
    Widget? edited,
    StreamMessageMetadataStyle? style,
  }) : props = .new(
         timestamp: timestamp,
         status: status,
         username: username,
         edited: edited,
         style: style,
       );

  /// The properties that configure this metadata row.
  final StreamMessageMetadataProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).messageMetadata;
    if (builder != null) return builder(context, props);
    return DefaultStreamMessageMetadata(props: props);
  }
}

/// Properties for configuring a [StreamMessageMetadata].
///
/// See also:
///
///  * [StreamMessageMetadata], which uses these properties.
class StreamMessageMetadataProps {
  /// Creates properties for a message metadata row.
  const StreamMessageMetadataProps({
    required this.timestamp,
    this.status,
    this.username,
    this.edited,
    this.style,
  });

  /// The timestamp widget, typically a [Text] displaying the message time.
  ///
  /// Styled by [StreamMessageMetadataStyle.timestampTextStyle] and
  /// [StreamMessageMetadataStyle.timestampColor].
  final Widget timestamp;

  /// An optional status icon widget indicating delivery state.
  ///
  /// Typically an [Icon] such as a clock (sending), single checkmark (sent),
  /// or double checkmark (delivered/read).
  ///
  /// Styled by [StreamMessageMetadataStyle.statusColor] and
  /// [StreamMessageMetadataStyle.statusIconSize].
  final Widget? status;

  /// An optional username widget displaying the sender name.
  ///
  /// Styled by [StreamMessageMetadataStyle.usernameTextStyle] and
  /// [StreamMessageMetadataStyle.usernameColor].
  final Widget? username;

  /// An optional edited indicator widget.
  ///
  /// Styled by [StreamMessageMetadataStyle.editedTextStyle] and
  /// [StreamMessageMetadataStyle.editedColor].
  final Widget? edited;

  /// Optional style overrides for placement-aware styling.
  ///
  /// Fields left null fall back to the inherited [StreamMessageItemTheme],
  /// then to built-in defaults.
  final StreamMessageMetadataStyle? style;
}

/// The default implementation of [StreamMessageMetadata].
///
/// See also:
///
///  * [StreamMessageMetadata], the public API widget.
///  * [StreamMessageMetadataProps], which configures this widget.
class DefaultStreamMessageMetadata extends StatelessWidget {
  /// Creates a default message metadata row with the given [props].
  const DefaultStreamMessageMetadata({super.key, required this.props});

  /// The properties that configure this metadata row.
  final StreamMessageMetadataProps props;

  @override
  Widget build(BuildContext context) {
    final layout = StreamMessageLayout.of(context);
    final themeStyle = StreamMessageItemTheme.of(context).metadata;
    final defaults = _StreamMessageMetadataDefaults(context);

    final resolve = StreamMessageLayoutResolver(layout, [props.style, themeStyle, defaults]);

    final effectiveUsernameTextStyle = resolve((s) => s?.usernameTextStyle);
    final effectiveUsernameColor = resolve((s) => s?.usernameColor);
    final effectiveTimestampTextStyle = resolve((s) => s?.timestampTextStyle);
    final effectiveTimestampColor = resolve((s) => s?.timestampColor);
    final effectiveEditedTextStyle = resolve((s) => s?.editedTextStyle);
    final effectiveEditedColor = resolve((s) => s?.editedColor);
    final effectiveStatusColor = resolve((s) => s?.statusColor);
    final effectiveStatusIconSize = resolve((s) => s?.statusIconSize);
    final effectiveSpacing = resolve((s) => s?.spacing);
    final effectiveStatusSpacing = resolve((s) => s?.statusSpacing);
    final effectiveMinHeight = resolve((s) => s?.minHeight);

    Widget? usernameWidget;
    if (props.username case final username?) {
      usernameWidget = Flexible(
        child: AnimatedDefaultTextStyle(
          style: effectiveUsernameTextStyle.copyWith(color: effectiveUsernameColor),
          duration: kThemeChangeDuration,
          child: username,
        ),
      );
    }

    final timestampWidget = AnimatedDefaultTextStyle(
      style: effectiveTimestampTextStyle.copyWith(color: effectiveTimestampColor),
      duration: kThemeChangeDuration,
      child: props.timestamp,
    );

    Widget? statusWidget;
    if (props.status case final status?) {
      statusWidget = IconTheme.merge(
        data: IconThemeData(
          color: effectiveStatusColor,
          size: effectiveStatusIconSize,
        ),
        child: status,
      );
    }

    final statusTimestampWidget = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: effectiveStatusSpacing,
      children: [?statusWidget, timestampWidget],
    );

    Widget? editedWidget;
    if (props.edited case final edited?) {
      editedWidget = AnimatedDefaultTextStyle(
        style: effectiveEditedTextStyle.copyWith(color: effectiveEditedColor),
        duration: kThemeChangeDuration,
        child: edited,
      );
    }

    return ConstrainedBox(
      constraints: .new(minHeight: effectiveMinHeight),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: effectiveSpacing,
        children: [?usernameWidget, statusTimestampWidget, ?editedWidget],
      ),
    );
  }
}

class _StreamMessageMetadataDefaults extends StreamMessageMetadataStyle {
  _StreamMessageMetadataDefaults(this._context);

  final BuildContext _context;

  late final StreamColorScheme _colorScheme = _context.streamColorScheme;
  late final StreamTextTheme _textTheme = _context.streamTextTheme;
  late final StreamSpacing _spacing = _context.streamSpacing;

  @override
  StreamMessageLayoutProperty<TextStyle> get usernameTextStyle => .all(_textTheme.metadataEmphasis);

  @override
  StreamMessageLayoutProperty<Color> get usernameColor => .all(_colorScheme.textSecondary);

  @override
  StreamMessageLayoutProperty<TextStyle> get timestampTextStyle => .all(_textTheme.metadataDefault);

  @override
  StreamMessageLayoutProperty<Color> get timestampColor => .all(_colorScheme.textTertiary);

  @override
  StreamMessageLayoutProperty<TextStyle> get editedTextStyle => .all(_textTheme.metadataDefault);

  @override
  StreamMessageLayoutProperty<Color> get editedColor => .all(_colorScheme.textTertiary);

  @override
  StreamMessageLayoutProperty<Color> get statusColor => .all(_colorScheme.textTertiary);

  @override
  StreamMessageLayoutProperty<double> get statusIconSize => .all(16);

  @override
  StreamMessageLayoutProperty<double> get spacing => .all(_spacing.xs);

  @override
  StreamMessageLayoutProperty<double> get statusSpacing => .all(_spacing.xxs);

  @override
  StreamMessageLayoutProperty<double> get minHeight => .all(24);
}
