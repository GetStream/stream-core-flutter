import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_message_composer_file_attachment_theme.g.theme.dart';

/// Applies a composer file attachment theme to descendant
/// [StreamMessageComposerFileAttachment] widgets.
///
/// Wrap a subtree with [StreamMessageComposerFileAttachmentTheme] to override
/// the typography and spacing of file attachments rendered inside the
/// composer. Access the merged theme using
/// [BuildContext.streamMessageComposerFileAttachmentTheme].
///
/// {@tool snippet}
///
/// Override the file attachment title style for a specific section:
///
/// ```dart
/// StreamMessageComposerFileAttachmentTheme(
///   data: StreamMessageComposerFileAttachmentThemeData(
///     titleTextStyle: TextStyle(fontWeight: FontWeight.w700),
///   ),
///   child: StreamMessageComposer(),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageComposerFileAttachmentThemeData], which describes the
///    theme data.
///  * [StreamMessageComposerFileAttachment], the widget affected by this theme.
class StreamMessageComposerFileAttachmentTheme extends InheritedTheme {
  /// Creates a composer file attachment theme that controls descendant file
  /// attachments.
  const StreamMessageComposerFileAttachmentTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The composer file attachment theme data for descendant widgets.
  final StreamMessageComposerFileAttachmentThemeData data;

  /// Returns the [StreamMessageComposerFileAttachmentThemeData] merged from
  /// local and global themes.
  ///
  /// Local values from the nearest [StreamMessageComposerFileAttachmentTheme]
  /// ancestor take precedence over global values from [StreamTheme.of].
  static StreamMessageComposerFileAttachmentThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamMessageComposerFileAttachmentTheme>();
    return StreamTheme.of(context).messageComposerFileAttachmentTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamMessageComposerFileAttachmentTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamMessageComposerFileAttachmentTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamMessageComposerFileAttachment] widgets.
///
/// Descendant widgets obtain their values from
/// [StreamMessageComposerFileAttachmentTheme.of]. All properties are null by
/// default, with fallback values applied by
/// [DefaultStreamMessageComposerFileAttachment].
///
/// {@tool snippet}
///
/// Customize file attachment typography globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   messageComposerFileAttachmentTheme:
///       StreamMessageComposerFileAttachmentThemeData(
///     titleTextStyle: TextStyle(fontWeight: FontWeight.w700),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageComposerFileAttachmentTheme], for overriding theme in a
///    widget subtree.
///  * [StreamMessageComposerFileAttachment], the widget that uses this theme data.
@themeGen
@immutable
class StreamMessageComposerFileAttachmentThemeData with _$StreamMessageComposerFileAttachmentThemeData {
  /// Creates composer file attachment theme data with optional overrides.
  const StreamMessageComposerFileAttachmentThemeData({
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.padding,
    this.spacing,
  });

  /// Text style for the file attachment title.
  ///
  /// If null, defaults to [StreamTextTheme.metadataEmphasis] tinted with
  /// [StreamColorScheme.textPrimary].
  final TextStyle? titleTextStyle;

  /// Text style for the file attachment subtitle.
  ///
  /// If null, defaults to [StreamTextTheme.metadataDefault] tinted with
  /// [StreamColorScheme.textSecondary].
  final TextStyle? subtitleTextStyle;

  /// Padding around the file attachment's content row.
  ///
  /// If null, defaults to a directional inset using [StreamSpacing.md] and
  /// [StreamSpacing.sm] tokens.
  final EdgeInsetsGeometry? padding;

  /// Horizontal space between the file type icon and the title/subtitle
  /// column.
  ///
  /// If null, defaults to [StreamSpacing.sm].
  final double? spacing;

  /// Linearly interpolate between two
  /// [StreamMessageComposerFileAttachmentThemeData] objects.
  static StreamMessageComposerFileAttachmentThemeData? lerp(
    StreamMessageComposerFileAttachmentThemeData? a,
    StreamMessageComposerFileAttachmentThemeData? b,
    double t,
  ) => _$StreamMessageComposerFileAttachmentThemeData.lerp(a, b, t);
}
