import 'package:flutter/material.dart';
import 'package:stream_core_flutter/core.dart';

/// The link/unlink control sitting between a light and a dark color tile.
///
/// Linked (default): editing either side's color edits both. Unlinked: each
/// side is edited independently. Styled off the *page's* ambient theme
/// (whatever brightness the studio itself currently is in) rather than
/// either the light or dark column, since it sits in the seam between them.
class LinkToggleButton extends StatelessWidget {
  const LinkToggleButton({super.key, required this.linked, required this.onTap});

  final bool linked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;

    return Center(
      child: Tooltip(
        message: linked ? 'Linked — editing either side edits both. Tap to unlink.' : 'Unlinked. Tap to link.',
        child: Material(
          color: linked ? colorScheme.backgroundSurfaceStrong : colorScheme.backgroundSurfaceSubtle,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: EdgeInsets.all(context.streamSpacing.xs),
              child: Icon(
                linked ? Icons.link : Icons.link_off,
                size: 16,
                color: linked ? colorScheme.accentPrimary : colorScheme.textTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
