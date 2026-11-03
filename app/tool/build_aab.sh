#!/usr/bin/env bash
# Build the signed release bundle and copy it to build/release/bhakti-reels-<name>.aab
set -euo pipefail
cd "$(dirname "$0")/.."
export JAVA_HOME="${JAVA_HOME:-/opt/homebrew/opt/openjdk@17}"
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
version=$(sed -n 's/^version: *//p' pubspec.yaml | tr -d '[:space:]' | cut -d+ -f1)
flutter build appbundle --release --dart-define-from-file=../.secrets/dart_defines.json
mkdir -p build/release
out="build/release/bhakti-reels-${version}.aab"
cp build/app/outputs/bundle/release/app-release.aab "$out"
echo "Wrote $PWD/$out"
