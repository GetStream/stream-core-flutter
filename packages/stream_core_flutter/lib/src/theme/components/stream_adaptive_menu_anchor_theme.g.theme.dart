// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_adaptive_menu_anchor_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamAdaptiveMenuAnchorThemeData {
  bool get canMerge => true;

  static StreamAdaptiveMenuAnchorThemeData? lerp(
    StreamAdaptiveMenuAnchorThemeData? a,
    StreamAdaptiveMenuAnchorThemeData? b,
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

    return StreamAdaptiveMenuAnchorThemeData(
      style: StreamAdaptiveMenuAnchorStyle.lerp(a.style, b.style, t),
      useSheet: t < 0.5 ? a.useSheet : b.useSheet,
    );
  }

  StreamAdaptiveMenuAnchorThemeData copyWith({
    StreamAdaptiveMenuAnchorStyle? style,
    bool? useSheet,
  }) {
    final _this = (this as StreamAdaptiveMenuAnchorThemeData);

    return StreamAdaptiveMenuAnchorThemeData(
      style: style ?? _this.style,
      useSheet: useSheet ?? _this.useSheet,
    );
  }

  StreamAdaptiveMenuAnchorThemeData merge(
    StreamAdaptiveMenuAnchorThemeData? other,
  ) {
    final _this = (this as StreamAdaptiveMenuAnchorThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      style: _this.style?.merge(other.style) ?? other.style,
      useSheet: other.useSheet,
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

    final _this = (this as StreamAdaptiveMenuAnchorThemeData);
    final _other = (other as StreamAdaptiveMenuAnchorThemeData);

    return _other.style == _this.style && _other.useSheet == _this.useSheet;
  }

  @override
  int get hashCode {
    final _this = (this as StreamAdaptiveMenuAnchorThemeData);

    return Object.hash(runtimeType, _this.style, _this.useSheet);
  }
}

mixin _$StreamAdaptiveMenuAnchorStyle {
  bool get canMerge => true;

  static StreamAdaptiveMenuAnchorStyle? lerp(
    StreamAdaptiveMenuAnchorStyle? a,
    StreamAdaptiveMenuAnchorStyle? b,
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

    return StreamAdaptiveMenuAnchorStyle(
      menuItemStyle: StreamContextMenuActionStyle.lerp(
        a.menuItemStyle,
        b.menuItemStyle,
        t,
      ),
      menuSelectedItemColor: Color.lerp(
        a.menuSelectedItemColor,
        b.menuSelectedItemColor,
        t,
      ),
      menuHeadingStyle: StreamContextMenuHeadingThemeData.lerp(
        a.menuHeadingStyle,
        b.menuHeadingStyle,
        t,
      ),
      menuGap: lerpDouble$(a.menuGap, b.menuGap, t),
      sheetTileStyle: StreamListTileThemeData.lerp(
        a.sheetTileStyle,
        b.sheetTileStyle,
        t,
      ),
      sheetHeadingStyle: StreamContextMenuHeadingThemeData.lerp(
        a.sheetHeadingStyle,
        b.sheetHeadingStyle,
        t,
      ),
      sheetPadding: EdgeInsetsGeometry.lerp(a.sheetPadding, b.sheetPadding, t),
    );
  }

  StreamAdaptiveMenuAnchorStyle copyWith({
    StreamContextMenuActionStyle? menuItemStyle,
    Color? menuSelectedItemColor,
    StreamContextMenuHeadingThemeData? menuHeadingStyle,
    double? menuGap,
    StreamListTileThemeData? sheetTileStyle,
    StreamContextMenuHeadingThemeData? sheetHeadingStyle,
    EdgeInsetsGeometry? sheetPadding,
  }) {
    final _this = (this as StreamAdaptiveMenuAnchorStyle);

    return StreamAdaptiveMenuAnchorStyle(
      menuItemStyle: menuItemStyle ?? _this.menuItemStyle,
      menuSelectedItemColor:
          menuSelectedItemColor ?? _this.menuSelectedItemColor,
      menuHeadingStyle: menuHeadingStyle ?? _this.menuHeadingStyle,
      menuGap: menuGap ?? _this.menuGap,
      sheetTileStyle: sheetTileStyle ?? _this.sheetTileStyle,
      sheetHeadingStyle: sheetHeadingStyle ?? _this.sheetHeadingStyle,
      sheetPadding: sheetPadding ?? _this.sheetPadding,
    );
  }

  StreamAdaptiveMenuAnchorStyle merge(StreamAdaptiveMenuAnchorStyle? other) {
    final _this = (this as StreamAdaptiveMenuAnchorStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      menuItemStyle:
          _this.menuItemStyle?.merge(other.menuItemStyle) ??
          other.menuItemStyle,
      menuSelectedItemColor: other.menuSelectedItemColor,
      menuHeadingStyle:
          _this.menuHeadingStyle?.merge(other.menuHeadingStyle) ??
          other.menuHeadingStyle,
      menuGap: other.menuGap,
      sheetTileStyle:
          _this.sheetTileStyle?.merge(other.sheetTileStyle) ??
          other.sheetTileStyle,
      sheetHeadingStyle:
          _this.sheetHeadingStyle?.merge(other.sheetHeadingStyle) ??
          other.sheetHeadingStyle,
      sheetPadding: other.sheetPadding,
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

    final _this = (this as StreamAdaptiveMenuAnchorStyle);
    final _other = (other as StreamAdaptiveMenuAnchorStyle);

    return _other.menuItemStyle == _this.menuItemStyle &&
        _other.menuSelectedItemColor == _this.menuSelectedItemColor &&
        _other.menuHeadingStyle == _this.menuHeadingStyle &&
        _other.menuGap == _this.menuGap &&
        _other.sheetTileStyle == _this.sheetTileStyle &&
        _other.sheetHeadingStyle == _this.sheetHeadingStyle &&
        _other.sheetPadding == _this.sheetPadding;
  }

  @override
  int get hashCode {
    final _this = (this as StreamAdaptiveMenuAnchorStyle);

    return Object.hash(
      runtimeType,
      _this.menuItemStyle,
      _this.menuSelectedItemColor,
      _this.menuHeadingStyle,
      _this.menuGap,
      _this.sheetTileStyle,
      _this.sheetHeadingStyle,
      _this.sheetPadding,
    );
  }
}
