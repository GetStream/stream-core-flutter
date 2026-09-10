#!/usr/bin/env python3
"""Flatten a design-token semantics JSON into sorted `path = value` lines.

The token repo's generated output is sorted by key, so any change that adds or
renames a token re-sorts the whole file and buries real value changes in
hundreds of lines of move noise. Diffing the flattened source instead makes an
added / removed / changed token obvious.

Usage:

    # one revision
    flatten_tokens.py tokens/core/semantics/light.json

    # compare two revisions of the same file (run from the token repo)
    flatten_tokens.py --diff main tokens/on-elevation-and-indicators \\
        tokens/core/semantics/light.json

The --diff form shells out to `git show <ref>:<path>` for each ref, so it needs
a git checkout of the token repo but no network. Values are left as authored —
`{yellow.200}` stays an alias rather than being resolved — because an alias
change and a hex change want to be read differently.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys


def flatten(node: dict, prefix: str = "") -> dict[str, str]:
    """Collapse a nested token tree into {"group/name": "$value"}."""
    out: dict[str, str] = {}
    for key, value in node.items():
        if not isinstance(value, dict):
            continue
        if "$value" in value:
            out[prefix + key] = value["$value"]
        else:
            out.update(flatten(value, f"{prefix}{key}/"))
    return out


def load(path: str, ref: str | None = None) -> dict[str, str]:
    if ref is None:
        with open(path) as handle:
            return flatten(json.load(handle))
    result = subprocess.run(
        ["git", "show", f"{ref}:{path}"],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        sys.exit(
            f"error: cannot read {path} at ref '{ref}'.\n"
            f"  git said: {result.stderr.strip()}\n"
            f"  A PR branch is often not in your local checkout yet — fetch it first:\n"
            f"      git fetch origin {ref}\n"
            f"  then pass the ref as 'FETCH_HEAD' or 'origin/{ref}'."
        )
    return flatten(json.loads(result.stdout))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("path", help="path to a semantics JSON file")
    parser.add_argument(
        "--diff",
        nargs=2,
        metavar=("BASE_REF", "HEAD_REF"),
        help="compare the file at two git refs instead of printing one",
    )
    args = parser.parse_args()

    if not args.diff:
        for key, value in sorted(load(args.path).items()):
            print(f"{key} = {value}")
        return 0

    base_ref, head_ref = args.diff
    base, head = load(args.path, base_ref), load(args.path, head_ref)

    removed = sorted(k for k in base if k not in head)
    added = sorted(k for k in head if k not in base)
    changed = sorted(k for k in base if k in head and base[k] != head[k])

    print(f"{args.path}: {len(base)} -> {len(head)} tokens")
    for key in removed:
        print(f"  REMOVED  {key} = {base[key]}")
    for key in added:
        print(f"  ADDED    {key} = {head[key]}")
    for key in changed:
        print(f"  CHANGED  {key}: {base[key]} -> {head[key]}")
    if not (removed or added or changed):
        print("  (no semantic changes)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
