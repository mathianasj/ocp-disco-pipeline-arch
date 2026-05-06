# Disconnected OpenShift Mirror Pipeline - Project Documentation

## Project Overview

This repository contains a **reference architecture for disconnected OpenShift deployments** using OpenShift Pipelines (Tekton) to automate artifact synchronization to air-gapped clusters via physical media transport.

## Purpose

Enable fully automated artifact flows from internet-connected OpenShift clusters to air-gapped (disconnected) OpenShift clusters. The solution handles:
- Container images (OpenShift platform, operators, applications)
- Helm charts
- Operator bundles and catalogs
- Generic artifacts (binaries, configurations, documentation)

## Architecture

### Three-Zone Model

1. **Connected Cluster (Internet Access)**
   - Collects artifacts from Red Hat CDN and registries
   - Uses oc-mirror for image/operator mirroring
   - Packages artifacts into versioned archives
   - Stores archives on PVC for physical media transfer

2. **Physical Media Transport**
   - Encrypted USB drives or approved media
   - Chain of custody tracking
   - Checksum verification at both ends

3. **Disconnected Cluster (Air-Gapped)**
   - Imports artifacts from physical media
   - Populates local mirror registry
   - Validates imports
   - Tracks imported versions

### Technology Stack

- **OpenShift Pipelines (Tekton)**: Pipeline orchestration
- **oc-mirror**: Primary tool for OpenShift/operator mirroring
- **Red Hat Quay**: Mirror registry (both clusters)
- **Bash/Shell**: Helper scripts and utilities

## Current Status

**Phase 1 - Foundation: COMPLETE**

Implemented:
- ✅ Complete directory structure
- ✅ ImageSetConfiguration for oc-mirror
- ✅ Manifest templates with version schema
- ✅ Tekton tasks: version-tag, oc-mirror-collect, generate-manifest, checksum-verify, package-archive
- ✅ Main collection pipeline
- ✅ PVC manifests for storage
- ✅ RBAC (ServiceAccount, Role, RoleBinding)
- ✅ Helper scripts (checksum-tools, version-generator, archive-packager)
- ✅ Operator subscriptions (Pipelines, Quay)
- ✅ Comprehensive README

## Implementation Phases

### Phase 1: Foundation (COMPLETE)
Basic collection pipeline for OpenShift images with manual execution.

### Phase 2: Comprehensive Artifacts (Weeks 3-4)
- Add Helm chart collection
- Extend operator mirroring
- Generic artifact collection
- Import pipeline for disconnected cluster
- End-to-end testing

### Phase 3: Automation & Monitoring (Weeks 5-6)
- Scheduled pipeline execution (CronJobs)
- Red Hat release monitoring
- Event-driven triggers (Tekton Triggers)
- Notifications
- Monitoring dashboard

### Phase 4: Optimization & Hardening (Weeks 7-8)
- Incremental mirroring
- Compression optimization
- Comprehensive test suite
- Rollback capability
- Security hardening
- Complete documentation

## Key Files and Locations

### Configuration
- `config/connected/imageset-config.yaml` - oc-mirror configuration
- `config/common/version-schema.json` - Version identifier schema
- `templates/manifest-template.yaml` - Artifact manifest template

### Pipelines
- `pipelines/connected/base/pipeline.yaml` - Main collection pipeline
- `pipelines/connected/tasks/` - Individual Tekton tasks
- `pipelines/connected/base/pipelineruns/manual-run.yaml` - Manual execution

### Infrastructure
- `manifests/storage/` - PVC definitions
- `manifests/rbac/` - ServiceAccounts, Roles, RoleBindings
- `manifests/operators/` - Operator subscriptions

### Scripts
- `scripts/common/checksum-tools.sh` - Checksum utilities
- `scripts/connected/version-generator.sh` - Version ID generation
- `scripts/connected/archive-packager.sh` - Archive creation

## Version Format

```
v{YYYY.MM.DD}.{BUILD_NUMBER}-{TRIGGER_TYPE}
```

Examples:
- `v2026.05.06.001-manual`
- `v2026.05.06.002-scheduled`
- `v2026.05.13.001-event`

## Deployment Prerequisites

