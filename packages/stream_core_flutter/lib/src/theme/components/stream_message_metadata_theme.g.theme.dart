// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_message_metadata_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamMessageMetadataStyle {
  bool get canMerge => true;

  static StreamMessageMetadataStyle? lerp(
    StreamMessageMetadataStyle? a,
    StreamMessageMetadataStyle? b,
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

    return StreamMessageMetadataStyle(
      usernameTextStyle: StreamMessageStyleProperty.lerp<TextStyle?>(
        a.usernameTextStyle,
        b.usernameTextStyle,
        t,
        TextStyle.lerp,
      ),
      usernameColor: StreamMessageStyleProperty.lerp<Color?>(
        a.usernameColor,
        b.usernameColor,
        t,
        Color.lerp,
      ),
      timestampTextStyle: StreamMessageStyleProperty.lerp<TextStyle?>(
        a.timestampTextStyle,
        b.timestampTextStyle,
        t,
        TextStyle.lerp,
      ),
      timestampColor: StreamMessageStyleProperty.lerp<Color?>(
        a.timestampColor,
        b.timestampColor,
        t,
        Color.lerp,
      ),
      editedTextStyle: StreamMessageStyleProperty.lerp<TextStyle?>(
        a.editedTextStyle,
        b.editedTextStyle,
        t,
        TextStyle.lerp,
      ),
      editedColor: StreamMessageStyleProperty.lerp<Color?>(
        a.editedColor,
        b.editedColor,
        t,
        Color.lerp,
      ),
      statusColor: StreamMessageStyleProperty.lerp<Color?>(
        a.statusColor,
        b.statusColor,
        t,
        Color.lerp,
      ),
      statusIconSize: StreamMessageStyleProperty.lerp<double?>(
        a.statusIconSize,
        b.statusIconSize,
        t,
        lerpDouble$,
      ),
      spacing: StreamMessageStyleProperty.lerp<double?>(
        a.spacing,
        b.spacing,
        t,
        lerpDouble$,
      ),
      statusSpacing: StreamMessageStyleProperty.lerp<double?>(
        a.statusSpacing,
        b.statusSpacing,
        t,
        lerpDouble$,
      ),
      minHeight: StreamMessageStyleProperty.lerp<double?>(
        a.minHeight,
        b.minHeight,
        t,
        lerpDouble$,
      ),
    );
  }

  StreamMessageMetadataStyle copyWith({
    StreamMessageStyleProperty<TextStyle?>? usernameTextStyle,
    StreamMessageStyleProperty<Color?>? usernameColor,
    StreamMessageStyleProperty<TextStyle?>? timestampTextStyle,
    StreamMessageStyleProperty<Color?>? timestampColor,
    StreamMessageStyleProperty<TextStyle?>? editedTextStyle,
    StreamMessageStyleProperty<Color?>? editedColor,
    StreamMessageStyleProperty<Color?>? statusColor,
    StreamMessageStyleProperty<double?>? statusIconSize,
    StreamMessageStyleProperty<double?>? spacing,
    StreamMessageStyleProperty<double?>? statusSpacing,
    StreamMessageStyleProperty<double?>? minHeight,
  }) {
    final _this = (this as StreamMessageMetadataStyle);

    return StreamMessageMetadataStyle(
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

  StreamMessageMetadataStyle merge(StreamMessageMetadataStyle? other) {
    final _this = (this as StreamMessageMetadataStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      usernameTextStyle: other.usernameTextStyle,
      usernameColor: other.usernameColor,
      timestampTextStyle: other.timestampTextStyle,
      timestampColor: other.timestampColor,
      editedTextStyle: other.editedTextStyle,
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

    final _this = (this as StreamMessageMetadataStyle);
    final _other = (other as StreamMessageMetadataStyle);

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
    final _this = (this as StreamMessageMetadataStyle);

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
