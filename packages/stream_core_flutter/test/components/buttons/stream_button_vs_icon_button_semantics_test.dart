import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

// Pretty-prints the merge-effective SemanticsData for direct comparison —
// strips rect/transform/traversalParentIdentifier noise, one field per line.
String _fmt(SemanticsData d) {
  final lines = <String>[];
  void add(String key, Object? value) {
    if (value == null) return;
    if (value is String && value.isEmpty) return;
    if (value is List && value.isEmpty) return;
    lines.add('  $key: $value');
  }

  final actions = SemanticsAction.values.where((a) => (d.actions & a.index) != 0).map((a) => a.name).toList();
  final flags = d.flagsCollection.toStrings();

  add('actions', actions);
  add('flags', flags);
  add('label', d.label);
  add('value', d.value);
  add('hint', d.hint);
  add('tooltip', d.tooltip);
  add('textDirection', d.textDirection?.name);
  return '{\n${lines.join(',\n')}\n}';
}

Widget _withStreamTheme(Widget child, {bool useMaterial3 = true}) {
  return MaterialApp(
    theme: ThemeData(
      useMaterial3: useMaterial3,
      extensions: [StreamTheme()],
    ),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('Semantic tree comparison: IconButton vs StreamButton.icon', () {
    testWidgets('with isSelected=true, tooltip, onPressed', (tester) async {
      final handle = tester.ensureSemantics();

      // Flutter Material IconButton
      await tester.pumpWidget(
        _withStreamTheme(
          IconButton(
            isSelected: true,
            tooltip: 'Photo Gallery',
            onPressed: () {},
            icon: const Icon(Icons.photo),
          ),
        ),
      );

      final iconButtonNode = tester.getSemantics(find.byType(IconButton));
      debugPrint('--- IconButton (isSelected: true) ---');
      debugPrint(_fmt(iconButtonNode.getSemanticsData()));

      // Stream's StreamButton.icon
      await tester.pumpWidget(
        _withStreamTheme(
          StreamButton.icon(
            isSelected: true,
            tooltip: 'Photo Gallery',
            onPressed: () {},
            icon: const Icon(Icons.photo),
          ),
        ),
      );

      final streamButtonNode = tester.getSemantics(find.byType(StreamButton));
      debugPrint('--- StreamButton.icon (isSelected: true) ---');
      debugPrint(_fmt(streamButtonNode.getSemanticsData()));

      handle.dispose();
    });

    testWidgets('with isSelected=false, tooltip, onPressed', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          IconButton(
            isSelected: false,
            tooltip: 'Photo Gallery',
            onPressed: () {},
            icon: const Icon(Icons.photo),
          ),
        ),
      );

      debugPrint('--- IconButton (isSelected: false) ---');
      debugPrint(_fmt(tester.getSemantics(find.byType(IconButton)).getSemanticsData()));

      await tester.pumpWidget(
        _withStreamTheme(
          StreamButton.icon(
            isSelected: false,
            tooltip: 'Photo Gallery',
            onPressed: () {},
            icon: const Icon(Icons.photo),
          ),
        ),
      );

      debugPrint('--- StreamButton.icon (isSelected: false) ---');
      debugPrint(_fmt(tester.getSemantics(find.byType(StreamButton)).getSemanticsData()));

      handle.dispose();
    });
  });

  group('ToggleButtons (Flutter) behavior', () {
    testWidgets('semantic tree for selected toggle button', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          ToggleButtons(
            isSelected: const [true, false, false],
            onPressed: (_) {},
            children: const [
              Icon(Icons.photo),
              Icon(Icons.camera_alt),
              Icon(Icons.folder),
            ],
          ),
        ),
      );

      debugPrint('--- ToggleButtons (first index selected) ---');
      debugPrint(_fmt(tester.getSemantics(find.byType(ToggleButtons)).getSemanticsData()));
      debugPrint('--- First button: ---');
      debugPrint(_fmt(tester.getSemantics(find.byIcon(Icons.photo)).getSemanticsData()));
      debugPrint('--- Second button: ---');
      debugPrint(_fmt(tester.getSemantics(find.byIcon(Icons.camera_alt)).getSemanticsData()));

      handle.dispose();
    });

    testWidgets('captures events when tapping a toggle button', (tester) async {
      final handle = tester.ensureSemantics();

      final events = <String>[];
      tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
        SystemChannels.accessibility,
        (message) async {
          if (message is Map) {
            final type = message['type']?.toString();
            if (type != null) events.add(type);
          }
          return null;
        },
      );

      var pressedIndex = -1;
      await tester.pumpWidget(
        _withStreamTheme(
          ToggleButtons(
            isSelected: const [true, false, false],
            onPressed: (i) => pressedIndex = i,
            children: const [
              Icon(Icons.photo),
              Icon(Icons.camera_alt),
              Icon(Icons.folder),
            ],
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
        SystemChannels.accessibility,
        null,
      );

      debugPrint('--- ToggleButtons tap fired events: $events');
      debugPrint('--- pressedIndex: $pressedIndex');

      handle.dispose();
    });
  });

  group('Tap behavior: events fired on activation', () {
    Future<List<String>> capturedEvents(
      WidgetTester tester,
      Widget widget,
      Finder finder,
    ) async {
      final events = <String>[];
      // Semantic events flow through SystemChannels.accessibility.
      tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
        SystemChannels.accessibility,
        (message) async {
          if (message is Map) {
            final type = message['type']?.toString();
            if (type != null) events.add(type);
          }
          return null;
        },
      );
      await tester.pumpWidget(widget);
      await tester.tap(finder);
      await tester.pumpAndSettle();
      tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
        SystemChannels.accessibility,
        null,
      );
      return events;
    }

    testWidgets('IconButton vs StreamButton.icon — events on tap', (tester) async {
      final handle = tester.ensureSemantics();
      var iconButtonPresses = 0;
      var streamButtonPresses = 0;

      final iconEvents = await capturedEvents(
        tester,
        _withStreamTheme(
          IconButton(
            isSelected: false,
            tooltip: 'Photo Gallery',
            onPressed: () => iconButtonPresses++,
            icon: const Icon(Icons.photo),
          ),
        ),
        find.byType(IconButton),
      );

      final streamEvents = await capturedEvents(
        tester,
        _withStreamTheme(
          StreamButton.icon(
            isSelected: false,
            tooltip: 'Photo Gallery',
            onPressed: () => streamButtonPresses++,
            icon: const Icon(Icons.photo),
          ),
        ),
        find.byType(StreamButton),
      );

      debugPrint('--- IconButton tap fired events: $iconEvents');
      debugPrint('--- StreamButton.icon tap fired events: $streamEvents');
      debugPrint('--- IconButton onPressed count: $iconButtonPresses');
      debugPrint('--- StreamButton onPressed count: $streamButtonPresses');

      handle.dispose();
    });
  });

  group('Material 3 variants', () {
    testWidgets('IconButton M2 vs M3 (isSelected: true)', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          useMaterial3: false,
          IconButton(
            isSelected: true,
            tooltip: 'Photo Gallery',
            onPressed: () {},
            icon: const Icon(Icons.photo),
          ),
        ),
      );

      debugPrint('--- IconButton M2 (isSelected: true) ---');
      debugPrint(_fmt(tester.getSemantics(find.byType(IconButton)).getSemanticsData()));

      await tester.pumpWidget(
        _withStreamTheme(
          IconButton(
            isSelected: true,
            tooltip: 'Photo Gallery',
            onPressed: () {},
            icon: const Icon(Icons.photo),
          ),
        ),
      );

      debugPrint('--- IconButton M3 (isSelected: true) ---');
      debugPrint(_fmt(tester.getSemantics(find.byType(IconButton)).getSemanticsData()));

      handle.dispose();
    });

    testWidgets('IconButton.filled M3 (toggle) vs StreamButton.icon', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          IconButton.filled(
            isSelected: true,
            tooltip: 'Photo Gallery',
            onPressed: () {},
            icon: const Icon(Icons.photo),
          ),
        ),
      );

      debugPrint('--- IconButton.filled M3 (isSelected: true) ---');
      debugPrint(_fmt(tester.getSemantics(find.byType(IconButton)).getSemanticsData()));

      await tester.pumpWidget(
        _withStreamTheme(
          StreamButton.icon(
            isSelected: true,
            tooltip: 'Photo Gallery',
            onPressed: () {},
            icon: const Icon(Icons.photo),
          ),
        ),
      );

      debugPrint('--- StreamButton.icon (isSelected: true) ---');
      debugPrint(_fmt(tester.getSemantics(find.byType(StreamButton)).getSemanticsData()));

      handle.dispose();
    });

    testWidgets('FilledButton M3 vs StreamButton (solid)', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          FilledButton(
            onPressed: () {},
            child: const Text('Submit'),
          ),
        ),
      );

      debugPrint('--- FilledButton M3 ---');
      debugPrint(_fmt(tester.getSemantics(find.byType(FilledButton)).getSemanticsData()));

      await tester.pumpWidget(
        _withStreamTheme(
          StreamButton(
            onPressed: () {},
            child: const Text('Submit'),
          ),
        ),
      );

      debugPrint('--- StreamButton (solid) ---');
      debugPrint(_fmt(tester.getSemantics(find.byType(StreamButton)).getSemanticsData()));

      handle.dispose();
    });
  });

  group('Semantic tree comparison: ElevatedButton vs StreamButton', () {
    testWidgets('with text child, onPressed', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          ElevatedButton(
            onPressed: () {},
            child: const Text('Submit'),
          ),
        ),
      );

      debugPrint('--- ElevatedButton ---');
      debugPrint(_fmt(tester.getSemantics(find.byType(ElevatedButton)).getSemanticsData()));

      await tester.pumpWidget(
        _withStreamTheme(
          StreamButton(
            onPressed: () {},
            child: const Text('Submit'),
          ),
        ),
      );

      debugPrint('--- StreamButton ---');
      debugPrint(_fmt(tester.getSemantics(find.byType(StreamButton)).getSemanticsData()));

      handle.dispose();
    });

    testWidgets('with text child, isSelected=true, onPressed', (tester) async {
      final handle = tester.ensureSemantics();

      // ElevatedButton has no isSelected param, so we apply Semantics(selected:)
      // externally to compare apples-to-apples with StreamButton's built-in
      // isSelected handling.
      await tester.pumpWidget(
        _withStreamTheme(
          Semantics(
            selected: true,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Submit'),
            ),
          ),
        ),
      );

      debugPrint('--- ElevatedButton + Semantics(selected: true) ---');
      debugPrint(_fmt(tester.getSemantics(find.byType(ElevatedButton)).getSemanticsData()));

      await tester.pumpWidget(
        _withStreamTheme(
          StreamButton(
            isSelected: true,
            onPressed: () {},
            child: const Text('Submit'),
          ),
        ),
      );

      debugPrint('--- StreamButton (isSelected: true) ---');
      debugPrint(_fmt(tester.getSemantics(find.byType(StreamButton)).getSemanticsData()));

      handle.dispose();
    });
  });
}
