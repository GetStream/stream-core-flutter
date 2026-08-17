import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stream_core_flutter/core.dart';

const _childKey = Key('media-child');

class _FakeBar extends StatelessWidget implements PreferredSizeWidget {
  const _FakeBar({required this.height});

  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}

Widget _wrap(
  Widget child, {
  StreamMediaViewerThemeData? viewerTheme,
  StreamSurfaceStyle surfaceStyle = StreamSurfaceStyle.regular,
}) {
  final scoped = viewerTheme == null ? child : StreamMediaViewerTheme(data: viewerTheme, child: child);
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme(surfaceStyle: surfaceStyle)]),
    home: scoped,
  );
}

EdgeInsets _mediaInset(WidgetTester tester) {
  final padding = tester.widget<AnimatedPadding>(
    find.ancestor(of: find.byKey(_childKey), matching: find.byType(AnimatedPadding)),
  );
  return padding.padding.resolve(TextDirection.ltr);
}

void main() {
  group('StreamMediaViewer chrome layout', () {
    testWidgets('follows a regular app style → media is inset between the bars', (tester) async {
      await tester.pumpWidget(
        _wrap(
          StreamMediaViewer(
            header: const _FakeBar(height: 56),
            footer: const _FakeBar(height: 72),
            child: const SizedBox.expand(key: _childKey),
          ),
        ),
      );

      final inset = _mediaInset(tester);
      expect(inset.top, 56.0);
      expect(inset.bottom, 72.0);
    });

    testWidgets('regular chrome adds the device inset to the bar heights', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              final base = MediaQuery.of(context);
              return MediaQuery(
                data: base.copyWith(padding: const EdgeInsets.only(top: 44, bottom: 34)),
                child: StreamMediaViewer(
                  header: const _FakeBar(height: 56),
                  footer: const _FakeBar(height: 72),
                  child: const SizedBox.expand(key: _childKey),
                ),
              );
            },
          ),
        ),
      );

      // Docked chrome clears the system insets: bar height + device padding.
      final inset = _mediaInset(tester);
      expect(inset.top, 56.0 + 44.0);
      expect(inset.bottom, 72.0 + 34.0);
    });

    testWidgets('follows a floating app style → media is full-bleed behind the chrome', (tester) async {
      await tester.pumpWidget(
        _wrap(
          StreamMediaViewer(
            header: const _FakeBar(height: 56),
            footer: const _FakeBar(height: 72),
            child: const SizedBox.expand(key: _childKey),
          ),
          surfaceStyle: .floating,
        ),
      );

      final inset = _mediaInset(tester);
      expect(inset.top, 0.0);
      expect(inset.bottom, 0.0);
    });

    testWidgets('a regular chrome override insets the media even under a floating app style', (tester) async {
      await tester.pumpWidget(
        _wrap(
          StreamMediaViewer(
            header: const _FakeBar(height: 56),
            footer: const _FakeBar(height: 72),
            child: const SizedBox.expand(key: _childKey),
          ),
          surfaceStyle: .floating,
          viewerTheme: const StreamMediaViewerThemeData(
            appBarStyle: StreamAppBarStyle(surfaceStyle: .regular),
            bottomAppBarStyle: StreamBottomAppBarStyle(surfaceStyle: .regular),
          ),
        ),
      );

      final inset = _mediaInset(tester);
      expect(inset.top, 56.0);
      expect(inset.bottom, 72.0);
    });
  });
}
