import 'package:flutter/widgets.dart';

import '../../../stream_core_flutter.dart';

class StreamRemoveControl extends StatelessWidget {
  const StreamRemoveControl({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.accentBlack,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.borderOnDark, width: 2),
        ),
        alignment: Alignment.center,
        height: 20,
        width: 20,
        child: Icon(
          context.streamIcons.crossSmall,
          color: colorScheme.textOnAccent,
          size: 10,
        ),
      ),
    );
  }
}
