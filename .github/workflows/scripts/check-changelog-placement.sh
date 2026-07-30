#!/bin/bash

# Enforce the structure of a package CHANGELOG on a pull request.
#
# A CHANGELOG heading is either `## Upcoming` or a version number, and entries
# for unreleased work go under `## Upcoming` (see the "Changelog policy" section
# of STYLE_GUIDE.md). Writing them into a `## <version>` heading is an easy
# mistake to make, because on a branch cut from a release commit that heading is
# what sits at the top of the file, and nothing about it looks unavailable.
#
# Three rules, checked by comparing the base and head revisions of one CHANGELOG:
#
#   1. A version section present in the base revision must survive unchanged.
#   2. Every heading that is not a version number must be exactly `Upcoming`.
#      `Unreleased`, `NEXT` and other spellings are rejected so the unreleased
#      section is always found in the same place under the same name.
#   3. Only a release branch may add a version heading. Turning `## Upcoming`
#      into `## 1.2.3` is what a release does; on any other branch it means
#      entries were filed under a version that has not shipped. A CHANGELOG the
#      PR creates is exempt, so a new package can declare its initial version.
#
# Usage: check-changelog-placement.sh BASE_FILE HEAD_FILE DISPLAY_PATH HEAD_BRANCH
# A missing BASE_FILE is treated as empty, for a CHANGELOG the PR adds.

# Fast fail the script on failures.
set -euo pipefail

if [ "$#" -ne 4 ]; then
  echo "usage: $(basename "$0") BASE_FILE HEAD_FILE DISPLAY_PATH HEAD_BRANCH" >&2
  exit 2
fi

base_file=$1
head_file=$2
display_path=$3
head_branch=$4

[ -f "$head_file" ] || head_file=/dev/null

# A CHANGELOG the PR creates belongs to a brand-new package, which declares its
# own initial version. Only rule 3 cares; the other two still apply.
is_new_changelog=false
if [ ! -s "$base_file" ]; then
  base_file=/dev/null
  is_new_changelog=true
fi

# The one heading a PR is meant to add entries under.
readonly UPCOMING='Upcoming'

# Releases are cut from `release/...`, and only they may add a version heading.
readonly RELEASE_PREFIX='release/'

# Every `## ` heading in the file, one per line, trimmed.
headings() {
  awk '/^## / {
    heading = substr($0, 4)
    sub(/^[ \t]+/, "", heading)
    sub(/[ \t]+$/, "", heading)
    print heading
  }' "$1"
}

# A released section: `0.4.1`, `1.0.0-beta.1`, `0.4.1 (2026-07-22)`, ...
is_version() {
  case "$1" in
    [0-9]*) return 0 ;;
    *) return 1 ;;
  esac
}

has_heading() {
  headings "$1" | grep -qxF "$2"
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

is_release_branch() {
  case "$head_branch" in
    "$RELEASE_PREFIX"*) return 0 ;;
    *) return 1 ;;
  esac
}

released=''
misnamed=''
premature=''

# Rule 1: no published section may change.
while IFS= read -r heading; do
  if [ -n "$heading" ] && is_version "$heading"; then
    if ! has_heading "$head_file" "$heading"; then
      released+="  - \`## $heading\` was removed"$'\n'
    elif [ "$(section "$base_file" "$heading")" != "$(section "$head_file" "$heading")" ]; then
      released+="  - \`## $heading\` was modified"$'\n'
    fi
  fi
done < <(headings "$base_file")

# Rules 2 and 3, over what the PR proposes.
while IFS= read -r heading; do
  [ -n "$heading" ] || continue

  if ! is_version "$heading"; then
    if [ "$heading" != "$UPCOMING" ]; then
      misnamed+="  - \`## $heading\`"$'\n'
    fi
  elif [ "$is_new_changelog" = false ] && ! is_release_branch && ! has_heading "$base_file" "$heading"; then
    premature+="  - \`## $heading\`"$'\n'
  fi
done < <(headings "$head_file")

if [ -z "$released" ] && [ -z "$misnamed" ] && [ -z "$premature" ]; then
  echo "$display_path: structure is fine."
  exit 0
fi

echo "::error file=$display_path::CHANGELOG structure check failed"
echo

if [ -n "$released" ]; then
  echo "$display_path changes a section for a version that is already published:"
  echo
  printf '%s' "$released"
  cat <<EOF

Entries for unreleased work go under \`## $UPCOMING\` at the top of the file.
Add that heading if it is missing, and move the entries there.
EOF
fi

if [ -n "$misnamed" ]; then
  [ -n "$released" ] && echo
  echo "$display_path has a heading that is neither a version nor \`## $UPCOMING\`:"
  echo
  printf '%s' "$misnamed"
  cat <<EOF

Rename it to \`## $UPCOMING\`. That is the only heading the release tooling and
the changelog checks look for.
EOF
fi

if [ -n "$premature" ]; then
  { [ -n "$released" ] || [ -n "$misnamed" ]; } && echo
  echo "$display_path adds a version heading on a branch that is not a release:"
  echo
  printf '%s' "$premature"
  cat <<EOF

Put the entries under \`## $UPCOMING\` instead. The version heading is created by
the release PR, which is cut from a \`${RELEASE_PREFIX}...\` branch.
EOF
fi

cat <<'EOF'

If the change to a published section is deliberate (fixing a typo in an entry
that already shipped, for example), add the `changelog-override` label.
EOF
exit 1
