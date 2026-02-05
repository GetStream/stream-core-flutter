// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_component_factory.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamComponentBuilders {
  bool get canMerge => true;

  static StreamComponentBuilders? lerp(
    StreamComponentBuilders? a,
    StreamComponentBuilders? b,
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

    return StreamComponentBuilders(
      button: t < 0.5 ? a.button : b.button,
      fileTypeIcon: t < 0.5 ? a.fileTypeIcon : b.fileTypeIcon,
    );
  }

  StreamComponentBuilders copyWith({
    Widget Function(BuildContext, StreamButtonProps)? button,
    Widget Function(BuildContext, StreamFileTypeIconProps)? fileTypeIcon,
  }) {
    final _this = (this as StreamComponentBuilders);

    return StreamComponentBuilders(
      button: button ?? _this.button,
      fileTypeIcon: fileTypeIcon ?? _this.fileTypeIcon,
    );
  }

  StreamComponentBuilders merge(StreamComponentBuilders? other) {
    final _this = (this as StreamComponentBuilders);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(button: other.button, fileTypeIcon: other.fileTypeIcon);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other.runtimeType != runtimeType) {
      return false;
    }

    final _this = (this as StreamComponentBuilders);
    final _other = (other as StreamComponentBuilders);

    return _other.button == _this.button &&
        _other.fileTypeIcon == _this.fileTypeIcon;
  }

  @override
  int get hashCode {
    final _this = (this as StreamComponentBuilders);

    return Object.hash(runtimeType, _this.button, _this.fileTypeIcon);
  }
}
