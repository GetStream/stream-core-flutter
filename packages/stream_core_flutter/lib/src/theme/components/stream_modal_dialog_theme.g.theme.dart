// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_modal_dialog_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamModalDialogThemeData {
  bool get canMerge => true;

  static StreamModalDialogThemeData? lerp(
    StreamModalDialogThemeData? a,
    StreamModalDialogThemeData? b,
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

    return StreamModalDialogThemeData(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      elevation: lerpDouble$(a.elevation, b.elevation, t),
      shape: ShapeBorder.lerp(a.shape, b.shape, t),
      insetPadding: EdgeInsets.lerp(a.insetPadding, b.insetPadding, t),
      constraints: BoxConstraints.lerp(a.constraints, b.constraints, t),
      headerStyle: StreamModalDialogHeaderStyle.lerp(
        a.headerStyle,
        b.headerStyle,
        t,
      ),
      footerStyle: StreamModalDialogFooterStyle.lerp(
        a.footerStyle,
        b.footerStyle,
        t,
      ),
      scrimColor: Color.lerp(a.scrimColor, b.scrimColor, t),
      scrimBlurSigma: lerpDouble$(a.scrimBlurSigma, b.scrimBlurSigma, t),
    );
  }

  StreamModalDialogThemeData copyWith({
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    EdgeInsets? insetPadding,
    BoxConstraints? constraints,
    StreamModalDialogHeaderStyle? headerStyle,
    StreamModalDialogFooterStyle? footerStyle,
    Color? scrimColor,
    double? scrimBlurSigma,
  }) {
    final _this = (this as StreamModalDialogThemeData);

    return StreamModalDialogThemeData(
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      elevation: elevation ?? _this.elevation,
      shape: shape ?? _this.shape,
      insetPadding: insetPadding ?? _this.insetPadding,
      constraints: constraints ?? _this.constraints,
      headerStyle: headerStyle ?? _this.headerStyle,
      footerStyle: footerStyle ?? _this.footerStyle,
      scrimColor: scrimColor ?? _this.scrimColor,
      scrimBlurSigma: scrimBlurSigma ?? _this.scrimBlurSigma,
    );
  }

  StreamModalDialogThemeData merge(StreamModalDialogThemeData? other) {
    final _this = (this as StreamModalDialogThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      backgroundColor: other.backgroundColor,
      elevation: other.elevation,
      shape: other.shape,
      insetPadding: other.insetPadding,
      constraints: other.constraints,
      headerStyle:
          _this.headerStyle?.merge(other.headerStyle) ?? other.headerStyle,
      footerStyle:
          _this.footerStyle?.merge(other.footerStyle) ?? other.footerStyle,
      scrimColor: other.scrimColor,
      scrimBlurSigma: other.scrimBlurSigma,
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

    final _this = (this as StreamModalDialogThemeData);
    final _other = (other as StreamModalDialogThemeData);

    return _other.backgroundColor == _this.backgroundColor &&
        _other.elevation == _this.elevation &&
        _other.shape == _this.shape &&
        _other.insetPadding == _this.insetPadding &&
        _other.constraints == _this.constraints &&
        _other.headerStyle == _this.headerStyle &&
        _other.footerStyle == _this.footerStyle &&
        _other.scrimColor == _this.scrimColor &&
        _other.scrimBlurSigma == _this.scrimBlurSigma;
  }

  @override
  int get hashCode {
    final _this = (this as StreamModalDialogThemeData);

    return Object.hash(
      runtimeType,
      _this.backgroundColor,
      _this.elevation,
      _this.shape,
      _this.insetPadding,
      _this.constraints,
      _this.headerStyle,
      _this.footerStyle,
      _this.scrimColor,
      _this.scrimBlurSigma,
    );
  }
}

mixin _$StreamModalDialogHeaderStyle {
  bool get canMerge => true;

  static StreamModalDialogHeaderStyle? lerp(
    StreamModalDialogHeaderStyle? a,
    StreamModalDialogHeaderStyle? b,
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

    return StreamModalDialogHeaderStyle(
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      titleTextStyle: TextStyle.lerp(a.titleTextStyle, b.titleTextStyle, t),
      spacing: lerpDouble$(a.spacing, b.spacing, t),
      actionsSpacing: lerpDouble$(a.actionsSpacing, b.actionsSpacing, t),
    );
  }

  StreamModalDialogHeaderStyle copyWith({
    EdgeInsetsGeometry? padding,
    TextStyle? titleTextStyle,
    double? spacing,
    double? actionsSpacing,
  }) {
    final _this = (this as StreamModalDialogHeaderStyle);

    return StreamModalDialogHeaderStyle(
      padding: padding ?? _this.padding,
      titleTextStyle: titleTextStyle ?? _this.titleTextStyle,
      spacing: spacing ?? _this.spacing,
      actionsSpacing: actionsSpacing ?? _this.actionsSpacing,
    );
  }

  StreamModalDialogHeaderStyle merge(StreamModalDialogHeaderStyle? other) {
    final _this = (this as StreamModalDialogHeaderStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      padding: other.padding,
      titleTextStyle:
          _this.titleTextStyle?.merge(other.titleTextStyle) ??
          other.titleTextStyle,
      spacing: other.spacing,
      actionsSpacing: other.actionsSpacing,
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

    final _this = (this as StreamModalDialogHeaderStyle);
    final _other = (other as StreamModalDialogHeaderStyle);

    return _other.padding == _this.padding &&
        _other.titleTextStyle == _this.titleTextStyle &&
        _other.spacing == _this.spacing &&
        _other.actionsSpacing == _this.actionsSpacing;
  }

  @override
  int get hashCode {
    final _this = (this as StreamModalDialogHeaderStyle);

    return Object.hash(
      runtimeType,
      _this.padding,
      _this.titleTextStyle,
      _this.spacing,
      _this.actionsSpacing,
    );
  }
}

mixin _$StreamModalDialogFooterStyle {
  bool get canMerge => true;

  static StreamModalDialogFooterStyle? lerp(
    StreamModalDialogFooterStyle? a,
    StreamModalDialogFooterStyle? b,
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

    return StreamModalDialogFooterStyle(
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      actionsSpacing: lerpDouble$(a.actionsSpacing, b.actionsSpacing, t),
    );
  }

  StreamModalDialogFooterStyle copyWith({
    EdgeInsetsGeometry? padding,
    double? actionsSpacing,
  }) {
    final _this = (this as StreamModalDialogFooterStyle);

    return StreamModalDialogFooterStyle(
      padding: padding ?? _this.padding,
      actionsSpacing: actionsSpacing ?? _this.actionsSpacing,
    );
  }

  StreamModalDialogFooterStyle merge(StreamModalDialogFooterStyle? other) {
    final _this = (this as StreamModalDialogFooterStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      padding: other.padding,
      actionsSpacing: other.actionsSpacing,
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

    final _this = (this as StreamModalDialogFooterStyle);
    final _other = (other as StreamModalDialogFooterStyle);

    return _other.padding == _this.padding &&
        _other.actionsSpacing == _this.actionsSpacing;
  }

  @override
  int get hashCode {
    final _this = (this as StreamModalDialogFooterStyle);

    return Object.hash(runtimeType, _this.padding, _this.actionsSpacing);
  }
}
