#!/usr/bin/env bash
# Analyze the whole workspace and run every package's tests.
# Usage: tool/check.sh [--no-test]
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> dart format (check)"
dart format --output=none --set-exit-if-changed lib test packages

echo "==> flutter analyze (workspace)"
flutter analyze

if [[ "${1:-}" == "--no-test" ]]; then
  exit 0
fi

for dir in . packages/*; do
  if [[ -n "$(find "$dir/test" -name '*_test.dart' -print -quit 2>/dev/null)" ]]; then
    echo "==> flutter test ($dir)"
    (cd "$dir" && flutter test)
  fi
done
