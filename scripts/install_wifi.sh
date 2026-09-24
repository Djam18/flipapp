#!/usr/bin/env bash
# ==============================================================================
# Flip to Focus - Wireless ADB Helper (Install APK without USB Cable)
# ==============================================================================
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

if [ ! -f "$APK_PATH" ]; then
    echo -e "${YELLOW}Release APK not found. Building release APK first...${NC}"
    flutter build apk --release
fi

echo -e "${BLUE}====================================================================${NC}"
echo -e "${BLUE}        WIRELESS ADB DEPLOYMENT (NO CABLE REQUIRED)                 ${NC}"
echo -e "${BLUE}====================================================================${NC}"
echo "1. On your phone, go to: Settings -> Developer Options -> Wireless debugging"
echo "2. Tap 'Pair device with pairing code'"
echo "3. Note down the IP address, port, and 6-digit code shown on your phone."
echo ""

read -p "Enter Pairing IP:Port (e.g. 192.168.1.45:41235): " PAIR_IP
read -p "Enter 6-digit Pairing Code: " PAIR_CODE

echo -e "\n${BLUE}Pairing with device...${NC}"
adb pair "$PAIR_IP" "$PAIR_CODE"

read -p "Enter Connect IP:Port from phone main screen (e.g. 192.168.1.45:39485): " CONNECT_IP
echo -e "${BLUE}Connecting to device...${NC}"
adb connect "$CONNECT_IP"

echo -e "\n${BLUE}Installing Flip to Focus onto connected device...${NC}"
adb install -r "$APK_PATH"

echo -e "\n${GREEN}✓ Flip to Focus successfully installed on your phone over Wi-Fi!${NC}"
