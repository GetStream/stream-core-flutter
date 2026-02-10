import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../../../stream_core_flutter.dart';

part 'stream_input_theme.g.theme.dart';

class StreamInputTheme extends InheritedTheme {
  const StreamInputTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final StreamInputThemeData data;

  static StreamInputThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamInputTheme>();
    return StreamTheme.of(context).inputTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamInputTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamInputTheme oldWidget) => data != oldWidget.data;
}

@themeGen
@immutable
class StreamInputThemeData with _$StreamInputThemeData {
  const StreamInputThemeData({
    this.textColor,
    this.placeholderColor,
    this.disabledColor,
    this.iconColor,
    this.borderColor,
  });

  final Color? textColor;
  final Color? placeholderColor;
  final Color? disabledColor;
  final Color? iconColor;

  final Color? borderColor;
}
