// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_message_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamMessageThemeData {
  bool get canMerge => true;

  static StreamMessageThemeData? lerp(
    StreamMessageThemeData? a,
    StreamMessageThemeData? b,
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

    return StreamMessageThemeData(
      incoming: t < 0.5 ? a.incoming : b.incoming,
      outgoing: t < 0.5 ? a.outgoing : b.outgoing,
    );
  }

  StreamMessageThemeData copyWith({
    StreamThemeMessageStyle? incoming,
    StreamThemeMessageStyle? outgoing,
  }) {
    final _this = (this as StreamMessageThemeData);

    return StreamMessageThemeData(
      incoming: incoming ?? _this.incoming,
      outgoing: outgoing ?? _this.outgoing,
    );
  }

  StreamMessageThemeData merge(StreamMessageThemeData? other) {
    final _this = (this as StreamMessageThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      incoming: _this.incoming?.merge(other.incoming) ?? other.incoming,
      outgoing: _this.outgoing?.merge(other.outgoing) ?? other.outgoing,
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

    final _this = (this as StreamMessageThemeData);
    final _other = (other as StreamMessageThemeData);

    return _other.incoming == _this.incoming &&
        _other.outgoing == _this.outgoing;
  }

  @override
  int get hashCode {
    final _this = (this as StreamMessageThemeData);

    return Object.hash(runtimeType, _this.incoming, _this.outgoing);
  }
}

