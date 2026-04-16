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
          color: colorScheme.backgroundInverse,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.borderOnInverse, width: 2),
        ),
        alignment: Alignment.center,
        height: 20,
        width: 20,
        child: Icon(
          context.streamIcons.xmarkSmall,
          color: colorScheme.textOnInverse,
          size: 12,
        ),
      ),
    );
  }
}
