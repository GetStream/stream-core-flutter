import 'package:flutter/foundation.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'app/gallery_app.dart';

void main() {
  // Initialize Marionette only in debug mode
  if (kDebugMode) MarionetteBinding.ensureInitialized();
  runApp(const StreamDesignSystemGallery());
}
