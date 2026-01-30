import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../components/buttons/stream_button.dart' show DefaultStreamButton, StreamButtonProps;
import '../components/accessories/file_type_icon.dart' show DefaultStreamFileTypeIcon, StreamFileTypeIconProps;

typedef StreamComponentBuilder<T> = Widget Function(BuildContext context, T props);

class StreamComponentFactory {
  StreamComponentFactory({
    StreamComponentBuilder<StreamButtonProps>? buttonFactory,
    StreamComponentBuilder<StreamFileTypeIconProps>? fileTypeIconFactory,
  }) : buttonFactory = buttonFactory ?? DefaultStreamButton.factory,
       fileTypeIconFactory = fileTypeIconFactory ?? DefaultStreamFileTypeIcon.factory;

  StreamComponentBuilder<StreamButtonProps> buttonFactory;
  StreamComponentBuilder<StreamFileTypeIconProps> fileTypeIconFactory;
}
