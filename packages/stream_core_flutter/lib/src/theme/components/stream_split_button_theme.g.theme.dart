// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_split_button_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamSplitButtonThemeData {
  bool get canMerge => true;

  static StreamSplitButtonThemeData? lerp(
    StreamSplitButtonThemeData? a,
    StreamSplitButtonThemeData? b,
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

    return StreamSplitButtonThemeData(
      style: StreamSplitButtonStyle.lerp(a.style, b.style, t),
    );
  }

  StreamSplitButtonThemeData copyWith({StreamSplitButtonStyle? style}) {
    final _this = (this as StreamSplitButtonThemeData);

    return StreamSplitButtonThemeData(style: style ?? _this.style);
  }

  StreamSplitButtonThemeData merge(StreamSplitButtonThemeData? other) {
    final _this = (this as StreamSplitButtonThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(style: _this.style?.merge(other.style) ?? other.style);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other.runtimeType != runtimeType) {
      return false;
    }

    final _this = (this as StreamSplitButtonThemeData);
    final _other = (other as StreamSplitButtonThemeData);

    return _other.style == _this.style;
  }

  @override
  int get hashCode {
    final _this = (this as StreamSplitButtonThemeData);

    return Object.hash(runtimeType, _this.style);
  }
}

mixin _$StreamSplitButtonStyle {
  bool get canMerge => true;

  static StreamSplitButtonStyle? lerp(
    StreamSplitButtonStyle? a,
    StreamSplitButtonStyle? b,
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

    return StreamSplitButtonStyle(
      buttonStyle: StreamButtonThemeStyle.lerp(a.buttonStyle, b.buttonStyle, t),
      separatorColor: WidgetStateProperty.lerp<Color?>(
        a.separatorColor,
        b.separatorColor,
        t,
        Color.lerp,
      ),
      separatorThickness: lerpDouble$(
        a.separatorThickness,
        b.separatorThickness,
        t,
      ),
      separatorHeight: lerpDouble$(a.separatorHeight, b.separatorHeight, t),
    );
  }

  StreamSplitButtonStyle copyWith({
    StreamButtonThemeStyle? buttonStyle,
    WidgetStateProperty<Color?>? separatorColor,
    double? separatorThickness,
    double? separatorHeight,
  }) {
    final _this = (this as StreamSplitButtonStyle);

    return StreamSplitButtonStyle(
      buttonStyle: buttonStyle ?? _this.buttonStyle,
      separatorColor: separatorColor ?? _this.separatorColor,
      separatorThickness: separatorThickness ?? _this.separatorThickness,
      separatorHeight: separatorHeight ?? _this.separatorHeight,
    );
  }

  StreamSplitButtonStyle merge(StreamSplitButtonStyle? other) {
    final _this = (this as StreamSplitButtonStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      buttonStyle:
          _this.buttonStyle?.merge(other.buttonStyle) ?? other.buttonStyle,
      separatorColor: other.separatorColor,
      separatorThickness: other.separatorThickness,
      separatorHeight: other.separatorHeight,
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

    final _this = (this as StreamSplitButtonStyle);
    final _other = (other as StreamSplitButtonStyle);

    return _other.buttonStyle == _this.buttonStyle &&
        _other.separatorColor == _this.separatorColor &&
        _other.separatorThickness == _this.separatorThickness &&
        _other.separatorHeight == _this.separatorHeight;
  }

  @override
  int get hashCode {
    final _this = (this as StreamSplitButtonStyle);

    return Object.hash(
      runtimeType,
      _this.buttonStyle,
      _this.separatorColor,
      _this.separatorThickness,
      _this.separatorHeight,
    );
  }
}
