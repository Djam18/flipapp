#!/usr/bin/env bash
# ==============================================================================
# Flip to Focus - Local Pre-Flight & CI Verification Script
# ==============================================================================
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== [1/4] Running Code Formatter Check ===${NC}"
dart format --output=none --set-exit-if-changed .
echo -e "${GREEN}✓ Code formatting conforms to style guidelines.${NC}\n"

echo -e "${BLUE}=== [2/4] Resolving Flutter Dependencies ===${NC}"
flutter pub get
echo -e "${GREEN}✓ Dependencies up to date.${NC}\n"

echo -e "${BLUE}=== [3/4] Running Flutter Static Analyzer ===${NC}"
flutter analyze
echo -e "${GREEN}✓ Zero static analysis errors or warnings.${NC}\n"

echo -e "${BLUE}=== [4/4] Executing Automated Test Suite ===${NC}"
flutter test --coverage
echo -e "${GREEN}✓ All tests passed successfully with coverage.${NC}\n"

echo -e "${GREEN}====================================================================${NC}"
echo -e "${GREEN}  ALL GATES PASSED: Workspace is clean, compliant, and ready to ship! ${NC}"
echo -e "${GREEN}====================================================================${NC}"
