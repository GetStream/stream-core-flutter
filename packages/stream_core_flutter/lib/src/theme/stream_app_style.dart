class StreamAppStyle {
  const StreamAppStyle({
    this.composerLocation = ComposerLocation.docked,
    this.appBarBehavior = AppBarBehavior.regular,
  });

  const StreamAppStyle.regular() : composerLocation = ComposerLocation.docked, appBarBehavior = AppBarBehavior.regular;

  const StreamAppStyle.floating()
    : composerLocation = ComposerLocation.floating,
      appBarBehavior = AppBarBehavior.floating;

  final AppBarBehavior appBarBehavior;
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
