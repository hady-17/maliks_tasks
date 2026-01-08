#!/usr/bin/env bash
set -euo pipefail

# Generates web favicons and icons from assets/Vector.png using ImageMagick (magick)
# Usage: ./scripts/generate_favicons.sh

SRC="assets/Vector.png"
if [ ! -f "$SRC" ]; then
  echo "Source file not found: $SRC"
  exit 1
fi

mkdir -p web/icons

echo "Generating favicons from $SRC..."

# small favicons
magick convert "$SRC" -resize 16x16 web/favicon-16x16.png
magick convert "$SRC" -resize 32x32 web/favicon-32x32.png

# general favicon
magick convert "$SRC" -resize 64x64 web/favicon.png

# PWA icons
magick convert "$SRC" -resize 192x192 web/icons/Icon-192.png
magick convert "$SRC" -resize 512x512 web/icons/Icon-512.png

# maskable icons (same source but marked maskable in manifest)
magick convert "$SRC" -resize 192x192 web/icons/Icon-maskable-192.png
magick convert "$SRC" -resize 512x512 web/icons/Icon-maskable-512.png

# iOS touch icon
magick convert "$SRC" -resize 180x180 web/icons/apple-touch-icon.png

echo "Favicons created in web/ and web/icons/"

echo "Done."
