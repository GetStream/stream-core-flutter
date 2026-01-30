import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../stream_core_flutter.dart';
import '../../factory/stream_component_factory.dart';

class StreamMessageComposer extends StatelessWidget {
  const StreamMessageComposer({
    super.key,
    this.isFloating = false,
  });

  final bool isFloating;

  @override
  Widget build(BuildContext context) {
    return StreamTheme.of(
      context,
    ).componentFactory.messageComposer.messageComposer(context, MessageComposerProps(isFloating: isFloating));
  }
}

/// Properties to build the main message composer component
class MessageComposerProps {
  const MessageComposerProps({
    this.isFloating = false,
  });

  final bool isFloating;
}

/// Properties to build any of the sub-components.
/// These properties are all the same, so features such as 'add attachment',
/// can be added to any of the sub-components.
class MessageComposerComponentProps {
  const MessageComposerComponentProps({
    required this.controller,
    this.onAddAttachment,
    this.isFloating = false,
  });

  final TextEditingController controller;
  final VoidCallback? onAddAttachment;
  final bool isFloating;
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

    final componentProps = MessageComposerComponentProps(
      controller: _controller,
      onAddAttachment: () {},
      isFloating: widget.props.isFloating,
    );
    final bottomPaddingSafeArea = MediaQuery.of(context).padding.bottom;
    final minimumBottomPadding = spacing.md;
    final bottomPadding = math.max(bottomPaddingSafeArea, minimumBottomPadding);

    return Container(
      padding: EdgeInsets.only(top: spacing.md, bottom: bottomPadding),
      decoration: widget.props.isFloating
          ? null
          : BoxDecoration(
              color: context.streamColorScheme.backgroundElevation1,
              border: Border(
                top: BorderSide(color: context.streamColorScheme.borderDefault),
              ),
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(width: spacing.md),
          StreamMessageComposerLeading(props: componentProps),
          Expanded(child: StreamMessageComposerInput(props: componentProps)),
          StreamMessageComposerTrailing(props: componentProps),
          SizedBox(width: spacing.md),
        ],
      ),
    );
  }
}
