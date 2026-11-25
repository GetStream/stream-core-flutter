import 'package:flutter/foundation.dart';
import 'package:widgetbook/widgetbook.dart';

/// Mirrors Widgetbook's preview mode (the `&preview` URL parameter) so the
/// gallery chrome outside of Widgetbook can react to it.
class PreviewModeIntegration extends WidgetbookIntegration {
  final _isPreview = ValueNotifier(false);

  /// Whether Widgetbook is currently in preview (embed) mode.
  ValueListenable<bool> get isPreview => _isPreview;

  @override
  void onChange(WidgetbookState state) => _isPreview.value = state.previewMode;

  /// Releases the underlying notifier.
  void dispose() => _isPreview.dispose();
}
