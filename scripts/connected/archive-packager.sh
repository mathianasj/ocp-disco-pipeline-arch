#!/bin/bash
# archive-packager.sh - Package mirror artifacts into versioned archive

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Parameters
VERSION="${1:-}"
SOURCE_DIR="${2:-/workspace/source}"
DEST_DIR="${3:-/workspace/packages}"
COMPRESSION="${4:-gzip}"

if [ -z "$VERSION" ]; then
  echo -e "${RED}Error: VERSION required${NC}"
  echo "Usage: $0 <version> [source_dir] [dest_dir] [compression]"
  exit 1
fi

echo -e "${YELLOW}=========================================${NC}"
echo -e "${YELLOW}Archive Packaging${NC}"
echo -e "${YELLOW}=========================================${NC}"
echo "Version: $VERSION"
echo "Source: $SOURCE_DIR"
echo "Destination: $DEST_DIR"
echo "Compression: $COMPRESSION"
echo ""

# Create package directory structure
PACKAGE_NAME="mirror-$VERSION"
PACKAGE_DIR="$DEST_DIR/$PACKAGE_NAME"

mkdir -p "$PACKAGE_DIR"

echo -e "${GREEN}Created package directory: $PACKAGE_DIR${NC}"
echo ""

# Copy oc-mirror workspace
echo "Copying oc-mirror artifacts..."
if [ -d "$SOURCE_DIR/oc-mirror-workspace" ]; then
  mkdir -p "$PACKAGE_DIR/images"
  cp -r "$SOURCE_DIR/oc-mirror-workspace" "$PACKAGE_DIR/images/"
  echo -e "${GREEN}✓ oc-mirror artifacts copied${NC}"
else
  echo -e "${YELLOW}⚠ No oc-mirror workspace found${NC}"
fi

# Copy manifest if exists
echo "Copying manifest..."
if [ -f "$SOURCE_DIR/manifests/MANIFEST-$VERSION.yaml" ]; then
  cp "$SOURCE_DIR/manifests/MANIFEST-$VERSION.yaml" "$PACKAGE_DIR/MANIFEST.yaml"
  echo -e "${GREEN}✓ Manifest copied${NC}"
else
  echo -e "${YELLOW}⚠ Manifest not found${NC}"
fi

# Create VERSION file
echo "$VERSION" > "$PACKAGE_DIR/VERSION"
echo -e "${GREEN}✓ VERSION file created${NC}"

# Create README
cat > "$PACKAGE_DIR/README.txt" <<EOF
OpenShift Disconnected Mirror Package
=====================================

Version: $VERSION
Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")

This package contains a versioned collection of OpenShift artifacts
for import into a disconnected (air-gapped) environment.

Contents:
---------
- MANIFEST.yaml: Complete manifest of all artifacts
- VERSION: Version identifier
- CHECKSUMS.sha256: SHA256 checksums for verification
- images/: Container images from oc-mirror
- helm-charts/: Helm chart packages (if included)
- operators/: Operator catalogs and bundles (if included)
- artifacts/: Additional artifacts (binaries, configs)

Import Instructions:
-------------------
1. Verify checksums:
   cd $PACKAGE_NAME
   sha256sum -c CHECKSUMS.sha256

2. On disconnected cluster, trigger import pipeline

For detailed instructions, see the operations guide.
EOF

echo -e "${GREEN}✓ README created${NC}"

# Create directory structure
mkdir -p "$PACKAGE_DIR/helm-charts"
mkdir -p "$PACKAGE_DIR/operators"
mkdir -p "$PACKAGE_DIR/artifacts/binaries"
mkdir -p "$PACKAGE_DIR/artifacts/configs"
mkdir -p "$PACKAGE_DIR/import-scripts"

# Generate checksums
echo ""
echo "Generating checksums..."
cd "$PACKAGE_DIR"
find . -type f ! -name "CHECKSUMS.sha256" -exec sha256sum {} \; > CHECKSUMS.sha256
CHECKSUM_COUNT=$(wc -l < CHECKSUMS.sha256)
echo -e "${GREEN}✓ Generated checksums for $CHECKSUM_COUNT files${NC}"

# Create archive
echo ""
echo "Creating archive..."
cd "$DEST_DIR"

case "$COMPRESSION" in
  gzip)
    ARCHIVE_FILE="$PACKAGE_NAME.tar.gz"
    tar -czf "$ARCHIVE_FILE" "$PACKAGE_NAME/"
    ;;
  zstd)
    ARCHIVE_FILE="$PACKAGE_NAME.tar.zst"
    if command -v zstd &> /dev/null; then
      tar -cf - "$PACKAGE_NAME/" | zstd -19 -T0 -o "$ARCHIVE_FILE"
    else
      echo -e "${YELLOW}⚠ zstd not available, using gzip${NC}"
      ARCHIVE_FILE="$PACKAGE_NAME.tar.gz"
      tar -czf "$ARCHIVE_FILE" "$PACKAGE_NAME/"
    fi
    ;;
  none)
    ARCHIVE_FILE="$PACKAGE_NAME.tar"
    tar -cf "$ARCHIVE_FILE" "$PACKAGE_NAME/"
    ;;
  *)
    echo -e "${RED}Error: Unknown compression: $COMPRESSION${NC}"
    exit 1
    ;;
esac

echo -e "${GREEN}✓ Archive created: $ARCHIVE_FILE${NC}"

# Calculate metadata
ARCHIVE_SIZE=$(du -h "$ARCHIVE_FILE" | cut -f1)
ARCHIVE_CHECKSUM=$(sha256sum "$ARCHIVE_FILE" | cut -d' ' -f1)

# Create archive checksum file
echo "$ARCHIVE_CHECKSUM  $ARCHIVE_FILE" > "$ARCHIVE_FILE.sha256"

echo ""
echo -e "${YELLOW}=========================================${NC}"
echo -e "${YELLOW}Package Summary${NC}"
echo -e "${YELLOW}=========================================${NC}"
echo "Version: $VERSION"
echo "Archive: $ARCHIVE_FILE"
echo "Size: $ARCHIVE_SIZE"
echo "SHA256: $ARCHIVE_CHECKSUM"
echo "Location: $DEST_DIR/"
echo ""
echo -e "${GREEN}✓ Package ready for transfer${NC}"
echo -e "${YELLOW}=========================================${NC}"
