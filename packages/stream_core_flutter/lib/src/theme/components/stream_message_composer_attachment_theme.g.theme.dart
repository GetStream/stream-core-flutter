// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_message_composer_attachment_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamMessageComposerAttachmentThemeData {
  bool get canMerge => true;

  static StreamMessageComposerAttachmentThemeData? lerp(
    StreamMessageComposerAttachmentThemeData? a,
    StreamMessageComposerAttachmentThemeData? b,
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

    return StreamMessageComposerAttachmentThemeData(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      shape: OutlinedBorder.lerp(a.shape, b.shape, t),
      side: a.side == null
          ? b.side
          : b.side == null
          ? a.side
          : BorderSide.lerp(a.side!, b.side!, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
    );
  }

  StreamMessageComposerAttachmentThemeData copyWith({
    Color? backgroundColor,
    OutlinedBorder? shape,
    BorderSide? side,
    EdgeInsetsGeometry? padding,
  }) {
    final _this = (this as StreamMessageComposerAttachmentThemeData);

    return StreamMessageComposerAttachmentThemeData(
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      shape: shape ?? _this.shape,
      side: side ?? _this.side,
      padding: padding ?? _this.padding,
    );
  }

  StreamMessageComposerAttachmentThemeData merge(
    StreamMessageComposerAttachmentThemeData? other,
  ) {
    final _this = (this as StreamMessageComposerAttachmentThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      backgroundColor: other.backgroundColor,
      shape: other.shape,
      side: _this.side != null && other.side != null
          ? BorderSide.merge(_this.side!, other.side!)
          : other.side,
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

    final _this = (this as StreamMessageComposerAttachmentThemeData);
    final _other = (other as StreamMessageComposerAttachmentThemeData);

    return _other.backgroundColor == _this.backgroundColor &&
        _other.shape == _this.shape &&
        _other.side == _this.side &&
        _other.padding == _this.padding;
  }

  @override
  int get hashCode {
    final _this = (this as StreamMessageComposerAttachmentThemeData);

    return Object.hash(
      runtimeType,
      _this.backgroundColor,
      _this.shape,
      _this.side,
      _this.padding,
    );
  }
}
