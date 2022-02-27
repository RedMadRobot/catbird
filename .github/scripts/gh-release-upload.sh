#!/usr/bin/env bash

# Upload asset files to a GitHub Release.
#
# The gh cli in GitHub Actions is preinstalled in macOS, but is missing in Docker on Linux.
# https://docs.github.com/en/rest/reference/releases#upload-a-release-asset

set -eu

FILE_NAME=$(basename "$FILE_PATH")
CONTENT_TYPE=$(file -b --mime-type "$FILE_PATH")
UPLOAD_URL="https://uploads.github.com/repos/RedMadRobot/catbird/releases/$RELEASE_ID/assets?name=$FILE_NAME"

echo "Upload URL: $UPLOAD_URL"
echo "Content-Type: $CONTENT_TYPE"

curl \
  -X POST "$UPLOAD_URL" \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Content-Type: $CONTENT_TYPE" \
  --upload-file "$FILE_PATH"
