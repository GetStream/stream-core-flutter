import 'package:flutter/material.dart';

import '../../theme/components/stream_badge_notification_theme.dart';
import '../../theme/components/stream_bottom_app_bar_theme.dart';
import '../../theme/stream_floating_fade.dart';
import '../../theme/stream_theme_extensions.dart';

/// A single item in a [StreamBottomNavBar].
///
/// Each item has an [icon] and [selectedIcon] widget (the latter is shown
/// when the item is active) and a text [label].
///
/// The icon widgets are fully generic — callers are free to wrap them in
/// badge overlays, unread indicators, or any other decorator.
class StreamBottomNavBarItem {
  /// Creates a bottom nav bar item.
  const StreamBottomNavBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  /// The icon displayed when this item is inactive.
  final Widget icon;

  /// The icon displayed when this item is active.
  final Widget selectedIcon;

  /// The text label shown below the icon.
  final String label;
}

/// A bottom navigation bar for Stream surfaces that automatically adapts
/// between a floating pill style and a regular docked style based on the
/// ambient [StreamBottomAppBarBehavior] from [StreamBottomAppBarTheme] or
/// [StreamAppStyle].
///
/// ## Floating style
///
/// When [StreamBottomAppBarBehavior.floating] is in effect, the bar renders as a
/// horizontally padded pill with a rounded background, a subtle box shadow,
/// and a hairline border. It sits above the body content and is typically
/// used with [StreamScaffold]'s floating bottom slot.
///
/// ## Regular style
///
/// When [StreamBottomAppBarBehavior.regular] is in effect, the bar renders as a
/// standard docked bottom navigation bar using Flutter's [BottomNavigationBar]
/// with Stream colour and typography tokens. A hairline `borderSubtle` top
/// border separates it from the body.
///
/// ## Behaviour resolution
///
/// The effective behaviour is resolved in this priority order:
/// 1. The per-instance [behavior] parameter on this widget.
/// 2. [StreamBottomAppBarStyle.behavior] from the ambient
///    [StreamBottomAppBarTheme].
/// 3. The ambient [StreamAppStyle] enum value.
///
/// {@tool snippet}
///
/// Basic usage:
///
/// ```dart
/// StreamBottomNavBar(
///   currentIndex: _currentIndex,
///   onTap: (i) => setState(() => _currentIndex = i),
///   items: const [
///     StreamBottomNavBarItem(
///       icon: Icon(Icons.chat_bubble_outline),
///       selectedIcon: Icon(Icons.chat_bubble),
///       label: 'Chats',
///     ),
///     StreamBottomNavBarItem(
///       icon: Icon(Icons.bookmark_outline),
///       selectedIcon: Icon(Icons.bookmark),
///       label: 'Saved',
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamBottomNavBarItem], which configures each tab.
///  * [StreamScaffold], which accepts this widget in its `bottom` slot.
///  * [StreamAppStyle], the global app-wide style that acts as fallback.
///  * [StreamBottomAppBarStyle.behavior], the per-theme component override.
class StreamBottomNavBar extends StatelessWidget {
  /// Creates a Stream bottom navigation bar.
  const StreamBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.behavior,
  }) : assert(items.length >= 2, 'StreamBottomNavBar requires at least 2 items');

  /// The list of items to display in the navigation bar.
  ///
  /// Must contain at least 2 items.
  final List<StreamBottomNavBarItem> items;

  /// The index of the currently selected item.
  final int currentIndex;

  /// Called when the user taps a navigation item.
  final ValueChanged<int> onTap;

  /// Overrides the resolved [StreamBottomAppBarBehavior] for this instance only.
  ///
  /// When null the effective behaviour is resolved from
  /// [StreamBottomAppBarStyle.behavior] in the ambient
  /// [StreamBottomAppBarTheme], falling back to the ambient [StreamAppStyle].
  final StreamBottomAppBarBehavior? behavior;

  @override
  Widget build(BuildContext context) {
    final appStyle = context.streamTheme.appStyle;
    final effectiveBehavior =
        behavior ??
        context.streamBottomAppBarTheme.style?.behavior ??
        (appStyle.isFloating ? StreamBottomAppBarBehavior.floating : StreamBottomAppBarBehavior.regular);

    if (effectiveBehavior == StreamBottomAppBarBehavior.floating) {
      return _FloatingNavBar(
        items: items,
        currentIndex: currentIndex,
        onTap: onTap,
      );
    }

    return _RegularNavBar(
      items: items,
      currentIndex: currentIndex,
      onTap: onTap,
    );
  }
}

// ---------------------------------------------------------------------------
// Floating pill nav bar
// ---------------------------------------------------------------------------

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<StreamBottomNavBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  LinearGradient _buildGradient(BuildContext context, Color backgroundColor) {
    final safeAreaBottom = MediaQuery.paddingOf(context).bottom;
    // Approximate rendered height: safe area + vertical padding + item height.
    const itemHeight = 56.0;
    final totalHeight = safeAreaBottom + itemHeight;
    final solidFraction = totalHeight > 0 ? safeAreaBottom / totalHeight : 0.0;

    return streamFloatingFadeLinearGradient(
      color: backgroundColor,
      solidFraction: solidFraction,
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final spacing = context.streamSpacing;
    final radius = context.streamRadius;
    final backgroundColor = colorScheme.backgroundElevation0;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: _buildGradient(context, backgroundColor),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.xl),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.backgroundElevation1,
              borderRadius: BorderRadius.all(radius.max),
              boxShadow: context.streamBoxShadow.elevation1,
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.all(radius.max),
              border: Border.all(color: colorScheme.borderSubtle),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: spacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var i = 0; i < items.length; i++)
                    _FloatingNavBarItem(
                      item: items[i],
                      selected: i == currentIndex,
                      onTap: () => onTap(i),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingNavBarItem extends StatelessWidget {
  const _FloatingNavBarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final StreamBottomNavBarItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.streamTextTheme;
    final colorScheme = context.streamColorScheme;
    final spacing = context.streamSpacing;
    final color = selected ? colorScheme.textPrimary : colorScheme.textTertiary;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      onTap: onTap,
      onTapHint: 'select',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.xxs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: spacing.xxxs,
            children: [
              StreamBadgeNotificationTheme(
                data: const StreamBadgeNotificationThemeData(size: StreamBadgeNotificationSize.xs),
                child: IconTheme(
                  data: IconThemeData(color: color, size: 20),
                  child: selected ? item.selectedIcon : item.icon,
                ),
              ),
              Text(
                item.label,
                style: textTheme.metadataEmphasis.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Regular docked nav bar
// ---------------------------------------------------------------------------

class _RegularNavBar extends StatelessWidget {
  const _RegularNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<StreamBottomNavBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.backgroundElevation1,
        border: Border(top: BorderSide(color: colorScheme.borderSubtle)),
      ),
      child: StreamBadgeNotificationTheme(
        data: const StreamBadgeNotificationThemeData(size: StreamBadgeNotificationSize.xs),
        child: BottomNavigationBar(
          elevation: 0,
          iconSize: 20,
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: colorScheme.textPrimary,
          unselectedItemColor: colorScheme.textTertiary,
          backgroundColor: Colors.transparent,
          selectedLabelStyle: textTheme.metadataEmphasis,
          unselectedLabelStyle: textTheme.metadataEmphasis,
          onTap: onTap,
          items: items.map((item) {
            return BottomNavigationBarItem(
              icon: item.icon,
              activeIcon: item.selectedIcon,
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}
