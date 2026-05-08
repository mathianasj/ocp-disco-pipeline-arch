# Configuration Examples

This directory contains **example configurations** that were generated using [OpenShift Airgap Architect](https://github.com/bstrauss84/openshift-airgap-architect/).

## ⚠️ Important: Do Not Use Static Configurations

**These are examples only.** Do not copy these files directly into production use.

Instead, you should:
1. Deploy OpenShift Airgap Architect
2. Use the wizard to generate configurations tailored to your environment
3. Use those generated configurations with this pipeline

## How to Generate Your Own Configurations

### Option 1: Run Airgap-Architect Locally (Development)

```bash
# Clone the repository
git clone https://github.com/bstrauss84/openshift-airgap-architect.git
cd openshift-airgap-architect

# Run with Docker Compose
docker-compose up -d

# Access the UI
open http://localhost:3000
```

### Option 2: Run Airgap-Architect in OpenShift (Recommended)

```bash
# Create namespace
oc new-project airgap-architect

# Deploy (adjust image registry as needed)
oc apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: airgap-architect
  namespace: airgap-architect
spec:
  replicas: 1
  selector:
    matchLabels:
      app: airgap-architect
  template:
    metadata:
      labels:
        app: airgap-architect
    spec:
      containers:
      - name: airgap-architect
        image: quay.io/bstrauss/openshift-airgap-architect:latest
        ports:
        - containerPort: 3000
---
apiVersion: v1
kind: Service
metadata:
  name: airgap-architect
  namespace: airgap-architect
spec:
  selector:
    app: airgap-architect
  ports:
  - port: 3000
    targetPort: 3000
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: airgap-architect
  namespace: airgap-architect
spec:
  to:
    kind: Service
    name: airgap-architect
  tls:
    termination: edge
    insecureEdgeTerminationPolicy: Redirect
EOF

# Get the URL
oc get route -n airgap-architect airgap-architect -o jsonpath='{.spec.host}'
```

### Option 3: Use Container Directly

```bash
# Run standalone container
podman run -d \
  --name airgap-architect \
  -p 3000:3000 \
  quay.io/bstrauss/openshift-airgap-architect:latest

# Access the UI
open http://localhost:3000
```

## Using the Wizard

### 1. Generate ImageSetConfiguration

1. Open Airgap-Architect UI
2. Select your scenario (e.g., "vSphere IPI")
3. Configure OpenShift version and channels
4. Select operators to mirror:
   - OpenShift Pipelines
   - Quay Operator
   - Any operators your environment needs
5. Add additional images (UBI, tooling, etc.)
6. **Download** `imageset-config.yaml`

### 2. Save Configuration for Pipeline Use

Place the generated `imageset-config.yaml` in one of these locations:

**Option A: Directly in this repository**
```bash
cp ~/Downloads/imageset-config.yaml \
  /path/to/disconnected-mirror-pipeline/config/connected/imageset-config.yaml
```

**Option B: ConfigMap (for production)**
```bash
oc create configmap imageset-config \
  --from-file=imageset-config.yaml=~/Downloads/imageset-config.yaml \
  -n mirror-pipeline
```

Then reference in PipelineRun:
```yaml
workspaces:
  - name: config
    configMap:
      name: imageset-config
```

**Option C: GitOps Repository (recommended)**
```bash
# Clone your GitOps repo
git clone https://github.com/yourorg/disconnected-configs.git
cd disconnected-configs

# Add configuration
cp ~/Downloads/imageset-config.yaml collections/base/imageset-config.yaml

# Commit and push
git add collections/base/imageset-config.yaml
git commit -m "Update imageset configuration for OCP 4.15.12"
git push

# ArgoCD will sync automatically
```

## Example Configurations in This Directory

### 1. `imageset-config-minimal.yaml`
- **Purpose:** Minimal configuration for testing
- **Contains:** Single OpenShift version, essential operators only
- **Use Case:** Development, CI/CD testing, proof-of-concept
- **Size:** ~50GB mirrored content

### 2. `imageset-config-production.yaml`
- **Purpose:** Production-ready configuration
- **Contains:** Multiple OpenShift versions, full operator set, additionalImages
- **Use Case:** Production disconnected clusters
- **Size:** ~300GB mirrored content

### 3. `imageset-config-vsphere.yaml`
- **Purpose:** vSphere-specific configuration
- **Contains:** vSphere-optimized images, CSI drivers, vSphere operators
- **Use Case:** vSphere IPI/UPI deployments
- **Size:** ~200GB mirrored content

### 4. `imageset-config-govcloud.yaml`
- **Purpose:** AWS GovCloud configuration
- **Contains:** AWS-specific operators, compliance-focused images
- **Use Case:** Government cloud deployments
- **Size:** ~250GB mirrored content

## Validating Your Configuration

After generating a configuration, validate it before running a collection:

```bash
# Install oc-mirror if not already installed
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/oc-mirror.tar.gz
tar -xzf oc-mirror.tar.gz
chmod +x oc-mirror
sudo mv oc-mirror /usr/local/bin/

# Dry-run validation
oc-mirror --config imageset-config.yaml \
  --dry-run \
  file://./test-mirror

# Check output for errors
```

## Testing with the Pipeline

Once you have a generated configuration:

```bash
# 1. Place config in repository or ConfigMap (see above)

# 2. Update the PipelineRun to reference it
# Edit: pipelines/connected/base/pipelineruns/manual-run.yaml

# 3. Create the PipelineRun
oc create -f pipelines/connected/base/pipelineruns/manual-run.yaml -n mirror-pipeline

# 4. Monitor
oc get pipelinerun -n mirror-pipeline -w
```

## Configuration Best Practices

### 1. Version Pinning
- **Do:** Pin specific OpenShift versions (e.g., `minVersion: 4.15.12`)
- **Don't:** Use `maxVersion: 4.15.99` in production (creates huge mirrors)

### 2. Operator Selection
- **Do:** Use `full: false` and specify individual packages
- **Don't:** Use `full: true` for entire catalogs (mirrors everything)

### 3. Additional Images
- **Do:** Use specific tags (e.g., `ubi9:9.2-489`)
- **Don't:** Use `:latest` tag (non-reproducible)

### 4. Archive Size
- **Do:** Set `archiveSize: 4` (4GB chunks for USB drives)
- **Adjust:** Based on your physical media size constraints

### 5. Incremental Updates
- **Do:** Reuse the same ImageSetConfiguration for incremental mirrors
- **Don't:** Change fundamental structure between full/incremental runs

## Troubleshooting

### "Operator not found" errors
- Run operator discovery in airgap-architect
- Requires `oc-mirror list operators` with registry.redhat.io authentication
- Ensure your pull secret is configured

### Configuration validation errors
- Use airgap-architect's built-in validation
- Check YAML syntax with `yamllint`
- Verify channel names match official OpenShift channels

### Mirror size larger than expected
- Review `maxVersion` settings (too broad?)
- Check if `full: true` is set for operator catalogs
- Use `shortestPath: true` for platform channels

## Additional Resources

- [OpenShift Airgap Architect Documentation](https://github.com/bstrauss84/openshift-airgap-architect/blob/main/README.md)
- [oc-mirror Documentation](https://docs.openshift.com/container-platform/latest/installing/disconnected_install/installing-mirroring-installation-images.html)
- [OpenShift Disconnected Install Guide](https://docs.openshift.com/container-platform/latest/installing/disconnected_install/)
- [ImageSetConfiguration API Reference](https://docs.openshift.com/container-platform/latest/installing/disconnected_install/installing-mirroring-creating-imageset.html)

## Support

For issues with:
- **Airgap-Architect:** https://github.com/bstrauss84/openshift-airgap-architect/issues
- **This Pipeline:** https://github.com/yourorg/disconnected-mirror-pipeline/issues
- **oc-mirror:** Red Hat Support

---

**Remember:** Always generate fresh configurations using Airgap-Architect. These examples are for reference only and may be outdated.
