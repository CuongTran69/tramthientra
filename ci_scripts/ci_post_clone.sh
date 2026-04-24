#!/bin/sh
set -e

echo "==> Installing XcodeGen via Homebrew..."
brew install xcodegen

echo "==> Generating Xcode project from project.yml..."
xcodegen generate

echo "==> ci_post_clone.sh completed successfully."
