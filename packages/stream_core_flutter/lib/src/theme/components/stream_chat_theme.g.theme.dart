// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_chat_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamChatThemeData {
  bool get canMerge => true;

  static StreamChatThemeData? lerp(
    StreamChatThemeData? a,
    StreamChatThemeData? b,
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

    return StreamChatThemeData(
      backgroundIncoming: Color.lerp(
        a.backgroundIncoming,
        b.backgroundIncoming,
        t,
      ),
      backgroundOutgoing: Color.lerp(
        a.backgroundOutgoing,
        b.backgroundOutgoing,
        t,
      ),
      backgroundAttachmentIncoming: Color.lerp(
        a.backgroundAttachmentIncoming,
        b.backgroundAttachmentIncoming,
        t,
      ),
      backgroundAttachmentOutgoing: Color.lerp(
        a.backgroundAttachmentOutgoing,
        b.backgroundAttachmentOutgoing,
        t,
      ),
      backgroundTypingIndicator: Color.lerp(
        a.backgroundTypingIndicator,
        b.backgroundTypingIndicator,
        t,
      ),
      textIncoming: Color.lerp(a.textIncoming, b.textIncoming, t),
      textOutgoing: Color.lerp(a.textOutgoing, b.textOutgoing, t),
      textUsername: Color.lerp(a.textUsername, b.textUsername, t),
      textMention: Color.lerp(a.textMention, b.textMention, t),
      textLink: Color.lerp(a.textLink, b.textLink, t),
      textReaction: Color.lerp(a.textReaction, b.textReaction, t),
      textSystem: Color.lerp(a.textSystem, b.textSystem, t),
      borderIncoming: Color.lerp(a.borderIncoming, b.borderIncoming, t),
      borderOutgoing: Color.lerp(a.borderOutgoing, b.borderOutgoing, t),
      borderOnChatIncoming: Color.lerp(
        a.borderOnChatIncoming,
        b.borderOnChatIncoming,
        t,
      ),
      borderOnChatOutgoing: Color.lerp(
        a.borderOnChatOutgoing,
        b.borderOnChatOutgoing,
        t,
      ),
      threadConnectorIncoming: Color.lerp(
        a.threadConnectorIncoming,
        b.threadConnectorIncoming,
        t,
      ),
      threadConnectorOutgoing: Color.lerp(
        a.threadConnectorOutgoing,
        b.threadConnectorOutgoing,
        t,
      ),
      progressTrackIncoming: Color.lerp(
        a.progressTrackIncoming,
        b.progressTrackIncoming,
        t,
      ),
      progressTrackOutgoing: Color.lerp(
        a.progressTrackOutgoing,
        b.progressTrackOutgoing,
        t,
      ),
      progressFillIncoming: Color.lerp(
        a.progressFillIncoming,
        b.progressFillIncoming,
        t,
      ),
      progressFillOutgoing: Color.lerp(
        a.progressFillOutgoing,
        b.progressFillOutgoing,
        t,
      ),
      replyIndicatorIncoming: Color.lerp(
        a.replyIndicatorIncoming,
        b.replyIndicatorIncoming,
        t,
      ),
      replyIndicatorOutgoing: Color.lerp(
        a.replyIndicatorOutgoing,
        b.replyIndicatorOutgoing,
        t,
      ),
      waveFormBar: Color.lerp(a.waveFormBar, b.waveFormBar, t),
      waveFormBarPlaying: Color.lerp(
        a.waveFormBarPlaying,
        b.waveFormBarPlaying,
        t,
      ),
    );
  }

  StreamChatThemeData copyWith({
    Color? backgroundIncoming,
    Color? backgroundOutgoing,
    Color? backgroundAttachmentIncoming,
    Color? backgroundAttachmentOutgoing,
    Color? backgroundTypingIndicator,
    Color? textIncoming,
    Color? textOutgoing,
    Color? textUsername,
    Color? textMention,
    Color? textLink,
    Color? textReaction,
    Color? textSystem,
    Color? borderIncoming,
    Color? borderOutgoing,
    Color? borderOnChatIncoming,
    Color? borderOnChatOutgoing,
    Color? threadConnectorIncoming,
    Color? threadConnectorOutgoing,
    Color? progressTrackIncoming,
    Color? progressTrackOutgoing,
    Color? progressFillIncoming,
    Color? progressFillOutgoing,
    Color? replyIndicatorIncoming,
    Color? replyIndicatorOutgoing,
    Color? waveFormBar,
    Color? waveFormBarPlaying,
  }) {
    final _this = (this as StreamChatThemeData);

    return StreamChatThemeData(
      backgroundIncoming: backgroundIncoming ?? _this.backgroundIncoming,
      backgroundOutgoing: backgroundOutgoing ?? _this.backgroundOutgoing,
      backgroundAttachmentIncoming:
          backgroundAttachmentIncoming ?? _this.backgroundAttachmentIncoming,
      backgroundAttachmentOutgoing:
          backgroundAttachmentOutgoing ?? _this.backgroundAttachmentOutgoing,
      backgroundTypingIndicator:
          backgroundTypingIndicator ?? _this.backgroundTypingIndicator,
      textIncoming: textIncoming ?? _this.textIncoming,
      textOutgoing: textOutgoing ?? _this.textOutgoing,
      textUsername: textUsername ?? _this.textUsername,
      textMention: textMention ?? _this.textMention,
      textLink: textLink ?? _this.textLink,
      textReaction: textReaction ?? _this.textReaction,
      textSystem: textSystem ?? _this.textSystem,
      borderIncoming: borderIncoming ?? _this.borderIncoming,
      borderOutgoing: borderOutgoing ?? _this.borderOutgoing,
      borderOnChatIncoming: borderOnChatIncoming ?? _this.borderOnChatIncoming,
      borderOnChatOutgoing: borderOnChatOutgoing ?? _this.borderOnChatOutgoing,
      threadConnectorIncoming:
          threadConnectorIncoming ?? _this.threadConnectorIncoming,
      threadConnectorOutgoing:
          threadConnectorOutgoing ?? _this.threadConnectorOutgoing,
      progressTrackIncoming:
          progressTrackIncoming ?? _this.progressTrackIncoming,
      progressTrackOutgoing:
          progressTrackOutgoing ?? _this.progressTrackOutgoing,
      progressFillIncoming: progressFillIncoming ?? _this.progressFillIncoming,
      progressFillOutgoing: progressFillOutgoing ?? _this.progressFillOutgoing,
      replyIndicatorIncoming:
          replyIndicatorIncoming ?? _this.replyIndicatorIncoming,
      replyIndicatorOutgoing:
          replyIndicatorOutgoing ?? _this.replyIndicatorOutgoing,
      waveFormBar: waveFormBar ?? _this.waveFormBar,
      waveFormBarPlaying: waveFormBarPlaying ?? _this.waveFormBarPlaying,
    );
  }

  StreamChatThemeData merge(StreamChatThemeData? other) {
    final _this = (this as StreamChatThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      backgroundIncoming: other.backgroundIncoming,
      backgroundOutgoing: other.backgroundOutgoing,
      backgroundAttachmentIncoming: other.backgroundAttachmentIncoming,
      backgroundAttachmentOutgoing: other.backgroundAttachmentOutgoing,
      backgroundTypingIndicator: other.backgroundTypingIndicator,
      textIncoming: other.textIncoming,
      textOutgoing: other.textOutgoing,
      textUsername: other.textUsername,
      textMention: other.textMention,
      textLink: other.textLink,
      textReaction: other.textReaction,
      textSystem: other.textSystem,
      borderIncoming: other.borderIncoming,
      borderOutgoing: other.borderOutgoing,
      borderOnChatIncoming: other.borderOnChatIncoming,
      borderOnChatOutgoing: other.borderOnChatOutgoing,
      threadConnectorIncoming: other.threadConnectorIncoming,
      threadConnectorOutgoing: other.threadConnectorOutgoing,
      progressTrackIncoming: other.progressTrackIncoming,
      progressTrackOutgoing: other.progressTrackOutgoing,
      progressFillIncoming: other.progressFillIncoming,
      progressFillOutgoing: other.progressFillOutgoing,
      replyIndicatorIncoming: other.replyIndicatorIncoming,
      replyIndicatorOutgoing: other.replyIndicatorOutgoing,
      waveFormBar: other.waveFormBar,
      waveFormBarPlaying: other.waveFormBarPlaying,
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

    final _this = (this as StreamChatThemeData);
    final _other = (other as StreamChatThemeData);

    return _other.backgroundIncoming == _this.backgroundIncoming &&
        _other.backgroundOutgoing == _this.backgroundOutgoing &&
        _other.backgroundAttachmentIncoming ==
            _this.backgroundAttachmentIncoming &&
        _other.backgroundAttachmentOutgoing ==
            _this.backgroundAttachmentOutgoing &&
        _other.backgroundTypingIndicator == _this.backgroundTypingIndicator &&
        _other.textIncoming == _this.textIncoming &&
        _other.textOutgoing == _this.textOutgoing &&
        _other.textUsername == _this.textUsername &&
        _other.textMention == _this.textMention &&
        _other.textLink == _this.textLink &&
        _other.textReaction == _this.textReaction &&
        _other.textSystem == _this.textSystem &&
        _other.borderIncoming == _this.borderIncoming &&
        _other.borderOutgoing == _this.borderOutgoing &&
        _other.borderOnChatIncoming == _this.borderOnChatIncoming &&
        _other.borderOnChatOutgoing == _this.borderOnChatOutgoing &&
        _other.threadConnectorIncoming == _this.threadConnectorIncoming &&
        _other.threadConnectorOutgoing == _this.threadConnectorOutgoing &&
        _other.progressTrackIncoming == _this.progressTrackIncoming &&
        _other.progressTrackOutgoing == _this.progressTrackOutgoing &&
        _other.progressFillIncoming == _this.progressFillIncoming &&
        _other.progressFillOutgoing == _this.progressFillOutgoing &&
        _other.replyIndicatorIncoming == _this.replyIndicatorIncoming &&
        _other.replyIndicatorOutgoing == _this.replyIndicatorOutgoing &&
        _other.waveFormBar == _this.waveFormBar &&
        _other.waveFormBarPlaying == _this.waveFormBarPlaying;
  }

  @override
  int get hashCode {
    final _this = (this as StreamChatThemeData);

    return Object.hashAll([
      runtimeType,
      _this.backgroundIncoming,
      _this.backgroundOutgoing,
      _this.backgroundAttachmentIncoming,
      _this.backgroundAttachmentOutgoing,
      _this.backgroundTypingIndicator,
      _this.textIncoming,
      _this.textOutgoing,
      _this.textUsername,
      _this.textMention,
      _this.textLink,
      _this.textReaction,
      _this.textSystem,
      _this.borderIncoming,
      _this.borderOutgoing,
      _this.borderOnChatIncoming,
      _this.borderOnChatOutgoing,
      _this.threadConnectorIncoming,
      _this.threadConnectorOutgoing,
      _this.progressTrackIncoming,
      _this.progressTrackOutgoing,
      _this.progressFillIncoming,
      _this.progressFillOutgoing,
      _this.replyIndicatorIncoming,
      _this.replyIndicatorOutgoing,
      _this.waveFormBar,
      _this.waveFormBarPlaying,
    ]);
  }
}