### Connected Cluster
- OpenShift 4.12+ (4.15+ recommended)
- Cluster-admin access
- 500GB+ storage
- Internet connectivity
- Red Hat pull secret

### Disconnected Cluster
- OpenShift 4.12+ (matching connected version)
- Cluster-admin access
- 300GB+ storage
- No internet connectivity

### Required Operators
- OpenShift Pipelines Operator
- Quay Operator (or existing Quay deployment)

### Required Tools
- `oc` CLI (matching cluster version)
- `oc-mirror` v1.0+
- `helm` v3.0+

## Quick Start

1. **Install operators on connected cluster:**
   ```bash
   oc apply -f manifests/operators/openshift-pipelines/subscription.yaml
   oc apply -f manifests/operators/quay-operator/subscription.yaml
   ```

2. **Set up storage and RBAC:**
   ```bash
   oc new-project mirror-pipeline
   oc apply -f manifests/storage/ -n mirror-pipeline
   oc apply -f manifests/rbac/ -n mirror-pipeline
   ```

3. **Configure ImageSetConfiguration:**
   - Edit `config/connected/imageset-config.yaml`
   - Update `<REGISTRY_URL>` with your mirror registry

4. **Deploy pipeline:**
   ```bash
   oc apply -f pipelines/connected/tasks/ -n mirror-pipeline
   oc apply -f pipelines/connected/base/pipeline.yaml -n mirror-pipeline
   ```

5. **Run collection:**
   ```bash
   oc create -f pipelines/connected/base/pipelineruns/manual-run.yaml -n mirror-pipeline
   ```

## Design Decisions

### Manifest-Based Version Tracking
YAML manifests provide human-readable, diff-friendly version tracking. Each collection generates an immutable manifest with complete metadata.

### Tarball Archive Format
Compressed tarballs offer maximum flexibility for physical media transport, easy splitting for size constraints, and standard tooling.

### Hybrid Mirroring Strategy
- **Full mirrors** (monthly): Complete, self-contained artifact sets
- **Incremental mirrors** (weekly): Delta updates, 60%+ size reduction

### Semi-Automated Import
Manual trigger on disconnected side ensures security compliance while automating validation and import execution.

## Testing and Validation

### Phase 1 Validation
```bash
# Trigger collection
oc create -f pipelines/connected/base/pipelineruns/manual-run.yaml -n mirror-pipeline

# Monitor execution
oc get pipelinerun -n mirror-pipeline -w

# Verify archive
oc exec -n mirror-pipeline <pod> -- ls -lh /workspace/packages/
```

## Troubleshooting

### Common Issues

**Pipeline fails with storage error:**
- Check PVC is bound: `oc get pvc -n mirror-pipeline`
- Verify storage class exists and has capacity

**oc-mirror task fails:**
- Verify Red Hat pull secret is configured
- Check imageset-config.yaml is valid
- Review oc-mirror.log in workspace

**Archive creation hangs:**
- Large archives take time (expected)
- Check storage space available
- Monitor pod resource usage

## Future Enhancements

Post-Phase 4:
- Web UI for pipeline management
- Multi-cluster support
- Differential analysis dashboard
- Integration with change management systems
- Support for additional artifact types (RPMs, ISOs)

## Contributing

This is a reference architecture. Customize for your environment:
- Adjust ImageSetConfiguration for required images
- Modify storage sizes
- Configure schedules for your update cadence
- Add custom artifact collection tasks

## Documentation

- `README.md` - Project overview and quickstart
- `docs/architecture.md` - Detailed architecture (to be created)
- `docs/operations-guide.md` - Day-2 operations (to be created)
- `docs/troubleshooting.md` - Common issues (to be created)

## Support and References

- [OpenShift Disconnected Installation](https://docs.openshift.com/container-platform/latest/installing/disconnected_install/)
- [oc-mirror Documentation](https://docs.openshift.com/container-platform/latest/installing/disconnected_install/installing-mirroring-installation-images.html)
- [OpenShift Pipelines](https://docs.openshift.com/container-platform/latest/cicd/pipelines/understanding-openshift-pipelines.html)
- [Red Hat Quay](https://docs.redhat.com/en/documentation/red_hat_quay)
