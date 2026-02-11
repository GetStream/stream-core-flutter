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
    this.backgroundIncoming,
    this.backgroundOutgoing,
    this.backgroundAttachmentIncoming,
    this.backgroundAttachmentOutgoing,
    this.backgroundTypingIndicator,
    this.textIncoming,
    this.textOutgoing,
    this.textUsername,
    this.textTimestamp,
    this.textMention,
    this.textLink,
    this.textReaction,
    this.textSystem,
    this.borderIncoming,
    this.borderOutgoing,
    this.borderOnChatIncoming,
    this.borderOnChatOutgoing,
    this.threadConnectorIncoming,
    this.threadConnectorOutgoing,
    this.progressTrackIncoming,
    this.progressTrackOutgoing,
    this.progressFillIncoming,
    this.progressFillOutgoing,
    this.replyIndicatorIncoming,
    this.replyIndicatorOutgoing,
    this.waveFormBar,
    this.waveFormBarPlaying,
  });

  final Color? backgroundIncoming;
  final Color? backgroundOutgoing;
  final Color? backgroundAttachmentIncoming;
  final Color? backgroundAttachmentOutgoing;
  final Color? backgroundTypingIndicator;

  final Color? textIncoming;
  final Color? textOutgoing;
  final Color? textUsername;
  final Color? textTimestamp;
  final Color? textMention;
  final Color? textLink;
  final Color? textReaction;
  final Color? textSystem;

  final Color? borderIncoming;
  final Color? borderOutgoing;
  final Color? borderOnChatIncoming;
  final Color? borderOnChatOutgoing;

  final Color? threadConnectorIncoming;
  final Color? threadConnectorOutgoing;

  final Color? progressTrackIncoming;
  final Color? progressTrackOutgoing;
  final Color? progressFillIncoming;
  final Color? progressFillOutgoing;

  final Color? replyIndicatorIncoming;
  final Color? replyIndicatorOutgoing;

  final Color? waveFormBar;
  final Color? waveFormBarPlaying;
}
