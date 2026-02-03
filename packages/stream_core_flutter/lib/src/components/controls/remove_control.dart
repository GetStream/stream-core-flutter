import 'package:flutter/widgets.dart';

import '../../../stream_core_flutter.dart';

class RemoveControl extends StatelessWidget {
  const RemoveControl({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;

    return Container(
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
        color: colorScheme.textInverse,
        size: 10,
      ),
    );
  }
}
