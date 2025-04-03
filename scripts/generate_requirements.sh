#!/bin/bash
# Validate requirements.txt against Poetry and generate if needed
set -euo pipefail

TMP_FILE=".tmp_requirements.txt"

# Generate fresh requirements.txt
poetry export -f requirements.txt -o $TMP_FILE --without-hashes

# Compare with existing
if ! diff -q requirements.txt $TMP_FILE >/dev/null 2>&1; then
    echo "❌ requirements.txt out of sync with Poetry!"
    echo "Diff:"
    diff --color=always -U3 requirements.txt $TMP_FILE || true
    echo "Run './scripts/poetry/generate_poetry_requirements.sh' to fix"
    rm $TMP_FILE
    exit 1
fi

rm $TMP_FILE
echo "✓ requirements.txt validated against Poetry lockfile"