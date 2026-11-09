#!/usr/bin/env bash
# Phase 2 setup for AI Buddy (Flutter).
# Run from the project root:  bash scripts/setup_phase2.sh
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> Flutter version"
flutter --version

echo "==> Adding runtime dependencies (pub picks the newest versions compatible with your SDK)"
flutter pub add \
  flutter_riverpod \
  dio \
  go_router \
  freezed_annotation \
  json_annotation \
  flutter_secure_storage \
  shared_preferences \
  flutter_markdown_plus \
  uuid \
  intl \
  package_info_plus

echo "==> Adding dev dependencies"
flutter pub add --dev \
  build_runner \
  freezed \
  json_serializable \
  mocktail

echo "==> Generating Freezed / JSON code"
dart run build_runner build --delete-conflicting-outputs

echo "==> Static analysis"
flutter analyze

echo "==> Tests"
flutter test

echo "Phase 2 setup complete."
