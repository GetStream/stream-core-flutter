import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/video.dart';

/// Three tabs, each drawing its name as its content.
List<StreamModalWindowTab> _tabs({List<String>? built}) => [
  for (final (name, icon) in [
    ('Device', const StreamIcons().settingsFill),
    ('Effects', const StreamIcons().blurFill),
    ('Captions', const StreamIcons().captionFill),
  ])
    StreamModalWindowTab(
      icon: Icon(icon),
      label: Text(name),
      builder: (context) {
        built?.add(name);
        return Text('$name content');
      },
    ),
];

class _TestWrapper extends StatelessWidget {
  const _TestWrapper({
    this.platform = TargetPlatform.android,
    required this.child,
  });

  final TargetPlatform platform;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(platform: platform, extensions: [StreamTheme()]),
      home: Material(child: child),
    );
  }
}

/// Pumps [window] in a surface of [size], as if it had been opened in an app
/// window that big.
Future<void> _pumpWindow(
  WidgetTester tester,
  Widget window, {
  Size size = const Size(1024, 768),
  TextDirection textDirection = TextDirection.ltr,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    _TestWrapper(
      child: Directionality(textDirection: textDirection, child: window),
    ),
  );
}

/// A window on iOS whose one tab is a menu anchor, wrapped by [wrap].
Widget _windowWithMenu({Widget Function(Widget child)? wrap}) {
  final Widget menu = StreamAdaptiveMenuAnchor(
    title: 'Microphone',
    sections: [
      StreamMenuSection(
        options: [StreamMenuOption(label: 'Jabra', onSelected: () {})],
      ),
    ],
    builder: (context, handle) => TextButton(onPressed: handle.toggle, child: const Text('open')),
  );

  return _TestWrapper(
    platform: TargetPlatform.iOS,
    child: StreamModalWindow(
      tabs: [
        StreamModalWindowTab(
          icon: Icon(const StreamIcons().settingsFill),
          label: const Text('Device'),
          builder: (context) => wrap?.call(menu) ?? menu,
        ),
      ],
    ),
  );
}

