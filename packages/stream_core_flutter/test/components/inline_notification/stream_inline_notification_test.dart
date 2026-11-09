import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  testWidgets('StreamInlineNotification renders the title and description', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamInlineNotification(
          title: const Text('Changes are saved automatically'),
          description: const Text('Edits sync across your devices.'),
        ),
      ),
    );

    expect(find.text('Changes are saved automatically'), findsOneWidget);
    expect(find.text('Edits sync across your devices.'), findsOneWidget);
  });

  final expectedBackgrounds = <StreamInlineNotificationType, Color Function(StreamColorScheme)>{
    .info: (colorScheme) => colorScheme.backgroundInfoSubtle,
    .success: (colorScheme) => colorScheme.backgroundSuccessSubtle,
    .warning: (colorScheme) => colorScheme.backgroundWarningSubtle,
    .error: (colorScheme) => colorScheme.backgroundErrorSubtle,
  };
  for (final type in StreamInlineNotificationType.values) {
    testWidgets('StreamInlineNotification paints the subtle background of the ${type.name} type', (tester) async {
      await tester.pumpWidget(_wrap(StreamInlineNotification(type: type, title: const Text('Title'))));

      expect(_backgroundColorOf(tester), expectedBackgrounds[type]!(_colorSchemeOf(tester)));
    });
  }

  final expectedIconColors = <StreamInlineNotificationType, Color Function(StreamColorScheme)>{
    .info: (colorScheme) => colorScheme.accentPrimary,
    .success: (colorScheme) => colorScheme.accentSuccess,
    .warning: (colorScheme) => colorScheme.accentWarning,
    .error: (colorScheme) => colorScheme.accentError,
  };
  for (final type in StreamInlineNotificationType.values) {
    testWidgets('StreamInlineNotification colors the ${type.name} icon with its accent', (tester) async {
      await tester.pumpWidget(_wrap(StreamInlineNotification(type: type, title: const Text('Title'))));

      expect(_leadingIconColorOf(tester), expectedIconColors[type]!(_colorSchemeOf(tester)));
    });
  }

  final expectedIcons = <StreamInlineNotificationType, IconData>{
    .info: StreamIconData.info,
    .success: StreamIconData.checkmark,
    .warning: StreamIconData.exclamationTriangleFill,
    .error: StreamIconData.exclamationCircle,
  };
  for (final type in StreamInlineNotificationType.values) {
    testWidgets('StreamInlineNotification shows the default icon for the ${type.name} type', (tester) async {
      await tester.pumpWidget(_wrap(StreamInlineNotification(type: type, title: const Text('Title'))));

      expect(find.byIcon(expectedIcons[type]!), findsOneWidget);
    });
  }

  testWidgets('StreamInlineNotification replaces the default icon with a custom one', (tester) async {
    await tester.pumpWidget(
      _wrap(StreamInlineNotification(type: .error, icon: const Icon(Icons.wifi_off), title: const Text('Title'))),
    );

    expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    expect(find.byIcon(StreamIconData.exclamationCircle), findsNothing);
  });

  testWidgets('StreamInlineNotification tints a custom icon with the icon color', (tester) async {
    await tester.pumpWidget(
      _wrap(StreamInlineNotification(type: .error, icon: const Icon(Icons.wifi_off), title: const Text('Title'))),
    );

    final iconTheme = IconTheme.of(tester.element(find.byIcon(Icons.wifi_off)));
    expect(iconTheme.color, _colorSchemeOf(tester).accentError);
  });

  testWidgets('StreamInlineNotification hides the icon when showIcon is false', (tester) async {
    await tester.pumpWidget(_wrap(StreamInlineNotification(showIcon: false, title: const Text('Title'))));

    expect(find.byType(Icon), findsNothing);
  });

  testWidgets('StreamInlineNotification hugs its content height in a bounded parent', (tester) async {
    await tester.pumpWidget(
      _wrap(SizedBox(width: 370, child: StreamInlineNotification(title: const Text('Title')))),
    );

    final screenHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(tester.getSize(find.byType(StreamInlineNotification)).height, lessThan(screenHeight));
  });

  testWidgets('StreamInlineNotification grows taller without overflowing at a large text scale', (tester) async {
    const title = 'A long title that wraps over several lines once the text is scaled up';
    final notification = SizedBox(width: 320, child: StreamInlineNotification(title: const Text(title)));

    await tester.pumpWidget(_wrap(notification));
    final unscaledHeight = tester.getSize(find.byType(StreamInlineNotification)).height;

    await tester.pumpWidget(_wrap(notification, textScale: 2));

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(StreamInlineNotification)).height, greaterThan(unscaledHeight));
  });

  testWidgets('StreamInlineNotification insets the content 12 from the end edge', (tester) async {
    await tester.pumpWidget(_wrap(SizedBox(width: 320, child: StreamInlineNotification(title: const Text('Title')))));

    final notificationRight = tester.getTopRight(find.byType(StreamInlineNotification)).dx;
    expect(notificationRight - tester.getTopRight(_contentOf(tester)).dx, 12);
  });

  group('when textDirection is RTL', () {
    testWidgets('StreamInlineNotification insets the content 12 from the left edge', (tester) async {
      await tester.pumpWidget(
        _wrap(SizedBox(width: 320, child: StreamInlineNotification(title: const Text('Title'))), rtl: true),
      );

      final notificationLeft = tester.getTopLeft(find.byType(StreamInlineNotification)).dx;
      expect(tester.getTopLeft(_contentOf(tester)).dx - notificationLeft, 12);
    });

    testWidgets('StreamInlineNotification insets the icon from the right edge', (tester) async {
      await tester.pumpWidget(
        _wrap(SizedBox(width: 320, child: StreamInlineNotification(title: const Text('Title'))), rtl: true),
      );

      final notificationRight = tester.getTopRight(find.byType(StreamInlineNotification)).dx;
      final iconRight = tester.getTopRight(find.byType(Icon)).dx;
      expect(notificationRight - iconRight, 12);
    });
  });

  testWidgets('StreamInlineNotification announces its text as a live region', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      _wrap(StreamInlineNotification(title: const Text('Title'), description: const Text('Description'))),
    );

    expect(
      tester.semantics.find(find.byType(DefaultStreamInlineNotification)),
      isSemantics(label: 'Title\nDescription', isLiveRegion: true),
    );
    handle.dispose();
  });

  testWidgets('StreamInlineNotificationTheme overrides the style of one type', (tester) async {
    const themeData = StreamInlineNotificationThemeData(
      error: StreamInlineNotificationThemeStyle(backgroundColor: Color(0xFF111111), iconColor: Color(0xFF222222)),
    );

    await tester.pumpWidget(
      _wrap(
        StreamInlineNotificationTheme(
          data: themeData,
          child: StreamInlineNotification(type: .error, title: const Text('Title')),
        ),
      ),
    );

    expect(_backgroundColorOf(tester), const Color(0xFF111111));
    expect(_leadingIconColorOf(tester), const Color(0xFF222222));
  });

  testWidgets('StreamInlineNotificationTheme leaves the other types untouched', (tester) async {
    const themeData = StreamInlineNotificationThemeData(
      error: StreamInlineNotificationThemeStyle(backgroundColor: Color(0xFF111111)),
    );

    await tester.pumpWidget(
      _wrap(
        StreamInlineNotificationTheme(
          data: themeData,
          child: StreamInlineNotification(title: const Text('Title')),
        ),
      ),
    );

    expect(_backgroundColorOf(tester), _colorSchemeOf(tester).backgroundInfoSubtle);
  });

  for (final type in StreamInlineNotificationType.values) {
    testWidgets('StreamInlineNotificationTheme applies a shared padding to the ${type.name} type', (tester) async {
      const themeData = StreamInlineNotificationThemeData(padding: EdgeInsets.all(20));

      await tester.pumpWidget(
        _wrap(
          StreamInlineNotificationTheme(
            data: themeData,
            child: SizedBox(
              width: 320,
              child: StreamInlineNotification(type: type, title: const Text('Title')),
            ),
          ),
        ),
      );

      final notificationLeft = tester.getTopLeft(find.byType(StreamInlineNotification)).dx;
      expect(tester.getTopLeft(find.byType(Icon)).dx - notificationLeft, 20);
    });
  }

  testWidgets('StreamInlineNotificationTheme overrides the title style of one type only', (tester) async {
    const themeData = StreamInlineNotificationThemeData(
      error: StreamInlineNotificationThemeStyle(titleTextStyle: TextStyle(color: Color(0xFF444444))),
    );

    await tester.pumpWidget(
      _wrap(
        StreamInlineNotificationTheme(
          data: themeData,
          child: Column(
            children: [
              StreamInlineNotification(type: .error, title: const Text('Error')),
              StreamInlineNotification(title: const Text('Info')),
            ],
          ),
        ),
      ),
    );

    final colorScheme = StreamTheme.of(tester.element(find.text('Error'))).colorScheme;
    expect(tester.renderObject<RenderParagraph>(find.text('Error')).text.style?.color, const Color(0xFF444444));
    expect(tester.renderObject<RenderParagraph>(find.text('Info')).text.style?.color, colorScheme.textPrimary);
  });

  testWidgets('StreamInlineNotificationTheme applies a themed spacing between the icon and the text', (tester) async {
    const themeData = StreamInlineNotificationThemeData(spacing: 16);

    await tester.pumpWidget(
      _wrap(
        StreamInlineNotificationTheme(
          data: themeData,
          child: SizedBox(width: 320, child: StreamInlineNotification(title: const Text('Title'))),
        ),
      ),
    );

    final iconRight = tester.getTopRight(find.byType(Icon)).dx;
    expect(tester.getTopLeft(_contentOf(tester)).dx - iconRight, 16);
  });

  testWidgets('StreamInlineNotification has rounded superellipse corners by default', (tester) async {
    await tester.pumpWidget(_wrap(StreamInlineNotification(title: const Text('Title'))));

    final radius = StreamTheme.of(tester.element(find.byType(StreamInlineNotification))).radius;
    expect(_surfaceOf(tester).shape, RoundedSuperellipseBorder(borderRadius: .all(radius.md)));
  });

  testWidgets('StreamInlineNotificationTheme applies a themed shape', (tester) async {
    const shape = StadiumBorder();

    await tester.pumpWidget(
      _wrap(
        StreamInlineNotificationTheme(
          data: const StreamInlineNotificationThemeData(shape: shape),
          child: StreamInlineNotification(title: const Text('Title')),
        ),
      ),
    );

    expect(_surfaceOf(tester).shape, shape);
  });

  testWidgets('StreamInlineNotification is at least 46 tall by default', (tester) async {
    await tester.pumpWidget(_wrap(SizedBox(width: 320, child: StreamInlineNotification(title: const Text('Title')))));

    expect(tester.getSize(find.byType(StreamInlineNotification)).height, 46);
  });

  testWidgets('StreamInlineNotificationTheme applies themed constraints', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamInlineNotificationTheme(
          data: const StreamInlineNotificationThemeData(constraints: BoxConstraints(minHeight: 80)),
          child: SizedBox(width: 320, child: StreamInlineNotification(title: const Text('Title'))),
        ),
      ),
    );

    expect(tester.getSize(find.byType(StreamInlineNotification)).height, 80);
  });

  testWidgets('StreamInlineNotificationTheme merges over the root StreamTheme', (tester) async {
    const rootTheme = StreamInlineNotificationThemeData(
      info: StreamInlineNotificationThemeStyle(backgroundColor: Color(0xFF111111), iconColor: Color(0xFF222222)),
    );
    const localTheme = StreamInlineNotificationThemeData(
      info: StreamInlineNotificationThemeStyle(backgroundColor: Color(0xFF333333)),
    );

    await tester.pumpWidget(
      _wrap(
        StreamInlineNotificationTheme(
          data: localTheme,
          child: StreamInlineNotification(title: const Text('Title')),
        ),
        streamTheme: StreamTheme(inlineNotificationTheme: rootTheme),
      ),
    );

    expect(_backgroundColorOf(tester), const Color(0xFF333333));
    expect(_leadingIconColorOf(tester), const Color(0xFF222222));
  });

  testWidgets('StreamComponentFactory replaces the default inline notification', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamComponentFactory(
          builders: StreamComponentBuilders(inlineNotification: (context, props) => const Text('custom')),
          child: StreamInlineNotification(title: const Text('Title')),
        ),
      ),
    );

    expect(find.text('custom'), findsOneWidget);
    expect(find.byType(DefaultStreamInlineNotification), findsNothing);
  });
}

