# API Specifications - Disconnected Platform Operator

**Version:** v1alpha1  
**Status:** Complete - Ready for Implementation  
**Target:** disconnected-platform-operator repository

## Overview

This document defines the Kubernetes Custom Resource Definitions (CRDs) for the Disconnected Platform Operator.

**API Group:** `disconnected.openshift.io`  
**Version:** `v1alpha1`

## Custom Resource Definitions

### 1. DisconnectedPlatform

**Purpose:** Top-level configuration for the disconnected platform deployment

**Scope:** Cluster-scoped (one per cluster)

**File:** `api/v1alpha1/disconnectedplatform_types.go`

#### Schema

```go
type DisconnectedPlatform struct {
    metav1.TypeMeta   `json:",inline"`
    metav1.ObjectMeta `json:"metadata,omitempty"`

    Spec   DisconnectedPlatformSpec   `json:"spec,omitempty"`
    Status DisconnectedPlatformStatus `json:"status,omitempty"`
}

type DisconnectedPlatformSpec struct {
    // Mode determines the operational mode
    // +kubebuilder:validation:Enum=connected;airgapped
    // +kubebuilder:validation:Required
    Mode PlatformMode `json:"mode"`

    // Connected cluster configuration
    // +optional
    Connected *ConnectedConfig `json:"connected,omitempty"`

    // Airgapped cluster configuration
    // +optional
    Airgapped *AirgappedConfig `json:"airgapped,omitempty"`

    // Airgap-Architect configuration
    // +optional
    AirgapArchitect *AirgapArchitectConfig `json:"airgapArchitect,omitempty"`

    // GitOps integration
    // +optional
    GitOps *GitOpsConfig `json:"gitOps,omitempty"`
}

type PlatformMode string

const (
    PlatformModeConnected  PlatformMode = "connected"
    PlatformModeAirgapped PlatformMode = "airgapped"
)

type ConnectedConfig struct {
    // Schedule for artifact collection (cron format)
    // +kubebuilder:validation:Required
    CollectionSchedule string `json:"collectionSchedule"`

    // Mirror registry URL
    // +kubebuilder:validation:Required
    MirrorRegistry string `json:"mirrorRegistry"`

    // Artifact storage configuration
    // +kubebuilder:validation:Required
    ArtifactStorage ArtifactStorageConfig `json:"artifactStorage"`

    // Trigger types enabled
    // +optional
    TriggerTypes []TriggerType `json:"triggerTypes,omitempty"`
}

type ArtifactStorageConfig struct {
    // Storage class for PVCs
    // +optional
    StorageClass string `json:"storageClass,omitempty"`

    // Size of storage (e.g., "2Ti")
    // +kubebuilder:validation:Required
    Size string `json:"size"`

    // Access mode
    // +kubebuilder:default=ReadWriteOnce
    AccessMode string `json:"accessMode,omitempty"`
}

type TriggerType string

const (
    TriggerTypeScheduled TriggerType = "scheduled"
    TriggerTypeManual    TriggerType = "manual"
    TriggerTypeEvent     TriggerType = "event"
)

type AirgappedConfig struct {
    // Whether this is a management cluster for bootstrapping
    // +kubebuilder:default=false
    ManagementCluster bool `json:"managementCluster"`

    // Mirror registry URL (internal)
    // +kubebuilder:validation:Required
    MirrorRegistry string `json:"mirrorRegistry"`

    // Enable cluster bootstrap functionality
    // +kubebuilder:default=false
    BootstrapEnabled bool `json:"bootstrapEnabled"`

    // Path for importing physical media
    // +optional
    ImportPath string `json:"importPath,omitempty"`

    // Registry credentials secret reference
    // +optional
    RegistryCredentials *SecretReference `json:"registryCredentials,omitempty"`
}

type AirgapArchitectConfig struct {
    // Enable airgap-architect UI
    // +kubebuilder:default=true
    Enabled bool `json:"enabled"`

    // Resource requirements for airgap-architect pod
    // +optional
    Resources *corev1.ResourceRequirements `json:"resources,omitempty"`

    // Route/Ingress configuration
    // +optional
    Route *RouteConfig `json:"route,omitempty"`
}

type RouteConfig struct {
    // Hostname for route
    // +optional
    Host string `json:"host,omitempty"`

    // TLS configuration
    // +optional
    TLS *RouteTLSConfig `json:"tls,omitempty"`
}

type RouteTLSConfig struct {
    // Termination type
    // +kubebuilder:validation:Enum=edge;passthrough;reencrypt
    Termination string `json:"termination"`

    // Certificate secret reference
    // +optional
    Certificate *SecretReference `json:"certificate,omitempty"`
}

type GitOpsConfig struct {
    // Enable GitOps integration
    // +kubebuilder:default=false
    Enabled bool `json:"enabled"`

    // Repository URL
    // +kubebuilder:validation:Required
    RepositoryURL string `json:"repositoryURL"`

    // Branch name
    // +kubebuilder:default=main
    Branch string `json:"branch,omitempty"`

    // Path within repository
    // +kubebuilder:default=collections
    Path string `json:"path,omitempty"`

    // Credentials secret reference
    // +optional
    Credentials *SecretReference `json:"credentials,omitempty"`
}

type SecretReference struct {
    // Name of the secret
    // +kubebuilder:validation:Required
    Name string `json:"name"`

    // Namespace of the secret
    // +optional
    Namespace string `json:"namespace,omitempty"`
}

type DisconnectedPlatformStatus struct {
    // Phase of the platform
    // +optional
    Phase PlatformPhase `json:"phase,omitempty"`

    // Conditions represent the latest available observations
    // +optional
    Conditions []metav1.Condition `json:"conditions,omitempty"`

    // Last collection information (connected mode)
    // +optional
    LastCollection *CollectionInfo `json:"lastCollection,omitempty"`

    // Last import information (airgapped mode)
    // +optional
    LastImport *ImportInfo `json:"lastImport,omitempty"`

    // Component status
    // +optional
    Components []ComponentStatus `json:"components,omitempty"`

    // Observed generation
    // +optional
    ObservedGeneration int64 `json:"observedGeneration,omitempty"`
}

type PlatformPhase string

const (
    PlatformPhaseReady      PlatformPhase = "Ready"
    PlatformPhaseCollecting PlatformPhase = "Collecting"
    PlatformPhaseImporting  PlatformPhase = "Importing"
    PlatformPhaseError      PlatformPhase = "Error"
    PlatformPhaseUnknown    PlatformPhase = "Unknown"
)

type CollectionInfo struct {
    // Version of the collection
    Version string `json:"version"`

    // Timestamp of collection
    Timestamp metav1.Time `json:"timestamp"`

    // Size of collected artifacts
    Size string `json:"size"`

    // Status of the collection
    Status string `json:"status"`
}

type ImportInfo struct {
    // Version imported
    Version string `json:"version"`

    // Timestamp of import
    Timestamp metav1.Time `json:"timestamp"`

    // Status of the import
    Status string `json:"status"`
}

type ComponentStatus struct {
    // Name of the component
    Name string `json:"name"`

    // Status of the component
    Status string `json:"status"`

    // URL if applicable (for web UIs)
    // +optional
    URL string `json:"url,omitempty"`

    // Last check timestamp
    // +optional
    LastCheck *metav1.Time `json:"lastCheck,omitempty"`
}
```