mixin _$StreamThemeMessageStyle {
  bool get canMerge => true;

  static StreamThemeMessageStyle? lerp(
    StreamThemeMessageStyle? a,
    StreamThemeMessageStyle? b,
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

    return StreamThemeMessageStyle(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      backgroundAttachmentColor: Color.lerp(
        a.backgroundAttachmentColor,
        b.backgroundAttachmentColor,
        t,
      ),
      backgroundTypingIndicatorColor: Color.lerp(
        a.backgroundTypingIndicatorColor,
        b.backgroundTypingIndicatorColor,
        t,
      ),
      textColor: Color.lerp(a.textColor, b.textColor, t),
      textUsernameColor: Color.lerp(
        a.textUsernameColor,
        b.textUsernameColor,
        t,
      ),
      textTimestampColor: Color.lerp(
        a.textTimestampColor,
        b.textTimestampColor,
        t,
      ),
      textMentionColor: Color.lerp(a.textMentionColor, b.textMentionColor, t),
      textLinkColor: Color.lerp(a.textLinkColor, b.textLinkColor, t),
      textReactionColor: Color.lerp(
        a.textReactionColor,
        b.textReactionColor,
        t,
      ),
      textSystemColor: Color.lerp(a.textSystemColor, b.textSystemColor, t),
      borderColor: Color.lerp(a.borderColor, b.borderColor, t),
      borderOnChatColor: Color.lerp(
        a.borderOnChatColor,
        b.borderOnChatColor,
        t,
      ),
      threadConnectorColor: Color.lerp(
        a.threadConnectorColor,
        b.threadConnectorColor,
        t,
      ),
      progressTrackColor: Color.lerp(
        a.progressTrackColor,
        b.progressTrackColor,
        t,
      ),
      progressFillColor: Color.lerp(
        a.progressFillColor,
        b.progressFillColor,
        t,
      ),
      replyIndicatorColor: Color.lerp(
        a.replyIndicatorColor,
        b.replyIndicatorColor,
        t,
      ),
      waveFormBarColor: Color.lerp(a.waveFormBarColor, b.waveFormBarColor, t),
      waveFormBarPlayingColor: Color.lerp(
        a.waveFormBarPlayingColor,
        b.waveFormBarPlayingColor,
        t,
      ),
    );
  }

  StreamThemeMessageStyle copyWith({
    Color? backgroundColor,
    Color? backgroundAttachmentColor,
    Color? backgroundTypingIndicatorColor,
    Color? textColor,
    Color? textUsernameColor,
    Color? textTimestampColor,
    Color? textMentionColor,
    Color? textLinkColor,
    Color? textReactionColor,
    Color? textSystemColor,
    Color? borderColor,
    Color? borderOnChatColor,
    Color? threadConnectorColor,
    Color? progressTrackColor,
    Color? progressFillColor,
    Color? replyIndicatorColor,
    Color? waveFormBarColor,
    Color? waveFormBarPlayingColor,
  }) {
    final _this = (this as StreamThemeMessageStyle);

    return StreamThemeMessageStyle(
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      backgroundAttachmentColor:
          backgroundAttachmentColor ?? _this.backgroundAttachmentColor,
      backgroundTypingIndicatorColor:
          backgroundTypingIndicatorColor ??
          _this.backgroundTypingIndicatorColor,
      textColor: textColor ?? _this.textColor,
      textUsernameColor: textUsernameColor ?? _this.textUsernameColor,
      textTimestampColor: textTimestampColor ?? _this.textTimestampColor,
      textMentionColor: textMentionColor ?? _this.textMentionColor,
      textLinkColor: textLinkColor ?? _this.textLinkColor,
      textReactionColor: textReactionColor ?? _this.textReactionColor,
      textSystemColor: textSystemColor ?? _this.textSystemColor,
      borderColor: borderColor ?? _this.borderColor,
      borderOnChatColor: borderOnChatColor ?? _this.borderOnChatColor,
      threadConnectorColor: threadConnectorColor ?? _this.threadConnectorColor,
      progressTrackColor: progressTrackColor ?? _this.progressTrackColor,
      progressFillColor: progressFillColor ?? _this.progressFillColor,
      replyIndicatorColor: replyIndicatorColor ?? _this.replyIndicatorColor,
      waveFormBarColor: waveFormBarColor ?? _this.waveFormBarColor,
      waveFormBarPlayingColor:
          waveFormBarPlayingColor ?? _this.waveFormBarPlayingColor,
    );
  }

  StreamThemeMessageStyle merge(StreamThemeMessageStyle? other) {
    final _this = (this as StreamThemeMessageStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      backgroundColor: other.backgroundColor,
      backgroundAttachmentColor: other.backgroundAttachmentColor,
      backgroundTypingIndicatorColor: other.backgroundTypingIndicatorColor,
      textColor: other.textColor,
      textUsernameColor: other.textUsernameColor,
      textTimestampColor: other.textTimestampColor,
      textMentionColor: other.textMentionColor,
      textLinkColor: other.textLinkColor,
      textReactionColor: other.textReactionColor,
      textSystemColor: other.textSystemColor,
      borderColor: other.borderColor,
      borderOnChatColor: other.borderOnChatColor,
      threadConnectorColor: other.threadConnectorColor,
      progressTrackColor: other.progressTrackColor,
      progressFillColor: other.progressFillColor,
      replyIndicatorColor: other.replyIndicatorColor,
      waveFormBarColor: other.waveFormBarColor,
      waveFormBarPlayingColor: other.waveFormBarPlayingColor,
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

    final _this = (this as StreamThemeMessageStyle);
    final _other = (other as StreamThemeMessageStyle);

    return _other.backgroundColor == _this.backgroundColor &&
        _other.backgroundAttachmentColor == _this.backgroundAttachmentColor &&
        _other.backgroundTypingIndicatorColor ==
            _this.backgroundTypingIndicatorColor &&
        _other.textColor == _this.textColor &&
        _other.textUsernameColor == _this.textUsernameColor &&
        _other.textTimestampColor == _this.textTimestampColor &&
        _other.textMentionColor == _this.textMentionColor &&
        _other.textLinkColor == _this.textLinkColor &&
        _other.textReactionColor == _this.textReactionColor &&
        _other.textSystemColor == _this.textSystemColor &&
        _other.borderColor == _this.borderColor &&
        _other.borderOnChatColor == _this.borderOnChatColor &&
        _other.threadConnectorColor == _this.threadConnectorColor &&
        _other.progressTrackColor == _this.progressTrackColor &&
        _other.progressFillColor == _this.progressFillColor &&
        _other.replyIndicatorColor == _this.replyIndicatorColor &&
        _other.waveFormBarColor == _this.waveFormBarColor &&
        _other.waveFormBarPlayingColor == _this.waveFormBarPlayingColor;
  }

  @override
  int get hashCode {
    final _this = (this as StreamThemeMessageStyle);

    return Object.hash(
      runtimeType,
      _this.backgroundColor,
      _this.backgroundAttachmentColor,
      _this.backgroundTypingIndicatorColor,
      _this.textColor,
      _this.textUsernameColor,
      _this.textTimestampColor,
      _this.textMentionColor,
      _this.textLinkColor,
      _this.textReactionColor,
      _this.textSystemColor,
      _this.borderColor,
      _this.borderOnChatColor,
      _this.threadConnectorColor,
      _this.progressTrackColor,
      _this.progressFillColor,
      _this.replyIndicatorColor,
      _this.waveFormBarColor,
      _this.waveFormBarPlayingColor,
    );
  }
}
