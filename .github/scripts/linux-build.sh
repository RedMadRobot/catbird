#!/usr/bin/env bash

# Usage: .github/scripts/linux-build.sh

set -eo pipefail

BUILD_OPTIONS=(
  --configuration release
  --package-path Packages/CatbirdApp
  --disable-sandbox
  --static-swift-stdlib
)

SWIFT_BUILD="swift build ${BUILD_OPTIONS[*]}"
$SWIFT_BUILD
BIN_PATH=$($SWIFT_BUILD --show-bin-path)
echo "::set-output name=bin_path::$BIN_PATH/catbird"