#### Example CR

```yaml
apiVersion: disconnected.openshift.io/v1alpha1
kind: DisconnectedPlatform
metadata:
  name: disconnected-platform
spec:
  mode: connected
  
  connected:
    collectionSchedule: "0 2 * * 0"  # Sunday 2am
    mirrorRegistry: quay.example.com/mirror
    artifactStorage:
      storageClass: gp3
      size: 2Ti
    triggerTypes:
      - scheduled
      - manual
  
  airgapArchitect:
    enabled: true
    route:
      host: airgap-architect.apps.example.com
      tls:
        termination: edge
  
  gitOps:
    enabled: true
    repositoryURL: https://github.com/org/disconnected-configs
    branch: main
    path: collections
    credentials:
      name: git-credentials
      namespace: disconnected-platform
```

---

### 2. ClusterBootstrap

**Purpose:** Define a cluster to be bootstrapped in airgapped environment

**Scope:** Namespaced

**File:** `api/v1alpha1/clusterbootstrap_types.go`

#### Schema

```go
type ClusterBootstrap struct {
    metav1.TypeMeta   `json:",inline"`
    metav1.ObjectMeta `json:"metadata,omitempty"`

    Spec   ClusterBootstrapSpec   `json:"spec,omitempty"`
    Status ClusterBootstrapStatus `json:"status,omitempty"`
}

type ClusterBootstrapSpec struct {
    // Version of artifacts to use for installation
    // +kubebuilder:validation:Required
    Version string `json:"version"`

    // Platform type
    // +kubebuilder:validation:Enum=vsphere;baremetal;aws-govcloud;azure-gov;nutanix
    // +kubebuilder:validation:Required
    Platform Platform `json:"platform"`

    // Install configuration secret reference
    // +kubebuilder:validation:Required
    InstallConfig SecretReference `json:"installConfig"`

    // Agent configuration for agent-based installs
    // +optional
    AgentConfig *SecretReference `json:"agentConfig,omitempty"`

    // Mirror registry configuration
    // +kubebuilder:validation:Required
    MirrorRegistry string `json:"mirrorRegistry"`

    // Pull secret for mirror registry
    // +kubebuilder:validation:Required
    PullSecret SecretReference `json:"pullSecret"`

    // Additional trust bundle for mirror registry
    // +optional
    TrustBundle *SecretReference `json:"trustBundle,omitempty"`

    // Network configuration
    // +optional
    Network *NetworkConfig `json:"network,omitempty"`

    // Control plane configuration
    // +optional
    ControlPlane *NodePoolConfig `json:"controlPlane,omitempty"`

    // Compute node configuration
    // +optional
    Compute *NodePoolConfig `json:"compute,omitempty"`

    // Post-install configurations to apply
    // +optional
    PostInstall *PostInstallConfig `json:"postInstall,omitempty"`
}

type Platform string

const (
    PlatformVSphere      Platform = "vsphere"
    PlatformBareMetal    Platform = "baremetal"
    PlatformAWSGovCloud  Platform = "aws-govcloud"
    PlatformAzureGov     Platform = "azure-gov"
    PlatformNutanix      Platform = "nutanix"
)

type NetworkConfig struct {
    // Cluster network CIDR
    ClusterNetwork string `json:"clusterNetwork,omitempty"`

    // Service network CIDR
    ServiceNetwork string `json:"serviceNetwork,omitempty"`

    // Network type
    // +kubebuilder:validation:Enum=OVNKubernetes;OpenShiftSDN
    // +kubebuilder:default=OVNKubernetes
    NetworkType string `json:"networkType,omitempty"`
}

type NodePoolConfig struct {
    // Number of replicas
    Replicas int32 `json:"replicas"`

    // Resource requirements
    // +optional
    Resources *NodeResources `json:"resources,omitempty"`
}

type NodeResources struct {
    // CPU cores
    CPU int32 `json:"cpu,omitempty"`

    // Memory in GB
    Memory int32 `json:"memory,omitempty"`

    // Disk size in GB
    Disk int32 `json:"disk,omitempty"`
}

type PostInstallConfig struct {
    // Operators to install
    // +optional
    Operators []OperatorInstall `json:"operators,omitempty"`

    // Day-2 configurations
    // +optional
    Configurations []ConfigurationRef `json:"configurations,omitempty"`
}

type OperatorInstall struct {
    // Operator name
    Name string `json:"name"`

    // Namespace for operator
    // +optional
    Namespace string `json:"namespace,omitempty"`

    // Channel
    // +optional
    Channel string `json:"channel,omitempty"`
}

type ConfigurationRef struct {
    // ConfigMap or Secret containing configuration
    Kind string `json:"kind"`
    Name string `json:"name"`
}

type ClusterBootstrapStatus struct {
    // Phase of the bootstrap process
    // +optional
    Phase BootstrapPhase `json:"phase,omitempty"`

    // Conditions
    // +optional
    Conditions []metav1.Condition `json:"conditions,omitempty"`

    // Installation log URL
    // +optional
    InstallLog string `json:"installLog,omitempty"`

    // Kubeconfig secret reference (created after success)
    // +optional
    Kubeconfig *SecretReference `json:"kubeconfig,omitempty"`

    // Console URL (after installation)
    // +optional
    ConsoleURL string `json:"consoleURL,omitempty"`

    // Installation started timestamp
    // +optional
    StartTime *metav1.Time `json:"startTime,omitempty"`

    // Installation completed timestamp
    // +optional
    CompletionTime *metav1.Time `json:"completionTime,omitempty"`

    // Current installation stage
    // +optional
    CurrentStage string `json:"currentStage,omitempty"`

    // Observed generation
    // +optional
    ObservedGeneration int64 `json:"observedGeneration,omitempty"`
}

type BootstrapPhase string

const (
    BootstrapPhasePending    BootstrapPhase = "Pending"
    BootstrapPhaseValidating BootstrapPhase = "Validating"
    BootstrapPhaseInstalling BootstrapPhase = "Installing"
    BootstrapPhaseComplete   BootstrapPhase = "Complete"
    BootstrapPhaseFailed     BootstrapPhase = "Failed"
)
```

