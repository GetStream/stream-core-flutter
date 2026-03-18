// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_reaction_picker_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamReactionPickerThemeData {
  bool get canMerge => true;

  static StreamReactionPickerThemeData? lerp(
    StreamReactionPickerThemeData? a,
    StreamReactionPickerThemeData? b,
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

    return StreamReactionPickerThemeData(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      elevation: lerpDouble$(a.elevation, b.elevation, t),
      spacing: lerpDouble$(a.spacing, b.spacing, t),
      shape: OutlinedBorder.lerp(a.shape, b.shape, t),
      side: a.side == null
          ? b.side
          : b.side == null
          ? a.side
          : BorderSide.lerp(a.side!, b.side!, t),
    );
  }

  StreamReactionPickerThemeData copyWith({
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    double? elevation,
    double? spacing,
    OutlinedBorder? shape,
    BorderSide? side,
  }) {
    final _this = (this as StreamReactionPickerThemeData);

    return StreamReactionPickerThemeData(
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      padding: padding ?? _this.padding,
      elevation: elevation ?? _this.elevation,
      spacing: spacing ?? _this.spacing,
      shape: shape ?? _this.shape,
      side: side ?? _this.side,
    );
  }

  StreamReactionPickerThemeData merge(StreamReactionPickerThemeData? other) {
    final _this = (this as StreamReactionPickerThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      backgroundColor: other.backgroundColor,
      padding: other.padding,
      elevation: other.elevation,
      spacing: other.spacing,
      shape: other.shape,
      side: _this.side != null && other.side != null
          ? BorderSide.merge(_this.side!, other.side!)
          : other.side,
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

    final _this = (this as StreamReactionPickerThemeData);
    final _other = (other as StreamReactionPickerThemeData);

    return _other.backgroundColor == _this.backgroundColor &&
        _other.padding == _this.padding &&
        _other.elevation == _this.elevation &&
        _other.spacing == _this.spacing &&
        _other.shape == _this.shape &&
        _other.side == _this.side;
  }

  @override
  int get hashCode {
    final _this = (this as StreamReactionPickerThemeData);

    return Object.hash(
      runtimeType,
      _this.backgroundColor,
      _this.padding,
      _this.elevation,
      _this.spacing,
      _this.shape,
      _this.side,
    );
  }
}
