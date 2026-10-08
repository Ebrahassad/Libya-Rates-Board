#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

flutter pub get
flutter analyze
flutter test

if [ -n "${FULUS_API_TOKEN:-}" ]; then
  flutter build apk --release \
    --dart-define="FULUS_API_TOKEN=${FULUS_API_TOKEN}"
else
  flutter build apk --release
fi

find build/app/outputs/flutter-apk -maxdepth 1 -type f -print