#### Example CR

```yaml
apiVersion: disconnected.openshift.io/v1alpha1
kind: ClusterBootstrap
metadata:
  name: production-cluster-01
  namespace: disconnected-platform
spec:
  version: v2026.05.06.001-scheduled
  platform: vsphere
  
  installConfig:
    name: production-cluster-01-install-config
  
  agentConfig:
    name: production-cluster-01-agent-config
  
  mirrorRegistry: quay.internal:8443/mirror
  
  pullSecret:
    name: mirror-pull-secret
  
  trustBundle:
    name: mirror-ca-bundle
  
  network:
    clusterNetwork: 10.128.0.0/14
    serviceNetwork: 172.30.0.0/16
    networkType: OVNKubernetes
  
  controlPlane:
    replicas: 3
    resources:
      cpu: 8
      memory: 32
      disk: 120
  
  compute:
    replicas: 3
    resources:
      cpu: 16
      memory: 64
      disk: 120
  
  postInstall:
    operators:
      - name: openshift-pipelines-operator-rh
        namespace: openshift-operators
        channel: latest
      - name: quay-operator
        namespace: openshift-operators
        channel: stable-3.11
```

---

### 3. CollectionPipeline

**Purpose:** Represent a collection pipeline execution

**Scope:** Namespaced

