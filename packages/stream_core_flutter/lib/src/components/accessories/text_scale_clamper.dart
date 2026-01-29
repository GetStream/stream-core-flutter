import 'package:flutter/material.dart';

/// {@template text_scale_factor_clamper}
/// Constrains text scale factor of app to certain range.
///
/// Wraps all widgets created under the [MaterialApp].
/// ```dart
/// MaterialApp(
///   builder: (_, child) => StreamTextScaleFactorClamper(child: child!),
///   ...
/// ),
/// ```
/// {@endtemplate}
class StreamTextScaleFactorClamper extends StatelessWidget {
  /// {@macro text_scale_factor_clamper}
  const StreamTextScaleFactorClamper({
    super.key,
    required this.child,
    this.minTextScaleFactor,
    this.maxTextScaleFactor,
  }) : assert(
         minTextScaleFactor == null || maxTextScaleFactor == null || minTextScaleFactor <= maxTextScaleFactor,
         'minTextScaleFactor must be less than maxTextScaleFactor',
       ),
       assert(
         maxTextScaleFactor == null || minTextScaleFactor == null || maxTextScaleFactor >= minTextScaleFactor,
         'maxTextScaleFactor must be greater than minTextScaleFactor',
       );

  /// Child widget.
  final Widget child;

  /// Min text scale factor.
  final double? minTextScaleFactor;

  /// Max text scale factor.
  final double? maxTextScaleFactor;

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);

    final constrainedTextScaleFactor = mediaQueryData.textScaler.clamp(
      minScaleFactor: minTextScaleFactor ?? 1,
      maxScaleFactor: maxTextScaleFactor ?? 1.3,
    );

    return MediaQuery(
      data: mediaQueryData.copyWith(
        textScaler: constrainedTextScaleFactor,
      ),
      child: child,
    );
  }
}
