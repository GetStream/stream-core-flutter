// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_tab_bar_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamTabBarThemeData {
  bool get canMerge => true;

  static StreamTabBarThemeData? lerp(
    StreamTabBarThemeData? a,
    StreamTabBarThemeData? b,
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

    return StreamTabBarThemeData(
      height: lerpDouble$(a.height, b.height, t),
      indicatorWeight: lerpDouble$(a.indicatorWeight, b.indicatorWeight, t),
      indicatorColor: WidgetStateProperty.lerp<Color?>(
        a.indicatorColor,
        b.indicatorColor,
        t,
        Color.lerp,
      ),
      labelStyle: TextStyle.lerp(a.labelStyle, b.labelStyle, t),
      foregroundColor: WidgetStateProperty.lerp<Color?>(
        a.foregroundColor,
        b.foregroundColor,
        t,
        Color.lerp,
      ),
      overlayColor: WidgetStateProperty.lerp<Color?>(
        a.overlayColor,
        b.overlayColor,
        t,
        Color.lerp,
      ),
      tabPadding: EdgeInsetsGeometry.lerp(a.tabPadding, b.tabPadding, t),
      spacing: lerpDouble$(a.spacing, b.spacing, t),
    );
  }

  StreamTabBarThemeData copyWith({
    double? height,
    double? indicatorWeight,
    WidgetStateProperty<Color?>? indicatorColor,
    TextStyle? labelStyle,
    WidgetStateProperty<Color?>? foregroundColor,
    WidgetStateProperty<Color?>? overlayColor,
    EdgeInsetsGeometry? tabPadding,
    double? spacing,
  }) {
    final _this = (this as StreamTabBarThemeData);

    return StreamTabBarThemeData(
      height: height ?? _this.height,
      indicatorWeight: indicatorWeight ?? _this.indicatorWeight,
      indicatorColor: indicatorColor ?? _this.indicatorColor,
      labelStyle: labelStyle ?? _this.labelStyle,
      foregroundColor: foregroundColor ?? _this.foregroundColor,
      overlayColor: overlayColor ?? _this.overlayColor,
      tabPadding: tabPadding ?? _this.tabPadding,
      spacing: spacing ?? _this.spacing,
    );
  }

  StreamTabBarThemeData merge(StreamTabBarThemeData? other) {
    final _this = (this as StreamTabBarThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      height: other.height,
      indicatorWeight: other.indicatorWeight,
      indicatorColor: other.indicatorColor,
      labelStyle: _this.labelStyle?.merge(other.labelStyle) ?? other.labelStyle,
      foregroundColor: other.foregroundColor,
      overlayColor: other.overlayColor,
      tabPadding: other.tabPadding,
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

    final _this = (this as StreamTabBarThemeData);
    final _other = (other as StreamTabBarThemeData);

    return _other.height == _this.height &&
        _other.indicatorWeight == _this.indicatorWeight &&
        _other.indicatorColor == _this.indicatorColor &&
        _other.labelStyle == _this.labelStyle &&
        _other.foregroundColor == _this.foregroundColor &&
        _other.overlayColor == _this.overlayColor &&
        _other.tabPadding == _this.tabPadding &&
        _other.spacing == _this.spacing;
  }

  @override
  int get hashCode {
    final _this = (this as StreamTabBarThemeData);

    return Object.hash(
      runtimeType,
      _this.height,
      _this.indicatorWeight,
      _this.indicatorColor,
      _this.labelStyle,
      _this.foregroundColor,
      _this.overlayColor,
      _this.tabPadding,
      _this.spacing,
    );
  }
}
