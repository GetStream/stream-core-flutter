// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_typing_indicator_dots_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamTypingIndicatorDotsThemeData {
  bool get canMerge => true;

  static StreamTypingIndicatorDotsThemeData? lerp(
    StreamTypingIndicatorDotsThemeData? a,
    StreamTypingIndicatorDotsThemeData? b,
    double t,
  ) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return StreamTypingIndicatorDotsThemeData(
      color: Color.lerp(a.color, b.color, t),
      dotSize: lerpDouble$(a.dotSize, b.dotSize, t),
      spacing: lerpDouble$(a.spacing, b.spacing, t),
      period: lerpDuration$(a.period, b.period, t),
    );
  }

  StreamTypingIndicatorDotsThemeData copyWith({
    Color? color,
    double? dotSize,
    double? spacing,
    Duration? period,
  }) {
    final _this = (this as StreamTypingIndicatorDotsThemeData);

    return StreamTypingIndicatorDotsThemeData(
      color: color ?? _this.color,
      dotSize: dotSize ?? _this.dotSize,
      spacing: spacing ?? _this.spacing,
      period: period ?? _this.period,
    );
  }

  StreamTypingIndicatorDotsThemeData merge(
    StreamTypingIndicatorDotsThemeData? other,
  ) {
    final _this = (this as StreamTypingIndicatorDotsThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      color: other.color,
      dotSize: other.dotSize,
      spacing: other.spacing,
      period: other.period,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other.runtimeType != runtimeType) {
      return false;
    }

    final _this = (this as StreamTypingIndicatorDotsThemeData);
    final _other = (other as StreamTypingIndicatorDotsThemeData);

    return _other.color == _this.color &&
        _other.dotSize == _this.dotSize &&
        _other.spacing == _this.spacing &&
        _other.period == _this.period;
  }

  @override
  int get hashCode {
    final _this = (this as StreamTypingIndicatorDotsThemeData);

    return Object.hash(
      runtimeType,
      _this.color,
      _this.dotSize,
      _this.spacing,
      _this.period,
    );
  }
}
