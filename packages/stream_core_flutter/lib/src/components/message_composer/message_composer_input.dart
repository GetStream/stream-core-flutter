import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../stream_core_flutter.dart';
import '../../factory/stream_component_factory.dart';

class StreamMessageComposerInput extends StatelessWidget {
  const StreamMessageComposerInput({super.key, required this.props});

  final MessageComposerComponentProps props;

  @override
  Widget build(BuildContext context) {
    return StreamTheme.of(
      context,
    ).componentFactory.messageComposer.input(context, props);
  }
}

class DefaultStreamMessageComposerInput extends StatelessWidget {
  const DefaultStreamMessageComposerInput({super.key, required this.props});

  static StreamComponentBuilder<MessageComposerComponentProps> get factory =>
      (context, props) => DefaultStreamMessageComposerInput(props: props);

  final MessageComposerComponentProps props;

  @override
  Widget build(BuildContext context) {
    // TODO: Add message composer theme

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.streamColorScheme.backgroundElevation1,
        borderRadius: BorderRadius.all(context.streamRadius.xxxl),
        border: Border.all(
          color: context.streamColorScheme.borderDefault,
        ),
        boxShadow: props.isFloating ? context.streamBoxShadow.elevation3 : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StreamMessageComposerInputHeader(props: props),
          Row(
            children: [
              StreamMessageComposerInputLeading(props: props),
              Expanded(child: _MessageComposerInputField(props: props)),
              StreamMessageComposerInputTrailing(props: props),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageComposerInputField extends StatelessWidget {
  const _MessageComposerInputField({required this.props});

  final MessageComposerComponentProps props;

  @override
  Widget build(BuildContext context) {
    // TODO: fully implement the input field

    final composerBorderRadius = context.streamRadius.xxxl;

    final border = OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.all(composerBorderRadius),
    );

    return TextField(
      controller: props.controller,
      decoration: InputDecoration(
        border: border,
        focusedBorder: border,
        enabledBorder: border,
        errorBorder: border,
        disabledBorder: border,
        fillColor: Colors.transparent,
        hintText: 'Placeholder',
      ),
    );
  }
}
