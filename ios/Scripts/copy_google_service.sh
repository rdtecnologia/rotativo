#!/bin/bash

# Script to copy the correct GoogleService-Info.plist based on the scheme
# Usage: copy_google_service.sh <city_name>

CITY_NAME=${1:-Main}
PROJECT_DIR="${SRCROOT}/.."
CONFIG_DIR="${PROJECT_DIR}/ios/config/cities"
TARGET_DIR="${PROJECT_DIR}/ios/Runner"

echo "🔄 Copying GoogleService-Info.plist for city: ${CITY_NAME}"
echo "📁 CONFIG_DIR: ${CONFIG_DIR}"
echo "📁 TARGET_DIR: ${TARGET_DIR}"

# List available files for debug
echo "📄 Available GoogleService files:"
ls -la "${CONFIG_DIR}/" | grep GoogleService || echo "No GoogleService files found"

# Copy the appropriate GoogleService-Info.plist
SOURCE_FILE="${CONFIG_DIR}/GoogleService-Info-${CITY_NAME}.plist"
if [ -f "${SOURCE_FILE}" ]; then
    cp "${SOURCE_FILE}" "${TARGET_DIR}/GoogleService-Info.plist"
    echo "✅ Successfully copied GoogleService-Info-${CITY_NAME}.plist"
    echo "📋 File size: $(wc -c < "${TARGET_DIR}/GoogleService-Info.plist") bytes"
else
    echo "⚠️ GoogleService-Info-${CITY_NAME}.plist not found, using default"
    DEFAULT_FILE="${CONFIG_DIR}/GoogleService-Info-Main.plist"
    if [ -f "${DEFAULT_FILE}" ]; then
        cp "${DEFAULT_FILE}" "${TARGET_DIR}/GoogleService-Info.plist"
        echo "✅ Successfully copied GoogleService-Info-Main.plist as fallback"
    else
        echo "❌ ERROR: No GoogleService files found!"
        exit 1
    fi
fi

# Verify the copied file
if [ -f "${TARGET_DIR}/GoogleService-Info.plist" ]; then
    echo "✅ Final verification: GoogleService-Info.plist exists in target"
else
    echo "❌ ERROR: GoogleService-Info.plist not found in target after copy!"
    exit 1
fi