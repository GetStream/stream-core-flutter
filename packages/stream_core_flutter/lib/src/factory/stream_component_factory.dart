import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'components/stream_button.dart' show DefaultStreamButton, StreamButtonProps;

typedef StreamComponentBuilder<T> = Widget Function(BuildContext context, T props);

class StreamComponentFactory {
  StreamComponentFactory({
    StreamComponentBuilder<StreamButtonProps>? buttonFactory,
  }) : buttonFactory = buttonFactory ?? DefaultStreamButton.factory;

  StreamComponentBuilder<StreamButtonProps> buttonFactory;
}
