// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_message_composer_edit_message_attachment_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamMessageComposerEditMessageAttachmentThemeData {
  bool get canMerge => true;

  static StreamMessageComposerEditMessageAttachmentThemeData? lerp(
    StreamMessageComposerEditMessageAttachmentThemeData? a,
    StreamMessageComposerEditMessageAttachmentThemeData? b,
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

    return StreamMessageComposerEditMessageAttachmentThemeData(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      indicatorColor: Color.lerp(a.indicatorColor, b.indicatorColor, t),
      titleTextStyle: TextStyle.lerp(a.titleTextStyle, b.titleTextStyle, t),
      subtitleTextStyle: TextStyle.lerp(
        a.subtitleTextStyle,
        b.subtitleTextStyle,
        t,
      ),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      thumbnailShape: OutlinedBorder.lerp(
        a.thumbnailShape,
        b.thumbnailShape,
        t,
      ),
      thumbnailSide: a.thumbnailSide == null
          ? b.thumbnailSide
          : b.thumbnailSide == null
          ? a.thumbnailSide
          : BorderSide.lerp(a.thumbnailSide!, b.thumbnailSide!, t),
      thumbnailSize: Size.lerp(a.thumbnailSize, b.thumbnailSize, t),
    );
  }

  StreamMessageComposerEditMessageAttachmentThemeData copyWith({
    Color? backgroundColor,
    Color? indicatorColor,
    TextStyle? titleTextStyle,
    TextStyle? subtitleTextStyle,
    EdgeInsetsGeometry? padding,
    OutlinedBorder? thumbnailShape,
    BorderSide? thumbnailSide,
    Size? thumbnailSize,
  }) {
    final _this = (this as StreamMessageComposerEditMessageAttachmentThemeData);

    return StreamMessageComposerEditMessageAttachmentThemeData(
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      indicatorColor: indicatorColor ?? _this.indicatorColor,
      titleTextStyle: titleTextStyle ?? _this.titleTextStyle,
      subtitleTextStyle: subtitleTextStyle ?? _this.subtitleTextStyle,
      padding: padding ?? _this.padding,
      thumbnailShape: thumbnailShape ?? _this.thumbnailShape,
      thumbnailSide: thumbnailSide ?? _this.thumbnailSide,
      thumbnailSize: thumbnailSize ?? _this.thumbnailSize,
    );
  }

  StreamMessageComposerEditMessageAttachmentThemeData merge(
    StreamMessageComposerEditMessageAttachmentThemeData? other,
  ) {
    final _this = (this as StreamMessageComposerEditMessageAttachmentThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      backgroundColor: other.backgroundColor,
      indicatorColor: other.indicatorColor,
      titleTextStyle:
          _this.titleTextStyle?.merge(other.titleTextStyle) ??
          other.titleTextStyle,
      subtitleTextStyle:
          _this.subtitleTextStyle?.merge(other.subtitleTextStyle) ??
          other.subtitleTextStyle,
      padding: other.padding,
      thumbnailShape: other.thumbnailShape,
      thumbnailSide: _this.thumbnailSide != null && other.thumbnailSide != null
          ? BorderSide.merge(_this.thumbnailSide!, other.thumbnailSide!)
          : other.thumbnailSide,
      thumbnailSize: other.thumbnailSize,
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

    final _this = (this as StreamMessageComposerEditMessageAttachmentThemeData);
    final _other =
        (other as StreamMessageComposerEditMessageAttachmentThemeData);

    return _other.backgroundColor == _this.backgroundColor &&
        _other.indicatorColor == _this.indicatorColor &&
        _other.titleTextStyle == _this.titleTextStyle &&
        _other.subtitleTextStyle == _this.subtitleTextStyle &&
        _other.padding == _this.padding &&
        _other.thumbnailShape == _this.thumbnailShape &&
        _other.thumbnailSide == _this.thumbnailSide &&
        _other.thumbnailSize == _this.thumbnailSize;
  }

  @override
  int get hashCode {
    final _this = (this as StreamMessageComposerEditMessageAttachmentThemeData);

    return Object.hash(
      runtimeType,
      _this.backgroundColor,
      _this.indicatorColor,
      _this.titleTextStyle,
      _this.subtitleTextStyle,
      _this.padding,
      _this.thumbnailShape,
      _this.thumbnailSide,
      _this.thumbnailSize,
    );
  }
}
