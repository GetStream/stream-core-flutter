// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_message_replies_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamMessageRepliesStyle {
  bool get canMerge => true;

  static StreamMessageRepliesStyle? lerp(
    StreamMessageRepliesStyle? a,
    StreamMessageRepliesStyle? b,
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

    return StreamMessageRepliesStyle(
      labelTextStyle: StreamMessageStyleProperty.lerp<TextStyle?>(
        a.labelTextStyle,
        b.labelTextStyle,
        t,
        TextStyle.lerp,
      ),
      labelColor: StreamMessageStyleProperty.lerp<Color?>(
        a.labelColor,
        b.labelColor,
        t,
        Color.lerp,
      ),
      spacing: StreamMessageStyleProperty.lerp<double?>(
        a.spacing,
        b.spacing,
        t,
        lerpDouble$,
      ),
      padding: StreamMessageStyleProperty.lerp<EdgeInsetsGeometry?>(
        a.padding,
        b.padding,
        t,
        EdgeInsetsGeometry.lerp,
      ),
      connectorColor: StreamMessageStyleProperty.lerp<Color?>(
        a.connectorColor,
        b.connectorColor,
        t,
        Color.lerp,
      ),
      connectorStrokeWidth: StreamMessageStyleProperty.lerp<double?>(
        a.connectorStrokeWidth,
        b.connectorStrokeWidth,
        t,
        lerpDouble$,
      ),
      clipBehavior: StreamMessageStyleClip.lerp(
        a.clipBehavior,
        b.clipBehavior,
        t,
      ),
    );
  }

  StreamMessageRepliesStyle copyWith({
    StreamMessageStyleProperty<TextStyle?>? labelTextStyle,
    StreamMessageStyleProperty<Color?>? labelColor,
    StreamMessageStyleProperty<double?>? spacing,
    StreamMessageStyleProperty<EdgeInsetsGeometry?>? padding,
    StreamMessageStyleProperty<Color?>? connectorColor,
    StreamMessageStyleProperty<double?>? connectorStrokeWidth,
    StreamMessageStyleClip? clipBehavior,
  }) {
    final _this = (this as StreamMessageRepliesStyle);

    return StreamMessageRepliesStyle(
      labelTextStyle: labelTextStyle ?? _this.labelTextStyle,
      labelColor: labelColor ?? _this.labelColor,
      spacing: spacing ?? _this.spacing,
      padding: padding ?? _this.padding,
      connectorColor: connectorColor ?? _this.connectorColor,
      connectorStrokeWidth: connectorStrokeWidth ?? _this.connectorStrokeWidth,
      clipBehavior: clipBehavior ?? _this.clipBehavior,
    );
  }

  StreamMessageRepliesStyle merge(StreamMessageRepliesStyle? other) {
    final _this = (this as StreamMessageRepliesStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      labelTextStyle: other.labelTextStyle,
      labelColor: other.labelColor,
      spacing: other.spacing,
      padding: other.padding,
      connectorColor: other.connectorColor,
      connectorStrokeWidth: other.connectorStrokeWidth,
      clipBehavior: other.clipBehavior,
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

    final _this = (this as StreamMessageRepliesStyle);
    final _other = (other as StreamMessageRepliesStyle);

    return _other.labelTextStyle == _this.labelTextStyle &&
        _other.labelColor == _this.labelColor &&
        _other.spacing == _this.spacing &&
        _other.padding == _this.padding &&
        _other.connectorColor == _this.connectorColor &&
        _other.connectorStrokeWidth == _this.connectorStrokeWidth &&
        _other.clipBehavior == _this.clipBehavior;
  }

  @override
  int get hashCode {
    final _this = (this as StreamMessageRepliesStyle);

    return Object.hash(
      runtimeType,
      _this.labelTextStyle,
      _this.labelColor,
      _this.spacing,
      _this.padding,
      _this.connectorColor,
      _this.connectorStrokeWidth,
      _this.clipBehavior,
    );
  }
}
