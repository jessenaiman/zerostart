#!/usr/bin/env bash
# Safe publishing workflow
set -euo pipefail

VERSION=$(poetry version -s)
REMOTE="origin"

echo "🚀 Publishing version ${VERSION}"

# Verify clean working state
if [[ -n $(git status --porcelain) ]]; then
    echo "❌ Working directory not clean"
    git status
    exit 1
fi

# Build and verify
poetry build
twine check dist/*

# Tag and push
git tag -a "v${VERSION}" -m "Release ${VERSION}"
git push "${REMOTE}" "v${VERSION}"

# Publish to PyPI
read -rp "Publish to PyPI? (y/n) " confirm
if [[ "${confirm}" =~ ^[Yy]$ ]]; then
    poetry publish
else
    echo "Dry run complete"
fi