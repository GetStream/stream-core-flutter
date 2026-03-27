import 'dart:ui' show Clip;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show BorderSide;

import '../../components/common/stream_visibility.dart';
import '../../components/message_layout/stream_message_layout.dart';

/// Resolves a value of type [T] based on a message's [StreamMessageLayoutData].
///
/// Each field in a message style class (e.g. `StreamMessageBubbleStyle.shape`)
/// is a [StreamMessageLayoutProperty] so that its value can vary by alignment
/// (start / end) and stack position (single / top / middle / bottom).
///
/// Use the factory constructors for common patterns:
///
/// {@tool snippet}
///
/// Uniform value for all layouts:
///
/// ```dart
/// StreamMessageLayoutProperty.all(EdgeInsets.all(12))
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Alignment-aware color:
///
/// ```dart
/// StreamMessageLayoutProperty.resolveWith((layout) {
///   final isEnd = layout.alignment == StreamMessageAlignment.end;
///   return isEnd ? brandColor : surfaceColor;
/// })
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Position + alignment aware shape:
///
/// ```dart
/// StreamMessageLayoutProperty.resolveWith((layout) {
///   final isEnd = layout.alignment == StreamMessageAlignment.end;
///   return switch (layout.stackPosition) {
///     StreamMessageStackPosition.single =>
///       RoundedRectangleBorder(borderRadius: BorderRadius.all(r.xxl)),
///     StreamMessageStackPosition.top =>
///       RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.only(
///         topStart: r.xxl,
///         topEnd: r.xxl,
///         bottomStart: isEnd ? r.xxl : tailRadius,
///         bottomEnd: isEnd ? tailRadius : r.xxl,
///       )),
///     _ => defaultShape,
///   };
/// })
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageLayoutData], the context passed to [resolve].
abstract class StreamMessageLayoutProperty<T> {
  /// Const constructor for subclasses.
  const StreamMessageLayoutProperty();

  /// Resolves this property for the given [layout].
  T resolve(StreamMessageLayoutData layout);

  /// Creates a property that returns [value] for every layout.
  static StreamMessageLayoutProperty<T> all<T>(T value) => _AllProperty<T>(value);

  /// Creates a property that delegates to [callback] for resolution.
  static StreamMessageLayoutProperty<T> resolveWith<T>(
    T Function(StreamMessageLayoutData layout) callback,
  ) => _ResolveWithProperty<T>(callback);

  /// Linearly interpolates between two [StreamMessageLayoutProperty] values.
  static StreamMessageLayoutProperty<T?>? lerp<T>(
    StreamMessageLayoutProperty<T?>? a,
    StreamMessageLayoutProperty<T?>? b,
    double t,
    T? Function(T?, T?, double) lerpFunction,
  ) {
    if (a == null && b == null) return null;
    return _LerpProperty<T>(a, b, t, lerpFunction);
  }
}

@immutable
class _AllProperty<T> extends StreamMessageLayoutProperty<T> {
  const _AllProperty(this._value);

  final T _value;

  @override
  T resolve(StreamMessageLayoutData layout) => _value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _AllProperty<T> && other._value == _value;
  }

  @override
  int get hashCode => _value.hashCode;
}

class _ResolveWithProperty<T> extends StreamMessageLayoutProperty<T> {
  const _ResolveWithProperty(this._callback);

  final T Function(StreamMessageLayoutData layout) _callback;

  @override
  T resolve(StreamMessageLayoutData layout) => _callback(layout);
}

class _LerpProperty<T> extends StreamMessageLayoutProperty<T?> {
  const _LerpProperty(this._a, this._b, this._t, this._lerpFunction);

  final StreamMessageLayoutProperty<T?>? _a;
  final StreamMessageLayoutProperty<T?>? _b;
  final double _t;
  final T? Function(T?, T?, double) _lerpFunction;

