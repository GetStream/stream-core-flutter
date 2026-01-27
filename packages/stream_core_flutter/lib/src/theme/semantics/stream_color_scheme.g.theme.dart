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
      borderDefault: Color.lerp(a.borderDefault, b.borderDefault, t)!,
      borderSurface: Color.lerp(a.borderSurface, b.borderSurface, t)!,
      borderSurfaceSubtle: Color.lerp(
        a.borderSurfaceSubtle,
        b.borderSurfaceSubtle,
        t,
      )!,
      borderSurfaceStrong: Color.lerp(
        a.borderSurfaceStrong,
        b.borderSurfaceStrong,
        t,
      )!,
      borderOnDark: Color.lerp(a.borderOnDark, b.borderOnDark, t)!,
      borderOnAccent: Color.lerp(a.borderOnAccent, b.borderOnAccent, t)!,
      borderSubtle: Color.lerp(a.borderSubtle, b.borderSubtle, t)!,
      borderImage: Color.lerp(a.borderImage, b.borderImage, t)!,
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
    Color? borderDefault,
    Color? borderSurface,
    Color? borderSurfaceSubtle,
    Color? borderSurfaceStrong,
    Color? borderOnDark,
    Color? borderOnAccent,
    Color? borderSubtle,
    Color? borderImage,
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
      borderDefault: borderDefault ?? _this.borderDefault,
      borderSurface: borderSurface ?? _this.borderSurface,
      borderSurfaceSubtle: borderSurfaceSubtle ?? _this.borderSurfaceSubtle,
      borderSurfaceStrong: borderSurfaceStrong ?? _this.borderSurfaceStrong,
      borderOnDark: borderOnDark ?? _this.borderOnDark,
      borderOnAccent: borderOnAccent ?? _this.borderOnAccent,
      borderSubtle: borderSubtle ?? _this.borderSubtle,
      borderImage: borderImage ?? _this.borderImage,
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
      borderDefault: other.borderDefault,
      borderSurface: other.borderSurface,
      borderSurfaceSubtle: other.borderSurfaceSubtle,
      borderSurfaceStrong: other.borderSurfaceStrong,
      borderOnDark: other.borderOnDark,
      borderOnAccent: other.borderOnAccent,
      borderSubtle: other.borderSubtle,
      borderImage: other.borderImage,
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
        _other.borderDefault == _this.borderDefault &&
        _other.borderSurface == _this.borderSurface &&
        _other.borderSurfaceSubtle == _this.borderSurfaceSubtle &&
        _other.borderSurfaceStrong == _this.borderSurfaceStrong &&
        _other.borderOnDark == _this.borderOnDark &&
        _other.borderOnAccent == _this.borderOnAccent &&
        _other.borderSubtle == _this.borderSubtle &&
        _other.borderImage == _this.borderImage &&
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
      _this.borderDefault,
      _this.borderSurface,
      _this.borderSurfaceSubtle,
      _this.borderSurfaceStrong,
      _this.borderOnDark,
      _this.borderOnAccent,
      _this.borderSubtle,
      _this.borderImage,
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
