// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_bottom_nav_bar_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamBottomNavBarThemeData {
  bool get canMerge => true;

  static StreamBottomNavBarThemeData? lerp(
    StreamBottomNavBarThemeData? a,
    StreamBottomNavBarThemeData? b,
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

    return StreamBottomNavBarThemeData(
      style: StreamBottomNavBarStyle.lerp(a.style, b.style, t),
    );
  }

  StreamBottomNavBarThemeData copyWith({StreamBottomNavBarStyle? style}) {
    final _this = (this as StreamBottomNavBarThemeData);

    return StreamBottomNavBarThemeData(style: style ?? _this.style);
  }

  StreamBottomNavBarThemeData merge(StreamBottomNavBarThemeData? other) {
    final _this = (this as StreamBottomNavBarThemeData);

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

    final _this = (this as StreamBottomNavBarThemeData);
    final _other = (other as StreamBottomNavBarThemeData);

    return _other.style == _this.style;
  }

  @override
  int get hashCode {
    final _this = (this as StreamBottomNavBarThemeData);

    return Object.hash(runtimeType, _this.style);
  }
}

mixin _$StreamBottomNavBarStyle {
  bool get canMerge => true;

  static StreamBottomNavBarStyle? lerp(
    StreamBottomNavBarStyle? a,
    StreamBottomNavBarStyle? b,
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

    return StreamBottomNavBarStyle(
      behavior: t < 0.5 ? a.behavior : b.behavior,
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      floatingBackgroundColor: Color.lerp(
        a.floatingBackgroundColor,
        b.floatingBackgroundColor,
        t,
      ),
      selectedItemColor: Color.lerp(
        a.selectedItemColor,
        b.selectedItemColor,
        t,
      ),
      unselectedItemColor: Color.lerp(
        a.unselectedItemColor,
        b.unselectedItemColor,
        t,
      ),
      iconSize: lerpDouble$(a.iconSize, b.iconSize, t),
      selectedLabelStyle: TextStyle.lerp(
        a.selectedLabelStyle,
        b.selectedLabelStyle,
        t,
      ),
      unselectedLabelStyle: TextStyle.lerp(
        a.unselectedLabelStyle,
        b.unselectedLabelStyle,
        t,
      ),
      borderColor: Color.lerp(a.borderColor, b.borderColor, t),
      borderRadius: BorderRadiusGeometry.lerp(
        a.borderRadius,
        b.borderRadius,
        t,
      ),
    );
  }

  StreamBottomNavBarStyle copyWith({
    StreamBottomNavBarBehavior? behavior,
    Color? backgroundColor,
    Color? floatingBackgroundColor,
    Color? selectedItemColor,
    Color? unselectedItemColor,
    double? iconSize,
    TextStyle? selectedLabelStyle,
    TextStyle? unselectedLabelStyle,
    Color? borderColor,
    BorderRadiusGeometry? borderRadius,
  }) {
    final _this = (this as StreamBottomNavBarStyle);

    return StreamBottomNavBarStyle(
      behavior: behavior ?? _this.behavior,
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      floatingBackgroundColor:
          floatingBackgroundColor ?? _this.floatingBackgroundColor,
      selectedItemColor: selectedItemColor ?? _this.selectedItemColor,
      unselectedItemColor: unselectedItemColor ?? _this.unselectedItemColor,
      iconSize: iconSize ?? _this.iconSize,
      selectedLabelStyle: selectedLabelStyle ?? _this.selectedLabelStyle,
      unselectedLabelStyle: unselectedLabelStyle ?? _this.unselectedLabelStyle,
      borderColor: borderColor ?? _this.borderColor,
      borderRadius: borderRadius ?? _this.borderRadius,
    );
  }

  StreamBottomNavBarStyle merge(StreamBottomNavBarStyle? other) {
    final _this = (this as StreamBottomNavBarStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      behavior: other.behavior,
      backgroundColor: other.backgroundColor,
      floatingBackgroundColor: other.floatingBackgroundColor,
      selectedItemColor: other.selectedItemColor,
      unselectedItemColor: other.unselectedItemColor,
      iconSize: other.iconSize,
      selectedLabelStyle:
          _this.selectedLabelStyle?.merge(other.selectedLabelStyle) ??
          other.selectedLabelStyle,
      unselectedLabelStyle:
          _this.unselectedLabelStyle?.merge(other.unselectedLabelStyle) ??
          other.unselectedLabelStyle,
      borderColor: other.borderColor,
      borderRadius: other.borderRadius,
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

    final _this = (this as StreamBottomNavBarStyle);
    final _other = (other as StreamBottomNavBarStyle);

    return _other.behavior == _this.behavior &&
        _other.backgroundColor == _this.backgroundColor &&
        _other.floatingBackgroundColor == _this.floatingBackgroundColor &&
        _other.selectedItemColor == _this.selectedItemColor &&
        _other.unselectedItemColor == _this.unselectedItemColor &&
        _other.iconSize == _this.iconSize &&
        _other.selectedLabelStyle == _this.selectedLabelStyle &&
        _other.unselectedLabelStyle == _this.unselectedLabelStyle &&
        _other.borderColor == _this.borderColor &&
        _other.borderRadius == _this.borderRadius;
  }

  @override
  int get hashCode {
    final _this = (this as StreamBottomNavBarStyle);

    return Object.hash(
      runtimeType,
      _this.behavior,
      _this.backgroundColor,
      _this.floatingBackgroundColor,
      _this.selectedItemColor,
      _this.unselectedItemColor,
      _this.iconSize,
      _this.selectedLabelStyle,
      _this.unselectedLabelStyle,
      _this.borderColor,
      _this.borderRadius,
    );
  }
}
