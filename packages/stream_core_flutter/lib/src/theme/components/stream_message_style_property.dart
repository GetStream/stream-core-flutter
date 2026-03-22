import 'dart:ui' show Clip;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show BorderSide;

import '../../components/common/stream_visibility.dart';
import '../../components/message_placement/stream_message_placement.dart';

/// Resolves a value of type [T] based on a message's [StreamMessagePlacementData].
///
/// Each field in a message style class (e.g. `StreamMessageBubbleStyle.shape`)
/// is a [StreamMessageStyleProperty] so that its value can vary by alignment
/// (start / end) and stack position (single / top / middle / bottom).
///
/// Use the factory constructors for common patterns:
///
/// {@tool snippet}
///
/// Uniform value for all placements:
///
/// ```dart
/// StreamMessageStyleProperty.all(EdgeInsets.all(12))
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Alignment-aware color:
///
/// ```dart
/// StreamMessageStyleProperty.resolveWith((placement) {
///   final isEnd = placement.alignment == StreamMessageAlignment.end;
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
/// StreamMessageStyleProperty.resolveWith((placement) {
///   final isEnd = placement.alignment == StreamMessageAlignment.end;
///   return switch (placement.stackPosition) {
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
///  * [StreamMessagePlacementData], the context passed to [resolve].
abstract class StreamMessageStyleProperty<T> {
  /// Const constructor for subclasses.
  const StreamMessageStyleProperty();

  /// Resolves this property for the given [placement].
  T resolve(StreamMessagePlacementData placement);

  /// Creates a property that returns [value] for every placement.
  static StreamMessageStyleProperty<T> all<T>(T value) => _AllProperty<T>(value);

  /// Creates a property that delegates to [callback] for resolution.
  static StreamMessageStyleProperty<T> resolveWith<T>(
    T Function(StreamMessagePlacementData placement) callback,
  ) => _ResolveWithProperty<T>(callback);

  /// Linearly interpolates between two [StreamMessageStyleProperty] values.
  static StreamMessageStyleProperty<T?>? lerp<T>(
    StreamMessageStyleProperty<T?>? a,
    StreamMessageStyleProperty<T?>? b,
    double t,
    T? Function(T?, T?, double) lerpFunction,
  ) {
    if (a == null && b == null) return null;
    return _LerpProperty<T>(a, b, t, lerpFunction);
  }
}

@immutable
class _AllProperty<T> extends StreamMessageStyleProperty<T> {
  const _AllProperty(this._value);

  final T _value;

  @override
  T resolve(StreamMessagePlacementData placement) => _value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _AllProperty<T> && other._value == _value;
  }

  @override
  int get hashCode => _value.hashCode;
}

class _ResolveWithProperty<T> extends StreamMessageStyleProperty<T> {
  const _ResolveWithProperty(this._callback);

  final T Function(StreamMessagePlacementData placement) _callback;

  @override
  T resolve(StreamMessagePlacementData placement) => _callback(placement);
}

class _LerpProperty<T> extends StreamMessageStyleProperty<T?> {
  const _LerpProperty(this._a, this._b, this._t, this._lerpFunction);

  final StreamMessageStyleProperty<T?>? _a;
  final StreamMessageStyleProperty<T?>? _b;
  final double _t;
  final T? Function(T?, T?, double) _lerpFunction;

  @override
  T? resolve(StreamMessagePlacementData placement) {
    return _lerpFunction(_a?.resolve(placement), _b?.resolve(placement), _t);
  }
}

/// A [Clip] value that can depend on [StreamMessagePlacementData].
///
/// {@tool snippet}
///
/// Same clip for all placements:
///
/// ```dart
/// StreamMessageStyleClip.all(Clip.hardEdge)
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Placement-aware clip:
///
/// ```dart
/// StreamMessageStyleClip.resolveWith((placement) {
///   return switch (placement.stackPosition) {
///     .top || .middle => Clip.none,
///     .bottom || .single => Clip.hardEdge,
///   };
/// })
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageStyleProperty], the generic placement-aware resolver.
///  * [StreamMessagePlacementData], the context passed to [resolve].
extension type const StreamMessageStyleClip._(StreamMessageStyleProperty<Clip?> _property)
    implements StreamMessageStyleProperty<Clip?> {
  /// Creates a clip that returns [clip] for every placement.
  static StreamMessageStyleClip all(Clip clip) => ._(.all(clip));

  /// Creates a clip that delegates to [callback] for resolution.
  static StreamMessageStyleClip resolveWith(
    Clip? Function(StreamMessagePlacementData placement) callback,
  ) => ._(.resolveWith(callback));

  /// Linearly interpolate between two [StreamMessageStyleClip] values.
  static StreamMessageStyleClip? lerp(
    StreamMessageStyleClip? a,
    StreamMessageStyleClip? b,
    double t,
  ) {
    if (a == null && b == null) return null;
    if (identical(a, b)) return a;
    return t < 0.5 ? a : b;
  }
}

