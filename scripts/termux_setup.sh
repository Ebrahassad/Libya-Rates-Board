#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

PROJECT_DIR="${1:-$HOME/projects/libya_rates_board}"

echo "=================================================="
echo " Hassadi Libya Rates Board — Termux setup"
echo "=================================================="

if ! command -v git >/dev/null 2>&1; then
  pkg install -y git
fi

if ! command -v curl >/dev/null 2>&1; then
  pkg install -y curl
fi

if ! command -v java >/dev/null 2>&1; then
  echo "Java is required. Install with:"
  echo "  pkg install openjdk-17"
  exit 1
fi

mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

flutter pub get

echo
echo "Run checks:"
echo "  flutter analyze"
echo "  flutter test"
echo
echo "Run with parallel-market API:"
echo "  flutter run --dart-define=FULUS_API_TOKEN=YOUR_TOKEN"
