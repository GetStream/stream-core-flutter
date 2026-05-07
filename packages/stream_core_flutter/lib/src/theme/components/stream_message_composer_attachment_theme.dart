import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_message_composer_attachment_theme.g.theme.dart';

/// Applies a composer attachment theme to descendant
/// [StreamMessageComposerAttachment] widgets.
///
/// Wrap a subtree with [StreamMessageComposerAttachmentTheme] to override
/// styling for the attachment containers shown in the message composer.
/// Access the merged theme using
/// [BuildContext.streamMessageComposerAttachmentTheme].
///
/// {@tool snippet}
///
/// Override the composer attachment background for a specific section:
///
/// ```dart
/// StreamMessageComposerAttachmentTheme(
///   data: StreamMessageComposerAttachmentThemeData(
///     backgroundColor: Colors.blue.shade50,
///   ),
///   child: StreamMessageComposer(),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageComposerAttachmentThemeData], which describes the theme
///    data.
///  * [StreamMessageComposerAttachment], the widget affected by this theme.
class StreamMessageComposerAttachmentTheme extends InheritedTheme {
  /// Creates a composer attachment theme that controls descendant attachment
  /// containers.
  const StreamMessageComposerAttachmentTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The composer attachment theme data for descendant widgets.
  final StreamMessageComposerAttachmentThemeData data;

  /// Returns the [StreamMessageComposerAttachmentThemeData] merged from local
  /// and global themes.
  ///
  /// Local values from the nearest [StreamMessageComposerAttachmentTheme]
  /// ancestor take precedence over global values from [StreamTheme.of].
  static StreamMessageComposerAttachmentThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamMessageComposerAttachmentTheme>();
    return StreamTheme.of(context).messageComposerAttachmentTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamMessageComposerAttachmentTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamMessageComposerAttachmentTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamMessageComposerAttachment] widgets.
///
/// Descendant widgets obtain their values from
/// [StreamMessageComposerAttachmentTheme.of]. All properties are null by
/// default, with fallback values applied by
/// [DefaultStreamMessageComposerAttachment].
///
/// {@tool snippet}
///
/// Customize composer attachment containers globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   messageComposerAttachmentTheme: StreamMessageComposerAttachmentThemeData(
///     backgroundColor: Colors.blue.shade50,
///     side: BorderSide(color: Colors.blue.shade200),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageComposerAttachmentTheme], for overriding theme in a
///    widget subtree.
///  * [StreamMessageComposerAttachment], the widget that uses this theme data.
@themeGen
@immutable
class StreamMessageComposerAttachmentThemeData with _$StreamMessageComposerAttachmentThemeData {
  /// Creates composer attachment theme data with optional overrides.
  const StreamMessageComposerAttachmentThemeData({
    this.backgroundColor,
    this.shape,
    this.side,
    this.padding,
  });

  /// Background fill color of the attachment container.
  ///
  /// If null, defaults to [StreamColorScheme.backgroundElevation1].
  final Color? backgroundColor;

  /// Outer shape of the attachment container.
  ///
  /// Composed with [side] to draw the container's border. If null, defaults
  /// to a [RoundedRectangleBorder] with radius [StreamRadius.lg].
  final OutlinedBorder? shape;

  /// Border side drawn around the attachment container.
  ///
  /// Composed onto [shape] via [OutlinedBorder.copyWith]. If null, defaults
  /// to a 1px [BorderSide] using [StreamColorScheme.borderDefault].
  final BorderSide? side;

  /// Outer padding around the attachment container, separating the container
  /// from its siblings and reserving room for the optional remove control
  /// overlay at the top-end corner.
  ///
  /// If null, defaults to [StreamSpacing.xxs] on all sides.
  final EdgeInsetsGeometry? padding;

  /// Linearly interpolate between two
  /// [StreamMessageComposerAttachmentThemeData] objects.
  static StreamMessageComposerAttachmentThemeData? lerp(
    StreamMessageComposerAttachmentThemeData? a,
    StreamMessageComposerAttachmentThemeData? b,
    double t,
  ) => _$StreamMessageComposerAttachmentThemeData.lerp(a, b, t);
}
