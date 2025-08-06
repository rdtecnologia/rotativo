#!/bin/bash

# Script to copy the correct GoogleService-Info.plist based on the scheme
# Usage: copy_google_service.sh <city_name>

CITY_NAME=${1:-Main}
PROJECT_DIR="${SRCROOT}/.."
CONFIG_DIR="${PROJECT_DIR}/ios/config/cities"
TARGET_DIR="${PROJECT_DIR}/ios/Runner"

echo "Copying GoogleService-Info.plist for city: ${CITY_NAME}"

# Copy the appropriate GoogleService-Info.plist
if [ -f "${CONFIG_DIR}/GoogleService-Info-${CITY_NAME}.plist" ]; then
    cp "${CONFIG_DIR}/GoogleService-Info-${CITY_NAME}.plist" "${TARGET_DIR}/GoogleService-Info.plist"
    echo "✅ Successfully copied GoogleService-Info-${CITY_NAME}.plist"
else
    echo "⚠️ GoogleService-Info-${CITY_NAME}.plist not found, using default"
    cp "${CONFIG_DIR}/GoogleService-Info-Main.plist" "${TARGET_DIR}/GoogleService-Info.plist"
fi