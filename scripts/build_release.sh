#!/usr/bin/env bash
# ==============================================================================
# Flip to Focus - Release Artifact Generation Script
# ==============================================================================
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== Building Standalone Release APK ===${NC}"
flutter build apk --release

APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
if [ -f "$APK_PATH" ]; then
    APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
    echo -e "${GREEN}✓ Release APK built successfully!${NC}"
    echo -e "  Location: ${YELLOW}$APK_PATH${NC} (Size: $APK_SIZE)\n"
fi

echo -e "${BLUE}=== Building Android App Bundle (AAB for Google Play) ===${NC}"
flutter build appbundle --release

AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
if [ -f "$AAB_PATH" ]; then
    AAB_SIZE=$(du -h "$AAB_PATH" | cut -f1)
    echo -e "${GREEN}✓ Release AAB built successfully!${NC}"
    echo -e "  Location: ${YELLOW}$AAB_PATH${NC} (Size: $AAB_SIZE)\n"
fi

echo -e "${GREEN}====================================================================${NC}"
echo -e "${GREEN}  Artifacts generated and ready for direct testing or distribution! ${NC}"
echo -e "${GREEN}====================================================================${NC}"