Widget _wrap(Widget child, {bool rtl = false, double textScale = 1, StreamTheme? streamTheme}) {
  return MaterialApp(
    theme: ThemeData(extensions: [streamTheme ?? StreamTheme()]),
    home: Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: MediaQuery.withClampedTextScaling(
        minScaleFactor: textScale,
        maxScaleFactor: textScale,
        child: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}

StreamColorScheme _colorSchemeOf(WidgetTester tester) {
  final context = tester.element(find.byType(StreamInlineNotification));
  return StreamTheme.of(context).colorScheme;
}

// The notification's own surface is the outermost Material under it.
Material _surfaceOf(WidgetTester tester) {
  final finder = find.descendant(of: find.byType(DefaultStreamInlineNotification), matching: find.byType(Material));
  return tester.widget<Material>(finder.first);
}

Color? _backgroundColorOf(WidgetTester tester) => _surfaceOf(tester).color;

Color? _leadingIconColorOf(WidgetTester tester) {
  final finder = find.descendant(of: find.byType(DefaultStreamInlineNotification), matching: find.byType(Icon));
  return IconTheme.of(tester.element(finder.first)).color;
}

// The title and description column, between the icon and the end edge.
Finder _contentOf(WidgetTester tester) {
  return find.ancestor(of: find.text('Title'), matching: find.byType(Column)).first;
}
