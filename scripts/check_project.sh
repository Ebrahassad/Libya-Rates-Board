#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "===== FLUTTER ====="
flutter --version
echo
echo "===== PUB GET ====="
flutter pub get
echo
echo "===== ANALYZE ====="
flutter analyze
echo
echo "===== TEST ====="
flutter test
echo
echo "===== DIFF CHECK ====="
git diff --check
echo
echo "===== STATUS ====="
git status --short
