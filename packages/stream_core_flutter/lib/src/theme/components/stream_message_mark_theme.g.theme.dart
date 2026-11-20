// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_message_mark_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamMessageMarkStyle {
  bool get canMerge => true;

  static StreamMessageMarkStyle? lerp(
    StreamMessageMarkStyle? a,
    StreamMessageMarkStyle? b,
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

    return StreamMessageMarkStyle(
      textStyle: StreamMessageLayoutProperty.lerp<TextStyle?>(
        a.textStyle,
        b.textStyle,
        t,
        TextStyle.lerp,
      ),
      color: StreamMessageLayoutProperty.lerp<Color?>(
        a.color,
        b.color,
        t,
        Color.lerp,
      ),
      highlightedColor: StreamMessageLayoutProperty.lerp<Color?>(
        a.highlightedColor,
        b.highlightedColor,
        t,
        Color.lerp,
      ),
      separatorColor: StreamMessageLayoutProperty.lerp<Color?>(
        a.separatorColor,
        b.separatorColor,
        t,
        Color.lerp,
      ),
      spacing: StreamMessageLayoutProperty.lerp<double?>(
        a.spacing,
        b.spacing,
        t,
        lerpDouble$,
      ),
    );
  }

  StreamMessageMarkStyle copyWith({
    StreamMessageLayoutProperty<TextStyle?>? textStyle,
    StreamMessageLayoutProperty<Color?>? color,
    StreamMessageLayoutProperty<Color?>? highlightedColor,
    StreamMessageLayoutProperty<Color?>? separatorColor,
    StreamMessageLayoutProperty<double?>? spacing,
  }) {
    final _this = (this as StreamMessageMarkStyle);

    return StreamMessageMarkStyle(
      textStyle: textStyle ?? _this.textStyle,
      color: color ?? _this.color,
      highlightedColor: highlightedColor ?? _this.highlightedColor,
      separatorColor: separatorColor ?? _this.separatorColor,
      spacing: spacing ?? _this.spacing,
    );
  }

  StreamMessageMarkStyle merge(StreamMessageMarkStyle? other) {
    final _this = (this as StreamMessageMarkStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      textStyle: other.textStyle,
      color: other.color,
      highlightedColor: other.highlightedColor,
      separatorColor: other.separatorColor,
      spacing: other.spacing,
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

    final _this = (this as StreamMessageMarkStyle);
    final _other = (other as StreamMessageMarkStyle);

    return _other.textStyle == _this.textStyle &&
        _other.color == _this.color &&
        _other.highlightedColor == _this.highlightedColor &&
        _other.separatorColor == _this.separatorColor &&
        _other.spacing == _this.spacing;
  }

  @override
  int get hashCode {
    final _this = (this as StreamMessageMarkStyle);

    return Object.hash(
      runtimeType,
      _this.textStyle,
      _this.color,
      _this.highlightedColor,
      _this.separatorColor,
      _this.spacing,
    );
  }
}
