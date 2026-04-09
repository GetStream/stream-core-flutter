// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_list_tile_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamListTileThemeData {
  bool get canMerge => true;

  static StreamListTileThemeData? lerp(
    StreamListTileThemeData? a,
    StreamListTileThemeData? b,
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

    return StreamListTileThemeData(
      titleTextStyle: TextStyle.lerp(a.titleTextStyle, b.titleTextStyle, t),
      subtitleTextStyle: TextStyle.lerp(
        a.subtitleTextStyle,
        b.subtitleTextStyle,
        t,
      ),
      descriptionTextStyle: TextStyle.lerp(
        a.descriptionTextStyle,
        b.descriptionTextStyle,
        t,
      ),
      titleColor: WidgetStateProperty.lerp<Color?>(
        a.titleColor,
        b.titleColor,
        t,
        Color.lerp,
      ),
      subtitleColor: WidgetStateProperty.lerp<Color?>(
        a.subtitleColor,
        b.subtitleColor,
        t,
        Color.lerp,
      ),
      descriptionColor: WidgetStateProperty.lerp<Color?>(
        a.descriptionColor,
        b.descriptionColor,
        t,
        Color.lerp,
      ),
      iconColor: WidgetStateProperty.lerp<Color?>(
        a.iconColor,
        b.iconColor,
        t,
        Color.lerp,
      ),
      backgroundColor: WidgetStateProperty.lerp<Color?>(
        a.backgroundColor,
        b.backgroundColor,
        t,
        Color.lerp,
      ),
      shape: ShapeBorder.lerp(a.shape, b.shape, t),
      contentPadding: EdgeInsetsGeometry.lerp(
        a.contentPadding,
        b.contentPadding,
        t,
      ),
      minTileHeight: lerpDouble$(a.minTileHeight, b.minTileHeight, t),
      overlayColor: WidgetStateProperty.lerp<Color?>(
        a.overlayColor,
        b.overlayColor,
        t,
        Color.lerp,
      ),
    );
  }

  StreamListTileThemeData copyWith({
    TextStyle? titleTextStyle,
    TextStyle? subtitleTextStyle,
    TextStyle? descriptionTextStyle,
    WidgetStateProperty<Color?>? titleColor,
    WidgetStateProperty<Color?>? subtitleColor,
    WidgetStateProperty<Color?>? descriptionColor,
    WidgetStateProperty<Color?>? iconColor,
    WidgetStateProperty<Color?>? backgroundColor,
    ShapeBorder? shape,
    EdgeInsetsGeometry? contentPadding,
    double? minTileHeight,
    WidgetStateProperty<Color?>? overlayColor,
  }) {
    final _this = (this as StreamListTileThemeData);

    return StreamListTileThemeData(
      titleTextStyle: titleTextStyle ?? _this.titleTextStyle,
      subtitleTextStyle: subtitleTextStyle ?? _this.subtitleTextStyle,
      descriptionTextStyle: descriptionTextStyle ?? _this.descriptionTextStyle,
      titleColor: titleColor ?? _this.titleColor,
      subtitleColor: subtitleColor ?? _this.subtitleColor,
      descriptionColor: descriptionColor ?? _this.descriptionColor,
      iconColor: iconColor ?? _this.iconColor,
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      shape: shape ?? _this.shape,
      contentPadding: contentPadding ?? _this.contentPadding,
      minTileHeight: minTileHeight ?? _this.minTileHeight,
      overlayColor: overlayColor ?? _this.overlayColor,
    );
  }

  StreamListTileThemeData merge(StreamListTileThemeData? other) {
    final _this = (this as StreamListTileThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      titleTextStyle:
          _this.titleTextStyle?.merge(other.titleTextStyle) ??
          other.titleTextStyle,
      subtitleTextStyle:
          _this.subtitleTextStyle?.merge(other.subtitleTextStyle) ??
          other.subtitleTextStyle,
      descriptionTextStyle:
          _this.descriptionTextStyle?.merge(other.descriptionTextStyle) ??
          other.descriptionTextStyle,
      titleColor: other.titleColor,
      subtitleColor: other.subtitleColor,
      descriptionColor: other.descriptionColor,
      iconColor: other.iconColor,
      backgroundColor: other.backgroundColor,
      shape: other.shape,
      contentPadding: other.contentPadding,
      minTileHeight: other.minTileHeight,
      overlayColor: other.overlayColor,
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

    final _this = (this as StreamListTileThemeData);
    final _other = (other as StreamListTileThemeData);

    return _other.titleTextStyle == _this.titleTextStyle &&
        _other.subtitleTextStyle == _this.subtitleTextStyle &&
        _other.descriptionTextStyle == _this.descriptionTextStyle &&
        _other.titleColor == _this.titleColor &&
        _other.subtitleColor == _this.subtitleColor &&
        _other.descriptionColor == _this.descriptionColor &&
        _other.iconColor == _this.iconColor &&
        _other.backgroundColor == _this.backgroundColor &&
        _other.shape == _this.shape &&
        _other.contentPadding == _this.contentPadding &&
        _other.minTileHeight == _this.minTileHeight &&
        _other.overlayColor == _this.overlayColor;
  }

  @override
  int get hashCode {
    final _this = (this as StreamListTileThemeData);

    return Object.hash(
      runtimeType,
      _this.titleTextStyle,
      _this.subtitleTextStyle,
      _this.descriptionTextStyle,
      _this.titleColor,
      _this.subtitleColor,
      _this.descriptionColor,
      _this.iconColor,
      _this.backgroundColor,
      _this.shape,
      _this.contentPadding,
      _this.minTileHeight,
      _this.overlayColor,
    );
  }
}
