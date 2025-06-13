#!/bin/bash

# Swift Migration Build Test Script
# Run this script to test if the Swift migration builds successfully

echo "🚀 Starting Swift Migration Build Test..."

cd "$(dirname "$0")"

# Check if we're in the right directory
if [ ! -f "Podfile" ]; then
    echo "❌ Error: Not in the correct directory. Please run this script from the project root."
    exit 1
fi

echo "📦 Installing/Updating Pods..."
pod install --quiet

echo "🔨 Building project..."
xcodebuild -workspace encodify.xcworkspace -scheme encodify -sdk iphonesimulator -configuration Debug build ONLY_ACTIVE_ARCH=YES -quiet

if [ $? -eq 0 ]; then
    echo "✅ Build successful! Swift migration completed successfully."
    echo ""
    echo "🎉 Your Encodify app has been successfully migrated to Swift!"
    echo ""
    echo "Next steps:"
    echo "1. Open encodify.xcworkspace in Xcode"
    echo "2. Remove old Objective-C files from the project navigator"
    echo "3. Add the new Swift files to the project"
    echo "4. Test the app on simulator or device"
else
    echo "❌ Build failed. Please check the errors above."
    exit 1
fi
