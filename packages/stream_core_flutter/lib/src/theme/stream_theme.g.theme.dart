// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_theme.dart';

// **************************************************************************
// ThemeExtensionsGenerator
// **************************************************************************

mixin _$StreamTheme on ThemeExtension<StreamTheme> {
  @override
  ThemeExtension<StreamTheme> copyWith({
    Brightness? brightness,
    StreamIcons? icons,
    StreamRadius? radius,
    StreamSpacing? spacing,
    StreamTypography? typography,
    StreamColorScheme? colorScheme,
    StreamTextTheme? textTheme,
    StreamBoxShadow? boxShadow,
    StreamAvatarThemeData? avatarTheme,
    StreamBadgeCountThemeData? badgeCountTheme,
    StreamButtonThemeData? buttonTheme,
    StreamEmojiButtonThemeData? emojiButtonTheme,
    StreamMessageThemeData? messageTheme,
    StreamInputThemeData? inputTheme,
    StreamOnlineIndicatorThemeData? onlineIndicatorTheme,
  }) {
    final _this = (this as StreamTheme);

    return StreamTheme.raw(
      brightness: brightness ?? _this.brightness,
      icons: icons ?? _this.icons,
      radius: radius ?? _this.radius,
      spacing: spacing ?? _this.spacing,
      typography: typography ?? _this.typography,
      colorScheme: colorScheme ?? _this.colorScheme,
      textTheme: textTheme ?? _this.textTheme,
      boxShadow: boxShadow ?? _this.boxShadow,
      avatarTheme: avatarTheme ?? _this.avatarTheme,
      badgeCountTheme: badgeCountTheme ?? _this.badgeCountTheme,
      buttonTheme: buttonTheme ?? _this.buttonTheme,
      emojiButtonTheme: emojiButtonTheme ?? _this.emojiButtonTheme,
      messageTheme: messageTheme ?? _this.messageTheme,
      inputTheme: inputTheme ?? _this.inputTheme,
      onlineIndicatorTheme: onlineIndicatorTheme ?? _this.onlineIndicatorTheme,
    );
  }

  @override
  ThemeExtension<StreamTheme> lerp(
    ThemeExtension<StreamTheme>? other,
    double t,
  ) {
    if (other is! StreamTheme) {
      return this;
    }

    final _this = (this as StreamTheme);

    return StreamTheme.raw(
      brightness: t < 0.5 ? _this.brightness : other.brightness,
      icons: StreamIcons.lerp(_this.icons, other.icons, t)!,
      radius: StreamRadius.lerp(_this.radius, other.radius, t)!,
      spacing: StreamSpacing.lerp(_this.spacing, other.spacing, t)!,
      typography: StreamTypography.lerp(_this.typography, other.typography, t)!,
      colorScheme:
          (_this.colorScheme.lerp(other.colorScheme, t) as StreamColorScheme),
      textTheme: (_this.textTheme.lerp(other.textTheme, t) as StreamTextTheme),
      boxShadow: StreamBoxShadow.lerp(_this.boxShadow, other.boxShadow, t)!,
      avatarTheme: StreamAvatarThemeData.lerp(
        _this.avatarTheme,
        other.avatarTheme,
        t,
      )!,
      badgeCountTheme: StreamBadgeCountThemeData.lerp(
        _this.badgeCountTheme,
        other.badgeCountTheme,
        t,
      )!,
      buttonTheme: t < 0.5 ? _this.buttonTheme : other.buttonTheme,
      emojiButtonTheme: StreamEmojiButtonThemeData.lerp(
        _this.emojiButtonTheme,
        other.emojiButtonTheme,
        t,
      )!,
      messageTheme: t < 0.5 ? _this.messageTheme : other.messageTheme,
      inputTheme: t < 0.5 ? _this.inputTheme : other.inputTheme,
      onlineIndicatorTheme: StreamOnlineIndicatorThemeData.lerp(
        _this.onlineIndicatorTheme,
        other.onlineIndicatorTheme,
        t,
      )!,
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

    final _this = (this as StreamTheme);
    final _other = (other as StreamTheme);

    return _other.brightness == _this.brightness &&
        _other.icons == _this.icons &&
        _other.radius == _this.radius &&
        _other.spacing == _this.spacing &&
        _other.typography == _this.typography &&
        _other.colorScheme == _this.colorScheme &&
        _other.textTheme == _this.textTheme &&
        _other.boxShadow == _this.boxShadow &&
        _other.avatarTheme == _this.avatarTheme &&
        _other.badgeCountTheme == _this.badgeCountTheme &&
        _other.buttonTheme == _this.buttonTheme &&
        _other.emojiButtonTheme == _this.emojiButtonTheme &&
        _other.messageTheme == _this.messageTheme &&
        _other.inputTheme == _this.inputTheme &&
        _other.onlineIndicatorTheme == _this.onlineIndicatorTheme;
  }

  @override
  int get hashCode {
    final _this = (this as StreamTheme);

    return Object.hash(
      runtimeType,
      _this.brightness,
      _this.icons,
      _this.radius,
      _this.spacing,
      _this.typography,
      _this.colorScheme,
      _this.textTheme,
      _this.boxShadow,
      _this.avatarTheme,
      _this.badgeCountTheme,
      _this.buttonTheme,
      _this.emojiButtonTheme,
      _this.messageTheme,
      _this.inputTheme,
      _this.onlineIndicatorTheme,
    );
  }
}
