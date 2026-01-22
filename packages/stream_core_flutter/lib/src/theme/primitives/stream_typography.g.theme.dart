// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_typography.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamTypography {
  bool get canMerge => true;

  static StreamTypography? lerp(
    StreamTypography? a,
    StreamTypography? b,
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

    return StreamTypography.raw(
      fontSize: StreamFontSize.lerp(a.fontSize, b.fontSize, t)!,
      lineHeight: StreamLineHeight.lerp(a.lineHeight, b.lineHeight, t)!,
      fontWeight: StreamFontWeight.lerp(a.fontWeight, b.fontWeight, t)!,
    );
  }

  StreamTypography copyWith({
    StreamFontSize? fontSize,
    StreamLineHeight? lineHeight,
    StreamFontWeight? fontWeight,
  }) {
    final _this = (this as StreamTypography);

    return StreamTypography.raw(
      fontSize: fontSize ?? _this.fontSize,
      lineHeight: lineHeight ?? _this.lineHeight,
      fontWeight: fontWeight ?? _this.fontWeight,
    );
  }

  StreamTypography merge(StreamTypography? other) {
    final _this = (this as StreamTypography);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      fontSize: _this.fontSize.merge(other.fontSize),
      lineHeight: _this.lineHeight.merge(other.lineHeight),
      fontWeight: _this.fontWeight.merge(other.fontWeight),
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

    final _this = (this as StreamTypography);
    final _other = (other as StreamTypography);

    return _other.fontSize == _this.fontSize &&
        _other.lineHeight == _this.lineHeight &&
        _other.fontWeight == _this.fontWeight;
  }

  @override
  int get hashCode {
    final _this = (this as StreamTypography);

    return Object.hash(
      runtimeType,
      _this.fontSize,
      _this.lineHeight,
      _this.fontWeight,
    );
  }
}

mixin _$StreamLineHeight {
  bool get canMerge => true;

  static StreamLineHeight? lerp(
    StreamLineHeight? a,
    StreamLineHeight? b,
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

    return StreamLineHeight(
      tight: lerpDouble$(a.tight, b.tight, t)!,
      normal: lerpDouble$(a.normal, b.normal, t)!,
      relaxed: lerpDouble$(a.relaxed, b.relaxed, t)!,
    );
  }

  StreamLineHeight copyWith({double? tight, double? normal, double? relaxed}) {
    final _this = (this as StreamLineHeight);

    return StreamLineHeight(
      tight: tight ?? _this.tight,
      normal: normal ?? _this.normal,
      relaxed: relaxed ?? _this.relaxed,
    );
  }

  StreamLineHeight merge(StreamLineHeight? other) {
    final _this = (this as StreamLineHeight);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      tight: other.tight,
      normal: other.normal,
      relaxed: other.relaxed,
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

    final _this = (this as StreamLineHeight);
    final _other = (other as StreamLineHeight);

    return _other.tight == _this.tight &&
        _other.normal == _this.normal &&
        _other.relaxed == _this.relaxed;
  }

  @override
  int get hashCode {
    final _this = (this as StreamLineHeight);

    return Object.hash(runtimeType, _this.tight, _this.normal, _this.relaxed);
  }
}

mixin _$StreamFontSize {
  bool get canMerge => true;

  static StreamFontSize? lerp(StreamFontSize? a, StreamFontSize? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return StreamFontSize.raw(
      micro: lerpDouble$(a.micro, b.micro, t)!,
      xxs: lerpDouble$(a.xxs, b.xxs, t)!,
      xs: lerpDouble$(a.xs, b.xs, t)!,
      sm: lerpDouble$(a.sm, b.sm, t)!,
      md: lerpDouble$(a.md, b.md, t)!,
      lg: lerpDouble$(a.lg, b.lg, t)!,
      xl: lerpDouble$(a.xl, b.xl, t)!,
      xxl: lerpDouble$(a.xxl, b.xxl, t)!,
    );
  }

  StreamFontSize copyWith({
    double? micro,
    double? xxs,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
  }) {
    final _this = (this as StreamFontSize);

    return StreamFontSize.raw(
      micro: micro ?? _this.micro,
      xxs: xxs ?? _this.xxs,
      xs: xs ?? _this.xs,
      sm: sm ?? _this.sm,
      md: md ?? _this.md,
      lg: lg ?? _this.lg,
      xl: xl ?? _this.xl,
      xxl: xxl ?? _this.xxl,
    );
  }

  StreamFontSize merge(StreamFontSize? other) {
    final _this = (this as StreamFontSize);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      micro: other.micro,
      xxs: other.xxs,
      xs: other.xs,
      sm: other.sm,
      md: other.md,
      lg: other.lg,
      xl: other.xl,
      xxl: other.xxl,
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

    final _this = (this as StreamFontSize);
    final _other = (other as StreamFontSize);

    return _other.micro == _this.micro &&
        _other.xxs == _this.xxs &&
        _other.xs == _this.xs &&
        _other.sm == _this.sm &&
        _other.md == _this.md &&
        _other.lg == _this.lg &&
        _other.xl == _this.xl &&
        _other.xxl == _this.xxl;
  }

  @override
  int get hashCode {
    final _this = (this as StreamFontSize);

    return Object.hash(
      runtimeType,
      _this.micro,
      _this.xxs,
      _this.xs,
      _this.sm,
      _this.md,
      _this.lg,
      _this.xl,
      _this.xxl,
    );
  }
}

mixin _$StreamFontWeight {
  bool get canMerge => true;

  static StreamFontWeight? lerp(
    StreamFontWeight? a,
    StreamFontWeight? b,
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

    return StreamFontWeight(
      regular: FontWeight.lerp(a.regular, b.regular, t)!,
      medium: FontWeight.lerp(a.medium, b.medium, t)!,
      semibold: FontWeight.lerp(a.semibold, b.semibold, t)!,
      bold: FontWeight.lerp(a.bold, b.bold, t)!,
    );
  }

  StreamFontWeight copyWith({
    FontWeight? regular,
    FontWeight? medium,
    FontWeight? semibold,
    FontWeight? bold,
  }) {
    final _this = (this as StreamFontWeight);

    return StreamFontWeight(
      regular: regular ?? _this.regular,
      medium: medium ?? _this.medium,
      semibold: semibold ?? _this.semibold,
      bold: bold ?? _this.bold,
    );
  }

  StreamFontWeight merge(StreamFontWeight? other) {
    final _this = (this as StreamFontWeight);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      regular: other.regular,
      medium: other.medium,
      semibold: other.semibold,
      bold: other.bold,
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

    final _this = (this as StreamFontWeight);
    final _other = (other as StreamFontWeight);

    return _other.regular == _this.regular &&
        _other.medium == _this.medium &&
        _other.semibold == _this.semibold &&
        _other.bold == _this.bold;
  }

  @override
  int get hashCode {
    final _this = (this as StreamFontWeight);

    return Object.hash(
      runtimeType,
      _this.regular,
      _this.medium,
      _this.semibold,
      _this.bold,
    );
  }
}
