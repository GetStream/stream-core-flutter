import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: ThemeConfig)
Widget buildCoolButtonUseCase(BuildContext context) {
  return ThemeConfig();
}

class ThemeConfig extends StatelessWidget {
  const ThemeConfig({super.key});

  @override
  Widget build(BuildContext context) {
    final themeConfiguration = Provider.of<ThemeConfiguration>(context);

    return Column(
      children: [
        Text('Theme config'),
        Row(
          spacing: 16,
          children: [
            Container(
              width: 25,
              height: 25,
              color: themeConfiguration.themeData.primaryColor,
            ),
            Text('Primary color'),
            StreamButton(
              label: 'Pick color',
              onTap: () => pickColor(
                context,
                themeConfiguration.themeData.primaryColor ??
                    Theme.of(context).colorScheme.primary,
                (color) {
                  themeConfiguration.setPrimaryColor(color);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void pickColor(
    BuildContext context,
    Color pickerColor,
    ValueChanged<Color> onColorChanged,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pick a color'),
        content: SingleChildScrollView(
          child: MaterialPicker(
            pickerColor: pickerColor,
            onColorChanged: onColorChanged,
          ),
        ),
      ),
    );
  }
}

class ThemeConfiguration extends ChangeNotifier {
  StreamTheme themeData;

  ThemeConfiguration({required this.themeData});

  ThemeConfiguration.empty() : themeData = StreamTheme();

  void setPrimaryColor(Color color) {
    themeData = themeData.copyWith(primaryColor: color);
    notifyListeners();
  }
}
