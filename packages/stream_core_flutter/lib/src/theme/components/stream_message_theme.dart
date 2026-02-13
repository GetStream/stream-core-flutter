import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../../../stream_core_flutter.dart';

part 'stream_message_theme.g.theme.dart';

class StreamMessageTheme extends InheritedTheme {
  const StreamMessageTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final StreamMessageThemeData data;

  static StreamMessageThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamMessageTheme>();
    return StreamTheme.of(context).messageTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamMessageTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamMessageTheme oldWidget) => data != oldWidget.data;
}

@themeGen
@immutable
class StreamMessageThemeData with _$StreamMessageThemeData {
  const StreamMessageThemeData({
    this.incoming,
    this.outgoing,
  });

  final StreamMessageStyle? incoming;
  final StreamMessageStyle? outgoing;

  StreamMessageThemeData mergeWithDefaults(BuildContext context) {
    final defaults = _MessageThemeDefaults(context: context);
    return StreamMessageThemeData(incoming: defaults.incoming, outgoing: defaults.outgoing).merge(this);
  }
}

@themeGen
@immutable
class StreamMessageStyle with _$StreamMessageStyle {
  const StreamMessageStyle({
    this.backgroundColor,
    this.backgroundAttachmentColor,
    this.backgroundTypingIndicatorColor,
    this.textColor,
    this.textUsernameColor,
    this.textTimestampColor,
    this.textMentionColor,
    this.textLinkColor,
    this.textReactionColor,
    this.textSystemColor,
    this.borderColor,
    this.borderOnChatColor,
    this.threadConnectorColor,
    this.progressTrackColor,
    this.progressFillColor,
    this.replyIndicatorColor,
    this.waveFormBarColor,
    this.waveFormBarPlayingColor,
  });

  final Color? backgroundColor;
  final Color? backgroundAttachmentColor;
  final Color? backgroundTypingIndicatorColor;

  final Color? textColor;
  final Color? textUsernameColor;
  final Color? textTimestampColor;
  final Color? textMentionColor;
  final Color? textLinkColor;
  final Color? textReactionColor;
  final Color? textSystemColor;

  final Color? borderColor;
  final Color? borderOnChatColor;

  final Color? threadConnectorColor;

  final Color? progressTrackColor;
  final Color? progressFillColor;

  final Color? replyIndicatorColor;

  final Color? waveFormBarColor;
  final Color? waveFormBarPlayingColor;
}

class _MessageThemeDefaults {
  _MessageThemeDefaults({required this.context}) : _colorScheme = context.streamColorScheme;

  final BuildContext context;
  final StreamColorScheme _colorScheme;

  StreamMessageStyle get incoming => StreamMessageStyle(
    backgroundColor: _colorScheme.backgroundSurface,
    backgroundAttachmentColor: _colorScheme.backgroundSurfaceStrong,
    backgroundTypingIndicatorColor: _colorScheme.accentNeutral,
    textColor: _colorScheme.textPrimary,
    textUsernameColor: _colorScheme.textSecondary,
    textTimestampColor: _colorScheme.textTertiary,
    textMentionColor: _colorScheme.textLink,
    textLinkColor: _colorScheme.textLink,
    textReactionColor: _colorScheme.textSecondary,
    textSystemColor: _colorScheme.textSecondary,
    borderColor: _colorScheme.borderSubtle,
    borderOnChatColor: _colorScheme.borderOnSurface,
    replyIndicatorColor: _colorScheme.borderOnSurface,
  );

  StreamMessageStyle get outgoing => StreamMessageStyle(
    backgroundColor: _colorScheme.brand.shade100,
    backgroundAttachmentColor: _colorScheme.brand.shade150,
    backgroundTypingIndicatorColor: _colorScheme.accentNeutral,
    textColor: _colorScheme.brand.shade900,
    textUsernameColor: _colorScheme.textSecondary,
    textTimestampColor: _colorScheme.textTertiary,
    textMentionColor: _colorScheme.textLink,
    textLinkColor: _colorScheme.textLink,
    textReactionColor: _colorScheme.textSecondary,
    textSystemColor: _colorScheme.textSecondary,
    borderColor: _colorScheme.brand.shade100,
    borderOnChatColor: _colorScheme.brand.shade300,
    replyIndicatorColor: _colorScheme.brand.shade400,
  );
}
