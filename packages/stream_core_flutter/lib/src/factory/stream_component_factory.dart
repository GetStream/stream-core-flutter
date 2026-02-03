import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../components/buttons/stream_button.dart' show DefaultStreamButton, StreamButtonProps;
import '../components/message_composer.dart';

typedef StreamComponentBuilder<T> = Widget Function(BuildContext context, T props);

class StreamComponentFactory {
  StreamComponentFactory({
    StreamComponentBuilder<StreamButtonProps>? buttonFactory,
    StreamMessageComposerFactory<dynamic>? messageComposer,
  }) : buttonFactory = buttonFactory ?? DefaultStreamButton.factory,
       messageComposer = messageComposer ?? StreamMessageComposerFactory();

  StreamComponentBuilder<StreamButtonProps> buttonFactory;
  StreamMessageComposerFactory<dynamic> messageComposer;
}

class StreamMessageComposerFactory<T> {
  StreamMessageComposerFactory({
    StreamComponentBuilder<MessageComposerProps>? messageComposer,
    StreamComponentBuilder<MessageComposerComponentProps>? leading,
    StreamComponentBuilder<MessageComposerComponentProps>? trailing,
    StreamComponentBuilder<MessageComposerComponentProps>? input,
    StreamComponentBuilder<MessageComposerComponentProps>? inputLeading,
    StreamComponentBuilder<MessageComposerComponentProps>? inputHeader,
    StreamComponentBuilder<MessageComposerComponentProps>? inputTrailing,
  }) : messageComposer = messageComposer ?? DefaultMessageComposer.factory,
       leading = leading ?? DefaultStreamMessageComposerLeading.factory,
       trailing = trailing ?? DefaultStreamMessageComposerTrailing.factory,
       input = input ?? DefaultStreamMessageComposerInput.factory,
       inputLeading = inputLeading ?? DefaultStreamMessageComposerInputLeading.factory,
       inputHeader = inputHeader ?? DefaultStreamMessageComposerInputHeader.factory,
       inputTrailing = inputTrailing ?? DefaultStreamMessageComposerInputTrailing.factory;

  StreamComponentBuilder<MessageComposerProps> messageComposer;
  StreamComponentBuilder<MessageComposerComponentProps> leading;
  StreamComponentBuilder<MessageComposerComponentProps> trailing;
  StreamComponentBuilder<MessageComposerComponentProps> input;
  StreamComponentBuilder<MessageComposerComponentProps> inputLeading;
  StreamComponentBuilder<MessageComposerComponentProps> inputHeader;
  StreamComponentBuilder<MessageComposerComponentProps> inputTrailing;
}
