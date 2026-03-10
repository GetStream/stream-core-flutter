import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme.dart';
import '../../theme/components/stream_message_metadata_theme.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_theme_extensions.dart';

/// The bottom metadata row of a chat message bubble.
///
/// Displays a [timestamp], and optional [status] icon, [username], and
/// [edited] indicator in a horizontal row with themed styling.
///
/// All content is provided by the caller via widget slots. The provided
/// widgets are automatically styled according to
/// [StreamMessageMetadataThemeData].
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
///  * [StreamMessageMetadataThemeData], for customizing metadata appearance.
///  * [StreamMessageMetadataTheme], for overriding theme in a widget subtree.
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
    double? spacing,
    double? minHeight,
  }) : props = .new(
         timestamp: timestamp,
         status: status,
         username: username,
         edited: edited,
         spacing: spacing,
         minHeight: minHeight,
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
    this.spacing,
    this.minHeight,
  });

  /// The timestamp widget, typically a [Text] displaying the message time.
  ///
  /// Styled by [StreamMessageMetadataThemeData.timestampTextStyle] and
  /// [StreamMessageMetadataThemeData.timestampColor].
  final Widget timestamp;

  /// An optional status icon widget indicating delivery state.
  ///
  /// Typically an [Icon] such as a clock (sending), single checkmark (sent),
  /// or double checkmark (delivered/read).
  ///
  /// Styled by [StreamMessageMetadataThemeData.statusColor] and
  /// [StreamMessageMetadataThemeData.statusIconSize].
  final Widget? status;

  /// An optional username widget displaying the sender name.
  ///
  /// Styled by [StreamMessageMetadataThemeData.usernameTextStyle] and
  /// [StreamMessageMetadataThemeData.usernameColor].
  final Widget? username;

  /// An optional edited indicator widget.
  ///
  /// Styled by [StreamMessageMetadataThemeData.editedTextStyle] and
  /// [StreamMessageMetadataThemeData.editedColor].
  final Widget? edited;

  /// The gap between main elements (username, timestamp group, edited).
  ///
  /// When null, falls back to [StreamMessageMetadataThemeData.spacing].
  final double? spacing;

  /// The minimum height of the metadata row.
  ///
  /// When null, falls back to [StreamMessageMetadataThemeData.minHeight].
  final double? minHeight;
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
    final theme = context.streamMessageMetadataTheme;
    final defaults = _StreamMessageMetadataThemeDefaults(context);

    final effectiveUsernameTextStyle = theme.usernameTextStyle ?? defaults.usernameTextStyle;
    final effectiveUsernameColor = theme.usernameColor ?? defaults.usernameColor;
    final effectiveTimestampTextStyle = theme.timestampTextStyle ?? defaults.timestampTextStyle;
    final effectiveTimestampColor = theme.timestampColor ?? defaults.timestampColor;
    final effectiveEditedTextStyle = theme.editedTextStyle ?? defaults.editedTextStyle;
    final effectiveEditedColor = theme.editedColor ?? defaults.editedColor;
    final effectiveStatusColor = theme.statusColor ?? defaults.statusColor;
    final effectiveStatusIconSize = theme.statusIconSize ?? defaults.statusIconSize;
    final effectiveSpacing = props.spacing ?? theme.spacing ?? defaults.spacing;
    final effectiveStatusSpacing = theme.statusSpacing ?? defaults.statusSpacing;
    final effectiveMinHeight = props.minHeight ?? theme.minHeight ?? defaults.minHeight;

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

class _StreamMessageMetadataThemeDefaults extends StreamMessageMetadataThemeData {
  _StreamMessageMetadataThemeDefaults(this._context);

  final BuildContext _context;

  late final StreamColorScheme _colorScheme = _context.streamColorScheme;
  late final StreamTextTheme _textTheme = _context.streamTextTheme;
  late final StreamSpacing _spacing = _context.streamSpacing;

  @override
  TextStyle get usernameTextStyle => _textTheme.metadataEmphasis;

  @override
  Color get usernameColor => _colorScheme.textSecondary;

  @override
  TextStyle get timestampTextStyle => _textTheme.metadataDefault;

  @override
  Color get timestampColor => _colorScheme.textTertiary;

  @override
  TextStyle get editedTextStyle => _textTheme.metadataDefault;

  @override
  Color get editedColor => _colorScheme.textTertiary;

  @override
  Color get statusColor => _colorScheme.textTertiary;

  @override
  double get statusIconSize => 16;

  @override
  double get spacing => _spacing.xs;

  @override
  double get statusSpacing => _spacing.xxs;

  @override
  double get minHeight => 24;
}
