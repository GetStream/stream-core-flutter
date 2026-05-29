import 'package:flutter/material.dart';

import '../../theme/stream_app_style.dart';
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
/// ambient [BottomBarBehavior] from [StreamAppStyle].
///
/// ## Floating style
///
/// When [StreamAppStyle.bottomBarBehavior] is [BottomBarBehavior.floating],
/// the bar renders as a horizontally padded pill with a rounded background,
/// a subtle box shadow, and a hairline border. It sits above the body content
/// and is typically used with [StreamScaffold]'s floating bottom slot.
///
/// ## Regular style
///
/// When [BottomBarBehavior.regular], the bar renders as a standard docked
/// bottom navigation bar using Flutter's [BottomNavigationBar] with Stream
/// colour and typography tokens. A hairline `borderSubtle` top border
/// separates it from the body.
///
/// ## Behaviour override
///
/// Pass an explicit [behavior] to override the ambient style for this
/// instance only.
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
///  * [StreamAppStyle], which controls the floating/regular behaviour.
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

  /// Overrides the ambient [BottomBarBehavior] for this instance only.
  ///
  /// When null, the value is read from [StreamAppStyle] in the current
  /// [StreamTheme].
  final BottomBarBehavior? behavior;

  @override
  Widget build(BuildContext context) {
    final effectiveBehavior = behavior ?? context.streamTheme.appStyle.bottomBarBehavior;

    if (effectiveBehavior == BottomBarBehavior.floating) {
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final spacing = context.streamSpacing;
    final radius = context.streamRadius;

    return SafeArea(
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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.xxs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: spacing.xxxs,
          children: [
            IconTheme(
              data: IconThemeData(color: color, size: 20),
              child: selected ? item.selectedIcon : item.icon,
            ),
            Text(
              item.label,
              style: textTheme.metadataEmphasis.copyWith(color: color),
            ),
          ],
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
    );
  }
}
