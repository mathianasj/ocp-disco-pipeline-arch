#!/bin/bash
# bootstrap-import.sh - Import mirrored content to bastion registry for fresh OpenShift install

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
ARCHIVE_PATH="${1:-}"
BASTION_REGISTRY="${2:-$(hostname -f):8443}"
REGISTRY_USER="${3:-admin}"
REGISTRY_PASSWORD="${4:-}"

usage() {
  cat <<EOF
Bootstrap Import Script
=======================
Imports mirror archive to bastion registry for fresh OpenShift installation.

Usage: $0 <archive_path> [registry_url] [registry_user] [registry_password]

Arguments:
  archive_path       Path to mirror archive (e.g., mirror-v2026.05.06.001.tar.gz)
  registry_url       Bastion registry URL (default: $(hostname -f):8443)
  registry_user      Registry username (default: admin)
  registry_password  Registry password (default: prompt)

Example:
  $0 /mnt/usb/mirror-v2026.05.06.001-scheduled.tar.gz

Prerequisites:
  - mirror-registry installed on bastion
  - Sufficient storage space
  - oc-mirror binary in PATH
  - Registry credentials configured

EOF
}

if [ -z "$ARCHIVE_PATH" ]; then
  echo -e "${RED}Error: Archive path required${NC}"
  usage
  exit 1
fi

if [ ! -f "$ARCHIVE_PATH" ]; then
  echo -e "${RED}Error: Archive not found: $ARCHIVE_PATH${NC}"
  exit 1
fi

# Prompt for password if not provided
if [ -z "$REGISTRY_PASSWORD" ]; then
  echo -n "Registry password: "
  read -s REGISTRY_PASSWORD
  echo ""
fi

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}Bootstrap Import to Bastion Registry${NC}"
echo -e "${BLUE}=========================================${NC}"
echo "Archive: $ARCHIVE_PATH"
echo "Registry: $BASTION_REGISTRY"
echo "User: $REGISTRY_USER"
echo ""

# Step 1: Extract archive
echo -e "${YELLOW}Step 1: Extracting archive...${NC}"
WORK_DIR="/tmp/mirror-import-$$"
mkdir -p "$WORK_DIR"

ARCHIVE_NAME=$(basename "$ARCHIVE_PATH" .tar.gz)
tar -xzf "$ARCHIVE_PATH" -C "$WORK_DIR"

if [ ! -d "$WORK_DIR/$ARCHIVE_NAME" ]; then
  echo -e "${RED}Error: Archive extraction failed${NC}"
  exit 1
fi

echo -e "${GREEN}✓ Archive extracted to $WORK_DIR/$ARCHIVE_NAME${NC}"

# Step 2: Verify checksums
echo ""
echo -e "${YELLOW}Step 2: Verifying checksums...${NC}"
cd "$WORK_DIR/$ARCHIVE_NAME"

if [ -f "CHECKSUMS.sha256" ]; then
  if sha256sum -c CHECKSUMS.sha256 > /dev/null 2>&1; then
    echo -e "${GREEN}✓ All checksums verified${NC}"
  else
    echo -e "${RED}✗ Checksum verification failed${NC}"
    echo "Continuing anyway (use at your own risk)..."
  fi
else
  echo -e "${YELLOW}⚠ No checksum file found${NC}"
fi

# Step 3: Configure authentication
echo ""
echo -e "${YELLOW}Step 3: Configuring registry authentication...${NC}"

export DOCKER_CONFIG="$WORK_DIR/.docker"
mkdir -p "$DOCKER_CONFIG"

# Create auth config
AUTH_ENCODED=$(echo -n "$REGISTRY_USER:$REGISTRY_PASSWORD" | base64 -w0)

cat > "$DOCKER_CONFIG/config.json" <<EOF
{
  "auths": {
    "$BASTION_REGISTRY": {
      "auth": "$AUTH_ENCODED"
    }
  }
}
EOF

echo -e "${GREEN}✓ Authentication configured${NC}"

# Step 4: Check registry connectivity
echo ""
echo -e "${YELLOW}Step 4: Testing registry connectivity...${NC}"

if curl -k -u "$REGISTRY_USER:$REGISTRY_PASSWORD" \
  "https://$BASTION_REGISTRY/health/instance" > /dev/null 2>&1; then
  echo -e "${GREEN}✓ Registry is accessible${NC}"
