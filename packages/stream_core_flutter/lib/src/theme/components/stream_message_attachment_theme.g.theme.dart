// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_message_attachment_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamMessageAttachmentStyle {
  bool get canMerge => true;

  static StreamMessageAttachmentStyle? lerp(
    StreamMessageAttachmentStyle? a,
    StreamMessageAttachmentStyle? b,
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

    return StreamMessageAttachmentStyle(
      backgroundColor: StreamMessageLayoutProperty.lerp<Color?>(
        a.backgroundColor,
        b.backgroundColor,
        t,
        Color.lerp,
      ),
      shape: StreamMessageLayoutProperty.lerp<OutlinedBorder?>(
        a.shape,
        b.shape,
        t,
        OutlinedBorder.lerp,
      ),
      side: StreamMessageLayoutBorderSide.lerp(a.side, b.side, t),
      padding: StreamMessageLayoutProperty.lerp<EdgeInsetsGeometry?>(
        a.padding,
        b.padding,
        t,
        EdgeInsetsGeometry.lerp,
      ),
    );
  }

  StreamMessageAttachmentStyle copyWith({
    StreamMessageLayoutProperty<Color?>? backgroundColor,
    StreamMessageLayoutProperty<OutlinedBorder?>? shape,
    StreamMessageLayoutBorderSide? side,
    StreamMessageLayoutProperty<EdgeInsetsGeometry?>? padding,
  }) {
    final _this = (this as StreamMessageAttachmentStyle);

    return StreamMessageAttachmentStyle(
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      shape: shape ?? _this.shape,
      side: side ?? _this.side,
      padding: padding ?? _this.padding,
    );
  }

  StreamMessageAttachmentStyle merge(StreamMessageAttachmentStyle? other) {
    final _this = (this as StreamMessageAttachmentStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      backgroundColor: other.backgroundColor,
      shape: other.shape,
      side: other.side,
      padding: other.padding,
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

    final _this = (this as StreamMessageAttachmentStyle);
    final _other = (other as StreamMessageAttachmentStyle);

    return _other.backgroundColor == _this.backgroundColor &&
        _other.shape == _this.shape &&
        _other.side == _this.side &&
        _other.padding == _this.padding;
  }

  @override
  int get hashCode {
    final _this = (this as StreamMessageAttachmentStyle);

    return Object.hash(
      runtimeType,
      _this.backgroundColor,
      _this.shape,
      _this.side,
      _this.padding,
    );
  }
}
