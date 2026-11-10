// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_context_menu_anchor_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamContextMenuAnchorThemeData {
  bool get canMerge => true;

  static StreamContextMenuAnchorThemeData? lerp(
    StreamContextMenuAnchorThemeData? a,
    StreamContextMenuAnchorThemeData? b,
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

    return StreamContextMenuAnchorThemeData(
      constraints: BoxConstraints.lerp(a.constraints, b.constraints, t),
      alignmentOffset: Offset.lerp(a.alignmentOffset, b.alignmentOffset, t),
      actionStyle: StreamContextMenuActionStyle.lerp(
        a.actionStyle,
        b.actionStyle,
        t,
      ),
    );
  }

  StreamContextMenuAnchorThemeData copyWith({
    BoxConstraints? constraints,
    Offset? alignmentOffset,
    StreamContextMenuActionStyle? actionStyle,
  }) {
    final _this = (this as StreamContextMenuAnchorThemeData);

    return StreamContextMenuAnchorThemeData(
      constraints: constraints ?? _this.constraints,
      alignmentOffset: alignmentOffset ?? _this.alignmentOffset,
      actionStyle: actionStyle ?? _this.actionStyle,
    );
  }

  StreamContextMenuAnchorThemeData merge(
    StreamContextMenuAnchorThemeData? other,
  ) {
    final _this = (this as StreamContextMenuAnchorThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      constraints: other.constraints,
      alignmentOffset: other.alignmentOffset,
      actionStyle:
          _this.actionStyle?.merge(other.actionStyle) ?? other.actionStyle,
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

    final _this = (this as StreamContextMenuAnchorThemeData);
    final _other = (other as StreamContextMenuAnchorThemeData);

    return _other.constraints == _this.constraints &&
        _other.alignmentOffset == _this.alignmentOffset &&
        _other.actionStyle == _this.actionStyle;
  }

  @override
  int get hashCode {
    final _this = (this as StreamContextMenuAnchorThemeData);

    return Object.hash(
      runtimeType,
      _this.constraints,
      _this.alignmentOffset,
      _this.actionStyle,
    );
  }
}
