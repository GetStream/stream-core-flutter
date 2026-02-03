import 'package:flutter/material.dart';

import '../../../stream_core_flutter.dart';
import '../../factory/stream_component_factory.dart';

class StreamMessageComposerLeading<T extends MessageData> extends StatelessWidget {
  const StreamMessageComposerLeading({super.key, required this.props});
  final MessageComposerComponentProps<T> props;

  @override
  Widget build(BuildContext context) {
    return StreamTheme.of(
      context,
    ).componentFactory.messageComposer.leading(context, props);
  }
}

class DefaultStreamMessageComposerLeading<T extends MessageData> extends StatelessWidget {
  const DefaultStreamMessageComposerLeading({super.key, required this.props});

  static StreamComponentBuilder<MessageComposerComponentProps> get factory =>
      (context, props) => DefaultStreamMessageComposerLeading(props: props);

  final MessageComposerComponentProps<T> props;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
