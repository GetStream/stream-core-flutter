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
  }) : buttonFactory = buttonFactory ?? DefaultStreamButton.factory,
       fileTypeIconFactory = fileTypeIconFactory ?? DefaultStreamFileTypeIcon.factory;

  StreamComponentBuilder<StreamButtonProps> buttonFactory;
  StreamComponentBuilder<StreamFileTypeIconProps> fileTypeIconFactory;
}