void main() {
  group('StreamModalWindow', () {
    testWidgets('a menu in a tab opens anchored on a phone platform', (tester) async {
      await tester.pumpWidget(_windowWithMenu());

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byType(StreamSheetHeader), findsNothing);
      expect(find.text('Jabra'), findsOneWidget);
    });

    testWidgets('a tab can ask its menus for a sheet', (tester) async {
      await tester.pumpWidget(
        _windowWithMenu(
          wrap: (child) => StreamAdaptiveMenuAnchorTheme(
            data: const StreamAdaptiveMenuAnchorThemeData(useSheet: true),
            child: child,
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byType(StreamSheetHeader), findsOneWidget);
    });

    testWidgets('shows the first tab with its label as the title', (tester) async {
      await _pumpWindow(tester, StreamModalWindow(tabs: _tabs()));

      expect(find.text('Device content'), findsOneWidget);
      // Once in the sidebar, once as the header's title.
      expect(find.text('Device'), findsNWidgets(2));
      expect(find.text('Effects'), findsOneWidget);
    });

    testWidgets('selecting a tab shows it and reports it', (tester) async {
      final changes = <int>[];
      await _pumpWindow(tester, StreamModalWindow(tabs: _tabs(), onTabChanged: changes.add));

      await tester.tap(find.text('Effects'));
      await tester.pump();

      expect(find.text('Effects content'), findsOneWidget);
      expect(find.text('Device content'), findsNothing);
      expect(find.text('Effects'), findsNWidgets(2));
      expect(changes, [1]);

      // Selecting the selected tab again changes nothing.
      await tester.tap(find.text('Effects').first);
      await tester.pump();
      expect(changes, [1]);
    });

    testWidgets('builds only the selected tab, again each time', (tester) async {
      final built = <String>[];
      await _pumpWindow(tester, StreamModalWindow(tabs: _tabs(built: built)));

      expect(built, ['Device']);

      await tester.tap(find.text('Captions'));
      await tester.pump();
      await tester.tap(find.text('Device').first);
      await tester.pump();

      expect(built, ['Device', 'Captions', 'Device']);
    });

    testWidgets('opens on initialIndex', (tester) async {
      await _pumpWindow(tester, StreamModalWindow(tabs: _tabs(), initialIndex: 2));
      expect(find.text('Captions content'), findsOneWidget);
    });

    test('an initialIndex outside the tabs asserts', () {
      expect(() => StreamModalWindow(tabs: _tabs(), initialIndex: 3), throwsAssertionError);
      expect(() => StreamModalWindow(tabs: _tabs(), initialIndex: -1), throwsAssertionError);
    });

    test('no tabs asserts', () {
      expect(() => StreamModalWindow(tabs: const []), throwsAssertionError);
    });

    testWidgets('losing the selected tab selects the last one left', (tester) async {
      await _pumpWindow(tester, StreamModalWindow(tabs: _tabs(), initialIndex: 2));
      expect(find.text('Captions content'), findsOneWidget);

      await _pumpWindow(tester, StreamModalWindow(tabs: _tabs().take(2).toList()));
      expect(find.text('Effects content'), findsOneWidget);
    });

    testWidgets('fills its constraints', (tester) async {
      await _pumpWindow(
        tester,
        StreamModalWindow(
          tabs: _tabs(),
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 400),
        ),
      );

      final surface = find.descendant(of: find.byType(Dialog), matching: find.byType(Material)).first;
      expect(tester.getSize(surface), const Size(600, 400));
    });

    testWidgets('the title is read out as a heading', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpWindow(tester, StreamModalWindow(tabs: _tabs()));

      expect(
        find.semantics.byPredicate((node) => node.label == 'Device' && node.flagsCollection.isHeader),
        findsOne,
      );
      semantics.dispose();
    });

    testWidgets('the selected tab is marked selected for screen readers', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpWindow(tester, StreamModalWindow(tabs: _tabs()));

      expect(
        find.semantics.byPredicate(
          (node) =>
              node.label == 'Device' &&
              node.flagsCollection.isButton &&
              node.flagsCollection.isSelected == Tristate.isTrue,
        ),
        findsOne,
      );
      expect(
        find.semantics.byPredicate(
          (node) =>
              node.label == 'Effects' &&
              node.flagsCollection.isButton &&
              node.flagsCollection.isSelected != Tristate.isTrue,
        ),
        findsOne,
      );
      semantics.dispose();
    });

    testWidgets('the close button pops the window', (tester) async {
      var popped = false;

      await tester.pumpWidget(
        _TestWrapper(
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                await showStreamModalDialog<void>(
                  context: context,
                  builder: (context) => StreamModalWindow(tabs: _tabs()),
                );
                popped = true;
              },
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Device content'), findsOneWidget);

      await tester.tap(find.byIcon(const StreamIcons().xmark));
      await tester.pumpAndSettle();

      expect(find.text('Device content'), findsNothing);
      expect(popped, isTrue);
    });

    testWidgets('onClose replaces popping', (tester) async {
      var closed = false;
      await _pumpWindow(tester, StreamModalWindow(tabs: _tabs(), onClose: () => closed = true));

      await tester.tap(find.byIcon(const StreamIcons().xmark));
      expect(closed, isTrue);
    });

    testWidgets('showCloseButton: false draws no close button', (tester) async {
      await _pumpWindow(tester, StreamModalWindow(tabs: _tabs(), showCloseButton: false));

      expect(find.byIcon(const StreamIcons().xmark), findsNothing);
    });

    testWidgets('the sidebar is at the start edge', (tester) async {
      await _pumpWindow(tester, StreamModalWindow(tabs: _tabs()));

      expect(
        tester.getCenter(find.text('Effects')).dx,
        lessThan(tester.getCenter(find.text('Device content')).dx),
      );
    });

    testWidgets('right to left, the sidebar is at the right edge', (tester) async {
      await _pumpWindow(tester, StreamModalWindow(tabs: _tabs()), textDirection: TextDirection.rtl);

      expect(
        tester.getCenter(find.text('Effects')).dx,
        greaterThan(tester.getCenter(find.text('Device content')).dx),
      );
    });

    testWidgets('a component factory builder replaces the default', (tester) async {
      StreamModalWindowProps? received;

      await _pumpWindow(
        tester,
        StreamComponentFactory(
          builders: StreamComponentBuilders(
            modalWindow: (context, props) {
              received = props;
              return const Text('custom window');
            },
          ),
          child: StreamModalWindow(tabs: _tabs(), initialIndex: 1),
        ),
      );

      expect(find.text('custom window'), findsOneWidget);
      expect(find.byType(DefaultStreamModalWindow), findsNothing);
      expect(received?.initialIndex, 1);
      expect(received?.tabs, hasLength(3));
    });

    group('in a narrow window', () {
      const narrow = Size(560, 600);

      testWidgets('the sidebar shows only icons', (tester) async {
        await _pumpWindow(tester, StreamModalWindow(tabs: _tabs()), size: narrow);

        // The labels are still in the tree for screen readers, but not drawn.
        final effects = find.text('Effects');
        expect(effects, findsOneWidget);
        expect(tester.getSize(effects), Size.zero);
        expect(find.byIcon(const StreamIcons().blurFill), findsOneWidget);
        expect(find.text('Device content'), findsOneWidget);
      });

      testWidgets('a row keeps its label for screen readers', (tester) async {
        final semantics = tester.ensureSemantics();
        await _pumpWindow(tester, StreamModalWindow(tabs: _tabs()), size: narrow);

        expect(
          find.semantics.byPredicate((node) => node.label == 'Effects' && node.flagsCollection.isButton),
          findsOne,
        );
        semantics.dispose();
      });

      testWidgets('a row shows its label as a tooltip', (tester) async {
        await _pumpWindow(tester, StreamModalWindow(tabs: _tabs()), size: narrow);

        await tester.longPress(find.byIcon(const StreamIcons().blurFill));
        await tester.pumpAndSettle();

        final tooltipLabel = find.descendant(of: find.byType(Overlay), matching: find.text('Effects'));
        // The hidden label in the row, and the one in the tooltip.
        expect(tooltipLabel, findsNWidgets(2));
        expect(tester.getSize(tooltipLabel.last), isNot(Size.zero));
      });

      testWidgets('tooltip replaces the label as the tooltip', (tester) async {
        await _pumpWindow(
          tester,
          StreamModalWindow(
            tabs: [
              StreamModalWindowTab(
                icon: Icon(const StreamIcons().settingsFill),
                label: const Text('Device'),
                tooltip: 'Camera and microphone',
                builder: (context) => const Text('Device content'),
              ),
            ],
          ),
          size: narrow,
        );

        await tester.longPress(find.byIcon(const StreamIcons().settingsFill));
        await tester.pumpAndSettle();

        expect(find.text('Camera and microphone'), findsOneWidget);
      });

      testWidgets('tapping an icon selects its tab', (tester) async {
        await _pumpWindow(tester, StreamModalWindow(tabs: _tabs()), size: narrow);

        await tester.tap(find.byIcon(const StreamIcons().captionFill));
        await tester.pump();

        expect(find.text('Captions content'), findsOneWidget);
      });

      testWidgets('right to left, the icons are at the right edge', (tester) async {
        await _pumpWindow(
          tester,
          StreamModalWindow(tabs: _tabs()),
          size: narrow,
          textDirection: TextDirection.rtl,
        );

        expect(
          tester.getCenter(find.byIcon(const StreamIcons().blurFill)).dx,
          greaterThan(tester.getCenter(find.text('Device content')).dx),
        );
      });
    });
  });
}
