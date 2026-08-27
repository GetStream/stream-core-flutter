/// A [Object.runtimeType] that is constant in release mode.
///
/// Returns the runtime type of [object] in debug mode, and [optimizedValue]
/// in release mode, where type names may be minified and reading them
/// prevents the compiler from discarding type information.
///
/// Mirrors Flutter's `objectRuntimeType`, so `toString` implementations can
/// name their exact type where it helps — a debug log — and a stable name
/// where it would not.
String objectRuntimeType(Object? object, String optimizedValue) {
  var value = optimizedValue;
  assert(() {
    value = object.runtimeType.toString();
    return true;
  }());
  return value;
}
