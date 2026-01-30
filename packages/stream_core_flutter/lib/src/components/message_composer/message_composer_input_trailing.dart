import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../stream_core_flutter.dart';
import '../../factory/stream_component_factory.dart';

class StreamMessageComposerInputTrailing extends StatelessWidget {
  const StreamMessageComposerInputTrailing({super.key, required this.props});

  final MessageComposerComponentProps props;

  @override
  Widget build(BuildContext context) {
    return StreamTheme.of(
      context,
    ).componentFactory.messageComposer.inputTrailing(context, props);
  }
}

class DefaultStreamMessageComposerInputTrailing extends StatefulWidget {
  const DefaultStreamMessageComposerInputTrailing({super.key, required this.props});

  static StreamComponentBuilder<MessageComposerComponentProps> get factory =>
      (context, props) => DefaultStreamMessageComposerInputTrailing(props: props);

  final MessageComposerComponentProps props;

  @override
  State<DefaultStreamMessageComposerInputTrailing> createState() => _DefaultStreamMessageComposerInputTrailingState();
}

class _DefaultStreamMessageComposerInputTrailingState extends State<DefaultStreamMessageComposerInputTrailing> {
  var _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.props.controller.addListener(_onInputTextChanged);
    _hasText = widget.props.controller.text.isNotEmpty;
  }

  @override
  void didUpdateWidget(DefaultStreamMessageComposerInputTrailing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.props.controller != oldWidget.props.controller) {
      oldWidget.props.controller.removeListener(_onInputTextChanged);
      widget.props.controller.addListener(_onInputTextChanged);
    }
  }

  void _onInputTextChanged() {
    final hasText = widget.props.controller.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Implement the trailing component

    if (_hasText) {
      return StreamButton.icon(
        key: _messageComposerInputTrailingSendKey,
        icon: context.streamIcons.paperPlane,
        size: StreamButtonSize.small,
        onTap: () {},
      );
    }
    return StreamButton.icon(
      key: _messageComposerInputTrailingMicrophoneKey,
      icon: context.streamIcons.microphone,
      type: StreamButtonType.ghost,
      style: StreamButtonStyle.secondary,
      size: StreamButtonSize.small,
      onTap: () {},
    );
  }
}

final _messageComposerInputTrailingSendKey = UniqueKey();
final _messageComposerInputTrailingMicrophoneKey = UniqueKey();
