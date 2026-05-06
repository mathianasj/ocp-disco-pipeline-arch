# Bootstrap Installation - Quick Start

## Overview

Use this guide for **installing a brand new OpenShift cluster** in a disconnected environment when no cluster exists yet.

## The Challenge

You can't install OpenShift without pulling images from a registry, but you don't have a registry until the cluster is running. The solution: **external mirror registry on a bastion node**.

## Architecture

```
[Archive] → [Bastion] → [Mirror Registry] → [Install OCP] → [New Cluster]
```

## Prerequisites

### Bastion/Helper Node
- **OS**: RHEL 8.6+ or RHEL 9.0+
- **Storage**: 500GB+
- **RAM**: 16GB+
- **CPU**: 4+ cores
- **Network**: Can reach future cluster nodes

### Mirror Archive
- Generated from connected environment
- Transferred via physical media
- Contains all images + bootstrap tools

## 5-Minute Workflow

### Step 1: Setup Bastion Registry (30 min)

```bash
# 1.1: Copy archive to bastion
cp /mnt/usb/mirror-v2026.05.06.001-scheduled.tar.gz /opt/
cd /opt
tar -xzf mirror-v2026.05.06.001-scheduled.tar.gz
cd mirror-v2026.05.06.001-scheduled

# 1.2: Verify checksums
sha256sum -c CHECKSUMS.sha256

# 1.3: Install mirror-registry
cd artifacts/binaries
tar -xzf mirror-registry.tar.gz
./mirror-registry install \
  --quayHostname $(hostname -f) \
  --quayRoot /opt/quay-install \
  --initPassword changeme123 \
  --initUser admin

# Save the pull secret and credentials!

# 1.4: Trust certificate
sudo cp /opt/quay-install/quay-rootCA/rootCA.pem \
  /etc/pki/ca-trust/source/anchors/quay-ca.crt
sudo update-ca-trust extract

# 1.5: Open firewall
sudo firewall-cmd --permanent --add-port=8443/tcp
sudo firewall-cmd --reload
```

### Step 2: Import Content to Registry (1-4 hours)

```bash
# Use the automated bootstrap import script
cd /opt/mirror-v2026.05.06.001-scheduled
./import-scripts/bootstrap-import.sh \
  /opt/mirror-v2026.05.06.001-scheduled.tar.gz \
  $(hostname -f):8443 \
  admin \
  changeme123

# This imports all images to the bastion registry
```

### Step 3: Prepare OpenShift Installer (10 min)

```bash
# 3.1: Extract installer binary
cd /opt/mirror-v2026.05.06.001-scheduled/artifacts/binaries
tar -xzf openshift-install-linux-*.tar.gz
tar -xzf openshift-client-linux-*.tar.gz
sudo mv openshift-install oc kubectl /usr/local/bin/
chmod +x /usr/local/bin/openshift-install /usr/local/bin/oc

# 3.2: Create install directory
mkdir -p /opt/openshift-install
cd /opt/openshift-install
```

### Step 4: Create install-config.yaml (15 min)

```bash
cat > install-config.yaml <<EOF
apiVersion: v1
baseDomain: example.com
metadata:
  name: ocp-prod
networking:
  networkType: OVNKubernetes
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  serviceNetwork:
  - 172.30.0.0/16
compute:
- name: worker
  replicas: 3
controlPlane:
  name: master
  replicas: 3
platform:
  # Your platform (vsphere, baremetal, etc.)
  none: {}
pullSecret: '$(cat /opt/quay-install/quay-pull-secret.json | jq -c .)'
sshKey: '$(cat ~/.ssh/id_rsa.pub)'
additionalTrustBundle: |
$(cat /etc/pki/ca-trust/source/anchors/quay-ca.crt | sed 's/^/  /')
imageContentSources:
- mirrors:
  - $(hostname -f):8443/openshift/release
  source: quay.io/openshift-release-dev/ocp-v4.0-art-dev
- mirrors:
  - $(hostname -f):8443/openshift/release-images
  source: quay.io/openshift-release-dev/ocp-release
EOF
```

**Critical**: Verify `imageContentSources` matches your archive. Check:
```bash
cat /opt/mirror-v2026.05.06.001-scheduled/images/oc-mirror-workspace/results-*/imageContentSourcePolicy.yaml
```

