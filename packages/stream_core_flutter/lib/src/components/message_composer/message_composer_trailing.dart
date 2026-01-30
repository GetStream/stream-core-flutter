import 'package:flutter/widgets.dart';

import '../../../stream_core_flutter.dart';
import '../../factory/stream_component_factory.dart';

class StreamMessageComposerTrailing extends StatelessWidget {
  const StreamMessageComposerTrailing({super.key, required this.props});

  final MessageComposerComponentProps props;

  @override
  Widget build(BuildContext context) {
    return StreamTheme.of(
      context,
    ).componentFactory.messageComposer.trailing(context, props);
  }
}

class DefaultStreamMessageComposerTrailing extends StatelessWidget {
  const DefaultStreamMessageComposerTrailing({super.key, required this.props});

  static StreamComponentBuilder<MessageComposerComponentProps> get factory =>
      (context, props) => DefaultStreamMessageComposerTrailing(props: props);

  final MessageComposerComponentProps props;

  @override
  Widget build(BuildContext context) {
    // Doesn't show anything by default
    return const SizedBox.shrink();
  }
}
