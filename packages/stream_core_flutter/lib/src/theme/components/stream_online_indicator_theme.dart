import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_online_indicator_theme.g.theme.dart';

/// Predefined sizes for the online indicator.
///
/// Each size corresponds to a specific diameter in logical pixels.
///
/// See also:
///
///  * [StreamOnlineIndicator], which uses these size variants.
///  * [StreamOnlineIndicatorThemeData.size], for setting a global default size.
enum StreamOnlineIndicatorSize {
  /// Small indicator (8px diameter).
  sm(8),

  /// Medium indicator (12px diameter).
  md(12),

  /// Large indicator (14px diameter).
  lg(14),

  /// Extra large indicator (16px diameter).
  xl(16)
  ;

  /// Constructs a [StreamOnlineIndicatorSize] with the given diameter.
  const StreamOnlineIndicatorSize(this.value);

  /// The diameter of the indicator in logical pixels.
  final double value;
}

/// Applies an online indicator theme to descendant [StreamOnlineIndicator]
/// widgets.
///
/// Wrap a subtree with [StreamOnlineIndicatorTheme] to override indicator
/// styling. Access the merged theme using [BuildContext.streamOnlineIndicatorTheme].
///
/// {@tool snippet}
///
/// Override indicator colors for a specific section:
///
/// ```dart
/// StreamOnlineIndicatorTheme(
///   data: StreamOnlineIndicatorThemeData(
///     backgroundOnline: Colors.green,
///     backgroundOffline: Colors.grey,
///   ),
///   child: Row(
///     children: [
///       StreamOnlineIndicator(state: StreamPresenceState.online),
///       StreamOnlineIndicator(state: StreamPresenceState.offline),
///     ],
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamOnlineIndicatorThemeData], which describes the indicator theme.
///  * [StreamOnlineIndicator], the widget affected by this theme.
class StreamOnlineIndicatorTheme extends InheritedTheme {
  /// Creates an online indicator theme that controls descendant indicators.
  const StreamOnlineIndicatorTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The online indicator theme data for descendant widgets.
  final StreamOnlineIndicatorThemeData data;

  /// Returns the [StreamOnlineIndicatorThemeData] merged from local and global
  /// themes.
  ///
  /// Local values from the nearest [StreamOnlineIndicatorTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  ///
  /// This allows partial overrides - for example, overriding only
  /// [backgroundOnline] while inheriting other properties from the global theme.
  static StreamOnlineIndicatorThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamOnlineIndicatorTheme>();
    return StreamTheme.of(context).onlineIndicatorTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamOnlineIndicatorTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamOnlineIndicatorTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamOnlineIndicator] widgets.
///
/// {@tool snippet}
///
/// Customize indicator appearance globally:
///
/// ```dart
/// StreamTheme(
///   onlineIndicatorTheme: StreamOnlineIndicatorThemeData(
///     backgroundOnline: Colors.green,
///     backgroundOffline: Colors.grey,
///     borderColor: Colors.white,
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamOnlineIndicator], the widget that uses this theme data.
///  * [StreamOnlineIndicatorTheme], for overriding theme in a widget subtree.
@themeGen
@immutable
class StreamOnlineIndicatorThemeData with _$StreamOnlineIndicatorThemeData {
  /// Creates an online indicator theme with optional style overrides.
  const StreamOnlineIndicatorThemeData({
    this.size,
    this.backgroundOnline,
    this.backgroundOffline,
    this.borderColor,
    this.alignment,
    this.offset,
  });

  /// The default size for online indicators.
  ///
  /// Falls back to [StreamOnlineIndicatorSize.lg].
  final StreamOnlineIndicatorSize? size;

  /// The background color for online presence indicators.
  ///
  /// Displayed when the user is currently online.
  final Color? backgroundOnline;

  /// The background color for offline presence indicators.
  ///
  /// Displayed when the user is offline or away.
  final Color? backgroundOffline;

  /// The border color for the indicator.
  ///
  /// A thin outline around the presence dot that matches the surface behind
  /// the avatar.
  final Color? borderColor;

  /// The alignment of the indicator relative to the child widget.
  ///
  /// Only used when [StreamOnlineIndicator.child] is provided.
  /// Falls back to [AlignmentDirectional.topEnd].
  final AlignmentGeometry? alignment;

  /// The offset for fine-tuning indicator position.
  ///
  /// Applied after alignment to adjust the indicator's final position.
  /// Falls back to [Offset.zero].
  final Offset? offset;

  /// Linearly interpolate between two [StreamOnlineIndicatorThemeData] objects.
  static StreamOnlineIndicatorThemeData? lerp(
    StreamOnlineIndicatorThemeData? a,
    StreamOnlineIndicatorThemeData? b,
    double t,
  ) => _$StreamOnlineIndicatorThemeData.lerp(a, b, t);
}
