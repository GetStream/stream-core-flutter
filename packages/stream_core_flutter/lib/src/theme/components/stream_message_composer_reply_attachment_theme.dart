import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_message_composer_reply_attachment_theme.g.theme.dart';

/// Applies a composer reply attachment theme to descendant
/// [StreamMessageComposerReplyAttachment] widgets.
///
/// Wrap a subtree with [StreamMessageComposerReplyAttachmentTheme] to
/// override the styling of the reply preview shown above the composer input.
/// Access the merged theme using
/// [BuildContext.streamMessageComposerReplyAttachmentTheme].
///
/// {@tool snippet}
///
/// Override the reply attachment indicator color for a specific section:
///
/// ```dart
/// StreamMessageComposerReplyAttachmentTheme(
///   data: StreamMessageComposerReplyAttachmentThemeData(
///     indicatorColor: Colors.green,
///   ),
///   child: StreamMessageComposer(),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageComposerReplyAttachmentThemeData], which describes the
///    theme data.
///  * [StreamMessageComposerReplyAttachment], the widget affected by this theme.
class StreamMessageComposerReplyAttachmentTheme extends InheritedTheme {
  /// Creates a composer reply attachment theme that controls descendant reply
  /// previews.
  const StreamMessageComposerReplyAttachmentTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The composer reply attachment theme data for descendant widgets.
  final StreamMessageComposerReplyAttachmentThemeData data;

  /// Returns the [StreamMessageComposerReplyAttachmentThemeData] merged from
  /// local and global themes.
  ///
  /// Local values from the nearest
  /// [StreamMessageComposerReplyAttachmentTheme] ancestor take precedence
  /// over global values from [StreamTheme.of].
  static StreamMessageComposerReplyAttachmentThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamMessageComposerReplyAttachmentTheme>();
    return StreamTheme.of(context).messageComposerReplyAttachmentTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamMessageComposerReplyAttachmentTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamMessageComposerReplyAttachmentTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamMessageComposerReplyAttachment] widgets.
///
/// Descendant widgets obtain their values from
/// [StreamMessageComposerReplyAttachmentTheme.of]. All properties are null by
/// default, with direction-aware fallback values applied by
/// [DefaultStreamMessageComposerReplyAttachment] based on the widget's
/// [StreamReplyDirection] (incoming or outgoing).
///
/// {@tool snippet}
///
/// Customize reply attachment styling globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   messageComposerReplyAttachmentTheme:
///       StreamMessageComposerReplyAttachmentThemeData(
///     indicatorColor: Colors.green,
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageComposerReplyAttachmentTheme], for overriding theme in a
///    widget subtree.
///  * [StreamMessageComposerReplyAttachment], the widget that uses this theme data.
@themeGen
@immutable
class StreamMessageComposerReplyAttachmentThemeData with _$StreamMessageComposerReplyAttachmentThemeData {
  /// Creates composer reply attachment theme data with optional overrides.
  const StreamMessageComposerReplyAttachmentThemeData({
    this.backgroundColor,
    this.indicatorColor,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.padding,
    this.thumbnailShape,
    this.thumbnailSide,
    this.thumbnailSize,
  });

  /// Background fill color of the reply preview card.
  ///
  /// If null, the consuming widget falls back to a direction-aware default:
  /// `colorScheme.backgroundSurface` for incoming replies,
  /// `colorScheme.brand.shade100` for outgoing.
  final Color? backgroundColor;

  /// Color of the leading indicator bar.
  ///
  /// If null, the consuming widget falls back to a direction-aware default:
  /// `colorScheme.chrome.shade400` for incoming replies,
  /// `colorScheme.brand.shade400` for outgoing.
  final Color? indicatorColor;

  /// Text style for the reply title (typically the quoted user's name).
  ///
  /// If null, defaults to [StreamTextTheme.metadataEmphasis] tinted with the
  /// direction-aware text color.
  final TextStyle? titleTextStyle;

  /// Text style for the reply subtitle (the quoted message preview).
  ///
  /// If null, defaults to [StreamTextTheme.metadataDefault] tinted with the
  /// direction-aware text color.
  final TextStyle? subtitleTextStyle;

  /// Padding around the reply preview's content row.
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

  /// Linearly interpolate between two
  /// [StreamMessageComposerReplyAttachmentThemeData] objects.
  static StreamMessageComposerReplyAttachmentThemeData? lerp(
    StreamMessageComposerReplyAttachmentThemeData? a,
    StreamMessageComposerReplyAttachmentThemeData? b,
    double t,
  ) => _$StreamMessageComposerReplyAttachmentThemeData.lerp(a, b, t);
}
