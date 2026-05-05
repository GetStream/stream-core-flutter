import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_message_composer_link_preview_attachment_theme.g.theme.dart';

/// Applies a composer link preview attachment theme to descendant
/// [StreamMessageComposerLinkPreviewAttachment] widgets.
///
/// Wrap a subtree with [StreamMessageComposerLinkPreviewAttachmentTheme] to
/// override the styling of the link preview shown above the composer input.
/// Access the merged theme using
/// [BuildContext.streamMessageComposerLinkPreviewAttachmentTheme].
///
/// {@tool snippet}
///
/// Override the link preview background for a specific section:
///
/// ```dart
/// StreamMessageComposerLinkPreviewAttachmentTheme(
///   data: StreamMessageComposerLinkPreviewAttachmentThemeData(
///     backgroundColor: Colors.amber.shade50,
///   ),
///   child: StreamMessageComposer(),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageComposerLinkPreviewAttachmentThemeData], which describes
///    the theme data.
///  * [StreamMessageComposerLinkPreviewAttachment], the widget affected by this
///    theme.
class StreamMessageComposerLinkPreviewAttachmentTheme extends InheritedTheme {
  /// Creates a composer link preview attachment theme that controls
  /// descendant link previews.
  const StreamMessageComposerLinkPreviewAttachmentTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The composer link preview attachment theme data for descendant widgets.
  final StreamMessageComposerLinkPreviewAttachmentThemeData data;

  /// Returns the [StreamMessageComposerLinkPreviewAttachmentThemeData] merged
  /// from local and global themes.
  ///
  /// Local values from the nearest
  /// [StreamMessageComposerLinkPreviewAttachmentTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  static StreamMessageComposerLinkPreviewAttachmentThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamMessageComposerLinkPreviewAttachmentTheme>();
    return StreamTheme.of(context).messageComposerLinkPreviewAttachmentTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamMessageComposerLinkPreviewAttachmentTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamMessageComposerLinkPreviewAttachmentTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamMessageComposerLinkPreviewAttachment] widgets.
///
/// Descendant widgets obtain their values from
/// [StreamMessageComposerLinkPreviewAttachmentTheme.of]. All properties are
/// null by default, with fallback values applied by
/// [DefaultStreamMessageComposerLinkPreviewAttachment].
///
/// {@tool snippet}
///
/// Customize link preview styling globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   messageComposerLinkPreviewAttachmentTheme:
///       StreamMessageComposerLinkPreviewAttachmentThemeData(
///     backgroundColor: Colors.amber.shade50,
///     titleTextStyle: TextStyle(fontWeight: FontWeight.w700),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageComposerLinkPreviewAttachmentTheme], for overriding theme
///    in a widget subtree.
///  * [StreamMessageComposerLinkPreviewAttachment], the widget that uses this theme
///    data.
@themeGen
@immutable
class StreamMessageComposerLinkPreviewAttachmentThemeData with _$StreamMessageComposerLinkPreviewAttachmentThemeData {
  /// Creates composer link preview attachment theme data with optional
  /// overrides.
  const StreamMessageComposerLinkPreviewAttachmentThemeData({
    this.backgroundColor,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.padding,
    this.thumbnailShape,
    this.thumbnailSide,
    this.thumbnailSize,
  });

  /// Background fill color of the link preview card.
  ///
  /// If null, defaults to `colorScheme.brand.shade100`.
  final Color? backgroundColor;

  /// Text style for the link preview title.
  ///
  /// If null, defaults to [StreamTextTheme.metadataEmphasis] tinted with
  /// `colorScheme.brand.shade900`.
  final TextStyle? titleTextStyle;

  /// Text style for the link preview subtitle and URL.
  ///
  /// If null, defaults to [StreamTextTheme.metadataDefault] tinted with
  /// `colorScheme.brand.shade900`.
  final TextStyle? subtitleTextStyle;

  /// Padding around the link preview's content row.
  ///
  /// If null, defaults to a directional inset using [StreamSpacing.xs] and
  /// [StreamSpacing.sm] tokens.
  final EdgeInsetsGeometry? padding;

  /// Outer shape of the leading thumbnail.
  ///
  /// Composed with [thumbnailSide] to draw the thumbnail's border. If null,
  /// defaults to a [RoundedSuperellipseBorder] with radius [StreamRadius.md].
  final OutlinedBorder? thumbnailShape;

  /// Border side drawn around the leading thumbnail.
  ///
  /// Composed onto [thumbnailShape] via [OutlinedBorder.copyWith]. If null,
  /// defaults to [BorderSide.none].
  final BorderSide? thumbnailSide;

  /// Dimensions of the leading thumbnail.
  ///
  /// If null, defaults to `Size.square(40)`.
  final Size? thumbnailSize;

  /// Linearly interpolate between two
  /// [StreamMessageComposerLinkPreviewAttachmentThemeData] objects.
  static StreamMessageComposerLinkPreviewAttachmentThemeData? lerp(
    StreamMessageComposerLinkPreviewAttachmentThemeData? a,
    StreamMessageComposerLinkPreviewAttachmentThemeData? b,
    double t,
  ) => _$StreamMessageComposerLinkPreviewAttachmentThemeData.lerp(a, b, t);
}