  @override
  T? resolve(StreamMessageLayoutData layout) {
    return _lerpFunction(_a?.resolve(layout), _b?.resolve(layout), _t);
  }
}

/// A [Clip] value that can depend on [StreamMessageLayoutData].
///
/// {@tool snippet}
///
/// Same clip for all layouts:
///
/// ```dart
/// StreamMessageLayoutClip.all(Clip.hardEdge)
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Placement-aware clip:
///
/// ```dart
/// StreamMessageLayoutClip.resolveWith((layout) {
///   return switch (layout.stackPosition) {
///     .top || .middle => Clip.none,
///     .bottom || .single => Clip.hardEdge,
///   };
/// })
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageLayoutProperty], the generic layout-aware resolver.
///  * [StreamMessageLayoutData], the context passed to [resolve].
extension type const StreamMessageLayoutClip._(StreamMessageLayoutProperty<Clip?> _property)
    implements StreamMessageLayoutProperty<Clip?> {
  /// Creates a clip that returns [clip] for every layout.
  static StreamMessageLayoutClip all(Clip clip) => ._(.all(clip));

  /// Creates a clip that delegates to [callback] for resolution.
  static StreamMessageLayoutClip resolveWith(
    Clip? Function(StreamMessageLayoutData layout) callback,
  ) => ._(.resolveWith(callback));

  /// Linearly interpolate between two [StreamMessageLayoutClip] values.
  static StreamMessageLayoutClip? lerp(
    StreamMessageLayoutClip? a,
    StreamMessageLayoutClip? b,
    double t,
  ) {
    if (a == null && b == null) return null;
    if (identical(a, b)) return a;
    return t < 0.5 ? a : b;
  }
}

/// A [StreamVisibility] value that can depend on [StreamMessageLayoutData].
///
/// {@tool snippet}
///
/// Same visibility for all layouts:
///
/// ```dart
/// StreamMessageLayoutVisibility.all(StreamVisibility.hidden)
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Placement-aware visibility:
///
/// ```dart
/// StreamMessageLayoutVisibility.resolveWith((layout) {
///   return switch (layout.stackPosition) {
///     .top || .middle => StreamVisibility.hidden,
///     .bottom || .single => StreamVisibility.visible,
///   };
/// })
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageLayoutProperty], the generic layout-aware resolver.
///  * [StreamMessageLayoutData], the context passed to [resolve].
extension type const StreamMessageLayoutVisibility._(StreamMessageLayoutProperty<StreamVisibility?> _property)
    implements StreamMessageLayoutProperty<StreamVisibility?> {
  /// Creates a visibility that returns [visibility] for every layout.
  static StreamMessageLayoutVisibility all(StreamVisibility visibility) => ._(.all(visibility));

  /// Creates a visibility that delegates to [callback] for resolution.
  static StreamMessageLayoutVisibility resolveWith(
    StreamVisibility? Function(StreamMessageLayoutData layout) callback,
  ) => ._(.resolveWith(callback));

  /// Linearly interpolate between two [StreamMessageLayoutVisibility] values.
  static StreamMessageLayoutVisibility? lerp(
    StreamMessageLayoutVisibility? a,
    StreamMessageLayoutVisibility? b,
    double t,
  ) {
    if (a == null && b == null) return null;
    if (identical(a, b)) return a;
    return t < 0.5 ? a : b;
  }
}

