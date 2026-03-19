// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_message_bubble_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamMessageBubbleStyle {
  bool get canMerge => true;

  static StreamMessageBubbleStyle? lerp(
    StreamMessageBubbleStyle? a,
    StreamMessageBubbleStyle? b,
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

    return StreamMessageBubbleStyle(
      shape: StreamMessageStyleProperty.lerp<OutlinedBorder?>(
        a.shape,
        b.shape,
        t,
        OutlinedBorder.lerp,
      ),
      side: StreamMessageStyleBorderSide.lerp(a.side, b.side, t),
      padding: StreamMessageStyleProperty.lerp<EdgeInsetsGeometry?>(
        a.padding,
        b.padding,
        t,
        EdgeInsetsGeometry.lerp,
      ),
      constraints: StreamMessageStyleProperty.lerp<BoxConstraints?>(
        a.constraints,
        b.constraints,
        t,
        BoxConstraints.lerp,
      ),
      backgroundColor: StreamMessageStyleProperty.lerp<Color?>(
        a.backgroundColor,
        b.backgroundColor,
        t,
        Color.lerp,
      ),
    );
  }

  StreamMessageBubbleStyle copyWith({
    StreamMessageStyleProperty<OutlinedBorder?>? shape,
    StreamMessageStyleBorderSide? side,
    StreamMessageStyleProperty<EdgeInsetsGeometry?>? padding,
    StreamMessageStyleProperty<BoxConstraints?>? constraints,
    StreamMessageStyleProperty<Color?>? backgroundColor,
  }) {
    final _this = (this as StreamMessageBubbleStyle);

    return StreamMessageBubbleStyle(
      shape: shape ?? _this.shape,
      side: side ?? _this.side,
      padding: padding ?? _this.padding,
      constraints: constraints ?? _this.constraints,
      backgroundColor: backgroundColor ?? _this.backgroundColor,
    );
  }

  StreamMessageBubbleStyle merge(StreamMessageBubbleStyle? other) {
    final _this = (this as StreamMessageBubbleStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      shape: other.shape,
      side: other.side,
      padding: other.padding,
      constraints: other.constraints,
      backgroundColor: other.backgroundColor,
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

    final _this = (this as StreamMessageBubbleStyle);
    final _other = (other as StreamMessageBubbleStyle);

    return _other.shape == _this.shape &&
        _other.side == _this.side &&
        _other.padding == _this.padding &&
        _other.constraints == _this.constraints &&
        _other.backgroundColor == _this.backgroundColor;
  }

  @override
  int get hashCode {
    final _this = (this as StreamMessageBubbleStyle);

    return Object.hash(
      runtimeType,
      _this.shape,
      _this.side,
      _this.padding,
      _this.constraints,
      _this.backgroundColor,
    );
  }
}
