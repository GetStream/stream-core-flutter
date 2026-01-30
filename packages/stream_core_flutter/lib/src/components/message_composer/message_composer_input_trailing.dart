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

class DefaultStreamMessageComposerInputTrailing extends StatelessWidget {
  const DefaultStreamMessageComposerInputTrailing({super.key, required this.props});

  static StreamComponentBuilder<MessageComposerComponentProps> get factory =>
      (context, props) => DefaultStreamMessageComposerInputTrailing(props: props);

  final MessageComposerComponentProps props;

  @override
  Widget build(BuildContext context) {
    // TODO: Implement the trailing component
    return StreamButton.icon(
      icon: Icons.send,
      type: StreamButtonType.ghost,
      style: StreamButtonStyle.secondary,
      onTap: () {},
    );
  }
}
