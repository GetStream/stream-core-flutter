import 'package:flutter/widgets.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

class StreamButtonTheme {
  StreamButtonTheme({this.primaryColor});

  final WidgetStateProperty<Color>? primaryColor;

  static StreamButtonTheme of(BuildContext context) {
    return StreamTheme.of(context).buttonTheme;
  }
}
