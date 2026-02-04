import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../components/accessories/stream_file_type_icon.dart' show DefaultStreamFileTypeIcon, StreamFileTypeIconProps;
import '../components/buttons/stream_button.dart' show DefaultStreamButton, StreamButtonProps;
import '../components/message_composer.dart';

typedef StreamComponentBuilder<T> = Widget Function(BuildContext context, T props);

class StreamComponentFactory<MessageComposerData extends MessageData> {
  StreamComponentFactory({
    StreamComponentBuilder<StreamButtonProps>? buttonFactory,
    StreamComponentBuilder<StreamFileTypeIconProps>? fileTypeIconFactory,
    StreamMessageComposerFactory<MessageComposerData>? messageComposer,
  }) : buttonFactory = buttonFactory ?? DefaultStreamButton.factory,
       fileTypeIconFactory = fileTypeIconFactory ?? DefaultStreamFileTypeIcon.factory,
       messageComposer = messageComposer ?? StreamMessageComposerFactory();

  StreamComponentBuilder<StreamButtonProps> buttonFactory;
  StreamComponentBuilder<StreamFileTypeIconProps> fileTypeIconFactory;
  StreamMessageComposerFactory<MessageComposerData> messageComposer;
}

class StreamMessageComposerFactory<T extends MessageData> {
  StreamMessageComposerFactory({
    StreamComponentBuilder<MessageComposerProps<T>>? messageComposer,
    StreamComponentBuilder<MessageComposerComponentProps<T>>? leading,
    StreamComponentBuilder<MessageComposerComponentProps<T>>? trailing,
    StreamComponentBuilder<MessageComposerComponentProps<T>>? input,
    StreamComponentBuilder<MessageComposerComponentProps<T>>? inputLeading,
    StreamComponentBuilder<MessageComposerComponentProps<T>>? inputHeader,
    StreamComponentBuilder<MessageComposerComponentProps<T>>? inputTrailing,
  }) : messageComposer = messageComposer ?? DefaultMessageComposer.factory,
       leading = leading ?? DefaultStreamMessageComposerLeading.factory,
       trailing = trailing ?? DefaultStreamMessageComposerTrailing.factory,
       input = input ?? DefaultStreamMessageComposerInput.factory,
       inputLeading = inputLeading ?? DefaultStreamMessageComposerInputLeading.factory,
       inputHeader = inputHeader ?? DefaultStreamMessageComposerInputHeader.factory,
       inputTrailing = inputTrailing ?? DefaultStreamMessageComposerInputTrailing.factory;

  StreamComponentBuilder<MessageComposerProps<T>> messageComposer;
  StreamComponentBuilder<MessageComposerComponentProps<T>> leading;
  StreamComponentBuilder<MessageComposerComponentProps<T>> trailing;
  StreamComponentBuilder<MessageComposerComponentProps<T>> input;
  StreamComponentBuilder<MessageComposerComponentProps<T>> inputLeading;
  StreamComponentBuilder<MessageComposerComponentProps<T>> inputHeader;
  StreamComponentBuilder<MessageComposerComponentProps<T>> inputTrailing;
}
