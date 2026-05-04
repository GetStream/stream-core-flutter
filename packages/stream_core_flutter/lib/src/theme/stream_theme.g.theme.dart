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
    StreamAppBarThemeData? appBarTheme,
    StreamAudioWaveformThemeData? audioWaveformTheme,
    StreamAvatarThemeData? avatarTheme,
    StreamBadgeCountThemeData? badgeCountTheme,
    StreamBadgeNotificationThemeData? badgeNotificationTheme,
    StreamButtonThemeData? buttonTheme,
    StreamCheckboxThemeData? checkboxTheme,
    StreamCommandChipThemeData? commandChipTheme,
    StreamContextMenuThemeData? contextMenuTheme,
    StreamContextMenuActionThemeData? contextMenuActionTheme,
    StreamEmojiButtonThemeData? emojiButtonTheme,
    StreamEmojiChipThemeData? emojiChipTheme,
    StreamJumpToUnreadButtonThemeData? jumpToUnreadButtonTheme,
    StreamListTileThemeData? listTileTheme,
    StreamMessageItemThemeData? messageItemTheme,
    StreamTextInputThemeData? textInputTheme,
    StreamOnlineIndicatorThemeData? onlineIndicatorTheme,
    StreamPlaybackSpeedToggleThemeData? playbackSpeedToggleTheme,
    StreamProgressBarThemeData? progressBarTheme,
    StreamReactionPickerThemeData? reactionPickerTheme,
    StreamReactionsThemeData? reactionsTheme,
    StreamSheetHeaderThemeData? sheetHeaderTheme,
    StreamSheetThemeData? sheetTheme,
    StreamSkeletonLoadingThemeData? skeletonLoadingTheme,
    StreamStepperThemeData? stepperTheme,
    StreamSwitchThemeData? switchTheme,
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
      appBarTheme: appBarTheme ?? _this.appBarTheme,
      audioWaveformTheme: audioWaveformTheme ?? _this.audioWaveformTheme,
      avatarTheme: avatarTheme ?? _this.avatarTheme,
      badgeCountTheme: badgeCountTheme ?? _this.badgeCountTheme,
      badgeNotificationTheme:
          badgeNotificationTheme ?? _this.badgeNotificationTheme,
      buttonTheme: buttonTheme ?? _this.buttonTheme,
      checkboxTheme: checkboxTheme ?? _this.checkboxTheme,
      commandChipTheme: commandChipTheme ?? _this.commandChipTheme,
      contextMenuTheme: contextMenuTheme ?? _this.contextMenuTheme,
      contextMenuActionTheme:
          contextMenuActionTheme ?? _this.contextMenuActionTheme,
      emojiButtonTheme: emojiButtonTheme ?? _this.emojiButtonTheme,
      emojiChipTheme: emojiChipTheme ?? _this.emojiChipTheme,
      jumpToUnreadButtonTheme:
          jumpToUnreadButtonTheme ?? _this.jumpToUnreadButtonTheme,
      listTileTheme: listTileTheme ?? _this.listTileTheme,
      messageItemTheme: messageItemTheme ?? _this.messageItemTheme,
      textInputTheme: textInputTheme ?? _this.textInputTheme,
      onlineIndicatorTheme: onlineIndicatorTheme ?? _this.onlineIndicatorTheme,
      playbackSpeedToggleTheme:
          playbackSpeedToggleTheme ?? _this.playbackSpeedToggleTheme,
      progressBarTheme: progressBarTheme ?? _this.progressBarTheme,
      reactionPickerTheme: reactionPickerTheme ?? _this.reactionPickerTheme,
      reactionsTheme: reactionsTheme ?? _this.reactionsTheme,
      sheetHeaderTheme: sheetHeaderTheme ?? _this.sheetHeaderTheme,
      sheetTheme: sheetTheme ?? _this.sheetTheme,
      skeletonLoadingTheme: skeletonLoadingTheme ?? _this.skeletonLoadingTheme,
      stepperTheme: stepperTheme ?? _this.stepperTheme,
      switchTheme: switchTheme ?? _this.switchTheme,
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
      appBarTheme: StreamAppBarThemeData.lerp(
        _this.appBarTheme,
        other.appBarTheme,
        t,
      )!,
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
      commandChipTheme: StreamCommandChipThemeData.lerp(
        _this.commandChipTheme,
        other.commandChipTheme,
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
      jumpToUnreadButtonTheme: StreamJumpToUnreadButtonThemeData.lerp(
        _this.jumpToUnreadButtonTheme,
        other.jumpToUnreadButtonTheme,
        t,
      )!,
      listTileTheme: StreamListTileThemeData.lerp(
        _this.listTileTheme,
        other.listTileTheme,
        t,
      )!,
      messageItemTheme: StreamMessageItemThemeData.lerp(
        _this.messageItemTheme,
        other.messageItemTheme,
        t,
      )!,
      textInputTheme: StreamTextInputThemeData.lerp(
        _this.textInputTheme,
        other.textInputTheme,
        t,
      )!,
      onlineIndicatorTheme: StreamOnlineIndicatorThemeData.lerp(
        _this.onlineIndicatorTheme,
        other.onlineIndicatorTheme,
        t,
      )!,
      playbackSpeedToggleTheme: StreamPlaybackSpeedToggleThemeData.lerp(
        _this.playbackSpeedToggleTheme,
        other.playbackSpeedToggleTheme,
        t,
      )!,
      progressBarTheme: StreamProgressBarThemeData.lerp(
        _this.progressBarTheme,
        other.progressBarTheme,
        t,
      )!,
      reactionPickerTheme: StreamReactionPickerThemeData.lerp(
        _this.reactionPickerTheme,
        other.reactionPickerTheme,
        t,
      )!,
      reactionsTheme: StreamReactionsThemeData.lerp(
        _this.reactionsTheme,
        other.reactionsTheme,
        t,
      )!,
      sheetHeaderTheme: StreamSheetHeaderThemeData.lerp(
        _this.sheetHeaderTheme,
        other.sheetHeaderTheme,
        t,
      )!,
      sheetTheme: StreamSheetThemeData.lerp(
        _this.sheetTheme,
        other.sheetTheme,
        t,
      )!,
      skeletonLoadingTheme: StreamSkeletonLoadingThemeData.lerp(
        _this.skeletonLoadingTheme,
        other.skeletonLoadingTheme,
        t,
      )!,
      stepperTheme: StreamStepperThemeData.lerp(
        _this.stepperTheme,
        other.stepperTheme,
        t,
      )!,
      switchTheme: StreamSwitchThemeData.lerp(
        _this.switchTheme,
        other.switchTheme,
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
        _other.appBarTheme == _this.appBarTheme &&
        _other.audioWaveformTheme == _this.audioWaveformTheme &&
        _other.avatarTheme == _this.avatarTheme &&
        _other.badgeCountTheme == _this.badgeCountTheme &&
        _other.badgeNotificationTheme == _this.badgeNotificationTheme &&
        _other.buttonTheme == _this.buttonTheme &&
        _other.checkboxTheme == _this.checkboxTheme &&
        _other.commandChipTheme == _this.commandChipTheme &&
        _other.contextMenuTheme == _this.contextMenuTheme &&
        _other.contextMenuActionTheme == _this.contextMenuActionTheme &&
        _other.emojiButtonTheme == _this.emojiButtonTheme &&
        _other.emojiChipTheme == _this.emojiChipTheme &&
        _other.jumpToUnreadButtonTheme == _this.jumpToUnreadButtonTheme &&
        _other.listTileTheme == _this.listTileTheme &&
        _other.messageItemTheme == _this.messageItemTheme &&
        _other.textInputTheme == _this.textInputTheme &&
        _other.onlineIndicatorTheme == _this.onlineIndicatorTheme &&
        _other.playbackSpeedToggleTheme == _this.playbackSpeedToggleTheme &&
        _other.progressBarTheme == _this.progressBarTheme &&
        _other.reactionPickerTheme == _this.reactionPickerTheme &&
        _other.reactionsTheme == _this.reactionsTheme &&
        _other.sheetHeaderTheme == _this.sheetHeaderTheme &&
        _other.sheetTheme == _this.sheetTheme &&
        _other.skeletonLoadingTheme == _this.skeletonLoadingTheme &&
        _other.stepperTheme == _this.stepperTheme &&
        _other.switchTheme == _this.switchTheme;
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
      _this.appBarTheme,
      _this.audioWaveformTheme,
      _this.avatarTheme,
      _this.badgeCountTheme,
      _this.badgeNotificationTheme,
      _this.buttonTheme,
      _this.checkboxTheme,
      _this.commandChipTheme,
      _this.contextMenuTheme,
      _this.contextMenuActionTheme,
      _this.emojiButtonTheme,
      _this.emojiChipTheme,
      _this.jumpToUnreadButtonTheme,
      _this.listTileTheme,
      _this.messageItemTheme,
      _this.textInputTheme,
      _this.onlineIndicatorTheme,
      _this.playbackSpeedToggleTheme,
      _this.progressBarTheme,
      _this.reactionPickerTheme,
      _this.reactionsTheme,
      _this.sheetHeaderTheme,
      _this.sheetTheme,
      _this.skeletonLoadingTheme,
      _this.stepperTheme,
      _this.switchTheme,
    ]);
  }
}
