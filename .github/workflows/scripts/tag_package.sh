#!/bin/bash

# Create a package's release tag (<pkg>-v<version>) at HEAD, idempotently.
# Invoked by `melos run release:tag` via `melos exec`, once per unpublished
# package — MELOS_PACKAGE_NAME / MELOS_PACKAGE_VERSION come from melos.
set -euo pipefail

tag="$MELOS_PACKAGE_NAME-v$MELOS_PACKAGE_VERSION"

if git rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
  # Tag already exists (e.g. a re-run). Fine only if it points at HEAD; a tag
  # on a different commit is a stale/failed release — stop loudly rather than
  # silently re-pushing the wrong tree (or not publishing at all).
  if [ "$(git rev-parse "$tag^{commit}")" != "$(git rev-parse "HEAD^{commit}")" ]; then
    echo "::error ::Tag $tag already exists at a different commit than HEAD; resolve it before releasing."
    exit 1
  fi
  echo "✅ $tag already exists at HEAD; nothing to do."
else
  git tag "$tag"
  echo "🏷️ Created $tag."
fi
