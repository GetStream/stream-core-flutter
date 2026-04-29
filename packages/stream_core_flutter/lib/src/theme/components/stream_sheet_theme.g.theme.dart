// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_sheet_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamSheetThemeData {
  bool get canMerge => true;

  static StreamSheetThemeData? lerp(
    StreamSheetThemeData? a,
    StreamSheetThemeData? b,
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

    return StreamSheetThemeData(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      surfaceTintColor: Color.lerp(a.surfaceTintColor, b.surfaceTintColor, t),
      shadowColor: Color.lerp(a.shadowColor, b.shadowColor, t),
      barrierColor: Color.lerp(a.barrierColor, b.barrierColor, t),
      elevation: lerpDouble$(a.elevation, b.elevation, t),
      shape: ShapeBorder.lerp(a.shape, b.shape, t),
      borderRadius: BorderRadiusGeometry.lerp(
        a.borderRadius,
        b.borderRadius,
        t,
      ),
      clipBehavior: t < 0.5 ? a.clipBehavior : b.clipBehavior,
      constraints: BoxConstraints.lerp(a.constraints, b.constraints, t),
      showDragHandle: t < 0.5 ? a.showDragHandle : b.showDragHandle,
      dragHandleColor: Color.lerp(a.dragHandleColor, b.dragHandleColor, t),
      dragHandleSize: Size.lerp(a.dragHandleSize, b.dragHandleSize, t),
    );
  }

  StreamSheetThemeData copyWith({
    Color? backgroundColor,
    Color? surfaceTintColor,
    Color? shadowColor,
    Color? barrierColor,
    double? elevation,
    ShapeBorder? shape,
    BorderRadiusGeometry? borderRadius,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    bool? showDragHandle,
    Color? dragHandleColor,
    Size? dragHandleSize,
  }) {
    final _this = (this as StreamSheetThemeData);

    return StreamSheetThemeData(
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      surfaceTintColor: surfaceTintColor ?? _this.surfaceTintColor,
      shadowColor: shadowColor ?? _this.shadowColor,
      barrierColor: barrierColor ?? _this.barrierColor,
      elevation: elevation ?? _this.elevation,
      shape: shape ?? _this.shape,
      borderRadius: borderRadius ?? _this.borderRadius,
      clipBehavior: clipBehavior ?? _this.clipBehavior,
      constraints: constraints ?? _this.constraints,
      showDragHandle: showDragHandle ?? _this.showDragHandle,
      dragHandleColor: dragHandleColor ?? _this.dragHandleColor,
      dragHandleSize: dragHandleSize ?? _this.dragHandleSize,
    );
  }

  StreamSheetThemeData merge(StreamSheetThemeData? other) {
    final _this = (this as StreamSheetThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      backgroundColor: other.backgroundColor,
      surfaceTintColor: other.surfaceTintColor,
      shadowColor: other.shadowColor,
      barrierColor: other.barrierColor,
      elevation: other.elevation,
      shape: other.shape,
      borderRadius: other.borderRadius,
      clipBehavior: other.clipBehavior,
      constraints: other.constraints,
      showDragHandle: other.showDragHandle,
      dragHandleColor: other.dragHandleColor,
      dragHandleSize: other.dragHandleSize,
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

    final _this = (this as StreamSheetThemeData);
    final _other = (other as StreamSheetThemeData);

    return _other.backgroundColor == _this.backgroundColor &&
        _other.surfaceTintColor == _this.surfaceTintColor &&
        _other.shadowColor == _this.shadowColor &&
        _other.barrierColor == _this.barrierColor &&
        _other.elevation == _this.elevation &&
        _other.shape == _this.shape &&
        _other.borderRadius == _this.borderRadius &&
        _other.clipBehavior == _this.clipBehavior &&
        _other.constraints == _this.constraints &&
        _other.showDragHandle == _this.showDragHandle &&
        _other.dragHandleColor == _this.dragHandleColor &&
        _other.dragHandleSize == _this.dragHandleSize;
  }

  @override
  int get hashCode {
    final _this = (this as StreamSheetThemeData);

    return Object.hash(
      runtimeType,
      _this.backgroundColor,
      _this.surfaceTintColor,
      _this.shadowColor,
      _this.barrierColor,
      _this.elevation,
      _this.shape,
      _this.borderRadius,
      _this.clipBehavior,
      _this.constraints,
      _this.showDragHandle,
      _this.dragHandleColor,
      _this.dragHandleSize,
    );
  }
}
