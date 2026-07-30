#!/bin/bash

# Fail when a PR changes a CHANGELOG section for an already-released version.
#
# Entries for unreleased work belong under `## Upcoming` (see the "Changelog
# policy" section of STYLE_GUIDE.md). Adding them to the topmost `## <version>`
# heading instead is an easy mistake to make, because on a branch cut from a
# release commit that heading is what sits at the top of the file, and nothing
# about it looks unavailable.
#
# Compares the base and head revisions of one CHANGELOG and reports every
# released section whose body was changed or removed. Sections that only exist
# on the head side are ignored, so a release PR renaming `## Upcoming` to a
# version number passes.
#
# Usage: check-changelog-placement.sh BASE_FILE HEAD_FILE DISPLAY_PATH
# A missing BASE_FILE is treated as empty, for a CHANGELOG the PR adds.

# Fast fail the script on failures.
set -euo pipefail

if [ "$#" -ne 3 ]; then
  echo "usage: $(basename "$0") BASE_FILE HEAD_FILE DISPLAY_PATH" >&2
  exit 2
fi

base_file=$1
head_file=$2
display_path=$3

[ -f "$base_file" ] || base_file=/dev/null
[ -f "$head_file" ] || head_file=/dev/null

# Every `## ` heading in the file, one per line, trimmed.
headings() {
  awk '/^## / {
    heading = substr($0, 4)
    sub(/^[ \t]+/, "", heading)
    sub(/[ \t]+$/, "", heading)
    print heading
  }' "$1"
}

# The lines under the requested heading. Trailing blank lines are dropped so
# spacing alone never fails the check; blank lines inside the body are kept as
# they are, so a real edit is still caught.
section() {
  awk -v want="$2" '
    /^## / {
      heading = substr($0, 4)
      sub(/^[ \t]+/, "", heading)
      sub(/[ \t]+$/, "", heading)
      inside = (heading == want)
      next
    }
    inside {
      if ($0 ~ /^[ \t]*$/) { held[++blanks] = $0; next }
      for (i = 1; i <= blanks; i++) print held[i]
      blanks = 0
      print
    }
  ' "$1"
}

problems=''

while IFS= read -r heading; do
  [ -n "$heading" ] || continue

  # `## Upcoming` is the one section a PR is meant to touch.
  if [ "$(printf '%s' "$heading" | tr '[:upper:]' '[:lower:]')" = 'upcoming' ]; then
    continue
  fi

  if ! headings "$head_file" | grep -qxF "$heading"; then
    problems+="  - \`## $heading\` was removed"$'\n'
    continue
  fi

  if [ "$(section "$base_file" "$heading")" != "$(section "$head_file" "$heading")" ]; then
    problems+="  - \`## $heading\` was modified"$'\n'
  fi
done < <(headings "$base_file")

if [ -z "$problems" ]; then
  echo "$display_path: only the Upcoming section was touched."
  exit 0
fi

echo "::error file=$display_path::Released CHANGELOG sections were changed"
echo
echo "$display_path changes a section for a version that is already published:"
echo
printf '%s' "$problems"
cat <<'EOF'

Entries for unreleased work go under `## Upcoming` at the top of the file.
Add that heading if it is missing, and move the entries there.

If the change to the released section is deliberate (fixing a typo in a
published entry, for example), add the `changelog-override` label to the PR.
EOF
exit 1
