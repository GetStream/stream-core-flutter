import 'package:flutter/material.dart';

import 'components/stream_button_theme.dart';
import 'stream_component_factory.dart';

class StreamTheme extends ThemeExtension<StreamTheme> {
  StreamTheme({
    StreamComponentFactory? componentFactory,
    this.primaryColor,
    StreamButtonTheme? buttonTheme,
  }) : componentFactory = componentFactory ?? StreamComponentFactory(),
       buttonTheme = buttonTheme ?? StreamButtonTheme();

  final StreamComponentFactory componentFactory;

  final Color? primaryColor;

  final StreamButtonTheme buttonTheme;

  static StreamTheme of(BuildContext context) {
    return Theme.of(context).extension<StreamTheme>() ?? StreamTheme();
  }

  @override
  StreamTheme copyWith({Color? primaryColor, StreamButtonTheme? buttonTheme}) {
    return StreamTheme(
      componentFactory: componentFactory,
      primaryColor: primaryColor ?? this.primaryColor,
      buttonTheme: buttonTheme ?? this.buttonTheme,
    );
  }

  @override
  ThemeExtension<StreamTheme> lerp(
    covariant ThemeExtension<StreamTheme>? other,
    double t,
  ) {
    if (other is! StreamTheme) {
      return this;
    }
    return StreamTheme();
  }
}
