import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_message_composer_media_attachment_theme.g.theme.dart';

/// Applies a composer media attachment theme to descendant
/// [StreamMessageComposerMediaAttachment] widgets.
///
/// Wrap a subtree with [StreamMessageComposerMediaAttachmentTheme] to override
/// styling for image and video thumbnails rendered inside the composer.
/// Access the merged theme using
/// [BuildContext.streamMessageComposerMediaAttachmentTheme].
///
/// {@tool snippet}
///
/// Override the media attachment border for a specific section:
///
/// ```dart
/// StreamMessageComposerMediaAttachmentTheme(
///   data: StreamMessageComposerMediaAttachmentThemeData(
///     borderColor: Colors.black12,
///   ),
///   child: StreamMessageComposer(),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageComposerMediaAttachmentThemeData], which describes the
///    theme data.
///  * [StreamMessageComposerMediaAttachment], the widget affected by this theme.
class StreamMessageComposerMediaAttachmentTheme extends InheritedTheme {
  /// Creates a composer media attachment theme that controls descendant media
  /// attachments.
  const StreamMessageComposerMediaAttachmentTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The composer media attachment theme data for descendant widgets.
  final StreamMessageComposerMediaAttachmentThemeData data;

  /// Returns the [StreamMessageComposerMediaAttachmentThemeData] merged from
  /// local and global themes.
  ///
  /// Local values from the nearest
  /// [StreamMessageComposerMediaAttachmentTheme] ancestor take precedence
  /// over global values from [StreamTheme.of].
  static StreamMessageComposerMediaAttachmentThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamMessageComposerMediaAttachmentTheme>();
    return StreamTheme.of(context).messageComposerMediaAttachmentTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamMessageComposerMediaAttachmentTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamMessageComposerMediaAttachmentTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamMessageComposerMediaAttachment] widgets.
///
/// Descendant widgets obtain their values from
/// [StreamMessageComposerMediaAttachmentTheme.of]. All properties are null by
/// default, with fallback values applied by
/// [DefaultStreamMessageComposerMediaAttachment].
///
/// {@tool snippet}
///
/// Customize media attachment styling globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   messageComposerMediaAttachmentTheme:
///       StreamMessageComposerMediaAttachmentThemeData(
///     borderColor: Colors.black12,
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageComposerMediaAttachmentTheme], for overriding theme in a
///    widget subtree.
///  * [StreamMessageComposerMediaAttachment], the widget that uses this theme
///    data.
@themeGen
@immutable
class StreamMessageComposerMediaAttachmentThemeData with _$StreamMessageComposerMediaAttachmentThemeData {
  /// Creates composer media attachment theme data with optional overrides.
  const StreamMessageComposerMediaAttachmentThemeData({
    this.borderColor,
    this.size,
  });

  /// Border color drawn around the media attachment's container.
  ///
  /// If null, defaults to [StreamColorScheme.borderOpacitySubtle].
  final Color? borderColor;

  /// Dimensions of the media thumbnail.
  ///
  /// If null, defaults to `Size(72, 72)` (square).
  final Size? size;

  /// Linearly interpolate between two
  /// [StreamMessageComposerMediaAttachmentThemeData] objects.
  static StreamMessageComposerMediaAttachmentThemeData? lerp(
    StreamMessageComposerMediaAttachmentThemeData? a,
    StreamMessageComposerMediaAttachmentThemeData? b,
    double t,
  ) => _$StreamMessageComposerMediaAttachmentThemeData.lerp(a, b, t);
}