/// A [BorderSide] value that can depend on [StreamMessageLayoutData].
///
/// {@tool snippet}
///
/// Same border for all layouts:
///
/// ```dart
/// StreamMessageLayoutBorderSide.all(BorderSide(color: Colors.grey))
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Placement-aware border:
///
/// ```dart
/// StreamMessageLayoutBorderSide.resolveWith((layout) {
///   return switch (layout.alignment) {
///     .start => BorderSide(color: Colors.grey),
///     .end => BorderSide(color: Colors.blue),
///   };
/// })
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageLayoutProperty], the generic layout-aware resolver.
///  * [StreamMessageLayoutData], the context passed to [resolve].
extension type const StreamMessageLayoutBorderSide._(StreamMessageLayoutProperty<BorderSide?> _property)
    implements StreamMessageLayoutProperty<BorderSide?> {
  /// Creates a border side that returns [side] for every layout.
  static StreamMessageLayoutBorderSide all(BorderSide side) => ._(.all(side));

  /// Creates a border side that delegates to [callback] for resolution.
  static StreamMessageLayoutBorderSide resolveWith(
    BorderSide? Function(StreamMessageLayoutData layout) callback,
  ) => ._(.resolveWith(callback));

  /// Linearly interpolate between two [StreamMessageLayoutBorderSide] values.
  static StreamMessageLayoutBorderSide? lerp(
    StreamMessageLayoutBorderSide? a,
    StreamMessageLayoutBorderSide? b,
    double t,
  ) {
    if (a == null && b == null) return null;
    if (identical(a, b)) return a;
    return ._(_LerpBorderSide(a, b, t));
  }
}

class _LerpBorderSide extends StreamMessageLayoutProperty<BorderSide?> {
  const _LerpBorderSide(this._a, this._b, this._t);

  final StreamMessageLayoutBorderSide? _a;
  final StreamMessageLayoutBorderSide? _b;
  final double _t;

  @override
  BorderSide? resolve(StreamMessageLayoutData layout) {
    final resolvedA = _a?.resolve(layout);
    final resolvedB = _b?.resolve(layout);
    if (resolvedA == null && resolvedB == null) return null;
    if (resolvedA == null) {
      return BorderSide.lerp(
        BorderSide(width: 0, color: resolvedB!.color.withAlpha(0)),
        resolvedB,
        _t,
      );
    }
    if (resolvedB == null) {
      return BorderSide.lerp(
        resolvedA,
        BorderSide(width: 0, color: resolvedA.color.withAlpha(0)),
        _t,
      );
    }
    return BorderSide.lerp(resolvedA, resolvedB, _t);
  }
}

/// Resolves style properties from an ordered list of style sources for a
/// given [StreamMessageLayoutData].
///
/// {@tool snippet}
///
/// ```dart
/// final resolve = StreamMessageLayoutResolver<StreamMessageBubbleStyle>(
///   layout,
///   [widgetStyle, themeStyle, defaults],
/// );
///
/// final color = resolve((s) => s?.backgroundColor);
/// final side = resolve.maybeResolve((s) => s?.side);
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageLayoutProperty], the resolver type for each field.
///  * [StreamMessageLayoutData], the context passed to each resolver.
class StreamMessageLayoutResolver<S> {
  /// Creates a resolver that cascades through [styles] in order.
  const StreamMessageLayoutResolver(this._layout, this._styles);

  final StreamMessageLayoutData _layout;
  final List<S?> _styles;

  /// Resolves the first non-null value for [getProperty] across all style
  /// sources, returning `null` if none is found.
  ///
  /// Unlike [call], this never throws — use it for optional properties
  /// that may not have a default.
  T? maybeResolve<T extends Object>(StreamMessageLayoutProperty<T?>? Function(S? style) getProperty) {
    for (final style in _styles) {
      final resolved = getProperty(style)?.resolve(_layout);
      if (resolved != null) return resolved;
    }

    return null; // No style source provided a value for the requested property
  }

  /// Resolves the first non-null value for [getProperty] across all style
  /// sources.
  ///
  /// Throws a [StateError] if no source provides a value. Use this when a
  /// defaults object guarantees every property is present.
  ///
  /// To return `null` instead of throwing, use [maybeResolve].
  T call<T extends Object>(StreamMessageLayoutProperty<T?>? Function(S? style) getProperty) {
    final result = maybeResolve(getProperty);
    if (result != null) return result;

    throw StateError('No style source provided a value for the requested property');
  }
}
