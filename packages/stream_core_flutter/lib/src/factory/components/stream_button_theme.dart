import 'package:flutter/widgets.dart';

import '../stream_theme.dart';

class StreamButtonTheme {
  StreamButtonTheme({this.primaryColor});

  final WidgetStateProperty<Color>? primaryColor;

  static StreamButtonTheme of(BuildContext context) {
    return StreamTheme.of(context).buttonTheme;
  }
}
