import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_button_theme.g.theme.dart';

class StreamButtonTheme extends InheritedTheme {
  const StreamButtonTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final StreamButtonThemeData data;

  static StreamButtonThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamButtonTheme>();
    return StreamTheme.of(context).buttonTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamButtonTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamButtonTheme oldWidget) => data != oldWidget.data;
}

@themeGen
@immutable
class StreamButtonThemeData with _$StreamButtonThemeData {
  const StreamButtonThemeData({
    this.primary,
    this.secondary,
    this.destructive,
  });

  final StreamButtonTypeStyle? primary;
  final StreamButtonTypeStyle? secondary;
  final StreamButtonTypeStyle? destructive;
}

@themeGen
@immutable
class StreamButtonTypeStyle with _$StreamButtonTypeStyle {
  const StreamButtonTypeStyle({
    this.solid,
    this.outline,
    this.ghost,
  });

  final StreamButtonThemeStyle? solid;
  final StreamButtonThemeStyle? outline;
  final StreamButtonThemeStyle? ghost;
}

class StreamButtonThemeStyle {
  const StreamButtonThemeStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  });

  final WidgetStateProperty<Color>? backgroundColor;
  final WidgetStateProperty<Color>? foregroundColor;
  final WidgetStateProperty<Color>? borderColor;
}
