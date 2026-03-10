// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_message_metadata_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamMessageMetadataThemeData {
  bool get canMerge => true;

  static StreamMessageMetadataThemeData? lerp(
    StreamMessageMetadataThemeData? a,
    StreamMessageMetadataThemeData? b,
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

    return StreamMessageMetadataThemeData(
      usernameTextStyle: TextStyle.lerp(
        a.usernameTextStyle,
        b.usernameTextStyle,
        t,
      ),
      usernameColor: Color.lerp(a.usernameColor, b.usernameColor, t),
      timestampTextStyle: TextStyle.lerp(
        a.timestampTextStyle,
        b.timestampTextStyle,
        t,
      ),
      timestampColor: Color.lerp(a.timestampColor, b.timestampColor, t),
      editedTextStyle: TextStyle.lerp(a.editedTextStyle, b.editedTextStyle, t),
      editedColor: Color.lerp(a.editedColor, b.editedColor, t),
      statusColor: Color.lerp(a.statusColor, b.statusColor, t),
      statusIconSize: lerpDouble$(a.statusIconSize, b.statusIconSize, t),
      spacing: lerpDouble$(a.spacing, b.spacing, t),
      statusSpacing: lerpDouble$(a.statusSpacing, b.statusSpacing, t),
      minHeight: lerpDouble$(a.minHeight, b.minHeight, t),
    );
  }

  StreamMessageMetadataThemeData copyWith({
    TextStyle? usernameTextStyle,
    Color? usernameColor,
    TextStyle? timestampTextStyle,
    Color? timestampColor,
    TextStyle? editedTextStyle,
    Color? editedColor,
    Color? statusColor,
    double? statusIconSize,
    double? spacing,
    double? statusSpacing,
    double? minHeight,
  }) {
    final _this = (this as StreamMessageMetadataThemeData);

    return StreamMessageMetadataThemeData(
      usernameTextStyle: usernameTextStyle ?? _this.usernameTextStyle,
      usernameColor: usernameColor ?? _this.usernameColor,
      timestampTextStyle: timestampTextStyle ?? _this.timestampTextStyle,
      timestampColor: timestampColor ?? _this.timestampColor,
      editedTextStyle: editedTextStyle ?? _this.editedTextStyle,
      editedColor: editedColor ?? _this.editedColor,
      statusColor: statusColor ?? _this.statusColor,
      statusIconSize: statusIconSize ?? _this.statusIconSize,
      spacing: spacing ?? _this.spacing,
      statusSpacing: statusSpacing ?? _this.statusSpacing,
      minHeight: minHeight ?? _this.minHeight,
    );
  }

  StreamMessageMetadataThemeData merge(StreamMessageMetadataThemeData? other) {
    final _this = (this as StreamMessageMetadataThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      usernameTextStyle:
          _this.usernameTextStyle?.merge(other.usernameTextStyle) ??
          other.usernameTextStyle,
      usernameColor: other.usernameColor,
      timestampTextStyle:
          _this.timestampTextStyle?.merge(other.timestampTextStyle) ??
          other.timestampTextStyle,
      timestampColor: other.timestampColor,
      editedTextStyle:
          _this.editedTextStyle?.merge(other.editedTextStyle) ??
          other.editedTextStyle,
      editedColor: other.editedColor,
      statusColor: other.statusColor,
      statusIconSize: other.statusIconSize,
      spacing: other.spacing,
      statusSpacing: other.statusSpacing,
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

    final _this = (this as StreamMessageMetadataThemeData);
    final _other = (other as StreamMessageMetadataThemeData);

    return _other.usernameTextStyle == _this.usernameTextStyle &&
        _other.usernameColor == _this.usernameColor &&
        _other.timestampTextStyle == _this.timestampTextStyle &&
        _other.timestampColor == _this.timestampColor &&
        _other.editedTextStyle == _this.editedTextStyle &&
        _other.editedColor == _this.editedColor &&
        _other.statusColor == _this.statusColor &&
        _other.statusIconSize == _this.statusIconSize &&
        _other.spacing == _this.spacing &&
        _other.statusSpacing == _this.statusSpacing &&
        _other.minHeight == _this.minHeight;
  }

  @override
  int get hashCode {
    final _this = (this as StreamMessageMetadataThemeData);

    return Object.hash(
      runtimeType,
      _this.usernameTextStyle,
      _this.usernameColor,
      _this.timestampTextStyle,
      _this.timestampColor,
      _this.editedTextStyle,
      _this.editedColor,
      _this.statusColor,
      _this.statusIconSize,
      _this.spacing,
      _this.statusSpacing,
      _this.minHeight,
    );
  }
}
