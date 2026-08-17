import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:material_ui/material_ui.dart';
import 'package:stream_core_flutter/core.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamScaffold,
  path: '[Components]/Scaffold',
)
Widget buildStreamScaffoldPlayground(BuildContext context) {
  final showAppBar = context.knobs.boolean(
    label: 'Show app bar',
    initialValue: true,
    description: 'Renders a StreamAppBar in the top slot.',
  );

  final showBottom = context.knobs.boolean(
    label: 'Show bottom',
    initialValue: true,
    description: 'Renders a StreamBottomNavBar in the bottom slot.',
  );

  final showDrawer = context.knobs.boolean(
    label: 'Enable drawer',
    description: 'Adds a navigation drawer, opened from the app-bar leading button.',
  );

  final appBarSurfaceStyle = context.knobs.object.dropdown(
    label: 'App bar surfaceStyle',
    options: StreamSurfaceStyle.values,
    labelBuilder: (value) => value.name,
    initialOption: StreamSurfaceStyle.floating,
    description:
        'regular — the body sits below the app bar. '
        'floating — the body extends behind the translucent app bar; the list '
        'auto-insets from MediaQuery.padding.top. Scroll to see rows pass behind it.',
  );

  final bottomSurfaceStyle = context.knobs.object.dropdown(
    label: 'Bottom bar surfaceStyle',
    options: StreamSurfaceStyle.values,
    labelBuilder: (value) => value.name,
    initialOption: StreamSurfaceStyle.floating,
    description:
        'regular — the bottom bar sits below the body. '
        'floating — the body extends behind the translucent bottom bar; the list '
        'auto-insets from MediaQuery.padding.bottom.',
  );

  final customBackground = context.knobs.boolean(
    label: 'Custom background color',
    description: 'Overrides the default StreamColorScheme.backgroundApp.',
  );

  final colorScheme = context.streamColorScheme;
  final appBarFloating = appBarSurfaceStyle == StreamSurfaceStyle.floating;
  final bottomFloating = bottomSurfaceStyle == StreamSurfaceStyle.floating;

  final scaffold = StreamScaffold(
    appBarSurfaceStyle: appBarSurfaceStyle,
    bottomSurfaceStyle: bottomSurfaceStyle,
    backgroundColor: customBackground ? colorScheme.backgroundSurfaceSubtle : null,
    appBar: showAppBar ? _demoAppBar(context, floating: appBarFloating, withDrawerButton: showDrawer) : null,
    drawer: showDrawer ? const _ExampleDrawer() : null,
    bottom: showBottom ? _DemoBottomNav(floating: bottomFloating) : null,
    // A plain ListView with NO `padding` — it auto-insets behind the floating
    // bars from the MediaQuery.padding that StreamScaffold injects. Zero wiring.
    body: const _ChatList(),
  );

  // A scaffold owns the whole screen — return it directly so it fills the
  // Widgetbook canvas rather than sitting in a centered frame.
  return scaffold;
}

// =============================================================================
// Drawers — exercises every forwarded drawer prop
// =============================================================================

