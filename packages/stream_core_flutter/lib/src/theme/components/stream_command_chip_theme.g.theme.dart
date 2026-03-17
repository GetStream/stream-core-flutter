// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_command_chip_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamCommandChipThemeData {
  bool get canMerge => true;

  static StreamCommandChipThemeData? lerp(
    StreamCommandChipThemeData? a,
    StreamCommandChipThemeData? b,
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

    return StreamCommandChipThemeData(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      labelColor: Color.lerp(a.labelColor, b.labelColor, t),
      iconColor: Color.lerp(a.iconColor, b.iconColor, t),
      minHeight: lerpDouble$(a.minHeight, b.minHeight, t),
    );
  }

  StreamCommandChipThemeData copyWith({
    Color? backgroundColor,
    Color? labelColor,
    Color? iconColor,
    double? minHeight,
  }) {
    final _this = (this as StreamCommandChipThemeData);

    return StreamCommandChipThemeData(
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      labelColor: labelColor ?? _this.labelColor,
      iconColor: iconColor ?? _this.iconColor,
      minHeight: minHeight ?? _this.minHeight,
    );
  }

  StreamCommandChipThemeData merge(StreamCommandChipThemeData? other) {
    final _this = (this as StreamCommandChipThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      backgroundColor: other.backgroundColor,
      labelColor: other.labelColor,
      iconColor: other.iconColor,
      minHeight: other.minHeight,
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

    final _this = (this as StreamCommandChipThemeData);
    final _other = (other as StreamCommandChipThemeData);

    return _other.backgroundColor == _this.backgroundColor &&
        _other.labelColor == _this.labelColor &&
        _other.iconColor == _this.iconColor &&
        _other.minHeight == _this.minHeight;
  }

  @override
  int get hashCode {
    final _this = (this as StreamCommandChipThemeData);

    return Object.hash(
      runtimeType,
      _this.backgroundColor,
      _this.labelColor,
      _this.iconColor,
      _this.minHeight,
    );
  }
}
