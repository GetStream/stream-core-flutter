// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_context_menu_action_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamContextMenuActionThemeData {
  bool get canMerge => true;

  static StreamContextMenuActionThemeData? lerp(
    StreamContextMenuActionThemeData? a,
    StreamContextMenuActionThemeData? b,
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

    return StreamContextMenuActionThemeData(
      style: StreamContextMenuActionStyle.lerp(a.style, b.style, t),
    );
  }

  StreamContextMenuActionThemeData copyWith({
    StreamContextMenuActionStyle? style,
  }) {
    final _this = (this as StreamContextMenuActionThemeData);

    return StreamContextMenuActionThemeData(style: style ?? _this.style);
  }

  StreamContextMenuActionThemeData merge(
    StreamContextMenuActionThemeData? other,
  ) {
    final _this = (this as StreamContextMenuActionThemeData);

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

    final _this = (this as StreamContextMenuActionThemeData);
    final _other = (other as StreamContextMenuActionThemeData);

    return _other.style == _this.style;
  }

  @override
  int get hashCode {
    final _this = (this as StreamContextMenuActionThemeData);

    return Object.hash(runtimeType, _this.style);
  }
}

mixin _$StreamContextMenuActionStyle {
  bool get canMerge => true;

  static StreamContextMenuActionStyle? lerp(
    StreamContextMenuActionStyle? a,
    StreamContextMenuActionStyle? b,
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

    return StreamContextMenuActionStyle(
      backgroundColor: WidgetStateProperty.lerp<Color?>(
        a.backgroundColor,
        b.backgroundColor,
        t,
        Color.lerp,
      ),
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
      iconColor: WidgetStateProperty.lerp<Color?>(
        a.iconColor,
        b.iconColor,
        t,
        Color.lerp,
      ),
      textStyle: WidgetStateProperty.lerp<TextStyle?>(
        a.textStyle,
        b.textStyle,
        t,
        TextStyle.lerp,
      ),
      iconSize: WidgetStateProperty.lerp<double?>(
        a.iconSize,
        b.iconSize,
        t,
        lerpDouble$,
      ),
      minimumSize: WidgetStateProperty.lerp<Size?>(
        a.minimumSize,
        b.minimumSize,
        t,
        Size.lerp,
      ),
      maximumSize: WidgetStateProperty.lerp<Size?>(
        a.maximumSize,
        b.maximumSize,
        t,
        Size.lerp,
      ),
      padding: WidgetStateProperty.lerp<EdgeInsetsGeometry?>(
        a.padding,
        b.padding,
        t,
        EdgeInsetsGeometry.lerp,
      ),
      shape: WidgetStateProperty.lerp<OutlinedBorder?>(
        a.shape,
        b.shape,
        t,
        OutlinedBorder.lerp,
      ),
    );
  }

  StreamContextMenuActionStyle copyWith({
    WidgetStateProperty<Color?>? backgroundColor,
    WidgetStateProperty<Color?>? foregroundColor,
    WidgetStateProperty<Color?>? overlayColor,
    WidgetStateProperty<Color?>? iconColor,
    WidgetStateProperty<TextStyle?>? textStyle,
    WidgetStateProperty<double?>? iconSize,
    WidgetStateProperty<Size?>? minimumSize,
    WidgetStateProperty<Size?>? maximumSize,
    WidgetStateProperty<EdgeInsetsGeometry?>? padding,
    WidgetStateProperty<OutlinedBorder?>? shape,
  }) {
    final _this = (this as StreamContextMenuActionStyle);

    return StreamContextMenuActionStyle(
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      foregroundColor: foregroundColor ?? _this.foregroundColor,
      overlayColor: overlayColor ?? _this.overlayColor,
      iconColor: iconColor ?? _this.iconColor,
      textStyle: textStyle ?? _this.textStyle,
      iconSize: iconSize ?? _this.iconSize,
      minimumSize: minimumSize ?? _this.minimumSize,
      maximumSize: maximumSize ?? _this.maximumSize,
      padding: padding ?? _this.padding,
      shape: shape ?? _this.shape,
    );
  }

  StreamContextMenuActionStyle merge(StreamContextMenuActionStyle? other) {
    final _this = (this as StreamContextMenuActionStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      backgroundColor: other.backgroundColor,
      foregroundColor: other.foregroundColor,
      overlayColor: other.overlayColor,
      iconColor: other.iconColor,
      textStyle: other.textStyle,
      iconSize: other.iconSize,
      minimumSize: other.minimumSize,
      maximumSize: other.maximumSize,
      padding: other.padding,
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

    final _this = (this as StreamContextMenuActionStyle);
    final _other = (other as StreamContextMenuActionStyle);

    return _other.backgroundColor == _this.backgroundColor &&
        _other.foregroundColor == _this.foregroundColor &&
        _other.overlayColor == _this.overlayColor &&
        _other.iconColor == _this.iconColor &&
        _other.textStyle == _this.textStyle &&
        _other.iconSize == _this.iconSize &&
        _other.minimumSize == _this.minimumSize &&
        _other.maximumSize == _this.maximumSize &&
        _other.padding == _this.padding &&
        _other.shape == _this.shape;
  }

  @override
  int get hashCode {
    final _this = (this as StreamContextMenuActionStyle);

    return Object.hash(
      runtimeType,
      _this.backgroundColor,
      _this.foregroundColor,
      _this.overlayColor,
      _this.iconColor,
      _this.textStyle,
      _this.iconSize,
      _this.minimumSize,
      _this.maximumSize,
      _this.padding,
      _this.shape,
    );
  }
}
