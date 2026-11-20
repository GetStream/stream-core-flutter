import 'package:flutter/foundation.dart';
import 'package:widgetbook/widgetbook.dart';

/// Mirrors Widgetbook's preview mode (the `&preview` URL parameter) so the
/// gallery chrome outside of Widgetbook can react to it.
///
/// Widgetbook keeps its state private to its own widget tree; integrations are
/// the one hook that receives it, so this exposes [WidgetbookState.previewMode]
/// as a [ValueListenable] for the toolbar and theme panel to listen to.
class PreviewModeIntegration extends WidgetbookIntegration {
  final _isPreview = ValueNotifier(false);

  /// Whether Widgetbook is currently in preview (embed) mode.
  ValueListenable<bool> get isPreview => _isPreview;

  @override
  void onInit(WidgetbookState state) => _isPreview.value = state.previewMode;

  @override
  void onChange(WidgetbookState state) => _isPreview.value = state.previewMode;

  /// Releases the underlying notifier.
  void dispose() => _isPreview.dispose();
}
