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
      shadowColor: Color.lerp(a.shadowColor, b.shadowColor, t),
      shape: ShapeBorder.lerp(a.shape, b.shape, t),
      insetPadding: EdgeInsets.lerp(a.insetPadding, b.insetPadding, t),
      constraints: BoxConstraints.lerp(a.constraints, b.constraints, t),
      contentPadding: EdgeInsetsGeometry.lerp(
        a.contentPadding,
        b.contentPadding,
        t,
      ),
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
      barrierColor: Color.lerp(a.barrierColor, b.barrierColor, t),
      barrierBlurSigma: lerpDouble$(a.barrierBlurSigma, b.barrierBlurSigma, t),
    );
  }

  StreamModalDialogThemeData copyWith({
    Color? backgroundColor,
    double? elevation,
    Color? shadowColor,
    ShapeBorder? shape,
    EdgeInsets? insetPadding,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? contentPadding,
    StreamModalDialogHeaderStyle? headerStyle,
    StreamModalDialogFooterStyle? footerStyle,
    Color? barrierColor,
    double? barrierBlurSigma,
  }) {
    final _this = (this as StreamModalDialogThemeData);

    return StreamModalDialogThemeData(
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      elevation: elevation ?? _this.elevation,
      shadowColor: shadowColor ?? _this.shadowColor,
      shape: shape ?? _this.shape,
      insetPadding: insetPadding ?? _this.insetPadding,
      constraints: constraints ?? _this.constraints,
      contentPadding: contentPadding ?? _this.contentPadding,
      headerStyle: headerStyle ?? _this.headerStyle,
      footerStyle: footerStyle ?? _this.footerStyle,
      barrierColor: barrierColor ?? _this.barrierColor,
      barrierBlurSigma: barrierBlurSigma ?? _this.barrierBlurSigma,
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
      shadowColor: other.shadowColor,
      shape: other.shape,
      insetPadding: other.insetPadding,
      constraints: other.constraints,
      contentPadding: other.contentPadding,
      headerStyle:
          _this.headerStyle?.merge(other.headerStyle) ?? other.headerStyle,
      footerStyle:
          _this.footerStyle?.merge(other.footerStyle) ?? other.footerStyle,
      barrierColor: other.barrierColor,
      barrierBlurSigma: other.barrierBlurSigma,
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
        _other.shadowColor == _this.shadowColor &&
        _other.shape == _this.shape &&
        _other.insetPadding == _this.insetPadding &&
        _other.constraints == _this.constraints &&
        _other.contentPadding == _this.contentPadding &&
        _other.headerStyle == _this.headerStyle &&
        _other.footerStyle == _this.footerStyle &&
        _other.barrierColor == _this.barrierColor &&
        _other.barrierBlurSigma == _this.barrierBlurSigma;
  }

  @override
  int get hashCode {
    final _this = (this as StreamModalDialogThemeData);

    return Object.hash(
      runtimeType,
      _this.backgroundColor,
      _this.elevation,
      _this.shadowColor,
      _this.shape,
      _this.insetPadding,
      _this.constraints,
      _this.contentPadding,
      _this.headerStyle,
      _this.footerStyle,
      _this.barrierColor,
      _this.barrierBlurSigma,
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
      expandActions: t < 0.5 ? a.expandActions : b.expandActions,
    );
  }

  StreamModalDialogFooterStyle copyWith({
    EdgeInsetsGeometry? padding,
    double? actionsSpacing,
    bool? expandActions,
  }) {
    final _this = (this as StreamModalDialogFooterStyle);

    return StreamModalDialogFooterStyle(
      padding: padding ?? _this.padding,
      actionsSpacing: actionsSpacing ?? _this.actionsSpacing,
      expandActions: expandActions ?? _this.expandActions,
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
      expandActions: other.expandActions,
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
        _other.actionsSpacing == _this.actionsSpacing &&
        _other.expandActions == _this.expandActions;
  }

  @override
  int get hashCode {
    final _this = (this as StreamModalDialogFooterStyle);

    return Object.hash(
      runtimeType,
      _this.padding,
      _this.actionsSpacing,
      _this.expandActions,
    );
  }
}
