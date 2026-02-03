// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_text_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamTextTheme {
  bool get canMerge => true;

  static StreamTextTheme? lerp(
    StreamTextTheme? a,
    StreamTextTheme? b,
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

    return StreamTextTheme.raw(
      headingLg: TextStyle.lerp(a.headingLg, b.headingLg, t)!,
      headingMd: TextStyle.lerp(a.headingMd, b.headingMd, t)!,
      headingSm: TextStyle.lerp(a.headingSm, b.headingSm, t)!,
      bodyDefault: TextStyle.lerp(a.bodyDefault, b.bodyDefault, t)!,
      bodyEmphasis: TextStyle.lerp(a.bodyEmphasis, b.bodyEmphasis, t)!,
      bodyLink: TextStyle.lerp(a.bodyLink, b.bodyLink, t)!,
      bodyLinkEmphasis: TextStyle.lerp(
        a.bodyLinkEmphasis,
        b.bodyLinkEmphasis,
        t,
      )!,
      captionDefault: TextStyle.lerp(a.captionDefault, b.captionDefault, t)!,
      captionEmphasis: TextStyle.lerp(a.captionEmphasis, b.captionEmphasis, t)!,
      captionLink: TextStyle.lerp(a.captionLink, b.captionLink, t)!,
      captionLinkEmphasis: TextStyle.lerp(
        a.captionLinkEmphasis,
        b.captionLinkEmphasis,
        t,
      )!,
      metadataDefault: TextStyle.lerp(a.metadataDefault, b.metadataDefault, t)!,
      metadataEmphasis: TextStyle.lerp(
        a.metadataEmphasis,
        b.metadataEmphasis,
        t,
      )!,
      metadataLink: TextStyle.lerp(a.metadataLink, b.metadataLink, t)!,
      metadataLinkEmphasis: TextStyle.lerp(
        a.metadataLinkEmphasis,
        b.metadataLinkEmphasis,
        t,
      )!,
      numericXl: TextStyle.lerp(a.numericXl, b.numericXl, t)!,
      numericLg: TextStyle.lerp(a.numericLg, b.numericLg, t)!,
      numericMd: TextStyle.lerp(a.numericMd, b.numericMd, t)!,
      numericSm: TextStyle.lerp(a.numericSm, b.numericSm, t)!,
    );
  }

  StreamTextTheme copyWith({
    TextStyle? headingLg,
    TextStyle? headingMd,
    TextStyle? headingSm,
    TextStyle? bodyDefault,
    TextStyle? bodyEmphasis,
    TextStyle? bodyLink,
    TextStyle? bodyLinkEmphasis,
    TextStyle? captionDefault,
    TextStyle? captionEmphasis,
    TextStyle? captionLink,
    TextStyle? captionLinkEmphasis,
    TextStyle? metadataDefault,
    TextStyle? metadataEmphasis,
    TextStyle? metadataLink,
    TextStyle? metadataLinkEmphasis,
    TextStyle? numericXl,
    TextStyle? numericLg,
    TextStyle? numericMd,
    TextStyle? numericSm,
  }) {
    final _this = (this as StreamTextTheme);

    return StreamTextTheme.raw(
      headingLg: headingLg ?? _this.headingLg,
      headingMd: headingMd ?? _this.headingMd,
      headingSm: headingSm ?? _this.headingSm,
      bodyDefault: bodyDefault ?? _this.bodyDefault,
      bodyEmphasis: bodyEmphasis ?? _this.bodyEmphasis,
      bodyLink: bodyLink ?? _this.bodyLink,
      bodyLinkEmphasis: bodyLinkEmphasis ?? _this.bodyLinkEmphasis,
      captionDefault: captionDefault ?? _this.captionDefault,
      captionEmphasis: captionEmphasis ?? _this.captionEmphasis,
      captionLink: captionLink ?? _this.captionLink,
      captionLinkEmphasis: captionLinkEmphasis ?? _this.captionLinkEmphasis,
      metadataDefault: metadataDefault ?? _this.metadataDefault,
      metadataEmphasis: metadataEmphasis ?? _this.metadataEmphasis,
      metadataLink: metadataLink ?? _this.metadataLink,
      metadataLinkEmphasis: metadataLinkEmphasis ?? _this.metadataLinkEmphasis,
      numericXl: numericXl ?? _this.numericXl,
      numericLg: numericLg ?? _this.numericLg,
      numericMd: numericMd ?? _this.numericMd,
      numericSm: numericSm ?? _this.numericSm,
    );
  }

  StreamTextTheme merge(StreamTextTheme? other) {
    final _this = (this as StreamTextTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      headingLg: _this.headingLg.merge(other.headingLg),
      headingMd: _this.headingMd.merge(other.headingMd),
      headingSm: _this.headingSm.merge(other.headingSm),
      bodyDefault: _this.bodyDefault.merge(other.bodyDefault),
      bodyEmphasis: _this.bodyEmphasis.merge(other.bodyEmphasis),
      bodyLink: _this.bodyLink.merge(other.bodyLink),
      bodyLinkEmphasis: _this.bodyLinkEmphasis.merge(other.bodyLinkEmphasis),
      captionDefault: _this.captionDefault.merge(other.captionDefault),
      captionEmphasis: _this.captionEmphasis.merge(other.captionEmphasis),
      captionLink: _this.captionLink.merge(other.captionLink),
      captionLinkEmphasis: _this.captionLinkEmphasis.merge(
        other.captionLinkEmphasis,
      ),
      metadataDefault: _this.metadataDefault.merge(other.metadataDefault),
      metadataEmphasis: _this.metadataEmphasis.merge(other.metadataEmphasis),
      metadataLink: _this.metadataLink.merge(other.metadataLink),
      metadataLinkEmphasis: _this.metadataLinkEmphasis.merge(
        other.metadataLinkEmphasis,
      ),
      numericXl: _this.numericXl.merge(other.numericXl),
      numericLg: _this.numericLg.merge(other.numericLg),
      numericMd: _this.numericMd.merge(other.numericMd),
      numericSm: _this.numericSm.merge(other.numericSm),
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

    final _this = (this as StreamTextTheme);
    final _other = (other as StreamTextTheme);

    return _other.headingLg == _this.headingLg &&
        _other.headingMd == _this.headingMd &&
        _other.headingSm == _this.headingSm &&
        _other.bodyDefault == _this.bodyDefault &&
        _other.bodyEmphasis == _this.bodyEmphasis &&
        _other.bodyLink == _this.bodyLink &&
        _other.bodyLinkEmphasis == _this.bodyLinkEmphasis &&
        _other.captionDefault == _this.captionDefault &&
        _other.captionEmphasis == _this.captionEmphasis &&
        _other.captionLink == _this.captionLink &&
        _other.captionLinkEmphasis == _this.captionLinkEmphasis &&
        _other.metadataDefault == _this.metadataDefault &&
        _other.metadataEmphasis == _this.metadataEmphasis &&
        _other.metadataLink == _this.metadataLink &&
        _other.metadataLinkEmphasis == _this.metadataLinkEmphasis &&
        _other.numericXl == _this.numericXl &&
        _other.numericLg == _this.numericLg &&
        _other.numericMd == _this.numericMd &&
        _other.numericSm == _this.numericSm;
  }

  @override
  int get hashCode {
    final _this = (this as StreamTextTheme);

    return Object.hash(
      runtimeType,
      _this.headingLg,
      _this.headingMd,
      _this.headingSm,
      _this.bodyDefault,
      _this.bodyEmphasis,
      _this.bodyLink,
      _this.bodyLinkEmphasis,
      _this.captionDefault,
      _this.captionEmphasis,
      _this.captionLink,
      _this.captionLinkEmphasis,
      _this.metadataDefault,
      _this.metadataEmphasis,
      _this.metadataLink,
      _this.metadataLinkEmphasis,
      _this.numericXl,
      _this.numericLg,
      _this.numericMd,
      _this.numericSm,
    );
  }
}
