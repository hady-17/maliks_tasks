param(
  [string]$Src = "assets/Vector.png"
)

# Generates web favicons and icons from assets/Vector.png using ImageMagick (magick)
# Usage (PowerShell): .\scripts\generate_favicons.ps1

if (-not (Test-Path $Src)) {
  Write-Error "Source file not found: $Src"
  exit 1
}

New-Item -ItemType Directory -Force -Path web\icons | Out-Null

Write-Output "Generating favicons from $Src..."

& magick convert $Src -resize 16x16 web\favicon-16x16.png
& magick convert $Src -resize 32x32 web\favicon-32x32.png
& magick convert $Src -resize 64x64 web\favicon.png

& magick convert $Src -resize 192x192 web\icons\Icon-192.png
& magick convert $Src -resize 512x512 web\icons\Icon-512.png

& magick convert $Src -resize 192x192 web\icons\Icon-maskable-192.png
& magick convert $Src -resize 512x512 web\icons\Icon-maskable-512.png

& magick convert $Src -resize 180x180 web\icons\apple-touch-icon.png

Write-Output "Favicons created in web/ and web/icons/"
