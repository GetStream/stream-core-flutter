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
      usernameTextStyle: StreamMessageLayoutProperty.lerp<TextStyle?>(
        a.usernameTextStyle,
        b.usernameTextStyle,
        t,
        TextStyle.lerp,
      ),
      usernameColor: StreamMessageLayoutProperty.lerp<Color?>(
        a.usernameColor,
        b.usernameColor,
        t,
        Color.lerp,
      ),
      timestampTextStyle: StreamMessageLayoutProperty.lerp<TextStyle?>(
        a.timestampTextStyle,
        b.timestampTextStyle,
        t,
        TextStyle.lerp,
      ),
      timestampColor: StreamMessageLayoutProperty.lerp<Color?>(
        a.timestampColor,
        b.timestampColor,
        t,
        Color.lerp,
      ),
      editedTextStyle: StreamMessageLayoutProperty.lerp<TextStyle?>(
        a.editedTextStyle,
        b.editedTextStyle,
        t,
        TextStyle.lerp,
      ),
      editedColor: StreamMessageLayoutProperty.lerp<Color?>(
        a.editedColor,
        b.editedColor,
        t,
        Color.lerp,
      ),
      statusTextStyle: StreamMessageLayoutProperty.lerp<TextStyle?>(
        a.statusTextStyle,
        b.statusTextStyle,
        t,
        TextStyle.lerp,
      ),
      statusColor: StreamMessageLayoutProperty.lerp<Color?>(
        a.statusColor,
        b.statusColor,
        t,
        Color.lerp,
      ),
      statusIconSize: StreamMessageLayoutProperty.lerp<double?>(
        a.statusIconSize,
        b.statusIconSize,
        t,
        lerpDouble$,
      ),
      spacing: StreamMessageLayoutProperty.lerp<double?>(
        a.spacing,
        b.spacing,
        t,
        lerpDouble$,
      ),
      statusSpacing: StreamMessageLayoutProperty.lerp<double?>(
        a.statusSpacing,
        b.statusSpacing,
        t,
        lerpDouble$,
      ),
      minHeight: StreamMessageLayoutProperty.lerp<double?>(
        a.minHeight,
        b.minHeight,
        t,
        lerpDouble$,
      ),
    );
  }

  StreamMessageMetadataStyle copyWith({
    StreamMessageLayoutProperty<TextStyle?>? usernameTextStyle,
    StreamMessageLayoutProperty<Color?>? usernameColor,
    StreamMessageLayoutProperty<TextStyle?>? timestampTextStyle,
    StreamMessageLayoutProperty<Color?>? timestampColor,
    StreamMessageLayoutProperty<TextStyle?>? editedTextStyle,
    StreamMessageLayoutProperty<Color?>? editedColor,
    StreamMessageLayoutProperty<TextStyle?>? statusTextStyle,
    StreamMessageLayoutProperty<Color?>? statusColor,
    StreamMessageLayoutProperty<double?>? statusIconSize,
    StreamMessageLayoutProperty<double?>? spacing,
    StreamMessageLayoutProperty<double?>? statusSpacing,
    StreamMessageLayoutProperty<double?>? minHeight,
  }) {
    final _this = (this as StreamMessageMetadataStyle);

    return StreamMessageMetadataStyle(
      usernameTextStyle: usernameTextStyle ?? _this.usernameTextStyle,
      usernameColor: usernameColor ?? _this.usernameColor,
      timestampTextStyle: timestampTextStyle ?? _this.timestampTextStyle,
      timestampColor: timestampColor ?? _this.timestampColor,
      editedTextStyle: editedTextStyle ?? _this.editedTextStyle,
      editedColor: editedColor ?? _this.editedColor,
      statusTextStyle: statusTextStyle ?? _this.statusTextStyle,
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
      statusTextStyle: other.statusTextStyle,
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
        _other.statusTextStyle == _this.statusTextStyle &&
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
      _this.statusTextStyle,
      _this.statusColor,
      _this.statusIconSize,
      _this.spacing,
      _this.statusSpacing,
      _this.minHeight,
    );
  }
}