**File:** `api/v1alpha1/collectionpipeline_types.go`

#### Schema

```go
type CollectionPipeline struct {
    metav1.TypeMeta   `json:",inline"`
    metav1.ObjectMeta `json:"metadata,omitempty"`

    Spec   CollectionPipelineSpec   `json:"spec,omitempty"`
    Status CollectionPipelineStatus `json:"status,omitempty"`
}

type CollectionPipelineSpec struct {
    // ImageSet configuration reference
    // +kubebuilder:validation:Required
    ImageSetConfig ConfigMapReference `json:"imageSetConfig"`

    // Trigger type for this collection
    // +kubebuilder:validation:Required
    TriggerType TriggerType `json:"triggerType"`

    // Whether this is an incremental collection
    // +kubebuilder:default=false
    Incremental bool `json:"incremental"`

    // Base version for incremental collection
    // +optional
    BaseVersion string `json:"baseVersion,omitempty"`

    // Storage configuration
    // +kubebuilder:validation:Required
    Storage CollectionStorageConfig `json:"storage"`
}

type ConfigMapReference struct {
    Name string `json:"name"`
    Key  string `json:"key,omitempty"`
}

type CollectionStorageConfig struct {
    // Mirror workspace PVC
    MirrorWorkspace string `json:"mirrorWorkspace"`

    // Package storage PVC
    PackageStorage string `json:"packageStorage"`
}

type CollectionPipelineStatus struct {
    // Phase of the collection
    // +optional
    Phase CollectionPhase `json:"phase,omitempty"`

    // Conditions
    // +optional
    Conditions []metav1.Condition `json:"conditions,omitempty"`

    // Version generated for this collection
    // +optional
    Version string `json:"version,omitempty"`

    // PipelineRun reference
    // +optional
    PipelineRun string `json:"pipelineRun,omitempty"`

    // Collection statistics
    // +optional
    Statistics *CollectionStatistics `json:"statistics,omitempty"`

    // Start time
    // +optional
    StartTime *metav1.Time `json:"startTime,omitempty"`

    // Completion time
    // +optional
    CompletionTime *metav1.Time `json:"completionTime,omitempty"`

    // Observed generation
    // +optional
    ObservedGeneration int64 `json:"observedGeneration,omitempty"`
}

type CollectionPhase string

const (
    CollectionPhasePending    CollectionPhase = "Pending"
    CollectionPhaseCollecting CollectionPhase = "Collecting"
    CollectionPhasePackaging  CollectionPhase = "Packaging"
    CollectionPhaseComplete   CollectionPhase = "Complete"
    CollectionPhaseFailed     CollectionPhase = "Failed"
)

type CollectionStatistics struct {
    // Number of images collected
    ImageCount int32 `json:"imageCount"`

    // Total size of collection
    TotalSize string `json:"totalSize"`

    // Number of operators
    OperatorCount int32 `json:"operatorCount"`

    // Number of Helm charts
    HelmChartCount int32 `json:"helmChartCount"`
}
```

