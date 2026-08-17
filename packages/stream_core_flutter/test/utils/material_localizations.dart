import 'package:material_ui/material_ui.dart';

/// Provides `material_ui`'s [MaterialLocalizations] to [child].
///
/// Alchemist scaffolds golden tests with Flutter's own `MaterialApp`, whose
/// `MaterialLocalizations` are an unrelated type to `material_ui`'s. A
/// component that reads them — through a `Tooltip`, a semantics label, or
/// `MaterialLocalizations.of` directly — throws `No MaterialLocalizations
/// found` and renders an error box instead. Widget tests do not need this:
/// they wrap in `material_ui`'s `MaterialApp`, which supplies them.
Widget withMaterialLocalizations({required Widget child}) {
  return Localizations(
    locale: const Locale('en', 'US'),
    delegates: const [
      DefaultMaterialLocalizations.delegate,
      DefaultWidgetsLocalizations.delegate,
    ],
    child: child,
  );
}
