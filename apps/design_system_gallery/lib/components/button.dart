import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// Import the widget from your app

@widgetbook.UseCase(name: 'Default', type: StreamButton)
Widget buildCoolButtonUseCase(BuildContext context) {
  return Center(
    child: StreamButton(
      label: context.knobs.string(label: 'Label', initialValue: 'Click me'),
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Button clicked')));
      },
      type: context.knobs.object.dropdown(
        label: 'Type',
        options: StreamButtonType.values,
        initialOption: StreamButtonType.primary,
        labelBuilder: (option) => option.name,
      ),
      size: context.knobs.object.dropdown(
        label: 'Size',
        options: StreamButtonSize.values,
        initialOption: StreamButtonSize.large,
        labelBuilder: (option) => option.name,
      ),
    ),
  );
}
