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
      accentPrimary: Color.lerp(a.accentPrimary, b.accentPrimary, t)!,
      accentSuccess: Color.lerp(a.accentSuccess, b.accentSuccess, t)!,
      accentWarning: Color.lerp(a.accentWarning, b.accentWarning, t)!,
      accentError: Color.lerp(a.accentError, b.accentError, t)!,
      accentNeutral: Color.lerp(a.accentNeutral, b.accentNeutral, t)!,
      accentBlack: Color.lerp(a.accentBlack, b.accentBlack, t)!,
      textPrimary: Color.lerp(a.textPrimary, b.textPrimary, t)!,
      textSecondary: Color.lerp(a.textSecondary, b.textSecondary, t)!,
      textTertiary: Color.lerp(a.textTertiary, b.textTertiary, t)!,
      textDisabled: Color.lerp(a.textDisabled, b.textDisabled, t)!,
      textInverse: Color.lerp(a.textInverse, b.textInverse, t)!,
      textLink: Color.lerp(a.textLink, b.textLink, t)!,
      textOnAccent: Color.lerp(a.textOnAccent, b.textOnAccent, t)!,
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
      backgroundOverlay: Color.lerp(
        a.backgroundOverlay,
        b.backgroundOverlay,
        t,
      )!,
      backgroundDisabled: Color.lerp(
        a.backgroundDisabled,
        b.backgroundDisabled,
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
      backgroundElevation4: Color.lerp(
        a.backgroundElevation4,
        b.backgroundElevation4,
        t,
      )!,
      borderDefault: Color.lerp(a.borderDefault, b.borderDefault, t)!,
      borderSubtle: Color.lerp(a.borderSubtle, b.borderSubtle, t)!,
      borderStrong: Color.lerp(a.borderStrong, b.borderStrong, t)!,
      borderOnDark: Color.lerp(a.borderOnDark, b.borderOnDark, t)!,
      borderOnAccent: Color.lerp(a.borderOnAccent, b.borderOnAccent, t)!,
      borderOpacity10: Color.lerp(a.borderOpacity10, b.borderOpacity10, t)!,
      borderOpacity25: Color.lerp(a.borderOpacity25, b.borderOpacity25, t)!,
      borderFocus: Color.lerp(a.borderFocus, b.borderFocus, t)!,
      borderDisabled: Color.lerp(a.borderDisabled, b.borderDisabled, t)!,
      borderError: Color.lerp(a.borderError, b.borderError, t)!,
      borderWarning: Color.lerp(a.borderWarning, b.borderWarning, t)!,
      borderSuccess: Color.lerp(a.borderSuccess, b.borderSuccess, t)!,
      borderSelected: Color.lerp(a.borderSelected, b.borderSelected, t)!,
      stateHover: Color.lerp(a.stateHover, b.stateHover, t)!,
      statePressed: Color.lerp(a.statePressed, b.statePressed, t)!,
      stateSelected: Color.lerp(a.stateSelected, b.stateSelected, t)!,
      stateFocused: Color.lerp(a.stateFocused, b.stateFocused, t)!,
      stateDisabled: Color.lerp(a.stateDisabled, b.stateDisabled, t)!,
      systemText: Color.lerp(a.systemText, b.systemText, t)!,
      systemScrollbar: Color.lerp(a.systemScrollbar, b.systemScrollbar, t)!,
      avatarPalette: t < 0.5 ? a.avatarPalette : b.avatarPalette,
    );
  }

  StreamColorScheme copyWith({
    StreamColorSwatch? brand,
    Color? accentPrimary,
    Color? accentSuccess,
    Color? accentWarning,
    Color? accentError,
    Color? accentNeutral,
    Color? accentBlack,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? textInverse,
    Color? textLink,
    Color? textOnAccent,
    Color? backgroundApp,
    Color? backgroundSurface,
    Color? backgroundSurfaceSubtle,
    Color? backgroundSurfaceStrong,
    Color? backgroundOverlay,
    Color? backgroundDisabled,
    Color? backgroundInverse,
    Color? backgroundElevation0,
    Color? backgroundElevation1,
    Color? backgroundElevation2,
    Color? backgroundElevation3,
    Color? backgroundElevation4,
    Color? borderDefault,
    Color? borderSubtle,
    Color? borderStrong,
    Color? borderOnDark,
    Color? borderOnAccent,
    Color? borderOpacity10,
    Color? borderOpacity25,
    Color? borderFocus,
    Color? borderDisabled,
    Color? borderError,
    Color? borderWarning,
    Color? borderSuccess,
    Color? borderSelected,
    Color? stateHover,
    Color? statePressed,
    Color? stateSelected,
    Color? stateFocused,
    Color? stateDisabled,
    Color? systemText,
    Color? systemScrollbar,
    List<StreamAvatarColorPair>? avatarPalette,
  }) {
    final _this = (this as StreamColorScheme);

    return StreamColorScheme.raw(
      brand: brand ?? _this.brand,
      accentPrimary: accentPrimary ?? _this.accentPrimary,
      accentSuccess: accentSuccess ?? _this.accentSuccess,
      accentWarning: accentWarning ?? _this.accentWarning,
      accentError: accentError ?? _this.accentError,
      accentNeutral: accentNeutral ?? _this.accentNeutral,
      accentBlack: accentBlack ?? _this.accentBlack,
      textPrimary: textPrimary ?? _this.textPrimary,
      textSecondary: textSecondary ?? _this.textSecondary,
      textTertiary: textTertiary ?? _this.textTertiary,
      textDisabled: textDisabled ?? _this.textDisabled,
      textInverse: textInverse ?? _this.textInverse,
      textLink: textLink ?? _this.textLink,
      textOnAccent: textOnAccent ?? _this.textOnAccent,
      backgroundApp: backgroundApp ?? _this.backgroundApp,
      backgroundSurface: backgroundSurface ?? _this.backgroundSurface,
      backgroundSurfaceSubtle:
          backgroundSurfaceSubtle ?? _this.backgroundSurfaceSubtle,
      backgroundSurfaceStrong:
          backgroundSurfaceStrong ?? _this.backgroundSurfaceStrong,
      backgroundOverlay: backgroundOverlay ?? _this.backgroundOverlay,
      backgroundDisabled: backgroundDisabled ?? _this.backgroundDisabled,
      backgroundInverse: backgroundInverse ?? _this.backgroundInverse,
      backgroundElevation0: backgroundElevation0 ?? _this.backgroundElevation0,
      backgroundElevation1: backgroundElevation1 ?? _this.backgroundElevation1,
      backgroundElevation2: backgroundElevation2 ?? _this.backgroundElevation2,
      backgroundElevation3: backgroundElevation3 ?? _this.backgroundElevation3,
      backgroundElevation4: backgroundElevation4 ?? _this.backgroundElevation4,
      borderDefault: borderDefault ?? _this.borderDefault,
      borderSubtle: borderSubtle ?? _this.borderSubtle,
      borderStrong: borderStrong ?? _this.borderStrong,
      borderOnDark: borderOnDark ?? _this.borderOnDark,
      borderOnAccent: borderOnAccent ?? _this.borderOnAccent,
      borderOpacity10: borderOpacity10 ?? _this.borderOpacity10,
      borderOpacity25: borderOpacity25 ?? _this.borderOpacity25,
      borderFocus: borderFocus ?? _this.borderFocus,
      borderDisabled: borderDisabled ?? _this.borderDisabled,
      borderError: borderError ?? _this.borderError,
      borderWarning: borderWarning ?? _this.borderWarning,
      borderSuccess: borderSuccess ?? _this.borderSuccess,
      borderSelected: borderSelected ?? _this.borderSelected,
      stateHover: stateHover ?? _this.stateHover,
      statePressed: statePressed ?? _this.statePressed,
      stateSelected: stateSelected ?? _this.stateSelected,
      stateFocused: stateFocused ?? _this.stateFocused,
      stateDisabled: stateDisabled ?? _this.stateDisabled,
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
      accentPrimary: other.accentPrimary,
      accentSuccess: other.accentSuccess,
      accentWarning: other.accentWarning,
      accentError: other.accentError,
      accentNeutral: other.accentNeutral,
      accentBlack: other.accentBlack,
      textPrimary: other.textPrimary,
      textSecondary: other.textSecondary,
      textTertiary: other.textTertiary,
      textDisabled: other.textDisabled,
      textInverse: other.textInverse,
      textLink: other.textLink,
      textOnAccent: other.textOnAccent,
      backgroundApp: other.backgroundApp,
      backgroundSurface: other.backgroundSurface,
      backgroundSurfaceSubtle: other.backgroundSurfaceSubtle,
      backgroundSurfaceStrong: other.backgroundSurfaceStrong,
      backgroundOverlay: other.backgroundOverlay,
      backgroundDisabled: other.backgroundDisabled,
      backgroundInverse: other.backgroundInverse,
      backgroundElevation0: other.backgroundElevation0,
      backgroundElevation1: other.backgroundElevation1,
      backgroundElevation2: other.backgroundElevation2,
      backgroundElevation3: other.backgroundElevation3,
      backgroundElevation4: other.backgroundElevation4,
      borderDefault: other.borderDefault,
      borderSubtle: other.borderSubtle,
      borderStrong: other.borderStrong,
      borderOnDark: other.borderOnDark,
      borderOnAccent: other.borderOnAccent,
      borderOpacity10: other.borderOpacity10,
      borderOpacity25: other.borderOpacity25,
      borderFocus: other.borderFocus,
      borderDisabled: other.borderDisabled,
      borderError: other.borderError,
      borderWarning: other.borderWarning,
      borderSuccess: other.borderSuccess,
      borderSelected: other.borderSelected,
      stateHover: other.stateHover,
      statePressed: other.statePressed,
      stateSelected: other.stateSelected,
      stateFocused: other.stateFocused,
      stateDisabled: other.stateDisabled,
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
        _other.accentPrimary == _this.accentPrimary &&
        _other.accentSuccess == _this.accentSuccess &&
        _other.accentWarning == _this.accentWarning &&
        _other.accentError == _this.accentError &&
        _other.accentNeutral == _this.accentNeutral &&
        _other.accentBlack == _this.accentBlack &&
        _other.textPrimary == _this.textPrimary &&
        _other.textSecondary == _this.textSecondary &&
        _other.textTertiary == _this.textTertiary &&
        _other.textDisabled == _this.textDisabled &&
        _other.textInverse == _this.textInverse &&
        _other.textLink == _this.textLink &&
        _other.textOnAccent == _this.textOnAccent &&
        _other.backgroundApp == _this.backgroundApp &&
        _other.backgroundSurface == _this.backgroundSurface &&
        _other.backgroundSurfaceSubtle == _this.backgroundSurfaceSubtle &&
        _other.backgroundSurfaceStrong == _this.backgroundSurfaceStrong &&
        _other.backgroundOverlay == _this.backgroundOverlay &&
        _other.backgroundDisabled == _this.backgroundDisabled &&
        _other.backgroundInverse == _this.backgroundInverse &&
        _other.backgroundElevation0 == _this.backgroundElevation0 &&
        _other.backgroundElevation1 == _this.backgroundElevation1 &&
        _other.backgroundElevation2 == _this.backgroundElevation2 &&
        _other.backgroundElevation3 == _this.backgroundElevation3 &&
        _other.backgroundElevation4 == _this.backgroundElevation4 &&
        _other.borderDefault == _this.borderDefault &&
        _other.borderSubtle == _this.borderSubtle &&
        _other.borderStrong == _this.borderStrong &&
        _other.borderOnDark == _this.borderOnDark &&
        _other.borderOnAccent == _this.borderOnAccent &&
        _other.borderOpacity10 == _this.borderOpacity10 &&
        _other.borderOpacity25 == _this.borderOpacity25 &&
        _other.borderFocus == _this.borderFocus &&
        _other.borderDisabled == _this.borderDisabled &&
        _other.borderError == _this.borderError &&
        _other.borderWarning == _this.borderWarning &&
        _other.borderSuccess == _this.borderSuccess &&
        _other.borderSelected == _this.borderSelected &&
        _other.stateHover == _this.stateHover &&
        _other.statePressed == _this.statePressed &&
        _other.stateSelected == _this.stateSelected &&
        _other.stateFocused == _this.stateFocused &&
        _other.stateDisabled == _this.stateDisabled &&
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
      _this.accentPrimary,
      _this.accentSuccess,
      _this.accentWarning,
      _this.accentError,
      _this.accentNeutral,
      _this.accentBlack,
      _this.textPrimary,
      _this.textSecondary,
      _this.textTertiary,
      _this.textDisabled,
      _this.textInverse,
      _this.textLink,
      _this.textOnAccent,
      _this.backgroundApp,
      _this.backgroundSurface,
      _this.backgroundSurfaceSubtle,
      _this.backgroundSurfaceStrong,
      _this.backgroundOverlay,
      _this.backgroundDisabled,
      _this.backgroundInverse,
      _this.backgroundElevation0,
      _this.backgroundElevation1,
      _this.backgroundElevation2,
      _this.backgroundElevation3,
      _this.backgroundElevation4,
      _this.borderDefault,
      _this.borderSubtle,
      _this.borderStrong,
      _this.borderOnDark,
      _this.borderOnAccent,
      _this.borderOpacity10,
      _this.borderOpacity25,
      _this.borderFocus,
      _this.borderDisabled,
      _this.borderError,
      _this.borderWarning,
      _this.borderSuccess,
      _this.borderSelected,
      _this.stateHover,
      _this.statePressed,
      _this.stateSelected,
      _this.stateFocused,
      _this.stateDisabled,
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
