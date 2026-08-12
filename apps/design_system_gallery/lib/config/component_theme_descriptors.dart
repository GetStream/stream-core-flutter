import 'package:flutter/material.dart';
import 'package:stream_core_flutter/core.dart';

/// A component theme this feature can edit: the plain `Color?` properties of
/// one of [StreamTheme]'s ~40 component theme data classes.
///
/// Scoped to a handful of components with meaningful *direct* Color
/// properties — most component themes bury their colors inside nested style
/// objects (e.g. [StreamMessageBubbleStyle]) instead of exposing them
/// directly, which this simple property-list model can't reach. Extending
/// coverage to more components, or to nested styles, means adding another
/// [ComponentThemeDescriptor] below; it doesn't require touching anything
/// else in `theme_studio`.
class ComponentThemeDescriptor {
  const ComponentThemeDescriptor({
    required this.name,
    required this.themeParameterName,
    required this.themeDataTypeName,
    required this.properties,
    required this.build,
  });

  /// Display name, e.g. `'Avatar'`.
  final String name;

  /// The named parameter on `StreamTheme(...)` this plugs into, e.g.
  /// `'avatarTheme'` for `StreamTheme(avatarTheme: ...)`.
  final String themeParameterName;

  /// The Dart type this builds, e.g. `'StreamAvatarThemeData'` — used by the
  /// code generator to emit `StreamAvatarThemeData(...)` calls.
  final String themeDataTypeName;

  /// The editable `Color?` property names, in constructor order.
  final List<String> properties;

  /// Builds the component's theme-data object from a (possibly partial) map
  /// of property name to color.
  final Object Function(Map<String, Color> values) build;
}

/// The component themes covered by the theme studio's "Add component theme"
/// picker, in the order they appear there.
///
/// Deliberately excludes Avatar: its color story is the Avatar Palette
/// section (a set of rotating background/foreground pairs, consumed by
/// downstream packages like stream_chat_flutter for per-user color
/// selection), not a single fixed override like the component themes below.
final componentThemeDescriptors = <ComponentThemeDescriptor>[
  ComponentThemeDescriptor(
    name: 'Badge Count',
    themeParameterName: 'badgeCountTheme',
    themeDataTypeName: 'StreamBadgeCountThemeData',
    properties: const ['textColor', 'backgroundColor', 'borderColor'],
    build: (Map<String, Color> v) => StreamBadgeCountThemeData(
      textColor: v['textColor'],
      backgroundColor: v['backgroundColor'],
      borderColor: v['borderColor'],
    ),
  ),
  ComponentThemeDescriptor(
    name: 'Badge Notification',
    themeParameterName: 'badgeNotificationTheme',
    themeDataTypeName: 'StreamBadgeNotificationThemeData',
    properties: const [
      'primaryBackgroundColor',
      'errorBackgroundColor',
      'neutralBackgroundColor',
      'textColor',
      'borderColor',
    ],
    build: (Map<String, Color> v) => StreamBadgeNotificationThemeData(
      primaryBackgroundColor: v['primaryBackgroundColor'],
      errorBackgroundColor: v['errorBackgroundColor'],
      neutralBackgroundColor: v['neutralBackgroundColor'],
      textColor: v['textColor'],
      borderColor: v['borderColor'],
    ),
  ),
  ComponentThemeDescriptor(
    name: 'Online Indicator',
    themeParameterName: 'onlineIndicatorTheme',
    themeDataTypeName: 'StreamOnlineIndicatorThemeData',
    properties: const ['backgroundOnline', 'backgroundOffline', 'borderColor'],
    build: (Map<String, Color> v) => StreamOnlineIndicatorThemeData(
      backgroundOnline: v['backgroundOnline'],
      backgroundOffline: v['backgroundOffline'],
      borderColor: v['borderColor'],
    ),
  ),
];
