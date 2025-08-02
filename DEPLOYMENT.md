# Deploying Mispelt to Vercel

This guide will help you deploy your Flutter web app to Vercel.

## Prerequisites

1. **Flutter SDK** installed and configured
2. **Vercel account** (free at [vercel.com](https://vercel.com))
3. **Git repository** with your project

## Step 1: Build the Web App

Run this command in your project root:

```bash
flutter build web --release
```

This creates a `build/web` directory with your optimized web build.

## Step 2: Deploy to Vercel

### Option A: Using Vercel CLI (Recommended)

1. Install Vercel CLI:
   ```bash
   npm i -g vercel
   ```

2. Login to Vercel:
   ```bash
   vercel login
   ```

3. Deploy from your project root:
   ```bash
   vercel
   ```

4. Follow the prompts:
   - Set up and deploy: `Y`
   - Which scope: Select your account
   - Link to existing project: `N`
   - Project name: `mispelt` (or your preferred name)
   - Directory: `./` (current directory)

### Option B: Using Vercel Dashboard

1. Go to [vercel.com](https://vercel.com) and sign in
2. Click "New Project"
3. Import your Git repository
4. Vercel will automatically detect the Flutter project and use the `vercel.json` configuration

## Step 3: Environment Variables (if needed)

If your app uses Firebase or other services, you may need to set environment variables in Vercel:

1. Go to your project dashboard in Vercel
2. Navigate to Settings → Environment Variables
3. Add any required environment variables

## Step 4: Custom Domain (Optional)

1. In your Vercel project dashboard, go to Settings → Domains
2. Add your custom domain
3. Follow the DNS configuration instructions

## Configuration Files

The project includes:

- **`vercel.json`**: Vercel deployment configuration
- **`web/index.html`**: Optimized for web performance and SEO
- **`.gitignore`**: Excludes build artifacts from version control

## Features

- ✅ Automatic builds on Git push
- ✅ Global CDN for fast loading
- ✅ HTTPS by default
- ✅ Custom domain support
- ✅ Environment variables
- ✅ Preview deployments for pull requests

## Troubleshooting

### Build Issues
- Ensure Flutter is properly installed: `flutter doctor`
- Clear build cache: `flutter clean`
- Rebuild: `flutter build web --release`

### Deployment Issues
- Check Vercel build logs in the dashboard
- Ensure all dependencies are in `pubspec.yaml`
- Verify `vercel.json` configuration

### Performance Issues
- The app is optimized for web with proper caching headers
- Assets are served from CDN for fast loading
- Consider enabling Vercel's Edge Functions for dynamic features

## Support

For Vercel-specific issues, check the [Vercel documentation](https://vercel.com/docs).
For Flutter web issues, check the [Flutter web documentation](https://flutter.dev/web). 