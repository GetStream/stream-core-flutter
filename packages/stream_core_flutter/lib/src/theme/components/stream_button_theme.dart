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
    this.primaryButtonColors,
    this.secondaryButtonColors,
    this.destructiveButtonColors,
  });

  final StreamButtonColors? primaryButtonColors;
  final StreamButtonColors? secondaryButtonColors;
  final StreamButtonColors? destructiveButtonColors;
}

@themeGen
@immutable
class StreamButtonColors with _$StreamButtonColors {
  const StreamButtonColors({
    this.solidBackgroundColor,
    this.solidForegroundColor,
    this.outlineBorderColor,
    this.outlineForegroundColor,
    this.ghostForegroundColor,
  });

  final Color? solidBackgroundColor;
  final Color? solidForegroundColor;
  final Color? outlineBorderColor;
  final Color? outlineForegroundColor;
  final Color? ghostForegroundColor;
}
