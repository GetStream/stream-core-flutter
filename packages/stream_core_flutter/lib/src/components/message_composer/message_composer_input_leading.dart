import 'package:flutter/widgets.dart';

import '../../../stream_core_flutter.dart';
import '../../factory/stream_component_factory.dart';

class StreamMessageComposerInputLeading extends StatelessWidget {
  const StreamMessageComposerInputLeading({super.key, required this.props});

  final MessageComposerComponentProps props;

  @override
  Widget build(BuildContext context) {
    return StreamTheme.of(
      context,
    ).componentFactory.messageComposer.inputLeading(context, props);
  }
}

class DefaultStreamMessageComposerInputLeading extends StatelessWidget {
  const DefaultStreamMessageComposerInputLeading({super.key, required this.props});

  static StreamComponentBuilder<MessageComposerComponentProps> get factory =>
      (context, props) => DefaultStreamMessageComposerInputLeading(props: props);

  final MessageComposerComponentProps props;

  @override
  Widget build(BuildContext context) {
    // Doesn't show anything by default
    return const SizedBox.shrink();
  }
}
