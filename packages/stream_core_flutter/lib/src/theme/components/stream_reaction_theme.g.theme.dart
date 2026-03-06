// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_reaction_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamReactionsThemeData {
  bool get canMerge => true;

  static StreamReactionsThemeData? lerp(
    StreamReactionsThemeData? a,
    StreamReactionsThemeData? b,
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

    return StreamReactionsThemeData(
      spacing: lerpDouble$(a.spacing, b.spacing, t),
      gap: lerpDouble$(a.gap, b.gap, t),
      overlapExtent: lerpDouble$(a.overlapExtent, b.overlapExtent, t),
      indent: lerpDouble$(a.indent, b.indent, t),
    );
  }

  StreamReactionsThemeData copyWith({
    double? spacing,
    double? gap,
    double? overlapExtent,
    double? indent,
  }) {
    final _this = (this as StreamReactionsThemeData);

    return StreamReactionsThemeData(
      spacing: spacing ?? _this.spacing,
      gap: gap ?? _this.gap,
      overlapExtent: overlapExtent ?? _this.overlapExtent,
      indent: indent ?? _this.indent,
    );
  }

  StreamReactionsThemeData merge(StreamReactionsThemeData? other) {
    final _this = (this as StreamReactionsThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      spacing: other.spacing,
      gap: other.gap,
      overlapExtent: other.overlapExtent,
      indent: other.indent,
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

    final _this = (this as StreamReactionsThemeData);
    final _other = (other as StreamReactionsThemeData);

    return _other.spacing == _this.spacing &&
        _other.gap == _this.gap &&
        _other.overlapExtent == _this.overlapExtent &&
        _other.indent == _this.indent;
  }

  @override
  int get hashCode {
    final _this = (this as StreamReactionsThemeData);

    return Object.hash(
      runtimeType,
      _this.spacing,
      _this.gap,
      _this.overlapExtent,
      _this.indent,
    );
  }
}