@widgetbook.UseCase(
  name: 'Real-world Example',
  type: StreamScaffold,
  path: '[Components]/Scaffold',
)
Widget buildStreamScaffoldDrawers(BuildContext context) {
  final showDrawer = context.knobs.boolean(
    label: 'drawer',
    initialValue: true,
    description: 'Leading side panel.',
  );
  final showEndDrawer = context.knobs.boolean(
    label: 'endDrawer',
    initialValue: true,
    description: 'Trailing side panel.',
  );
  final enableOpenDrag = context.knobs.boolean(
    label: 'drawerEnableOpenDragGesture',
    initialValue: true,
    description: 'Open the drawer with a start-edge swipe.',
  );
  final endEnableOpenDrag = context.knobs.boolean(
    label: 'endDrawerEnableOpenDragGesture',
    initialValue: true,
    description: 'Open the end drawer with a trailing-edge swipe.',
  );
  final barrierDismissible = context.knobs.boolean(
    label: 'drawerBarrierDismissible',
    initialValue: true,
    description: 'Tap the scrim to dismiss an open drawer.',
  );
  final customScrim = context.knobs.boolean(
    label: 'Custom drawerScrimColor',
    description: 'Tints the scrim with an accent color instead of the default.',
  );
  final edgeDragWidth = context.knobs.double.slider(
    label: 'drawerEdgeDragWidth',
    initialValue: 20,
    max: 160,
    description: 'Width (px) of the edge zone that opens the drawer by swipe.',
  );
  final dragStartBehavior = context.knobs.object.dropdown(
    label: 'drawerDragStartBehavior',
    options: DragStartBehavior.values,
    labelBuilder: (value) => value.name,
    initialOption: DragStartBehavior.start,
    description: 'How the open-drag gesture is recognized.',
  );

  final colorScheme = context.streamColorScheme;

  return StreamScaffold(
    appBar: StreamAppBar(
      leading: showDrawer
          ? Builder(
              builder: (ctx) => StreamButton.icon(
                icon: Icon(ctx.streamIcons.more),
                style: StreamButtonStyle.secondary,
                type: StreamButtonType.ghost,
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            )
          : null,
      title: const Text('Drawers'),
      trailing: showEndDrawer
          ? Builder(
              builder: (ctx) => StreamButton.icon(
                icon: Icon(ctx.streamIcons.user),
                style: StreamButtonStyle.secondary,
                type: StreamButtonType.ghost,
                onPressed: () => Scaffold.of(ctx).openEndDrawer(),
              ),
            )
          : null,
    ),
    drawer: showDrawer ? const _ExampleDrawer(title: 'Navigation (drawer)') : null,
    endDrawer: showEndDrawer ? const _ExampleDrawer(title: 'Details (endDrawer)') : null,
    onDrawerChanged: (isOpen) => _notify(context, 'drawer ${isOpen ? 'opened' : 'closed'}'),
    onEndDrawerChanged: (isOpen) => _notify(context, 'endDrawer ${isOpen ? 'opened' : 'closed'}'),
    drawerScrimColor: customScrim ? colorScheme.accentPrimary.withValues(alpha: 0.4) : null,
    drawerEdgeDragWidth: edgeDragWidth,
    drawerEnableOpenDragGesture: enableOpenDrag,
    endDrawerEnableOpenDragGesture: endEnableOpenDrag,
    drawerDragStartBehavior: dragStartBehavior,
    drawerBarrierDismissible: barrierDismissible,
    body: _DrawerTestBody(hasDrawer: showDrawer, hasEndDrawer: showEndDrawer),
  );
}

/// Shows a short-lived snackbar so the drawer-change callbacks are visible.
void _notify(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), duration: const Duration(milliseconds: 900)));
}

/// Body for the Drawers use-case: instructions plus buttons to open each drawer
/// (so the drawers are reachable even when the open-drag gestures are disabled).
class _DrawerTestBody extends StatelessWidget {
  const _DrawerTestBody({required this.hasDrawer, required this.hasEndDrawer});

