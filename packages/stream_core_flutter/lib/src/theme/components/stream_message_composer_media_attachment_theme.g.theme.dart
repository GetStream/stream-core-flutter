// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_message_composer_media_attachment_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamMessageComposerMediaAttachmentThemeData {
  bool get canMerge => true;

  static StreamMessageComposerMediaAttachmentThemeData? lerp(
    StreamMessageComposerMediaAttachmentThemeData? a,
    StreamMessageComposerMediaAttachmentThemeData? b,
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

    return StreamMessageComposerMediaAttachmentThemeData(
      borderColor: Color.lerp(a.borderColor, b.borderColor, t),
      size: Size.lerp(a.size, b.size, t),
    );
  }

  StreamMessageComposerMediaAttachmentThemeData copyWith({
    Color? borderColor,
    Size? size,
  }) {
    final _this = (this as StreamMessageComposerMediaAttachmentThemeData);

    return StreamMessageComposerMediaAttachmentThemeData(
      borderColor: borderColor ?? _this.borderColor,
      size: size ?? _this.size,
    );
  }

  StreamMessageComposerMediaAttachmentThemeData merge(
    StreamMessageComposerMediaAttachmentThemeData? other,
  ) {
    final _this = (this as StreamMessageComposerMediaAttachmentThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(borderColor: other.borderColor, size: other.size);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other.runtimeType != runtimeType) {
      return false;
    }

    final _this = (this as StreamMessageComposerMediaAttachmentThemeData);
    final _other = (other as StreamMessageComposerMediaAttachmentThemeData);

    return _other.borderColor == _this.borderColor && _other.size == _this.size;
  }

  @override
  int get hashCode {
    final _this = (this as StreamMessageComposerMediaAttachmentThemeData);

    return Object.hash(runtimeType, _this.borderColor, _this.size);
  }
}
