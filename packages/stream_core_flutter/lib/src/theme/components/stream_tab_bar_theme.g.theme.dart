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
      minHeight: lerpDouble$(a.minHeight, b.minHeight, t),
      indicatorWeight: lerpDouble$(a.indicatorWeight, b.indicatorWeight, t),
      indicatorColor: WidgetStateProperty.lerp<Color?>(
        a.indicatorColor,
        b.indicatorColor,
        t,
        Color.lerp,
      ),
      dividerHeight: lerpDouble$(a.dividerHeight, b.dividerHeight, t),
      dividerColor: Color.lerp(a.dividerColor, b.dividerColor, t),
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
      overlaySide: t < 0.5 ? a.overlaySide : b.overlaySide,
      labelPadding: EdgeInsetsGeometry.lerp(a.labelPadding, b.labelPadding, t),
      spacing: lerpDouble$(a.spacing, b.spacing, t),
    );
  }

  StreamTabBarThemeData copyWith({
    double? minHeight,
    double? indicatorWeight,
    WidgetStateProperty<Color?>? indicatorColor,
    double? dividerHeight,
    Color? dividerColor,
    TextStyle? labelStyle,
    WidgetStateProperty<Color?>? foregroundColor,
    WidgetStateProperty<Color?>? overlayColor,
    WidgetStateProperty<BorderSide?>? overlaySide,
    EdgeInsetsGeometry? labelPadding,
    double? spacing,
  }) {
    final _this = (this as StreamTabBarThemeData);

    return StreamTabBarThemeData(
      minHeight: minHeight ?? _this.minHeight,
      indicatorWeight: indicatorWeight ?? _this.indicatorWeight,
      indicatorColor: indicatorColor ?? _this.indicatorColor,
      dividerHeight: dividerHeight ?? _this.dividerHeight,
      dividerColor: dividerColor ?? _this.dividerColor,
      labelStyle: labelStyle ?? _this.labelStyle,
      foregroundColor: foregroundColor ?? _this.foregroundColor,
      overlayColor: overlayColor ?? _this.overlayColor,
      overlaySide: overlaySide ?? _this.overlaySide,
      labelPadding: labelPadding ?? _this.labelPadding,
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
      minHeight: other.minHeight,
      indicatorWeight: other.indicatorWeight,
      indicatorColor: other.indicatorColor,
      dividerHeight: other.dividerHeight,
      dividerColor: other.dividerColor,
      labelStyle: _this.labelStyle?.merge(other.labelStyle) ?? other.labelStyle,
      foregroundColor: other.foregroundColor,
      overlayColor: other.overlayColor,
      overlaySide: other.overlaySide,
      labelPadding: other.labelPadding,
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

    return _other.minHeight == _this.minHeight &&
        _other.indicatorWeight == _this.indicatorWeight &&
        _other.indicatorColor == _this.indicatorColor &&
        _other.dividerHeight == _this.dividerHeight &&
        _other.dividerColor == _this.dividerColor &&
        _other.labelStyle == _this.labelStyle &&
        _other.foregroundColor == _this.foregroundColor &&
        _other.overlayColor == _this.overlayColor &&
        _other.overlaySide == _this.overlaySide &&
        _other.labelPadding == _this.labelPadding &&
        _other.spacing == _this.spacing;
  }

  @override
  int get hashCode {
    final _this = (this as StreamTabBarThemeData);

    return Object.hash(
      runtimeType,
      _this.minHeight,
      _this.indicatorWeight,
      _this.indicatorColor,
      _this.dividerHeight,
      _this.dividerColor,
      _this.labelStyle,
      _this.foregroundColor,
      _this.overlayColor,
      _this.overlaySide,
      _this.labelPadding,
      _this.spacing,
    );
  }
}
