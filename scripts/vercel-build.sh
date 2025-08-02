#!/bin/bash

# Exit on any error
set -e

echo "🚀 Starting Flutter web build for Vercel..."

# Install Flutter
echo "📦 Installing Flutter..."
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Verify Flutter installation
echo "✅ Flutter version:"
flutter --version

# Get Flutter dependencies
echo "📚 Getting Flutter dependencies..."
flutter pub get

# Build the web app
echo "🔨 Building Flutter web app..."
flutter build web --release

echo "✅ Build completed successfully!" 