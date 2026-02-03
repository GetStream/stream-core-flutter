import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../stream_core_flutter.dart';
import '../../factory/stream_component_factory.dart';

class StreamMessageComposer<T extends MessageData> extends StatelessWidget {
  const StreamMessageComposer({
    super.key,
    this.isFloating = false,
    this.messageData,
  });

  final bool isFloating;
  final T? messageData;

  @override
  Widget build(BuildContext context) {
    return StreamTheme.of(
      context,
    ).componentFactory.messageComposer.messageComposer(
      context,
      MessageComposerProps(isFloating: isFloating, messageData: messageData),
    );
  }
}

/// Properties to build the main message composer component
class MessageComposerProps<T extends MessageData> {
  const MessageComposerProps({
    this.isFloating = false,
    this.messageData,
  });

  final bool isFloating;
  final T? messageData;
}

/// Properties to build any of the sub-components.
/// These properties are all the same, so features such as 'add attachment',
/// can be added to any of the sub-components.
class MessageComposerComponentProps<T extends MessageData> {
  const MessageComposerComponentProps({
    required this.controller,
    this.isFloating = false,
    this.messageData,
  });

  final TextEditingController controller;
  final bool isFloating;
  final T? messageData;
}

class DefaultMessageComposer<T extends MessageData> extends StatefulWidget {
  const DefaultMessageComposer({super.key, required this.props});

  static StreamComponentBuilder<MessageComposerProps<MessageData>> get factory =>
      (context, props) => DefaultMessageComposer<MessageData>(props: props);

  final MessageComposerProps<T> props;

  @override
  State<DefaultMessageComposer<T>> createState() => _DefaultMessageComposerState();
}

class _DefaultMessageComposerState<T extends MessageData> extends State<DefaultMessageComposer<T>> {
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
      isFloating: widget.props.isFloating,
      messageData: widget.props.messageData,
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

class MessageData {}