### Step 5: Install OpenShift (45-90 min)

```bash
cd /opt/openshift-install

# Backup config (it gets consumed)
cp install-config.yaml install-config.yaml.backup

# Generate ignition configs
openshift-install create ignition-configs --dir=.

# This creates:
# - bootstrap.ign
# - master.ign
# - worker.ign

# Boot your cluster nodes with these ignition configs
# (Method depends on your platform: bare metal, vSphere, etc.)

# Monitor bootstrap
openshift-install wait-for bootstrap-complete --dir=. --log-level=info

# After bootstrap complete, remove bootstrap node
# Then wait for install complete
openshift-install wait-for install-complete --dir=. --log-level=info
```

### Step 6: Access Cluster

```bash
# Set kubeconfig
export KUBECONFIG=/opt/openshift-install/auth/kubeconfig

# Verify
oc get nodes
oc get co  # All should be Available

# Get console URL
oc whoami --show-console

# Get admin password
cat /opt/openshift-install/auth/kubeadmin-password
```

## Key Differences from Connected Install

| Aspect | Connected Install | Disconnected (Bootstrap) Install |
|--------|-------------------|----------------------------------|
| **Registry** | pull from quay.io | pull from bastion:8443 |
| **Pull Secret** | Red Hat pull secret | Bastion registry credentials |
| **Certificate Trust** | Public CAs | Bastion CA in additionalTrustBundle |
| **imageContentSources** | Not needed | **Required** - redirects to bastion |
| **Preparation** | Minimal | Extract archive, setup registry |
| **Prerequisites** | Internet access | Bastion node + archive |

## Troubleshooting

### Can't pull images
```bash
# Verify registry accessible
curl -k https://$(hostname -f):8443/health/instance

# Check firewall
sudo firewall-cmd --list-ports | grep 8443

# Verify DNS
nslookup $(hostname -f)
```

### Certificate errors
```bash
# Verify cert in install-config.yaml additionalTrustBundle
# Verify cert in /etc/pki/ca-trust
# Re-run: sudo update-ca-trust extract
```

### Images not found in registry
```bash
# Check images exist
curl -k -u admin:password \
  https://$(hostname -f):8443/api/v1/repository?namespace=openshift4

# Verify bootstrap-import.sh completed successfully
# Re-run import if needed
```

## After Installation

### Install Operators
```bash
# Operators are available from mirrored catalogs
oc get packagemanifests

# Install via OperatorHub UI or YAML as normal
```

### Set Up Update Pipeline (Optional)
```bash
# Install Pipelines operator from mirror
# Deploy import pipeline for future updates
# See main README for update procedures
```

### Move Registry to Cluster (Optional)
```bash
# Install Quay operator on cluster
# Migrate content from bastion to in-cluster Quay
# Update ImageContentSourcePolicy
# See full bootstrap-installation.md for details
```

## Complete Guide

For full details, troubleshooting, and advanced scenarios:
**[docs/bootstrap-installation.md](bootstrap-installation.md)**

## Quick Commands Reference

```bash
# Install mirror-registry on bastion
./mirror-registry install --quayHostname $(hostname -f)

# Import archive to bastion registry
./bootstrap-import.sh /path/to/archive.tar.gz

# Extract installer
tar -xzf openshift-install-linux-*.tar.gz

# Create install config
vim install-config.yaml  # Use template above

# Install cluster
openshift-install create ignition-configs
# Boot nodes with ignition
openshift-install wait-for bootstrap-complete
openshift-install wait-for install-complete

# Access cluster
export KUBECONFIG=auth/kubeconfig
oc get nodes
```

## Success Criteria

✅ Bastion registry running and accessible  
✅ All images imported to bastion registry  
✅ install-config.yaml has correct imageContentSources  
✅ Cluster nodes can reach bastion registry  
✅ Ignition configs generated  
✅ Bootstrap completes successfully  
✅ All cluster operators Available  
✅ Worker nodes join cluster  

## What's in the Archive

- ✅ All OpenShift platform images
- ✅ Operator catalogs and bundles
- ✅ openshift-install binary
- ✅ oc/kubectl CLI tools
- ✅ oc-mirror binary
- ✅ mirror-registry installer
- ✅ Helm CLI
- ✅ bootstrap-import.sh script
- ✅ Complete documentation

Everything you need for a fresh install in one archive!
