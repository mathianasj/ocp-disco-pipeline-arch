#!/bin/bash
# version-generator.sh - Generate version identifiers for mirror collections

set -euo pipefail

# Default values
TRIGGER_TYPE="${1:-manual}"
BASE_VERSION="${2:-}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Version Generator${NC}"
echo "================================"

# Get current date components
YEAR=$(date +%Y)
MONTH=$(date +%m)
DAY=$(date +%d)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Determine build number for today
# In production, this would query a ConfigMap or version registry
# For now, use a simple incrementing number based on existing files

BUILD_NUMBER=1

# Check if we can find existing versions from today
if [ -d "/workspace/packages" ]; then
  TODAY_PREFIX="v${YEAR}.${MONTH}.${DAY}"
  EXISTING_COUNT=$(find /workspace/packages -maxdepth 1 -name "${TODAY_PREFIX}.*" -type d 2>/dev/null | wc -l)
  BUILD_NUMBER=$((EXISTING_COUNT + 1))
fi

# Format build number with leading zeros
BUILD_NUM_FORMATTED=$(printf "%03d" "$BUILD_NUMBER")

# Construct version string
VERSION="v${YEAR}.${MONTH}.${DAY}.${BUILD_NUM_FORMATTED}-${TRIGGER_TYPE}"

echo "Generated Version Information:"
echo "  Version: $VERSION"
echo "  Timestamp: $TIMESTAMP"
echo "  Build Number: $BUILD_NUM_FORMATTED"
echo "  Trigger Type: $TRIGGER_TYPE"

if [ -n "$BASE_VERSION" ]; then
  echo "  Incremental From: $BASE_VERSION"
fi

echo "================================"

# Output for Tekton results (if running in pipeline)
if [ -n "${TEKTON_RESULTS_VERSION:-}" ]; then
  echo -n "$VERSION" | tee "$TEKTON_RESULTS_VERSION"
fi

if [ -n "${TEKTON_RESULTS_TIMESTAMP:-}" ]; then
  echo -n "$TIMESTAMP" | tee "$TEKTON_RESULTS_TIMESTAMP"
fi

if [ -n "${TEKTON_RESULTS_BUILD_NUMBER:-}" ]; then
  echo -n "$BUILD_NUM_FORMATTED" | tee "$TEKTON_RESULTS_BUILD_NUMBER"
fi

# Also output to stdout for direct usage
echo "$VERSION"
