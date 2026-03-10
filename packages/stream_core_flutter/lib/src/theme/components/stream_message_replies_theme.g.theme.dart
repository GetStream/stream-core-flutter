// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_message_replies_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamMessageRepliesThemeData {
  bool get canMerge => true;

  static StreamMessageRepliesThemeData? lerp(
    StreamMessageRepliesThemeData? a,
    StreamMessageRepliesThemeData? b,
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

    return StreamMessageRepliesThemeData(
      labelTextStyle: TextStyle.lerp(a.labelTextStyle, b.labelTextStyle, t),
      labelColor: Color.lerp(a.labelColor, b.labelColor, t),
      spacing: lerpDouble$(a.spacing, b.spacing, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      connectorColor: Color.lerp(a.connectorColor, b.connectorColor, t),
      connectorStrokeWidth: lerpDouble$(
        a.connectorStrokeWidth,
        b.connectorStrokeWidth,
        t,
      ),
    );
  }

  StreamMessageRepliesThemeData copyWith({
    TextStyle? labelTextStyle,
    Color? labelColor,
    double? spacing,
    EdgeInsetsGeometry? padding,
    Color? connectorColor,
    double? connectorStrokeWidth,
  }) {
    final _this = (this as StreamMessageRepliesThemeData);

    return StreamMessageRepliesThemeData(
      labelTextStyle: labelTextStyle ?? _this.labelTextStyle,
      labelColor: labelColor ?? _this.labelColor,
      spacing: spacing ?? _this.spacing,
      padding: padding ?? _this.padding,
      connectorColor: connectorColor ?? _this.connectorColor,
      connectorStrokeWidth: connectorStrokeWidth ?? _this.connectorStrokeWidth,
    );
  }

  StreamMessageRepliesThemeData merge(StreamMessageRepliesThemeData? other) {
    final _this = (this as StreamMessageRepliesThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      labelTextStyle:
          _this.labelTextStyle?.merge(other.labelTextStyle) ??
          other.labelTextStyle,
      labelColor: other.labelColor,
      spacing: other.spacing,
      padding: other.padding,
      connectorColor: other.connectorColor,
      connectorStrokeWidth: other.connectorStrokeWidth,
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

    final _this = (this as StreamMessageRepliesThemeData);
    final _other = (other as StreamMessageRepliesThemeData);

    return _other.labelTextStyle == _this.labelTextStyle &&
        _other.labelColor == _this.labelColor &&
        _other.spacing == _this.spacing &&
        _other.padding == _this.padding &&
        _other.connectorColor == _this.connectorColor &&
        _other.connectorStrokeWidth == _this.connectorStrokeWidth;
  }

  @override
  int get hashCode {
    final _this = (this as StreamMessageRepliesThemeData);

    return Object.hash(
      runtimeType,
      _this.labelTextStyle,
      _this.labelColor,
      _this.spacing,
      _this.padding,
      _this.connectorColor,
      _this.connectorStrokeWidth,
    );
  }
}
