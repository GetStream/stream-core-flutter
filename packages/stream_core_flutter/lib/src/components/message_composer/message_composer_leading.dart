import 'package:flutter/material.dart';

import '../../../stream_core_flutter.dart';
import '../../factory/stream_component_factory.dart';

class StreamMessageComposerLeading extends StatelessWidget {
  const StreamMessageComposerLeading({super.key, required this.props});
  final MessageComposerComponentProps props;

  @override
  Widget build(BuildContext context) {
    return StreamTheme.of(
      context,
    ).componentFactory.messageComposer.leading(context, props);
  }
}

class DefaultStreamMessageComposerLeading extends StatelessWidget {
  const DefaultStreamMessageComposerLeading({super.key, required this.props});

  static StreamComponentBuilder<MessageComposerComponentProps> get factory =>
      (context, props) => DefaultStreamMessageComposerLeading(props: props);

  final MessageComposerComponentProps props;

  @override
  Widget build(BuildContext context) {
    // TODO: Implement the leading component
    return StreamButton.icon(
      icon: context.streamIcons.plusLarge,
      type: StreamButtonType.outline,
      style: StreamButtonStyle.secondary,
      size: StreamButtonSize.large,
      onTap: () {},
    );
  }
}
