import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_message_composer_edit_message_attachment_theme.g.theme.dart';

/// Applies a composer edit-message attachment theme to descendant
/// [StreamMessageComposerEditMessageAttachment] widgets.
///
/// Wrap a subtree with [StreamMessageComposerEditMessageAttachmentTheme] to override the styling
/// of the edit-message preview shown above the composer input. Access the merged theme using
/// [BuildContext.streamMessageComposerEditMessageAttachmentTheme].
///
/// {@tool snippet}
///
/// Override the edit-message indicator color for a specific section:
///
/// ```dart
/// StreamMessageComposerEditMessageAttachmentTheme(
///   data: StreamMessageComposerEditMessageAttachmentThemeData(
///     indicatorColor: Colors.green,
///   ),
///   child: StreamMessageComposer(),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageComposerEditMessageAttachmentThemeData], which describes the theme data.
///  * [StreamMessageComposerEditMessageAttachment], the widget affected by this theme.
class StreamMessageComposerEditMessageAttachmentTheme extends InheritedTheme {
  /// Creates a composer edit-message attachment theme that controls descendant edit previews.
  const StreamMessageComposerEditMessageAttachmentTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The composer edit-message attachment theme data for descendant widgets.
  final StreamMessageComposerEditMessageAttachmentThemeData data;

  /// Returns the [StreamMessageComposerEditMessageAttachmentThemeData] merged from local and
  /// global themes.
  ///
  /// Local values from the nearest [StreamMessageComposerEditMessageAttachmentTheme] ancestor
  /// take precedence over global values from [StreamTheme.of].
  static StreamMessageComposerEditMessageAttachmentThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamMessageComposerEditMessageAttachmentTheme>();
    return StreamTheme.of(context).messageComposerEditMessageAttachmentTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamMessageComposerEditMessageAttachmentTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamMessageComposerEditMessageAttachmentTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamMessageComposerEditMessageAttachment] widgets.
///
/// Descendant widgets obtain their values from
/// [StreamMessageComposerEditMessageAttachmentTheme.of]. All properties are null by default,
/// with fallback values applied by [DefaultStreamMessageComposerEditMessageAttachment] — a
/// brand-tinted background and indicator from the outgoing palette, with neutral text.
///
/// {@tool snippet}
///
/// Customize edit-message attachment styling globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   messageComposerEditMessageAttachmentTheme:
///       StreamMessageComposerEditMessageAttachmentThemeData(
///     indicatorColor: Colors.green,
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageComposerEditMessageAttachmentTheme], for overriding theme in a widget
///    subtree.
///  * [StreamMessageComposerEditMessageAttachment], the widget that uses this theme data.
@themeGen
@immutable
class StreamMessageComposerEditMessageAttachmentThemeData with _$StreamMessageComposerEditMessageAttachmentThemeData {
  /// Creates composer edit-message attachment theme data with optional overrides.
  const StreamMessageComposerEditMessageAttachmentThemeData({
    this.backgroundColor,
    this.indicatorColor,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.padding,
    this.thumbnailShape,
    this.thumbnailSide,
    this.thumbnailSize,
  });

  /// Background fill color of the edit-message preview card.
  ///
  /// If null, defaults to `colorScheme.brand.shade100`.
  final Color? backgroundColor;

  /// Color of the leading indicator bar.
  ///
  /// If null, defaults to `colorScheme.brand.shade400`.
  final Color? indicatorColor;

  /// Text style for the preview title (typically the localized "Edit message" label).
  ///
  /// If null, defaults to [StreamTextTheme.metadataEmphasis] tinted with
  /// [StreamColorScheme.textPrimary].
  final TextStyle? titleTextStyle;

  /// Text style for the preview subtitle (the message body being edited).
  ///
  /// If null, defaults to [StreamTextTheme.metadataDefault] tinted with
  /// [StreamColorScheme.textPrimary].
  final TextStyle? subtitleTextStyle;

  /// Padding around the preview's content row.
  ///
  /// If null, defaults to [StreamSpacing.xs] on all sides.
  final EdgeInsetsGeometry? padding;

  /// Outer shape of the trailing thumbnail.
  ///
  /// Composed with [thumbnailSide] to draw the thumbnail's border. If null,
  /// defaults to a [RoundedSuperellipseBorder] with radius [StreamRadius.md].
  final OutlinedBorder? thumbnailShape;

  /// Border side drawn around the trailing thumbnail.
  ///
  /// Composed onto [thumbnailShape] via [OutlinedBorder.copyWith]. If null,
  /// defaults to [BorderSide.none].
  final BorderSide? thumbnailSide;

  /// Dimensions of the trailing thumbnail.
  ///
  /// If null, defaults to `Size.square(40)`.
  final Size? thumbnailSize;

  /// Linearly interpolate between two [StreamMessageComposerEditMessageAttachmentThemeData]
  /// objects.
  static StreamMessageComposerEditMessageAttachmentThemeData? lerp(
    StreamMessageComposerEditMessageAttachmentThemeData? a,
    StreamMessageComposerEditMessageAttachmentThemeData? b,
    double t,
  ) => _$StreamMessageComposerEditMessageAttachmentThemeData.lerp(a, b, t);
}
