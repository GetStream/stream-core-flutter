import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

/// Guards the border-side branches of the generated `lerp` methods.
///
/// These are emitted by `theme_extensions_builder`, so a generator bump can
/// change them without anything in this repo being edited. The
/// [WidgetStateBorderSide] case in particular shipped broken in 0.5.1: the
/// existing `StreamTheme.lerp` coverage leaves every nested style null, which
/// short-circuits before the branch is ever reached.
void main() {
  group('lerp on a style with a WidgetStateBorderSide', () {
    // `WidgetStateBorderSide.lerp` returns Flutter's private `_LerpSides`,
    // which implements `WidgetStateProperty<BorderSide?>` and *not*
    // `WidgetStateBorderSide` — so the `as WidgetStateBorderSide?` cast in
    // `StreamCheckboxStyle`'s constructor threw on every non-null lerp.
    final a = StreamCheckboxStyle.from(side: const BorderSide(color: Color(0xFF112233)));
    final b = StreamCheckboxStyle.from(side: const BorderSide(color: Color(0xFFFFFFFF), width: 3));

    test('does not throw part-way through a transition', () {
      for (final t in const [0.0, 0.25, 0.5, 0.75, 1.0]) {
        expect(() => StreamCheckboxStyle.lerp(a, b, t), returnsNormally, reason: 't = $t');
      }
    });

    test('steps at the midpoint rather than interpolating', () {
      const enabled = <WidgetState>{};

      expect(StreamCheckboxStyle.lerp(a, b, 0.25)?.side?.resolve(enabled), equals(a.side?.resolve(enabled)));
      expect(StreamCheckboxStyle.lerp(a, b, 0.75)?.side?.resolve(enabled), equals(b.side?.resolve(enabled)));
    });

    test('holds at both endpoints', () {
      const enabled = <WidgetState>{};

      expect(StreamCheckboxStyle.lerp(a, b, 0)?.side?.resolve(enabled), equals(a.side?.resolve(enabled)));
      expect(StreamCheckboxStyle.lerp(a, b, 1)?.side?.resolve(enabled), equals(b.side?.resolve(enabled)));
    });
  });

  group('lerp on a style whose plain BorderSide is set on one end only', () {
    const withSide = StreamContextMenuStyle(side: BorderSide(color: Color(0xFF00FF00)));
    const withoutSide = StreamContextMenuStyle();

    test('holds at both endpoints', () {
      // The pre-7.5.0 generator returned the non-null side across the whole
      // range, so a border popped in at t = 0 and lerp(a, b, 0) != a.
      expect(StreamContextMenuStyle.lerp(withoutSide, withSide, 0)?.side, isNull);
      expect(StreamContextMenuStyle.lerp(withoutSide, withSide, 1)?.side, equals(withSide.side));
    });

    test('steps at the midpoint', () {
      expect(StreamContextMenuStyle.lerp(withoutSide, withSide, 0.25)?.side, isNull);
      expect(StreamContextMenuStyle.lerp(withoutSide, withSide, 0.75)?.side, equals(withSide.side));
    });
  });

  group('merge keeps a border side the argument leaves null', () {
    const base = StreamContextMenuStyle(side: BorderSide(color: Color(0xFF00FF00)));

    test('receiver survives an argument with no side', () {
      expect(base.merge(const StreamContextMenuStyle()).side, equals(base.side));
    });

    test('both sides go through BorderSide.merge when both are set', () {
      // `BorderSide.merge` asserts `canMerge`, so the two have to share a
      // color, and it sums their widths rather than replacing one with the
      // other — the argument does not simply win here.
      const other = StreamContextMenuStyle(side: BorderSide(color: Color(0xFF00FF00), width: 2));

      expect(base.merge(other).side?.width, equals(3));
    });
  });
}
