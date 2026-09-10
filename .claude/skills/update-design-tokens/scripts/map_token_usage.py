#!/usr/bin/env python3
"""Map `StreamColorScheme` fields to the files that read them, in any repo.

Answers "who paints with this color?" for a consuming SDK without reading it
into context file by file. Run it against a ref rather than a working tree, so a
design-system branch can be inspected without checking it out.

    map_token_usage.py <repo-path> <ref>              # whole scheme
    map_token_usage.py <repo-path> <ref> accentWarning  # one field

Both receiver spellings are matched (`colorScheme.x` and the `_colorScheme.x`
used inside `_Defaults` classes), and test files are skipped by default.

Scope note: this finds where a field is *read*, which is one indirection away
from the widget that renders it — a component theme's defaults class will show
up rather than the widget consuming that theme. Follow the theme field to the
widget when the answer needs to name a component.

The match is on the bare string `colorScheme.`, so Material's
`Theme.of(context).colorScheme.surface` is reported identically to a
`StreamColorScheme` read. This repo uses `StreamTheme.of(context).colorScheme` and
has no collisions, but the consuming SDKs are Material apps where it is real —
check the receiver before trusting a hit, and note that app/example directories
are not filtered either, only tests.

It also only sees root semantics, the ones with a `colorScheme` field. Derived
chat/video tokens have no field at all — the SDK inlines them as swatch reads
(`colorScheme.brand.shade300`) inside component-theme defaults, which no token
name will match. Those live in `references/derived-token-map.md` instead.
"""

from __future__ import annotations

import argparse
import collections
import re
import subprocess
import sys

PATTERN = r"_\?colorScheme\.[A-Za-z][A-Za-z0-9]*"
LINE_RE = re.compile(r"^(?P<ref>.*?):(?P<path>.*?):(?P<line>\d+):.*?_?colorScheme\.(?P<field>[A-Za-z0-9]+)")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("repo", help="path to the consuming SDK checkout")
    parser.add_argument("ref", help="git ref to inspect, e.g. origin/v2")
    parser.add_argument("field", nargs="?", help="limit to one colorScheme field")
    parser.add_argument("--include-tests", action="store_true")
    args = parser.parse_args()

    pattern = rf"_\?colorScheme\.{args.field}\b" if args.field else PATTERN
    result = subprocess.run(
        ["git", "grep", "-Ion", pattern, args.ref, "--", "*.dart"],
        cwd=args.repo,
        capture_output=True,
        text=True,
    )
    # git grep exits 1 on "no matches", which is an answer, not an error.
    if result.returncode not in (0, 1):
        sys.exit(f"error: git grep failed in {args.repo}\n{result.stderr.strip()}")

    usage: dict[str, set[str]] = collections.defaultdict(set)
    for line in result.stdout.splitlines():
        match = LINE_RE.match(line)
        if not match:
            continue
        path = match.group("path")
        if not args.include_tests and ("/test/" in path or path.endswith("_test.dart")):
            continue
        usage[match.group("field")].add(path.split("/")[-1].removesuffix(".dart"))

    if not usage:
        target = f"field '{args.field}'" if args.field else "any colorScheme field"
        print(f"no reads of {target} in {args.repo} at {args.ref}")
        print("If this is a repo whose design-system work lives on a branch, check that")
        print("branch — the default branch may not depend on stream_core_flutter at all.")
        return 0

    width = max(len(f) for f in usage) + 2
    for field in sorted(usage):
        print(f"{field:<{width}} {', '.join(sorted(usage[field]))}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
