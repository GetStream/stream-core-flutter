import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../stream_core_flutter.dart';
import '../../factory/stream_component_factory.dart';

class StreamMessageComposerInputHeader extends StatelessWidget {
  const StreamMessageComposerInputHeader({super.key, required this.props});

  final MessageComposerComponentProps props;

  @override
  Widget build(BuildContext context) {
    return StreamTheme.of(
      context,
    ).componentFactory.messageComposer.inputHeader(context, props);
  }
}

class DefaultStreamMessageComposerInputHeader extends StatelessWidget {
  const DefaultStreamMessageComposerInputHeader({super.key, required this.props});

  static StreamComponentBuilder<MessageComposerComponentProps<MessageData>> get factory =>
      (context, props) => DefaultStreamMessageComposerInputHeader(props: props);

  final MessageComposerComponentProps props;

  @override
  Widget build(BuildContext context) {
    // Empty by default
    return const SizedBox.shrink();
  }
}
