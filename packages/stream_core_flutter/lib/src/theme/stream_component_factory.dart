import 'package:flutter/widgets.dart';
import '../../stream_core_flutter.dart';

import '../components/stream_button.dart' show DefaultStreamButton;

typedef StreamComponentBuilder<T> = Widget Function(BuildContext context, T props);

class StreamComponentFactory {
  StreamComponentFactory({
    StreamComponentBuilder<StreamButtonProps>? buttonFactory,
  }) : buttonFactory = buttonFactory ?? DefaultStreamButton.factory;

  StreamComponentBuilder<StreamButtonProps> buttonFactory;
}
