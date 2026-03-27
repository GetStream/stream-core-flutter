// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_color_scheme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamColorScheme {
  bool get canMerge => true;

  static StreamColorScheme? lerp(
    StreamColorScheme? a,
    StreamColorScheme? b,
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

    return StreamColorScheme.raw(
      brand: t < 0.5 ? a.brand : b.brand,
      chrome: t < 0.5 ? a.chrome : b.chrome,
      accentPrimary: Color.lerp(a.accentPrimary, b.accentPrimary, t)!,
      accentSuccess: Color.lerp(a.accentSuccess, b.accentSuccess, t)!,
      accentWarning: Color.lerp(a.accentWarning, b.accentWarning, t)!,
      accentError: Color.lerp(a.accentError, b.accentError, t)!,
      accentNeutral: Color.lerp(a.accentNeutral, b.accentNeutral, t)!,
      textPrimary: Color.lerp(a.textPrimary, b.textPrimary, t)!,
      textSecondary: Color.lerp(a.textSecondary, b.textSecondary, t)!,
      textTertiary: Color.lerp(a.textTertiary, b.textTertiary, t)!,
      textDisabled: Color.lerp(a.textDisabled, b.textDisabled, t)!,
      textLink: Color.lerp(a.textLink, b.textLink, t)!,
      textOnAccent: Color.lerp(a.textOnAccent, b.textOnAccent, t)!,
      textOnInverse: Color.lerp(a.textOnInverse, b.textOnInverse, t)!,
      backgroundApp: Color.lerp(a.backgroundApp, b.backgroundApp, t)!,
      backgroundSurface: Color.lerp(
        a.backgroundSurface,
        b.backgroundSurface,
        t,
      )!,
      backgroundSurfaceSubtle: Color.lerp(
        a.backgroundSurfaceSubtle,
        b.backgroundSurfaceSubtle,
        t,
      )!,
      backgroundSurfaceStrong: Color.lerp(
        a.backgroundSurfaceStrong,
        b.backgroundSurfaceStrong,
        t,
      )!,
      backgroundSurfaceCard: Color.lerp(
        a.backgroundSurfaceCard,
        b.backgroundSurfaceCard,
        t,
      )!,
      backgroundOnAccent: Color.lerp(
        a.backgroundOnAccent,
        b.backgroundOnAccent,
        t,
      )!,
      backgroundHighlight: Color.lerp(
        a.backgroundHighlight,
        b.backgroundHighlight,
        t,
      )!,
      backgroundScrim: Color.lerp(a.backgroundScrim, b.backgroundScrim, t)!,
      backgroundOverlayLight: Color.lerp(
        a.backgroundOverlayLight,
        b.backgroundOverlayLight,
        t,
      )!,
      backgroundOverlayDark: Color.lerp(
        a.backgroundOverlayDark,
        b.backgroundOverlayDark,
        t,
      )!,
      backgroundDisabled: Color.lerp(
        a.backgroundDisabled,
        b.backgroundDisabled,
        t,
      )!,
      backgroundHover: Color.lerp(a.backgroundHover, b.backgroundHover, t)!,
      backgroundPressed: Color.lerp(
        a.backgroundPressed,
        b.backgroundPressed,
        t,
      )!,
      backgroundSelected: Color.lerp(
        a.backgroundSelected,
        b.backgroundSelected,
        t,
      )!,
      backgroundInverse: Color.lerp(
        a.backgroundInverse,
        b.backgroundInverse,
        t,
      )!,
      backgroundElevation0: Color.lerp(
        a.backgroundElevation0,
        b.backgroundElevation0,
        t,
      )!,
      backgroundElevation1: Color.lerp(
        a.backgroundElevation1,
        b.backgroundElevation1,
        t,
      )!,
      backgroundElevation2: Color.lerp(
        a.backgroundElevation2,
        b.backgroundElevation2,
        t,
      )!,
      backgroundElevation3: Color.lerp(
        a.backgroundElevation3,
        b.backgroundElevation3,
        t,
      )!,
      borderDefault: Color.lerp(a.borderDefault, b.borderDefault, t)!,
      borderSubtle: Color.lerp(a.borderSubtle, b.borderSubtle, t)!,
      borderStrong: Color.lerp(a.borderStrong, b.borderStrong, t)!,
      borderOnAccent: Color.lerp(a.borderOnAccent, b.borderOnAccent, t)!,
      borderOnInverse: Color.lerp(a.borderOnInverse, b.borderOnInverse, t)!,
      borderOnSurface: Color.lerp(a.borderOnSurface, b.borderOnSurface, t)!,
      borderOpacitySubtle: Color.lerp(
        a.borderOpacitySubtle,
        b.borderOpacitySubtle,
        t,
      )!,
      borderOpacityStrong: Color.lerp(
        a.borderOpacityStrong,
        b.borderOpacityStrong,
        t,
      )!,
      borderFocus: Color.lerp(a.borderFocus, b.borderFocus, t)!,
      borderDisabled: Color.lerp(a.borderDisabled, b.borderDisabled, t)!,
      borderDisabledOnSurface: Color.lerp(
        a.borderDisabledOnSurface,
        b.borderDisabledOnSurface,
        t,
      )!,
      borderHover: Color.lerp(a.borderHover, b.borderHover, t)!,
      borderPressed: Color.lerp(a.borderPressed, b.borderPressed, t)!,
      borderActive: Color.lerp(a.borderActive, b.borderActive, t)!,
      borderError: Color.lerp(a.borderError, b.borderError, t)!,
      borderWarning: Color.lerp(a.borderWarning, b.borderWarning, t)!,
      borderSuccess: Color.lerp(a.borderSuccess, b.borderSuccess, t)!,
      borderSelected: Color.lerp(a.borderSelected, b.borderSelected, t)!,
      systemText: Color.lerp(a.systemText, b.systemText, t)!,
      systemScrollbar: Color.lerp(a.systemScrollbar, b.systemScrollbar, t)!,
      avatarPalette: t < 0.5 ? a.avatarPalette : b.avatarPalette,
    );
  }

  StreamColorScheme copyWith({
    StreamColorSwatch? brand,
    StreamColorSwatch? chrome,
    Color? accentPrimary,
    Color? accentSuccess,
    Color? accentWarning,
    Color? accentError,
    Color? accentNeutral,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? textLink,
    Color? textOnAccent,
    Color? textOnInverse,
    Color? backgroundApp,
    Color? backgroundSurface,
    Color? backgroundSurfaceSubtle,
    Color? backgroundSurfaceStrong,
    Color? backgroundSurfaceCard,
    Color? backgroundOnAccent,
    Color? backgroundHighlight,
    Color? backgroundScrim,
    Color? backgroundOverlayLight,
    Color? backgroundOverlayDark,
    Color? backgroundDisabled,
    Color? backgroundHover,
    Color? backgroundPressed,
    Color? backgroundSelected,
    Color? backgroundInverse,
    Color? backgroundElevation0,
    Color? backgroundElevation1,
    Color? backgroundElevation2,
    Color? backgroundElevation3,
    Color? borderDefault,
    Color? borderSubtle,
    Color? borderStrong,
    Color? borderOnAccent,
    Color? borderOnInverse,
    Color? borderOnSurface,
    Color? borderOpacitySubtle,
    Color? borderOpacityStrong,
    Color? borderFocus,
    Color? borderDisabled,
    Color? borderDisabledOnSurface,
    Color? borderHover,
    Color? borderPressed,
    Color? borderActive,
    Color? borderError,
    Color? borderWarning,
    Color? borderSuccess,
    Color? borderSelected,
    Color? systemText,
    Color? systemScrollbar,
    List<StreamAvatarColorPair>? avatarPalette,
  }) {
    final _this = (this as StreamColorScheme);

    return StreamColorScheme.raw(
      brand: brand ?? _this.brand,
      chrome: chrome ?? _this.chrome,
      accentPrimary: accentPrimary ?? _this.accentPrimary,
      accentSuccess: accentSuccess ?? _this.accentSuccess,
      accentWarning: accentWarning ?? _this.accentWarning,
      accentError: accentError ?? _this.accentError,
      accentNeutral: accentNeutral ?? _this.accentNeutral,
      textPrimary: textPrimary ?? _this.textPrimary,
      textSecondary: textSecondary ?? _this.textSecondary,
      textTertiary: textTertiary ?? _this.textTertiary,
      textDisabled: textDisabled ?? _this.textDisabled,
      textLink: textLink ?? _this.textLink,
      textOnAccent: textOnAccent ?? _this.textOnAccent,
      textOnInverse: textOnInverse ?? _this.textOnInverse,
      backgroundApp: backgroundApp ?? _this.backgroundApp,
      backgroundSurface: backgroundSurface ?? _this.backgroundSurface,
      backgroundSurfaceSubtle:
          backgroundSurfaceSubtle ?? _this.backgroundSurfaceSubtle,
      backgroundSurfaceStrong:
          backgroundSurfaceStrong ?? _this.backgroundSurfaceStrong,
      backgroundSurfaceCard:
          backgroundSurfaceCard ?? _this.backgroundSurfaceCard,
      backgroundOnAccent: backgroundOnAccent ?? _this.backgroundOnAccent,
      backgroundHighlight: backgroundHighlight ?? _this.backgroundHighlight,
      backgroundScrim: backgroundScrim ?? _this.backgroundScrim,
      backgroundOverlayLight:
          backgroundOverlayLight ?? _this.backgroundOverlayLight,
      backgroundOverlayDark:
          backgroundOverlayDark ?? _this.backgroundOverlayDark,
      backgroundDisabled: backgroundDisabled ?? _this.backgroundDisabled,
      backgroundHover: backgroundHover ?? _this.backgroundHover,
      backgroundPressed: backgroundPressed ?? _this.backgroundPressed,
      backgroundSelected: backgroundSelected ?? _this.backgroundSelected,
      backgroundInverse: backgroundInverse ?? _this.backgroundInverse,
      backgroundElevation0: backgroundElevation0 ?? _this.backgroundElevation0,
      backgroundElevation1: backgroundElevation1 ?? _this.backgroundElevation1,
      backgroundElevation2: backgroundElevation2 ?? _this.backgroundElevation2,
      backgroundElevation3: backgroundElevation3 ?? _this.backgroundElevation3,
      borderDefault: borderDefault ?? _this.borderDefault,
      borderSubtle: borderSubtle ?? _this.borderSubtle,
      borderStrong: borderStrong ?? _this.borderStrong,
      borderOnAccent: borderOnAccent ?? _this.borderOnAccent,
      borderOnInverse: borderOnInverse ?? _this.borderOnInverse,
      borderOnSurface: borderOnSurface ?? _this.borderOnSurface,
      borderOpacitySubtle: borderOpacitySubtle ?? _this.borderOpacitySubtle,
      borderOpacityStrong: borderOpacityStrong ?? _this.borderOpacityStrong,
      borderFocus: borderFocus ?? _this.borderFocus,
      borderDisabled: borderDisabled ?? _this.borderDisabled,
      borderDisabledOnSurface:
          borderDisabledOnSurface ?? _this.borderDisabledOnSurface,
      borderHover: borderHover ?? _this.borderHover,
      borderPressed: borderPressed ?? _this.borderPressed,
      borderActive: borderActive ?? _this.borderActive,
      borderError: borderError ?? _this.borderError,
      borderWarning: borderWarning ?? _this.borderWarning,
      borderSuccess: borderSuccess ?? _this.borderSuccess,
      borderSelected: borderSelected ?? _this.borderSelected,
      systemText: systemText ?? _this.systemText,
      systemScrollbar: systemScrollbar ?? _this.systemScrollbar,
      avatarPalette: avatarPalette ?? _this.avatarPalette,
    );
  }

  StreamColorScheme merge(StreamColorScheme? other) {
    final _this = (this as StreamColorScheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      brand: other.brand,
      chrome: other.chrome,
      accentPrimary: other.accentPrimary,
      accentSuccess: other.accentSuccess,
      accentWarning: other.accentWarning,
      accentError: other.accentError,
      accentNeutral: other.accentNeutral,
      textPrimary: other.textPrimary,
      textSecondary: other.textSecondary,
      textTertiary: other.textTertiary,
      textDisabled: other.textDisabled,
      textLink: other.textLink,
      textOnAccent: other.textOnAccent,
      textOnInverse: other.textOnInverse,
      backgroundApp: other.backgroundApp,
      backgroundSurface: other.backgroundSurface,
      backgroundSurfaceSubtle: other.backgroundSurfaceSubtle,
      backgroundSurfaceStrong: other.backgroundSurfaceStrong,
      backgroundSurfaceCard: other.backgroundSurfaceCard,
      backgroundOnAccent: other.backgroundOnAccent,
      backgroundHighlight: other.backgroundHighlight,
      backgroundScrim: other.backgroundScrim,
      backgroundOverlayLight: other.backgroundOverlayLight,
      backgroundOverlayDark: other.backgroundOverlayDark,
      backgroundDisabled: other.backgroundDisabled,
      backgroundHover: other.backgroundHover,
      backgroundPressed: other.backgroundPressed,
      backgroundSelected: other.backgroundSelected,
      backgroundInverse: other.backgroundInverse,
      backgroundElevation0: other.backgroundElevation0,
      backgroundElevation1: other.backgroundElevation1,
      backgroundElevation2: other.backgroundElevation2,
      backgroundElevation3: other.backgroundElevation3,
      borderDefault: other.borderDefault,
      borderSubtle: other.borderSubtle,
      borderStrong: other.borderStrong,
      borderOnAccent: other.borderOnAccent,
      borderOnInverse: other.borderOnInverse,
      borderOnSurface: other.borderOnSurface,
      borderOpacitySubtle: other.borderOpacitySubtle,
      borderOpacityStrong: other.borderOpacityStrong,
      borderFocus: other.borderFocus,
      borderDisabled: other.borderDisabled,
      borderDisabledOnSurface: other.borderDisabledOnSurface,
      borderHover: other.borderHover,
      borderPressed: other.borderPressed,
      borderActive: other.borderActive,
      borderError: other.borderError,
      borderWarning: other.borderWarning,
      borderSuccess: other.borderSuccess,
      borderSelected: other.borderSelected,
      systemText: other.systemText,
      systemScrollbar: other.systemScrollbar,
      avatarPalette: other.avatarPalette,
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

    final _this = (this as StreamColorScheme);
    final _other = (other as StreamColorScheme);

    return _other.brand == _this.brand &&
        _other.chrome == _this.chrome &&
        _other.accentPrimary == _this.accentPrimary &&
        _other.accentSuccess == _this.accentSuccess &&
        _other.accentWarning == _this.accentWarning &&
        _other.accentError == _this.accentError &&
        _other.accentNeutral == _this.accentNeutral &&
        _other.textPrimary == _this.textPrimary &&
        _other.textSecondary == _this.textSecondary &&
        _other.textTertiary == _this.textTertiary &&
        _other.textDisabled == _this.textDisabled &&
        _other.textLink == _this.textLink &&
        _other.textOnAccent == _this.textOnAccent &&
        _other.textOnInverse == _this.textOnInverse &&
        _other.backgroundApp == _this.backgroundApp &&
        _other.backgroundSurface == _this.backgroundSurface &&
        _other.backgroundSurfaceSubtle == _this.backgroundSurfaceSubtle &&
        _other.backgroundSurfaceStrong == _this.backgroundSurfaceStrong &&
        _other.backgroundSurfaceCard == _this.backgroundSurfaceCard &&
        _other.backgroundOnAccent == _this.backgroundOnAccent &&
        _other.backgroundHighlight == _this.backgroundHighlight &&
        _other.backgroundScrim == _this.backgroundScrim &&
        _other.backgroundOverlayLight == _this.backgroundOverlayLight &&
        _other.backgroundOverlayDark == _this.backgroundOverlayDark &&
        _other.backgroundDisabled == _this.backgroundDisabled &&
        _other.backgroundHover == _this.backgroundHover &&
        _other.backgroundPressed == _this.backgroundPressed &&
        _other.backgroundSelected == _this.backgroundSelected &&
        _other.backgroundInverse == _this.backgroundInverse &&
        _other.backgroundElevation0 == _this.backgroundElevation0 &&
        _other.backgroundElevation1 == _this.backgroundElevation1 &&
        _other.backgroundElevation2 == _this.backgroundElevation2 &&
        _other.backgroundElevation3 == _this.backgroundElevation3 &&
        _other.borderDefault == _this.borderDefault &&
        _other.borderSubtle == _this.borderSubtle &&
        _other.borderStrong == _this.borderStrong &&
        _other.borderOnAccent == _this.borderOnAccent &&
        _other.borderOnInverse == _this.borderOnInverse &&
        _other.borderOnSurface == _this.borderOnSurface &&
        _other.borderOpacitySubtle == _this.borderOpacitySubtle &&
        _other.borderOpacityStrong == _this.borderOpacityStrong &&
        _other.borderFocus == _this.borderFocus &&
        _other.borderDisabled == _this.borderDisabled &&
        _other.borderDisabledOnSurface == _this.borderDisabledOnSurface &&
        _other.borderHover == _this.borderHover &&
        _other.borderPressed == _this.borderPressed &&
        _other.borderActive == _this.borderActive &&
        _other.borderError == _this.borderError &&
        _other.borderWarning == _this.borderWarning &&
        _other.borderSuccess == _this.borderSuccess &&
        _other.borderSelected == _this.borderSelected &&
        _other.systemText == _this.systemText &&
        _other.systemScrollbar == _this.systemScrollbar &&
        _other.avatarPalette == _this.avatarPalette;
  }

  @override
  int get hashCode {
    final _this = (this as StreamColorScheme);

    return Object.hashAll([
      runtimeType,
      _this.brand,
      _this.chrome,
      _this.accentPrimary,
      _this.accentSuccess,
      _this.accentWarning,
      _this.accentError,
      _this.accentNeutral,
      _this.textPrimary,
      _this.textSecondary,
      _this.textTertiary,
      _this.textDisabled,
      _this.textLink,
      _this.textOnAccent,
      _this.textOnInverse,
      _this.backgroundApp,
      _this.backgroundSurface,
      _this.backgroundSurfaceSubtle,
      _this.backgroundSurfaceStrong,
      _this.backgroundSurfaceCard,
      _this.backgroundOnAccent,
      _this.backgroundHighlight,
      _this.backgroundScrim,
      _this.backgroundOverlayLight,
      _this.backgroundOverlayDark,
      _this.backgroundDisabled,
      _this.backgroundHover,
      _this.backgroundPressed,
      _this.backgroundSelected,
      _this.backgroundInverse,
      _this.backgroundElevation0,
      _this.backgroundElevation1,
      _this.backgroundElevation2,
      _this.backgroundElevation3,
      _this.borderDefault,
      _this.borderSubtle,
      _this.borderStrong,
      _this.borderOnAccent,
      _this.borderOnInverse,
      _this.borderOnSurface,
      _this.borderOpacitySubtle,
      _this.borderOpacityStrong,
      _this.borderFocus,
      _this.borderDisabled,
      _this.borderDisabledOnSurface,
      _this.borderHover,
      _this.borderPressed,
      _this.borderActive,
      _this.borderError,
      _this.borderWarning,
      _this.borderSuccess,
      _this.borderSelected,
      _this.systemText,
      _this.systemScrollbar,
      _this.avatarPalette,
    ]);
  }
}

mixin _$StreamAvatarColorPair {
  bool get canMerge => true;

  static StreamAvatarColorPair? lerp(
    StreamAvatarColorPair? a,
    StreamAvatarColorPair? b,
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

    return StreamAvatarColorPair(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t)!,
      foregroundColor: Color.lerp(a.foregroundColor, b.foregroundColor, t)!,
    );
  }

  StreamAvatarColorPair copyWith({
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    final _this = (this as StreamAvatarColorPair);

    return StreamAvatarColorPair(
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      foregroundColor: foregroundColor ?? _this.foregroundColor,
    );
  }

  StreamAvatarColorPair merge(StreamAvatarColorPair? other) {
    final _this = (this as StreamAvatarColorPair);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      backgroundColor: other.backgroundColor,
      foregroundColor: other.foregroundColor,
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

    final _this = (this as StreamAvatarColorPair);
    final _other = (other as StreamAvatarColorPair);

    return _other.backgroundColor == _this.backgroundColor &&
        _other.foregroundColor == _this.foregroundColor;
  }

  @override
  int get hashCode {
    final _this = (this as StreamAvatarColorPair);

    return Object.hash(
      runtimeType,
      _this.backgroundColor,
      _this.foregroundColor,
    );
  }
}