---

## Validation Rules

### DisconnectedPlatform

```go
// +kubebuilder:validation:XValidation:rule="self.mode == 'connected' ? has(self.connected) : true",message="connected configuration required when mode is connected"
// +kubebuilder:validation:XValidation:rule="self.mode == 'airgapped' ? has(self.airgapped) : true",message="airgapped configuration required when mode is airgapped"
```

### ClusterBootstrap

```go
// +kubebuilder:validation:XValidation:rule="self.incremental == true ? has(self.baseVersion) : true",message="baseVersion required for incremental collections"
```

---

## Condition Types

### DisconnectedPlatform Conditions

| Type | Status | Reason | Message |
|------|--------|--------|---------|
| Ready | True | ComponentsReady | All components are ready |
| Ready | False | ComponentsNotReady | One or more components not ready |
| Ready | Unknown | Initializing | Platform initializing |
| AirgapArchitectReady | True | DeploymentAvailable | Airgap-Architect is available |
| PipelineReady | True | TektonReady | Collection pipeline is ready |
| GitOpsSynced | True | SyncSuccessful | GitOps repository synced |

### ClusterBootstrap Conditions

| Type | Status | Reason | Message |
|------|--------|--------|---------|
| Validated | True | ConfigurationValid | Installation configuration validated |
| Validated | False | ConfigurationInvalid | Configuration validation failed |
| Installing | True | BootstrapInProgress | Bootstrap installation in progress |
| Ready | True | InstallationComplete | Cluster installation complete |
| Ready | False | InstallationFailed | Cluster installation failed |

---

## Status Phase Transitions

### DisconnectedPlatform

```
Unknown → Ready → Collecting → Ready
                ↓            ↓
              Error ←────── Error
```

### ClusterBootstrap

```
Pending → Validating → Installing → Complete
            ↓              ↓           
          Failed ←────── Failed
```

### CollectionPipeline

```
Pending → Collecting → Packaging → Complete
            ↓              ↓          
          Failed ←────── Failed
```

---

## Versioning

**API Version:** `v1alpha1`

**Stability:** Alpha

**Upgrade Path:**
- v1alpha1 → v1alpha2 (breaking changes allowed)
- v1alpha2 → v1beta1 (stabilization)
- v1beta1 → v1 (production ready)

**Conversion Webhooks:** Required when introducing new versions

---

## Additional Resources

### ConfigMaps

- **imageset-config**: Contains ImageSetConfiguration YAML
- **helm-repos**: Contains Helm repository configuration

### Secrets

- **registry-credentials**: Mirror registry credentials
- **git-credentials**: GitOps repository credentials
- **install-config**: OpenShift install-config.yaml
- **pull-secret**: Registry pull secret
- **ca-bundle**: Custom CA bundle

---

## OpenAPI Schema Extensions

### Prometheus Metrics

All CRDs include annotations for Prometheus monitoring:

```yaml
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/path: "/metrics"
  prometheus.io/port: "8080"
```

### Console Plugin Integration

DisconnectedPlatform includes console plugin annotations:

```yaml
annotations:
  console.openshift.io/plugins: "disconnected-platform-console-plugin"
```

---

## Implementation Notes

1. **Use Operator SDK** for scaffolding: `operator-sdk create api`
2. **Generate CRDs**: `make manifests` generates CRD YAML
3. **Validation**: Use kubebuilder markers for OpenAPI validation
4. **Webhooks**: Implement admission webhooks for complex validation
5. **Testing**: Generate sample CRs for unit/integration tests

---

## Next Steps

1. Implement these types in Go using Operator SDK
2. Generate CRD manifests with `make manifests`
3. Add admission webhooks for validation
4. Create sample CRs for testing
5. Document API in godoc format

---

**Status:** ✅ Complete - Ready for Implementation  
**Next:** [Controller Specifications](./controller-specifications.md)
