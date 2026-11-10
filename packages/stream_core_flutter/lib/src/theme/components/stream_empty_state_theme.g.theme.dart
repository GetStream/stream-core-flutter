// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_empty_state_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamEmptyStateThemeData {
  bool get canMerge => true;

  static StreamEmptyStateThemeData? lerp(
    StreamEmptyStateThemeData? a,
    StreamEmptyStateThemeData? b,
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

    return StreamEmptyStateThemeData(
      iconSize: lerpDouble$(a.iconSize, b.iconSize, t),
      iconColor: Color.lerp(a.iconColor, b.iconColor, t),
      titleTextStyle: TextStyle.lerp(a.titleTextStyle, b.titleTextStyle, t),
      descriptionTextStyle: TextStyle.lerp(
        a.descriptionTextStyle,
        b.descriptionTextStyle,
        t,
      ),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      spacing: lerpDouble$(a.spacing, b.spacing, t),
      textSpacing: lerpDouble$(a.textSpacing, b.textSpacing, t),
      maxTextWidth: lerpDouble$(a.maxTextWidth, b.maxTextWidth, t),
    );
  }

  StreamEmptyStateThemeData copyWith({
    double? iconSize,
    Color? iconColor,
    TextStyle? titleTextStyle,
    TextStyle? descriptionTextStyle,
    EdgeInsetsGeometry? padding,
    double? spacing,
    double? textSpacing,
    double? maxTextWidth,
  }) {
    final _this = (this as StreamEmptyStateThemeData);

    return StreamEmptyStateThemeData(
      iconSize: iconSize ?? _this.iconSize,
      iconColor: iconColor ?? _this.iconColor,
      titleTextStyle: titleTextStyle ?? _this.titleTextStyle,
      descriptionTextStyle: descriptionTextStyle ?? _this.descriptionTextStyle,
      padding: padding ?? _this.padding,
      spacing: spacing ?? _this.spacing,
      textSpacing: textSpacing ?? _this.textSpacing,
      maxTextWidth: maxTextWidth ?? _this.maxTextWidth,
    );
  }

  StreamEmptyStateThemeData merge(StreamEmptyStateThemeData? other) {
    final _this = (this as StreamEmptyStateThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      iconSize: other.iconSize,
      iconColor: other.iconColor,
      titleTextStyle:
          _this.titleTextStyle?.merge(other.titleTextStyle) ??
          other.titleTextStyle,
      descriptionTextStyle:
          _this.descriptionTextStyle?.merge(other.descriptionTextStyle) ??
          other.descriptionTextStyle,
      padding: other.padding,
      spacing: other.spacing,
      textSpacing: other.textSpacing,
      maxTextWidth: other.maxTextWidth,
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

    final _this = (this as StreamEmptyStateThemeData);
    final _other = (other as StreamEmptyStateThemeData);

    return _other.iconSize == _this.iconSize &&
        _other.iconColor == _this.iconColor &&
        _other.titleTextStyle == _this.titleTextStyle &&
        _other.descriptionTextStyle == _this.descriptionTextStyle &&
        _other.padding == _this.padding &&
        _other.spacing == _this.spacing &&
        _other.textSpacing == _this.textSpacing &&
        _other.maxTextWidth == _this.maxTextWidth;
  }

  @override
  int get hashCode {
    final _this = (this as StreamEmptyStateThemeData);

    return Object.hash(
      runtimeType,
      _this.iconSize,
      _this.iconColor,
      _this.titleTextStyle,
      _this.descriptionTextStyle,
      _this.padding,
      _this.spacing,
      _this.textSpacing,
      _this.maxTextWidth,
    );
  }
}
