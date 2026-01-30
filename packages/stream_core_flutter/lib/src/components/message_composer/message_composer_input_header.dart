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

  static StreamComponentBuilder<MessageComposerComponentProps> get factory =>
      (context, props) => DefaultStreamMessageComposerInputHeader(props: props);

  final MessageComposerComponentProps props;

  @override
  Widget build(BuildContext context) {
    // TODO: Implement the header component
    return Padding(
      padding: EdgeInsets.only(
        left: context.streamSpacing.xs,
        right: context.streamSpacing.xs,
        top: context.streamSpacing.xs,
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HeaderSlotPlaceholder(),
          HeaderSlotPlaceholder(),
          HeaderSlotPlaceholder(),
        ],
      ),
    );
  }
}

class HeaderSlotPlaceholder extends StatelessWidget {
  const HeaderSlotPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    return Padding(
      padding: EdgeInsets.all(spacing.xxs),
      child: Container(
        height: 40,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.pinkAccent,
          border: Border.all(color: Colors.pink),
          borderRadius: BorderRadius.all(context.streamRadius.md),
        ),
      ),
    );
  }
}
