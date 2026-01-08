# Vercel Deployment Guide

This guide covers deploying your Flutter web app to Vercel with Supabase integration.

## Prerequisites

- Vercel account
- Supabase project with URL and anon key
- Git repository connected to Vercel

## Files Created

### 1. `vercel.json`
Vercel configuration that:
- Routes all requests to `index.html` (fixes deep-link refresh issues)
- Configures caching for optimal performance
- Sets up the build process

### 2. `scripts/vercel_build.sh`
Build script that:
- Installs Flutter (stable channel)
- Runs `flutter pub get`
- Builds Flutter web in release mode
- Passes environment variables via `--dart-define`

### 3. Updated `.gitignore`
Ensures sensitive files are excluded:
- `.env` and variants
- `build/` directory
- `.dart_tool/`

### 4. Updated `lib/main.dart`
- Uses `String.fromEnvironment` to read Supabase credentials
- Falls back to `.env` file for local development
- Validates environment variables before initialization
- No hardcoded secrets

## Deployment Steps

### 1. Set Up Environment Variables in Vercel

In your Vercel project settings, add the following environment variables:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

**Important:** Do NOT commit these values to Git.

### 2. Configure Build Settings

Vercel should automatically detect `vercel.json`, but verify:

- **Build Command:** `bash scripts/vercel_build.sh`
- **Output Directory:** `build/web`
- **Install Command:** `echo 'Skip default install'`

### 3. Deploy

Push your code to your Git repository. Vercel will automatically:
1. Run the build script
2. Install Flutter
3. Build your web app with environment variables
4. Deploy to production

## Local Development

For local development, create a `.env` file in the project root:

```env
project_url=https://your-project.supabase.co
anon_api_key=your-anon-key-here
```

Run locally:
```bash
flutter run -d chrome
```

## Testing Production Build Locally

Build with environment variables:
```bash
flutter build web \
  --release \
  --dart-define=SUPABASE_URL="https://your-project.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="your-anon-key-here"
```

Serve locally:
```bash
# Using Python
cd build/web
python -m http.server 8000

# Or using any static file server
```

## How It Works

### Environment Variable Loading

The app checks for environment variables in this order:

1. **Production (Vercel):** Uses `String.fromEnvironment` values passed via `--dart-define`
2. **Local Development:** Falls back to `.env` file if environment variables are not set
3. **Validation:** Throws an error if credentials are missing

### Deep Link Support

The `vercel.json` configuration ensures:
- All routes rewrite to `index.html`
- Direct URL navigation works (e.g., `/login`, `/profile`)
- Page refreshes don't result in 404 errors

### Caching Strategy

- **HTML files:** No caching (always fetch latest)
- **Assets:** 1 year cache (immutable)
- **Service Worker:** No cache (ensures latest version)

## Troubleshooting

### Build Fails on Vercel

1. Check build logs for errors
2. Verify environment variables are set correctly
3. Ensure `scripts/vercel_build.sh` has Unix line endings (LF, not CRLF)

### App Shows Missing Credentials Error

1. Verify environment variables in Vercel project settings
2. Check that variable names match exactly: `SUPABASE_URL` and `SUPABASE_ANON_KEY`
3. Redeploy after adding/updating variables

### Deep Links Don't Work

1. Verify `vercel.json` is in project root
2. Check that routes configuration is correct
3. Clear browser cache and retry

### Local Development Issues

1. Ensure `.env` file exists with correct variables
2. Check that `flutter_dotenv` package is installed
3. Run `flutter pub get` to install dependencies

## Security Best Practices

✅ **DO:**
- Use environment variables for all secrets
- Keep `.env` files in `.gitignore`
- Use Supabase Row Level Security (RLS)
- Rotate keys if compromised

❌ **DON'T:**
- Hardcode secrets in source code
- Commit `.env` files to Git
- Share environment variables publicly
- Use production keys in development

## Additional Resources

- [Vercel Documentation](https://vercel.com/docs)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
- [Supabase Flutter SDK](https://supabase.com/docs/reference/dart)

## Support

For issues specific to:
- **Vercel:** Check Vercel build logs
- **Flutter:** Run `flutter doctor`
- **Supabase:** Verify project settings and RLS policies
