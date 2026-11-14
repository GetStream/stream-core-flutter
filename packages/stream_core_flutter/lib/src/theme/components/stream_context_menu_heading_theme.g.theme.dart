// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_context_menu_heading_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamContextMenuHeadingThemeData {
  bool get canMerge => true;

  static StreamContextMenuHeadingThemeData? lerp(
    StreamContextMenuHeadingThemeData? a,
    StreamContextMenuHeadingThemeData? b,
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

    return StreamContextMenuHeadingThemeData(
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t),
      foregroundColor: Color.lerp(a.foregroundColor, b.foregroundColor, t),
      iconSize: lerpDouble$(a.iconSize, b.iconSize, t),
      overlayColor: WidgetStateProperty.lerp<Color?>(
        a.overlayColor,
        b.overlayColor,
        t,
        Color.lerp,
      ),
      minimumSize: Size.lerp(a.minimumSize, b.minimumSize, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      spacing: lerpDouble$(a.spacing, b.spacing, t),
      shape: OutlinedBorder.lerp(a.shape, b.shape, t),
    );
  }

  StreamContextMenuHeadingThemeData copyWith({
    TextStyle? textStyle,
    Color? foregroundColor,
    double? iconSize,
    WidgetStateProperty<Color?>? overlayColor,
    Size? minimumSize,
    EdgeInsetsGeometry? padding,
    double? spacing,
    OutlinedBorder? shape,
  }) {
    final _this = (this as StreamContextMenuHeadingThemeData);

    return StreamContextMenuHeadingThemeData(
      textStyle: textStyle ?? _this.textStyle,
      foregroundColor: foregroundColor ?? _this.foregroundColor,
      iconSize: iconSize ?? _this.iconSize,
      overlayColor: overlayColor ?? _this.overlayColor,
      minimumSize: minimumSize ?? _this.minimumSize,
      padding: padding ?? _this.padding,
      spacing: spacing ?? _this.spacing,
      shape: shape ?? _this.shape,
    );
  }

  StreamContextMenuHeadingThemeData merge(
    StreamContextMenuHeadingThemeData? other,
  ) {
    final _this = (this as StreamContextMenuHeadingThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      textStyle: _this.textStyle?.merge(other.textStyle) ?? other.textStyle,
      foregroundColor: other.foregroundColor,
      iconSize: other.iconSize,
      overlayColor: other.overlayColor,
      minimumSize: other.minimumSize,
      padding: other.padding,
      spacing: other.spacing,
      shape: other.shape,
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

    final _this = (this as StreamContextMenuHeadingThemeData);
    final _other = (other as StreamContextMenuHeadingThemeData);

    return _other.textStyle == _this.textStyle &&
        _other.foregroundColor == _this.foregroundColor &&
        _other.iconSize == _this.iconSize &&
        _other.overlayColor == _this.overlayColor &&
        _other.minimumSize == _this.minimumSize &&
        _other.padding == _this.padding &&
        _other.spacing == _this.spacing &&
        _other.shape == _this.shape;
  }

  @override
  int get hashCode {
    final _this = (this as StreamContextMenuHeadingThemeData);

    return Object.hash(
      runtimeType,
      _this.textStyle,
      _this.foregroundColor,
      _this.iconSize,
      _this.overlayColor,
      _this.minimumSize,
      _this.padding,
      _this.spacing,
      _this.shape,
    );
  }
}
