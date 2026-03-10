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
    StreamAudioWaveformThemeData? audioWaveformTheme,
    StreamAvatarThemeData? avatarTheme,
    StreamBadgeCountThemeData? badgeCountTheme,
    StreamBadgeNotificationThemeData? badgeNotificationTheme,
    StreamButtonThemeData? buttonTheme,
    StreamCheckboxThemeData? checkboxTheme,
    StreamContextMenuThemeData? contextMenuTheme,
    StreamContextMenuActionThemeData? contextMenuActionTheme,
    StreamEmojiButtonThemeData? emojiButtonTheme,
    StreamEmojiChipThemeData? emojiChipTheme,
    StreamListTileThemeData? listTileTheme,
    StreamMessageMetadataThemeData? messageMetadataTheme,
    StreamMessageRepliesThemeData? messageRepliesTheme,
    StreamMessageThemeData? messageTheme,
    StreamInputThemeData? inputTheme,
    StreamOnlineIndicatorThemeData? onlineIndicatorTheme,
    StreamProgressBarThemeData? progressBarTheme,
    StreamReactionsThemeData? reactionsTheme,
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
      audioWaveformTheme: audioWaveformTheme ?? _this.audioWaveformTheme,
      avatarTheme: avatarTheme ?? _this.avatarTheme,
      badgeCountTheme: badgeCountTheme ?? _this.badgeCountTheme,
      badgeNotificationTheme:
          badgeNotificationTheme ?? _this.badgeNotificationTheme,
      buttonTheme: buttonTheme ?? _this.buttonTheme,
      checkboxTheme: checkboxTheme ?? _this.checkboxTheme,
      contextMenuTheme: contextMenuTheme ?? _this.contextMenuTheme,
      contextMenuActionTheme:
          contextMenuActionTheme ?? _this.contextMenuActionTheme,
      emojiButtonTheme: emojiButtonTheme ?? _this.emojiButtonTheme,
      emojiChipTheme: emojiChipTheme ?? _this.emojiChipTheme,
      listTileTheme: listTileTheme ?? _this.listTileTheme,
      messageMetadataTheme: messageMetadataTheme ?? _this.messageMetadataTheme,
      messageRepliesTheme: messageRepliesTheme ?? _this.messageRepliesTheme,
      messageTheme: messageTheme ?? _this.messageTheme,
      inputTheme: inputTheme ?? _this.inputTheme,
      onlineIndicatorTheme: onlineIndicatorTheme ?? _this.onlineIndicatorTheme,
      progressBarTheme: progressBarTheme ?? _this.progressBarTheme,
      reactionsTheme: reactionsTheme ?? _this.reactionsTheme,
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
      audioWaveformTheme: StreamAudioWaveformThemeData.lerp(
        _this.audioWaveformTheme,
        other.audioWaveformTheme,
        t,
      )!,
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
      badgeNotificationTheme: StreamBadgeNotificationThemeData.lerp(
        _this.badgeNotificationTheme,
        other.badgeNotificationTheme,
        t,
      )!,
      buttonTheme: StreamButtonThemeData.lerp(
        _this.buttonTheme,
        other.buttonTheme,
        t,
      )!,
      checkboxTheme: StreamCheckboxThemeData.lerp(
        _this.checkboxTheme,
        other.checkboxTheme,
        t,
      )!,
      contextMenuTheme: StreamContextMenuThemeData.lerp(
        _this.contextMenuTheme,
        other.contextMenuTheme,
        t,
      )!,
      contextMenuActionTheme: StreamContextMenuActionThemeData.lerp(
        _this.contextMenuActionTheme,
        other.contextMenuActionTheme,
        t,
      )!,
      emojiButtonTheme: StreamEmojiButtonThemeData.lerp(
        _this.emojiButtonTheme,
        other.emojiButtonTheme,
        t,
      )!,
      emojiChipTheme: StreamEmojiChipThemeData.lerp(
        _this.emojiChipTheme,
        other.emojiChipTheme,
        t,
      )!,
      listTileTheme: StreamListTileThemeData.lerp(
        _this.listTileTheme,
        other.listTileTheme,
        t,
      )!,
      messageMetadataTheme: StreamMessageMetadataThemeData.lerp(
        _this.messageMetadataTheme,
        other.messageMetadataTheme,
        t,
      )!,
      messageRepliesTheme: StreamMessageRepliesThemeData.lerp(
        _this.messageRepliesTheme,
        other.messageRepliesTheme,
        t,
      )!,
      messageTheme: t < 0.5 ? _this.messageTheme : other.messageTheme,
      inputTheme: t < 0.5 ? _this.inputTheme : other.inputTheme,
      onlineIndicatorTheme: StreamOnlineIndicatorThemeData.lerp(
        _this.onlineIndicatorTheme,
        other.onlineIndicatorTheme,
        t,
      )!,
      progressBarTheme: StreamProgressBarThemeData.lerp(
        _this.progressBarTheme,
        other.progressBarTheme,
        t,
      )!,
      reactionsTheme: StreamReactionsThemeData.lerp(
        _this.reactionsTheme,
        other.reactionsTheme,
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
        _other.audioWaveformTheme == _this.audioWaveformTheme &&
        _other.avatarTheme == _this.avatarTheme &&
        _other.badgeCountTheme == _this.badgeCountTheme &&
        _other.badgeNotificationTheme == _this.badgeNotificationTheme &&
        _other.buttonTheme == _this.buttonTheme &&
        _other.checkboxTheme == _this.checkboxTheme &&
        _other.contextMenuTheme == _this.contextMenuTheme &&
        _other.contextMenuActionTheme == _this.contextMenuActionTheme &&
        _other.emojiButtonTheme == _this.emojiButtonTheme &&
        _other.emojiChipTheme == _this.emojiChipTheme &&
        _other.listTileTheme == _this.listTileTheme &&
        _other.messageMetadataTheme == _this.messageMetadataTheme &&
        _other.messageRepliesTheme == _this.messageRepliesTheme &&
        _other.messageTheme == _this.messageTheme &&
        _other.inputTheme == _this.inputTheme &&
        _other.onlineIndicatorTheme == _this.onlineIndicatorTheme &&
        _other.progressBarTheme == _this.progressBarTheme &&
        _other.reactionsTheme == _this.reactionsTheme;
  }

  @override
  int get hashCode {
    final _this = (this as StreamTheme);

    return Object.hashAll([
      runtimeType,
      _this.brightness,
      _this.icons,
      _this.radius,
      _this.spacing,
      _this.typography,
      _this.colorScheme,
      _this.textTheme,
      _this.boxShadow,
      _this.audioWaveformTheme,
      _this.avatarTheme,
      _this.badgeCountTheme,
      _this.badgeNotificationTheme,
      _this.buttonTheme,
      _this.checkboxTheme,
      _this.contextMenuTheme,
      _this.contextMenuActionTheme,
      _this.emojiButtonTheme,
      _this.emojiChipTheme,
      _this.listTileTheme,
      _this.messageMetadataTheme,
      _this.messageRepliesTheme,
      _this.messageTheme,
      _this.inputTheme,
      _this.onlineIndicatorTheme,
      _this.progressBarTheme,
      _this.reactionsTheme,
    ]);
  }
}
