#!/bin/bash

# Script to copy Firebase configuration based on flavor
# This script should be added as a build phase in Xcode

set -e

echo "🍎 iOS Firebase Config Copy Script"

# Get the flavor from environment variable or configuration name
FLAVOR=""

# Try to get flavor from CONFIGURATION name (e.g., "Debug-vicosa", "Release-ouroPreto")
if [[ "$CONFIGURATION" == *"-"* ]]; then
    FLAVOR=$(echo "$CONFIGURATION" | cut -d'-' -f2)
    echo "📱 Detected flavor from configuration: $FLAVOR"
elif [[ -n "$FLUTTER_FLAVOR" ]]; then
    FLAVOR="$FLUTTER_FLAVOR"
    echo "📱 Using FLUTTER_FLAVOR: $FLAVOR"
else
    # Default to demo if no flavor specified
    FLAVOR="demo"
    echo "📱 No flavor specified, using default: $FLAVOR"
fi

# Convert to lowercase for consistency
FLAVOR=$(echo "$FLAVOR" | tr '[:upper:]' '[:lower:]')

echo "🔧 Processing flavor: $FLAVOR"

# Navigate to project root (assuming script is in ios/Scripts/)
cd "${SRCROOT}/../.."

# Run the Dart script to copy the configuration
echo "🚀 Running Dart script to copy Firebase config..."
dart scripts/copy_ios_firebase_config.dart "$FLAVOR"

if [ $? -eq 0 ]; then
    echo "✅ Firebase configuration copied successfully for flavor: $FLAVOR"
else
    echo "❌ Failed to copy Firebase configuration"
    exit 1
fi
