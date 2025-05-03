#!/bin/bash
# MirrorHR Project - Replace Real Identifiers with Placeholders
#
# This script replaces all original identifiers in the codebase with generic placeholders.
# It helps prepare the project for open-source release by removing references to specific
# developer accounts, bundle IDs, and provisioning profiles.
#
# IMPORTANT: The original identifiers have been replaced with UPPERCASE_PLACEHOLDERS.
# You MUST edit this script to replace these placeholders with your actual identifiers
# before running it.

echo "🔄 Replacing real identifiers with placeholders..."

# Define target placeholder values
TEAM_ID="YOURTEAMID"
BUNDLE_PREFIX="com.example"
APP_NAME="MirrorHR-App"
BUNDLE_ID="${BUNDLE_PREFIX}.${APP_NAME}"
APP_GROUP="group.${BUNDLE_PREFIX}.${APP_NAME}"
MERCHANT_ID="merchant.${BUNDLE_PREFIX}.${APP_NAME}"
SERVICE_NAME="_${APP_NAME}"

# !!! IMPORTANT: Replace these placeholders with your actual identifiers !!!
# For example, change ORIGINAL_TEAM_ID to your actual team ID like "93T3LG4NPG"
ORIGINAL_TEAM_ID="YOUR_ACTUAL_TEAM_ID"
ORIGINAL_BUNDLE_ID="YOUR_ACTUAL_BUNDLE_ID"  # e.g., "com.your-company.your-app"
ORIGINAL_APP_GROUP="YOUR_ACTUAL_APP_GROUP"  # e.g., "group.your-company.your-app"
ORIGINAL_MERCHANT_ID="YOUR_ACTUAL_MERCHANT_ID"  # e.g., "merchant.your-company.your-app"
ORIGINAL_SERVICE_TCP="YOUR_ACTUAL_SERVICE_NAME._tcp"  # e.g., "_yourapp._tcp"
ORIGINAL_SERVICE_UDP="YOUR_ACTUAL_SERVICE_NAME._udp"  # e.g., "_yourapp._udp"

# Replace your actual provisioning profile names with these placeholders
ORIGINAL_IOS_DEV_PROFILE="YOUR_IOS_DEV_PROFILE_NAME"  # e.g., "Your Company iOS Development"
ORIGINAL_IOS_DIST_PROFILE="YOUR_IOS_DIST_PROFILE_NAME"  # e.g., "Your Company iOS Distribution"
ORIGINAL_WATCH_DEV_PROFILE="YOUR_WATCH_DEV_PROFILE_NAME"  # e.g., "Your Company watchOS Development"
ORIGINAL_WATCH_DIST_PROFILE="YOUR_WATCH_DIST_PROFILE_NAME"  # e.g., "Your Company watchOS Distribution"
ORIGINAL_WIDGET_DEV_PROFILE="YOUR_WIDGET_DEV_PROFILE_NAME"  # e.g., "Your Company Widget Development"
ORIGINAL_WIDGET_DIST_PROFILE="YOUR_WIDGET_DIST_PROFILE_NAME"  # e.g., "Your Company Widget Distribution"

# Check if placeholders have been replaced
if [[ "$ORIGINAL_TEAM_ID" == "YOUR_ACTUAL_TEAM_ID" ]]; then
  echo "⚠️ ERROR: You must edit this script to replace the placeholder values with your actual identifiers."
  echo "    Please open this script, find all uppercase placeholder variables, and replace them with"
  echo "    your actual values before running it again."
  exit 1
fi

# Replace Team ID
echo "• Replacing Team ID with ${TEAM_ID}..."
find . -type f -name "*.pbxproj" -exec sed -i '' "s/${ORIGINAL_TEAM_ID}/${TEAM_ID}/g" {} \;

# Replace Bundle IDs
echo "• Replacing Bundle IDs with ${BUNDLE_ID}..."
find . -type f \( -name "*.plist" -o -name "*.pbxproj" -o -name "*.swift" -o -name "*.entitlements" \) -exec sed -i '' "s/${ORIGINAL_BUNDLE_ID}/${BUNDLE_ID}/g" {} \;

# Replace App Groups
echo "• Replacing App Groups with ${APP_GROUP}..."
find . -type f \( -name "*.plist" -o -name "*.entitlements" -o -name "*.swift" \) -exec sed -i '' "s/${ORIGINAL_APP_GROUP}/${APP_GROUP}/g" {} \;

# Replace Merchant ID
echo "• Replacing Merchant ID with ${MERCHANT_ID}..."
find . -type f -name "*.entitlements" -exec sed -i '' "s/${ORIGINAL_MERCHANT_ID}/${MERCHANT_ID}/g" {} \;

# Replace Bonjour Service Names
echo "• Replacing Bonjour Service Names with ${SERVICE_NAME}._tcp and ${SERVICE_NAME}._udp..."
find . -type f -name "*.plist" -exec sed -i '' "s/${ORIGINAL_SERVICE_TCP}/${SERVICE_NAME}._tcp/g" {} \;
find . -type f -name "*.plist" -exec sed -i '' "s/${ORIGINAL_SERVICE_UDP}/${SERVICE_NAME}._udp/g" {} \;

# Replace provisioning profile names with placeholders
echo "• Replacing provisioning profile names with generic placeholders..."
find . -type f -name "*.pbxproj" -exec sed -i '' "s/${ORIGINAL_IOS_DEV_PROFILE}/iOS Development/g" {} \;
find . -type f -name "*.pbxproj" -exec sed -i '' "s/${ORIGINAL_IOS_DIST_PROFILE}/iOS Distribution/g" {} \;
find . -type f -name "*.pbxproj" -exec sed -i '' "s/${ORIGINAL_WATCH_DEV_PROFILE}/watchOS Development/g" {} \;
find . -type f -name "*.pbxproj" -exec sed -i '' "s/${ORIGINAL_WATCH_DIST_PROFILE}/watchOS Distribution/g" {} \;
find . -type f -name "*.pbxproj" -exec sed -i '' "s/${ORIGINAL_WIDGET_DEV_PROFILE}/Widget Development/g" {} \;
find . -type f -name "*.pbxproj" -exec sed -i '' "s/${ORIGINAL_WIDGET_DIST_PROFILE}/Widget Distribution/g" {} \;

echo "✅ Replacement complete! All real identifiers have been replaced with placeholders."
echo "Please verify the changes before committing to your repository." 