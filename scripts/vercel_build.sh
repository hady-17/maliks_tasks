echo "Installing Flutter..."
echo "Verifying Flutter installation..."
echo "Enabling Flutter web support..."
echo "Installing dependencies..."
echo "Building Flutter web in release mode..."
#!/usr/bin/env bash
set -euo pipefail

echo "========================================="
echo "Starting Flutter Web Build for Vercel"
echo "========================================="

# Clone Flutter stable into /tmp if not already present (cached between builds when possible)
if [ ! -d "/tmp/flutter" ]; then
  echo "Installing Flutter (stable)..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 /tmp/flutter
fi

export PATH="/tmp/flutter/bin:$PATH"

echo "Flutter version:"
flutter --version

# Ensure web is enabled
flutter config --enable-web || true

echo "Installing pub dependencies..."
flutter pub get

echo "Validating environment variables..."
if [ -z "${SUPABASE_URL-}" ]; then
  echo "Error: SUPABASE_URL environment variable is not set"
  exit 1
fi

if [ -z "${SUPABASE_ANON_KEY-}" ]; then
  echo "Error: SUPABASE_ANON_KEY environment variable is not set"
  exit 1
fi

echo "Building Flutter web in release mode..."
# Note: some Flutter releases may not support the --web-renderer flag; omit it for maximum compatibility.
flutter build web \
  --release \
  --dart-define=SUPABASE_URL="${SUPABASE_URL}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}" \
  --base-href /

echo "========================================="
echo "Build completed successfully!"
echo "Output directory: build/web"
echo "========================================="