  final bool hasDrawer;
  final bool hasEndDrawer;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Open a drawer from the app-bar buttons, an edge swipe, or below. '
              'Open/close fires onDrawerChanged (snackbar).',
              textAlign: TextAlign.center,
              style: textTheme.bodyDefault.copyWith(color: colorScheme.textSecondary),
            ),
            SizedBox(height: spacing.lg),
            if (hasDrawer)
              Builder(
                builder: (ctx) => StreamButton(
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                  child: const Text('Open drawer'),
                ),
              ),
            if (hasEndDrawer) ...[
              SizedBox(height: spacing.sm),
              Builder(
                builder: (ctx) => StreamButton(
                  style: StreamButtonStyle.secondary,
                  type: StreamButtonType.outline,
                  onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                  child: const Text('Open end drawer'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Shared chrome builders
// =============================================================================

PreferredSizeWidget _demoAppBar(
  BuildContext context, {
  required bool floating,
  bool withDrawerButton = false,
}) {
  return StreamAppBar(
    // primary: true (default) so the bar self-insets the status bar / notch.
    style: StreamAppBarStyle(
      surfaceStyle: floating ? StreamSurfaceStyle.floating : StreamSurfaceStyle.regular,
    ),
    leading: withDrawerButton
        ? Builder(
            builder: (context) => StreamButton.icon(
              icon: Icon(context.streamIcons.more),
              style: StreamButtonStyle.secondary,
              type: floating ? StreamButtonType.outline : StreamButtonType.ghost,
              isFloating: floating,
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          )
        : null,
    title: const Text('Messages'),
    trailing: StreamButton.icon(
      icon: Icon(context.streamIcons.plus),
      isFloating: floating,
      onPressed: () {},
    ),
  );
}

/// A stateful [StreamBottomNavBar] demo for the scaffold's bottom slot. When
/// [floating] it renders as a translucent pill over the content whose measured
/// height becomes the body's bottom inset; otherwise it's a docked bar below the
/// body.
class _DemoBottomNav extends StatefulWidget {
  const _DemoBottomNav({required this.floating});

  final bool floating;

  @override
  State<_DemoBottomNav> createState() => _DemoBottomNavState();
}

class _DemoBottomNavState extends State<_DemoBottomNav> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;

    return StreamBottomNavBar(
      currentIndex: _index,
      onTap: (index) => setState(() => _index = index),
      style: StreamBottomNavBarStyle(
        surfaceStyle: widget.floating ? StreamSurfaceStyle.floating : StreamSurfaceStyle.regular,
      ),
      items: [
        StreamBottomNavBarItem(
          icon: Icon(icons.messageBubble),
          selectedIcon: Icon(icons.messageBubbleFill),
          label: 'Chats',
        ),
        StreamBottomNavBarItem(icon: Icon(icons.thread), selectedIcon: Icon(icons.threadFill), label: 'Threads'),
        StreamBottomNavBarItem(icon: Icon(icons.mention), selectedIcon: Icon(icons.mention), label: 'Mentions'),
        StreamBottomNavBarItem(icon: Icon(icons.user), selectedIcon: Icon(icons.account), label: 'Profile'),
      ],
    );
  }
}

// =============================================================================
// Body
// =============================================================================

/// A realistic channel-list body built from a **plain [ListView]** with no
/// `padding` argument. It auto-insets behind the scaffold's floating bars from
/// the injected `MediaQuery.padding` — no manual wiring — so the rows scroll
/// *behind* the translucent bars and rest clear of them.
class _ChatList extends StatelessWidget {
  const _ChatList();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;

    return ListView.builder(
      itemCount: 24,
      itemBuilder: (context, index) {
        final row = _rows[index % _rows.length];
        return StreamListTile(
          leading: StreamAvatar(placeholder: (_) => Text(row.initials)),
          title: Text(row.name),
          subtitle: Text(row.message, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Text(
            row.time,
            style: textTheme.captionDefault.copyWith(color: colorScheme.textSecondary),
          ),
          onTap: () {},
        );
      },
    );
  }
}

const _rows = <({String initials, String name, String message, String time})>[
  (initials: 'AK', name: 'Alice Kim', message: 'See you at the standup 👋', time: '9:41'),
  (initials: 'BT', name: 'Ben Turner', message: 'Pushed the fix, can you review?', time: '9:12'),
  (initials: 'CD', name: 'Carla Diaz', message: 'Lunch today?', time: '8:56'),
  (initials: 'DO', name: 'Deni Ortega', message: 'Thanks for the help earlier!', time: 'Yst'),
  (initials: 'EM', name: 'Eve Miller', message: 'The designs are ready for handoff', time: 'Yst'),
  (initials: 'FN', name: 'Femi Nabil', message: 'Call me when you get a sec', time: 'Mon'),
  (initials: 'GR', name: 'Grace Rao', message: 'On my way 🚗', time: 'Mon'),
  (initials: 'HS', name: 'Hana Sato', message: 'Shipped it! 🚀', time: 'Sun'),
];

// =============================================================================
// Helpers
// =============================================================================

/// A minimal drawer used by the drawer demos.
class _ExampleDrawer extends StatelessWidget {
  const _ExampleDrawer({this.title = 'Navigation'});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Drawer(
      backgroundColor: colorScheme.backgroundSurface,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.headingSm.copyWith(color: colorScheme.textPrimary)),
              SizedBox(height: spacing.md),
              Text('Forwarded to the underlying Scaffold.', style: textTheme.bodyDefault),
            ],
          ),
        ),
      ),
    );
  }
}
