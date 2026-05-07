// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_message_composer_unsupported_attachment_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamMessageComposerUnsupportedAttachmentThemeData {
  bool get canMerge => true;

  static StreamMessageComposerUnsupportedAttachmentThemeData? lerp(
    StreamMessageComposerUnsupportedAttachmentThemeData? a,
    StreamMessageComposerUnsupportedAttachmentThemeData? b,
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

    return StreamMessageComposerUnsupportedAttachmentThemeData(
      labelTextStyle: TextStyle.lerp(a.labelTextStyle, b.labelTextStyle, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      spacing: lerpDouble$(a.spacing, b.spacing, t),
    );
  }

  StreamMessageComposerUnsupportedAttachmentThemeData copyWith({
    TextStyle? labelTextStyle,
    EdgeInsetsGeometry? padding,
    double? spacing,
  }) {
    final _this = (this as StreamMessageComposerUnsupportedAttachmentThemeData);

    return StreamMessageComposerUnsupportedAttachmentThemeData(
      labelTextStyle: labelTextStyle ?? _this.labelTextStyle,
      padding: padding ?? _this.padding,
      spacing: spacing ?? _this.spacing,
    );
  }

  StreamMessageComposerUnsupportedAttachmentThemeData merge(
    StreamMessageComposerUnsupportedAttachmentThemeData? other,
  ) {
    final _this = (this as StreamMessageComposerUnsupportedAttachmentThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      labelTextStyle:
          _this.labelTextStyle?.merge(other.labelTextStyle) ??
          other.labelTextStyle,
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

    final _this = (this as StreamMessageComposerUnsupportedAttachmentThemeData);
    final _other =
        (other as StreamMessageComposerUnsupportedAttachmentThemeData);

    return _other.labelTextStyle == _this.labelTextStyle &&
        _other.padding == _this.padding &&
        _other.spacing == _this.spacing;
  }

  @override
  int get hashCode {
    final _this = (this as StreamMessageComposerUnsupportedAttachmentThemeData);

    return Object.hash(
      runtimeType,
      _this.labelTextStyle,
      _this.padding,
      _this.spacing,
    );
  }
}
