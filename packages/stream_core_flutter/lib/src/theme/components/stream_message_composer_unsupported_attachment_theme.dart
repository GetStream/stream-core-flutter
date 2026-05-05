import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_message_composer_unsupported_attachment_theme.g.theme.dart';

/// Applies a composer unsupported-attachment theme to descendant
/// [StreamMessageComposerUnsupportedAttachment] widgets.
///
/// Wrap a subtree with [StreamMessageComposerUnsupportedAttachmentTheme] to override the
/// styling of the placeholder shown for attachments the client cannot render. Access the merged
/// theme using [BuildContext.streamMessageComposerUnsupportedAttachmentTheme].
///
/// {@tool snippet}
///
/// Override the unsupported-attachment label style for a specific section:
///
/// ```dart
/// StreamMessageComposerUnsupportedAttachmentTheme(
///   data: StreamMessageComposerUnsupportedAttachmentThemeData(
///     labelTextStyle: TextStyle(fontStyle: FontStyle.italic),
///   ),
///   child: StreamMessageComposer(),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageComposerUnsupportedAttachmentThemeData], which describes the theme data.
///  * [StreamMessageComposerUnsupportedAttachment], the widget affected by this theme.
class StreamMessageComposerUnsupportedAttachmentTheme extends InheritedTheme {
  /// Creates a composer unsupported-attachment theme that controls descendant placeholders.
  const StreamMessageComposerUnsupportedAttachmentTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The composer unsupported-attachment theme data for descendant widgets.
  final StreamMessageComposerUnsupportedAttachmentThemeData data;

  /// Returns the [StreamMessageComposerUnsupportedAttachmentThemeData] merged from local and
  /// global themes.
  ///
  /// Local values from the nearest [StreamMessageComposerUnsupportedAttachmentTheme] ancestor
  /// take precedence over global values from [StreamTheme.of].
  static StreamMessageComposerUnsupportedAttachmentThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamMessageComposerUnsupportedAttachmentTheme>();
    return StreamTheme.of(context).messageComposerUnsupportedAttachmentTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamMessageComposerUnsupportedAttachmentTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamMessageComposerUnsupportedAttachmentTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamMessageComposerUnsupportedAttachment] widgets.
///
/// Descendant widgets obtain their values from
/// [StreamMessageComposerUnsupportedAttachmentTheme.of]. All properties are null by default,
/// with fallback values applied by [DefaultStreamMessageComposerUnsupportedAttachment].
///
/// {@tool snippet}
///
/// Customize the unsupported-attachment label globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   messageComposerUnsupportedAttachmentTheme:
///       StreamMessageComposerUnsupportedAttachmentThemeData(
///     labelTextStyle: TextStyle(fontStyle: FontStyle.italic),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageComposerUnsupportedAttachmentTheme], for overriding theme in a widget
///    subtree.
///  * [StreamMessageComposerUnsupportedAttachment], the widget that uses this theme data.
@themeGen
@immutable
class StreamMessageComposerUnsupportedAttachmentThemeData with _$StreamMessageComposerUnsupportedAttachmentThemeData {
  /// Creates composer unsupported-attachment theme data with optional overrides.
  const StreamMessageComposerUnsupportedAttachmentThemeData({
    this.labelTextStyle,
    this.padding,
    this.spacing,
  });

  /// Text style for the placeholder label.
  ///
  /// If null, defaults to [StreamTextTheme.metadataEmphasis] tinted with
  /// [StreamColorScheme.textPrimary].
  final TextStyle? labelTextStyle;

  /// Padding around the placeholder's content row.
  ///
  /// If null, defaults to a directional inset using [StreamSpacing.md] and [StreamSpacing.sm]
  /// tokens.
  final EdgeInsetsGeometry? padding;

  /// Horizontal space between the leading icon and the label.
  ///
  /// If null, defaults to [StreamSpacing.xs].
  final double? spacing;

  /// Linearly interpolate between two
  /// [StreamMessageComposerUnsupportedAttachmentThemeData] objects.
  static StreamMessageComposerUnsupportedAttachmentThemeData? lerp(
    StreamMessageComposerUnsupportedAttachmentThemeData? a,
    StreamMessageComposerUnsupportedAttachmentThemeData? b,
    double t,
  ) => _$StreamMessageComposerUnsupportedAttachmentThemeData.lerp(a, b, t);
}