else
  echo -e "${RED}✗ Cannot connect to registry${NC}"
  echo "Verify:"
  echo "  - Registry is running: systemctl status quay-app"
  echo "  - Firewall allows port 8443: firewall-cmd --list-ports"
  echo "  - DNS resolves: nslookup $(hostname -f)"
  exit 1
fi

# Step 5: Import with oc-mirror
echo ""
echo -e "${YELLOW}Step 5: Importing images to registry...${NC}"
echo "This will take 1-4 hours depending on content size..."
echo ""

if [ -d "images/oc-mirror-workspace" ]; then
  cd images/oc-mirror-workspace

  # Find the mirror directory
  if [ -d "mirror_seq1_000000.tar" ] || [ -d "mirror" ]; then
    echo "Found oc-mirror workspace"

    # Import to registry
    echo "Starting oc-mirror import..."

    if oc-mirror --from file://./mirror \
      docker://$BASTION_REGISTRY 2>&1 | tee "$WORK_DIR/import.log"; then
      echo ""
      echo -e "${GREEN}✓ Import completed successfully${NC}"
    else
      echo ""
      echo -e "${RED}✗ Import failed${NC}"
      echo "Check logs: $WORK_DIR/import.log"
      exit 1
    fi
  else
    echo -e "${RED}Error: oc-mirror workspace not found in expected format${NC}"
    exit 1
  fi
else
  echo -e "${RED}Error: No images directory found in archive${NC}"
  exit 1
fi

# Step 6: Verify import
echo ""
echo -e "${YELLOW}Step 6: Verifying imported images...${NC}"

# Query registry for OpenShift images
if curl -k -u "$REGISTRY_USER:$REGISTRY_PASSWORD" \
  "https://$BASTION_REGISTRY/api/v1/repository?namespace=openshift4" 2>/dev/null | grep -q "openshift4"; then
  echo -e "${GREEN}✓ OpenShift images found in registry${NC}"
else
  echo -e "${YELLOW}⚠ Could not verify OpenShift images${NC}"
fi

# Step 7: Generate installation notes
echo ""
echo -e "${YELLOW}Step 7: Generating installation notes...${NC}"

cat > "$WORK_DIR/INSTALLATION_NOTES.txt" <<EOF
OpenShift Bootstrap Installation - Next Steps
==============================================

Archive: $ARCHIVE_NAME
Registry: $BASTION_REGISTRY
Imported: $(date)

NEXT STEPS:

1. Extract installation binaries:
   cd $WORK_DIR/$ARCHIVE_NAME/artifacts/binaries
   tar -xzf openshift-install-linux-*.tar.gz
   tar -xzf openshift-client-linux-*.tar.gz
   sudo mv openshift-install oc kubectl /usr/local/bin/

2. Create install-config.yaml with these settings:

   additionalTrustBundle: |
$(cat /etc/pki/ca-trust/source/anchors/quay-ca.crt 2>/dev/null | sed 's/^/     /' || echo '     <REGISTRY_CA_CERT>')

   imageContentSources:
$(cat $WORK_DIR/$ARCHIVE_NAME/images/oc-mirror-workspace/results-*/imageContentSourcePolicy.yaml 2>/dev/null | grep -A 10 "repositoryDigestMirrors:" | sed 's/^/   /' || echo '   # See imageContentSourcePolicy in archive')

3. Generate ignition configs:
   openshift-install create ignition-configs --dir=/opt/openshift-install

4. Boot cluster nodes with ignition configs

5. Monitor installation:
   openshift-install wait-for bootstrap-complete --dir=/opt/openshift-install
   openshift-install wait-for install-complete --dir=/opt/openshift-install

For detailed instructions, see:
  $WORK_DIR/$ARCHIVE_NAME/artifacts/docs/bootstrap-installation.md

Registry Details:
  URL: https://$BASTION_REGISTRY
  Username: $REGISTRY_USER
  CA Certificate: /etc/pki/ca-trust/source/anchors/quay-ca.crt

Workspace:
  Working directory: $WORK_DIR
  Import log: $WORK_DIR/import.log
  Archive extracted: $WORK_DIR/$ARCHIVE_NAME

EOF

cat "$WORK_DIR/INSTALLATION_NOTES.txt"

echo ""
echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}Bootstrap Import Complete!${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""
echo "Next steps:"
echo "  1. Review: $WORK_DIR/INSTALLATION_NOTES.txt"
echo "  2. Extract binaries and create install-config.yaml"
echo "  3. Install OpenShift cluster"
echo ""
echo "Detailed guide: $WORK_DIR/$ARCHIVE_NAME/artifacts/docs/bootstrap-installation.md"
echo ""
