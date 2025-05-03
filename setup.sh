#!/bin/bash
# MirrorHR Setup Script for Open Source Contributors
# This script replaces all developer-specific identifiers with placeholders

echo "🛡️ MirrorHR Project Setup Script 🛡️"
echo "This script will replace all developer-specific identifiers with your own values"
echo ""

# Get user's Team ID
read -p "Enter your Apple Developer Team ID (leave blank to use 'YOURTEAMID'): " TEAM_ID
TEAM_ID=${TEAM_ID:-YOURTEAMID}

# Get user's Bundle ID prefix
read -p "Enter your Bundle ID prefix (leave blank to use 'com.example'): " BUNDLE_PREFIX
BUNDLE_PREFIX=${BUNDLE_PREFIX:-com.example}

# Get user's app name
read -p "Enter your app name (leave blank to use 'MirrorHR-App'): " APP_NAME
APP_NAME=${APP_NAME:-MirrorHR-App}

# Bundle ID replacements
BUNDLE_ID="$BUNDLE_PREFIX.$APP_NAME"
APP_GROUP="group.$BUNDLE_PREFIX.$APP_NAME"
MERCHANT_ID="merchant.$BUNDLE_PREFIX.$APP_NAME"
SERVICE_NAME="_${APP_NAME}._tcp"
SERVICE_NAME_UDP="_${APP_NAME}._udp"

echo ""
echo "Making replacements with:"
echo "• Team ID: $TEAM_ID"
echo "• Bundle ID: $BUNDLE_ID"
echo "• App Group: $APP_GROUP"
echo "• Merchant ID: $MERCHANT_ID"
echo "• Bonjour Service: $SERVICE_NAME"
echo ""

# Replace Team ID
echo "Replacing Team ID..."
find . -type f -name "*.pbxproj" -exec sed -i '' "s/93T3LG4NPG/$TEAM_ID/g" {} \;

# Replace Bundle IDs
echo "Replacing Bundle IDs..."
find . -type f \( -name "*.plist" -o -name "*.pbxproj" -o -name "*.swift" -o -name "*.entitlements" \) -exec sed -i '' "s/com\.mirror-labs\.Epilepsy-Research-Kit/$BUNDLE_ID/g" {} \;

# Replace App Groups
echo "Replacing App Groups..."
find . -type f \( -name "*.plist" -o -name "*.entitlements" -o -name "*.swift" \) -exec sed -i '' "s/group\.mirror-labs\.Epilepsy-Research-Kit/$APP_GROUP/g" {} \;

# Replace Merchant ID
echo "Replacing Merchant ID..."
find . -type f -name "*.entitlements" -exec sed -i '' "s/merchant\.com\.mirror-labs\.Epilepsy-Research-Kit/$MERCHANT_ID/g" {} \;

# Replace Bonjour Service Names
echo "Replacing Bonjour Service Names..."
find . -type f -name "*.plist" -exec sed -i '' "s/_mirrorHR\._tcp/$SERVICE_NAME/g" {} \;
find . -type f -name "*.plist" -exec sed -i '' "s/_mirrorHR\._udp/$SERVICE_NAME_UDP/g" {} \;

# Remove provisioning profile specifiers
echo "Removing provisioning profile specifiers..."
find . -type f -name "*.pbxproj" -exec sed -i '' 's/PROVISIONING_PROFILE_SPECIFIER = ".*";/PROVISIONING_PROFILE_SPECIFIER = "";/g' {} \;
find . -type f -name "*.pbxproj" -exec sed -i '' 's/"PROVISIONING_PROFILE_SPECIFIER\[sdk=.*\]" = ".*";/PROVISIONING_PROFILE_SPECIFIER = "";/g' {} \;

echo ""
echo "✅ Setup complete! Please open the project in Xcode and verify the changes."
echo "   You may need to update the signing settings in Xcode."
echo ""
echo "🔍 Next steps:"
echo "1. Review the README.md for additional setup instructions"
echo "2. Configure your Apple Developer account settings in Xcode"
echo "3. Set up required environmental variables (see .env.example files)"
echo ""

chmod +x "$0"