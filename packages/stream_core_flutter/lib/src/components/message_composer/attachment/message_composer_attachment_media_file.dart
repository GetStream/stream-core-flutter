import 'package:flutter/widgets.dart';

import '../../../../stream_core_flutter.dart';
import '../../controls/remove_control.dart';

class MessageComposerAttachmentMediaFile extends StatelessWidget {
  const MessageComposerAttachmentMediaFile({super.key, required this.image, required this.onRemovePressed});

  final ImageProvider image;
  final VoidCallback onRemovePressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      width: 80,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(context.streamSpacing.xxs),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(context.streamRadius.lg),
                border: Border.all(
                  color: context.streamColorScheme.borderDefault.withAlpha(25),
                ),
                image: DecorationImage(image: image, fit: BoxFit.cover),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: RemoveControl(onPressed: onRemovePressed),
          ),
        ],
      ),
    );
  }
}
