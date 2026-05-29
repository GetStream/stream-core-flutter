class StreamAppStyle {
  const StreamAppStyle({
    this.composerLocation = ComposerLocation.docked,
    this.appBarBehavior = AppBarBehavior.regular,
    this.bottomBarBehavior = BottomBarBehavior.regular,
  });

  const StreamAppStyle.regular()
    : composerLocation = ComposerLocation.docked,
      appBarBehavior = AppBarBehavior.regular,
      bottomBarBehavior = BottomBarBehavior.regular;

  const StreamAppStyle.floating()
    : composerLocation = ComposerLocation.floating,
      appBarBehavior = AppBarBehavior.floating,
      bottomBarBehavior = BottomBarBehavior.floating;

  final AppBarBehavior appBarBehavior;
  final BottomBarBehavior bottomBarBehavior;
  final ComposerLocation composerLocation;
}

enum ComposerLocation {
  floating,
  docked,
}

enum AppBarBehavior {
  regular,
  floating,
}

enum BottomBarBehavior {
  regular,
  floating,
}
