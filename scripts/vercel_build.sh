#!/bin/bash
set -e

echo "========================================="
echo "Starting Flutter Web Build for Vercel"
echo "========================================="

# Install Flutter
echo "Installing Flutter..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1 /tmp/flutter
export PATH="/tmp/flutter/bin:$PATH"

# Verify Flutter installation
echo "Verifying Flutter installation..."
flutter --version

# Enable Flutter Web
echo "Enabling Flutter web support..."
flutter config --enable-web

# Install dependencies
echo "Installing dependencies..."
flutter pub get

# Build Flutter web with environment variables
echo "Building Flutter web in release mode..."

# Check if environment variables are set
if [ -z "$SUPABASE_URL" ]; then
  echo "Error: SUPABASE_URL environment variable is not set"
  exit 1
fi

if [ -z "$SUPABASE_ANON_KEY" ]; then
  echo "Error: SUPABASE_ANON_KEY environment variable is not set"
  exit 1
fi

# Build with dart-define for environment variables
flutter build web \
  --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --web-renderer canvaskit \
  --base-href /

echo "========================================="
echo "Build completed successfully!"
echo "Output directory: build/web"
echo "========================================="
