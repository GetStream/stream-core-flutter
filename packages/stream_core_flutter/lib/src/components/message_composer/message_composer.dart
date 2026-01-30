import 'package:flutter/widgets.dart';

import '../../../stream_core_flutter.dart';
import '../../factory/stream_component_factory.dart';

class StreamMessageComposer extends StatelessWidget {
  const StreamMessageComposer({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamTheme.of(
      context,
    ).componentFactory.messageComposer.messageComposer(context, const MessageComposerProps());
  }
}

/// Properties to build the main message composer component
class MessageComposerProps {
  const MessageComposerProps();
}

/// Properties to build any of the sub-components.
/// These properties are all the same, so features such as 'add attachment',
/// can be added to any of the sub-components.
class MessageComposerComponentProps {
  const MessageComposerComponentProps({
    required this.controller,
  });

  final TextEditingController controller;
}

class DefaultMessageComposer extends StatefulWidget {
  const DefaultMessageComposer({super.key, required this.props});

  static StreamComponentBuilder<MessageComposerProps> get factory =>
      (context, props) => DefaultMessageComposer(props: props);

  final MessageComposerProps props;

  @override
  State<DefaultMessageComposer> createState() => _DefaultMessageComposerState();
}

class _DefaultMessageComposerState extends State<DefaultMessageComposer> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    final componentProps = MessageComposerComponentProps(controller: _controller);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(width: spacing.md),
        StreamMessageComposerLeading(props: componentProps),
        SizedBox(width: spacing.xs),
        Expanded(child: StreamMessageComposerInput(props: componentProps)),
        StreamMessageComposerTrailing(props: componentProps),
        SizedBox(width: spacing.md),
      ],
    );
  }
}
