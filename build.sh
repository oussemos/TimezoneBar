#!/bin/bash
set -e

APP_NAME="TimezoneBar"
BUNDLE="${APP_NAME}.app"

echo "▸ Building ${APP_NAME}…"
swift build -c release 2>&1

echo "▸ Creating app bundle…"
rm -rf "${BUNDLE}"
mkdir -p "${BUNDLE}/Contents/MacOS"
mkdir -p "${BUNDLE}/Contents/Resources"

cp ".build/release/${APP_NAME}" "${BUNDLE}/Contents/MacOS/"
cp "Info.plist" "${BUNDLE}/Contents/"

# Generate icon if not already built
if [ ! -f "AppIcon.icns" ]; then
    echo "▸ Generating app icon…"
    swift make_icon.swift
    iconutil -c icns AppIcon.iconset -o AppIcon.icns
fi
cp "AppIcon.icns" "${BUNDLE}/Contents/Resources/"

# Remove quarantine so it runs without Gatekeeper prompts (local build)
xattr -cr "${BUNDLE}" 2>/dev/null || true

echo ""
echo "✓ Built: ${BUNDLE}"
echo ""
echo "  • Double-click ${BUNDLE} to launch, or:"
echo "  • Copy to /Applications/ for permanent install"
echo ""

read -p "Launch now? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open "${BUNDLE}"
fi
