// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_message_composer_file_attachment_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamMessageComposerFileAttachmentThemeData {
  bool get canMerge => true;

  static StreamMessageComposerFileAttachmentThemeData? lerp(
    StreamMessageComposerFileAttachmentThemeData? a,
    StreamMessageComposerFileAttachmentThemeData? b,
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

    return StreamMessageComposerFileAttachmentThemeData(
      titleTextStyle: TextStyle.lerp(a.titleTextStyle, b.titleTextStyle, t),
      subtitleTextStyle: TextStyle.lerp(
        a.subtitleTextStyle,
        b.subtitleTextStyle,
        t,
      ),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      spacing: lerpDouble$(a.spacing, b.spacing, t),
    );
  }

  StreamMessageComposerFileAttachmentThemeData copyWith({
    TextStyle? titleTextStyle,
    TextStyle? subtitleTextStyle,
    EdgeInsetsGeometry? padding,
    double? spacing,
  }) {
    final _this = (this as StreamMessageComposerFileAttachmentThemeData);

    return StreamMessageComposerFileAttachmentThemeData(
      titleTextStyle: titleTextStyle ?? _this.titleTextStyle,
      subtitleTextStyle: subtitleTextStyle ?? _this.subtitleTextStyle,
      padding: padding ?? _this.padding,
      spacing: spacing ?? _this.spacing,
    );
  }

  StreamMessageComposerFileAttachmentThemeData merge(
    StreamMessageComposerFileAttachmentThemeData? other,
  ) {
    final _this = (this as StreamMessageComposerFileAttachmentThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      titleTextStyle:
          _this.titleTextStyle?.merge(other.titleTextStyle) ??
          other.titleTextStyle,
      subtitleTextStyle:
          _this.subtitleTextStyle?.merge(other.subtitleTextStyle) ??
          other.subtitleTextStyle,
      padding: other.padding,
      spacing: other.spacing,
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

    final _this = (this as StreamMessageComposerFileAttachmentThemeData);
    final _other = (other as StreamMessageComposerFileAttachmentThemeData);

    return _other.titleTextStyle == _this.titleTextStyle &&
        _other.subtitleTextStyle == _this.subtitleTextStyle &&
        _other.padding == _this.padding &&
        _other.spacing == _this.spacing;
  }

  @override
  int get hashCode {
    final _this = (this as StreamMessageComposerFileAttachmentThemeData);

    return Object.hash(
      runtimeType,
      _this.titleTextStyle,
      _this.subtitleTextStyle,
      _this.padding,
      _this.spacing,
    );
  }
}