/// A [StreamVisibility] value that can depend on [StreamMessagePlacementData].
///
/// {@tool snippet}
///
/// Same visibility for all placements:
///
/// ```dart
/// StreamMessageStyleVisibility.all(StreamVisibility.hidden)
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Placement-aware visibility:
///
/// ```dart
/// StreamMessageStyleVisibility.resolveWith((placement) {
///   return switch (placement.stackPosition) {
///     .top || .middle => StreamVisibility.hidden,
///     .bottom || .single => StreamVisibility.visible,
///   };
/// })
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageStyleProperty], the generic placement-aware resolver.
///  * [StreamMessagePlacementData], the context passed to [resolve].
extension type const StreamMessageStyleVisibility._(StreamMessageStyleProperty<StreamVisibility?> _property)
    implements StreamMessageStyleProperty<StreamVisibility?> {
  /// Creates a visibility that returns [visibility] for every placement.
  static StreamMessageStyleVisibility all(StreamVisibility visibility) => ._(.all(visibility));

  /// Creates a visibility that delegates to [callback] for resolution.
  static StreamMessageStyleVisibility resolveWith(
    StreamVisibility? Function(StreamMessagePlacementData placement) callback,
  ) => ._(.resolveWith(callback));

  /// Linearly interpolate between two [StreamMessageStyleVisibility] values.
  static StreamMessageStyleVisibility? lerp(
    StreamMessageStyleVisibility? a,
    StreamMessageStyleVisibility? b,
    double t,
  ) {
    if (a == null && b == null) return null;
    if (identical(a, b)) return a;
    return t < 0.5 ? a : b;
  }
}

/// A [BorderSide] value that can depend on [StreamMessagePlacementData].
///
/// {@tool snippet}
///
/// Same border for all placements:
///
/// ```dart
/// StreamMessageStyleBorderSide.all(BorderSide(color: Colors.grey))
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Placement-aware border:
///
/// ```dart
/// StreamMessageStyleBorderSide.resolveWith((placement) {
///   return switch (placement.alignment) {
///     .start => BorderSide(color: Colors.grey),
///     .end => BorderSide(color: Colors.blue),
///   };
/// })
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageStyleProperty], the generic placement-aware resolver.
///  * [StreamMessagePlacementData], the context passed to [resolve].
extension type const StreamMessageStyleBorderSide._(StreamMessageStyleProperty<BorderSide?> _property)
    implements StreamMessageStyleProperty<BorderSide?> {
  /// Creates a border side that returns [side] for every placement.
  static StreamMessageStyleBorderSide all(BorderSide side) => ._(.all(side));

  /// Creates a border side that delegates to [callback] for resolution.
  static StreamMessageStyleBorderSide resolveWith(
    BorderSide? Function(StreamMessagePlacementData placement) callback,
  ) => ._(.resolveWith(callback));

  /// Linearly interpolate between two [StreamMessageStyleBorderSide] values.
  static StreamMessageStyleBorderSide? lerp(
    StreamMessageStyleBorderSide? a,
    StreamMessageStyleBorderSide? b,
    double t,
  ) {
    if (a == null && b == null) return null;
    if (identical(a, b)) return a;
    return ._(_LerpBorderSide(a, b, t));
  }
}

class _LerpBorderSide extends StreamMessageStyleProperty<BorderSide?> {
  const _LerpBorderSide(this._a, this._b, this._t);

  final StreamMessageStyleBorderSide? _a;
  final StreamMessageStyleBorderSide? _b;
  final double _t;

  @override
  BorderSide? resolve(StreamMessagePlacementData placement) {
    final resolvedA = _a?.resolve(placement);
    final resolvedB = _b?.resolve(placement);
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
/// given [StreamMessagePlacementData].
///
/// {@tool snippet}
///
/// ```dart
/// final resolve = StreamMessageStyleResolver<StreamMessageBubbleStyle>(
///   placement,
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
///  * [StreamMessageStyleProperty], the resolver type for each field.
///  * [StreamMessagePlacementData], the context passed to each resolver.
class StreamMessageStyleResolver<S> {
  /// Creates a resolver that cascades through [styles] in order.
  const StreamMessageStyleResolver(this._placement, this._styles);

  final StreamMessagePlacementData _placement;
  final List<S?> _styles;

  /// Resolves the first non-null value for [getProperty] across all style
  /// sources, returning `null` if none is found.
  ///
  /// Unlike [call], this never throws — use it for optional properties
  /// that may not have a default.
  T? maybeResolve<T extends Object>(StreamMessageStyleProperty<T?>? Function(S? style) getProperty) {
    for (final style in _styles) {
      final resolved = getProperty(style)?.resolve(_placement);
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
  T call<T extends Object>(StreamMessageStyleProperty<T?>? Function(S? style) getProperty) {
    final result = maybeResolve(getProperty);
    if (result != null) return result;

    throw StateError('No style source provided a value for the requested property');
  }
}
