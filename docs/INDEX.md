# Documentation Index

**Purpose:** This repository is THE canonical reference architecture for implementing airgapped release cycles.

---

## Start Here

### 🎯 New to Airgapped Deployments?

1. **[Reference Architecture Pattern](reference-architecture-pattern.md)** - **START HERE** - The industry standard pattern
2. **[Architecture Overview](architecture.md)** - How airgapped release cycles work (to be created)
3. **[README](../README.md)** - Quick start and overview

### 🏗️ Building a Production Implementation?

1. **[Reference Architecture Pattern](reference-architecture-pattern.md)** - The three-repository pattern
2. **[Repository Strategy](repository-strategy.md)** - Why separate repositories
3. **[Operator Specifications](operator-specs/README.md)** - Complete technical specs
4. **[Future Vision](future-vision-operator-integration.md)** - Full operator architecture

### 🔧 Using This Reference Architecture?

1. **[Examples](examples/README.md)** - Configuration examples with airgap-architect
2. **[Bootstrap Workflow](bootstrap-workflow.md)** - Fresh cluster installation
3. **Pipeline Tasks** in `../pipelines/connected/tasks/` - Example Tekton tasks
4. **Scripts** in `../scripts/` - Reusable utilities

---

## Core Documentation

### Patterns and Guidance

| Document | Purpose | Audience |
|----------|---------|----------|
| **[Reference Architecture Pattern](reference-architecture-pattern.md)** | THE industry standard for airgapped release cycles | Everyone |
| **[Repository Strategy](repository-strategy.md)** | Why and how to separate repositories | Architects, Team Leads |
| **[Future Vision](future-vision-operator-integration.md)** | Complete operator-based architecture | Architects, Developers |

### Implementation Guides

| Document | Purpose | Audience |
|----------|---------|----------|
| **[Bootstrap Workflow](bootstrap-workflow.md)** | Install fresh OpenShift in airgapped env | Operators, SREs |
| **[Examples](examples/README.md)** | Configuration generation with airgap-architect | Platform Engineers |
| **[Overlap Analysis](airgap-architect-overlap-analysis.md)** | Integration with airgap-architect | Developers |

### Technical Specifications

| Document | Purpose | Audience |
|----------|---------|----------|
| **[Operator Specs Index](operator-specs/README.md)** | Overview of operator specifications | Developers |
| **[API Specifications](operator-specs/api-specifications.md)** | Complete CRD schemas and types | Go Developers |
| **[Airgap-Architect Contributions](airgap-architect-contributions.md)** | Upstream enhancement plan | Contributors |

---

## By Role

### Platform Architects

**Your Focus:** Understanding patterns and making architectural decisions

**Read:**
1. [Reference Architecture Pattern](reference-architecture-pattern.md) - The standard approach
2. [Repository Strategy](repository-strategy.md) - Repository separation rationale
3. [Future Vision](future-vision-operator-integration.md) - Complete operator architecture
4. [Overlap Analysis](airgap-architect-overlap-analysis.md) - Tool integration

**Do:**
- Decide whether to adopt reference patterns or build operator
- Plan repository structure for your implementation
- Identify upstream tools to integrate/enhance

---

### Development Team Leads

**Your Focus:** Planning implementation and team structure

**Read:**
1. [Reference Architecture Pattern](reference-architecture-pattern.md) - Implementation checklist
2. [Operator Specs Index](operator-specs/README.md) - Technical specifications
3. [Repository Strategy](repository-strategy.md) - Team and repo organization
4. [Airgap-Architect Contributions](airgap-architect-contributions.md) - Upstream collaboration

**Do:**
- Set up three repositories (reference, operator, upstream fork)
- Assign team roles per repository
- Establish contribution processes
- Plan implementation phases

---

### Go/Operator Developers

**Your Focus:** Implementing the operator

**Read:**
1. [API Specifications](operator-specs/api-specifications.md) - CRD definitions
2. [Future Vision](future-vision-operator-integration.md) - Controller architecture
3. [Reference Architecture Pattern](reference-architecture-pattern.md) - Operator checklist
4. **Pipeline Tasks** in `../pipelines/connected/tasks/` - Implementation patterns

**Do:**
- Implement CRDs and controllers per specs
- Translate reference Tekton tasks to operator-managed resources
- Build test suites
- Create OLM bundles

---

### Platform Engineers

**Your Focus:** Deploying and operating the solution

**Read:**
1. [Examples](examples/README.md) - Configuration generation
2. [Bootstrap Workflow](bootstrap-workflow.md) - Fresh cluster setup
3. **README** in `../README.md` - Quick start guide
4. **Scripts** in `../scripts/` - Operational utilities

**Do:**
- Generate configurations with airgap-architect
- Deploy reference pipelines or production operator
- Execute artifact collections
- Import to disconnected environments

---

### SREs and Operations

**Your Focus:** Day-2 operations and troubleshooting

**Read:**
1. [Bootstrap Workflow](bootstrap-workflow.md) - Cluster provisioning
2. **README** troubleshooting section
3. **CLAUDE.md** - Project context
4. **Scripts** in `../scripts/` - Operational tools

**Do:**
- Monitor pipeline executions
- Manage artifact transfers
- Troubleshoot failures
- Maintain version tracking

---

### Contributors

**Your Focus:** Improving patterns and tools

**Read:**
1. [Airgap-Architect Contributions](airgap-architect-contributions.md) - Upstream contribution guide
2. [Reference Architecture Pattern](reference-architecture-pattern.md) - Pattern evolution
3. [Repository Strategy](repository-strategy.md) - Where to contribute what

**Do:**
- Improve reference patterns
- Contribute to airgap-architect upstream
- Add examples and documentation
- Share lessons learned

---

## By Phase

### Phase 1-4: Building Reference Architecture ✅ COMPLETE

- ✅ [Phase 1 Complete](../README.md#current-status) - Foundation
- ✅ [Reference Architecture Pattern](reference-architecture-pattern.md) - Documented
- ✅ [Examples](examples/README.md) - Created
- ✅ [Bootstrap Workflow](bootstrap-workflow.md) - Documented

**Next:** Phase 5 - Operator Implementation

### Phase 5: Operator Implementation 📋 PLANNED

**Start Here:**
1. [Operator Specs Index](operator-specs/README.md) - What to build
2. [API Specifications](operator-specs/api-specifications.md) - CRD definitions
3. [Future Vision](future-vision-operator-integration.md) - Architecture
4. [Repository Strategy](repository-strategy.md) - Repo setup

**Create:**
- New repository: `disconnected-platform-operator`
- Operator SDK scaffolding
- CRD implementations
- Controller logic

### Phase 6: Production Hardening 🔮 FUTURE

**Focus:**
- Testing and validation
- Security hardening
- Performance optimization
- Production deployment

---

## Document Status

| Document | Status | Last Updated | Version |
|----------|--------|--------------|---------|
| Reference Architecture Pattern | ✅ Complete | 2026-05-08 | 1.0.0 |
| Repository Strategy | ✅ Complete | 2026-05-08 | 1.0.0 |
| API Specifications | ✅ Complete | 2026-05-08 | 1.0.0 |
| Airgap-Architect Contributions | ✅ Complete | 2026-05-08 | 1.0.0 |
| Future Vision | ✅ Complete | 2026-05-08 | 1.0.0 |
| Overlap Analysis | ✅ Complete | 2026-05-08 | 1.0.0 |
| Bootstrap Workflow | ✅ Complete | 2026-05-08 | 1.0.0 |
| Examples README | ✅ Complete | 2026-05-08 | 1.0.0 |
| Operator Specs Index | ✅ Complete | 2026-05-08 | 1.0.0 |
| Controller Specifications | 📋 Planned | TBD | - |
| Deployment Specifications | 📋 Planned | TBD | - |
| Integration Specifications | 📋 Planned | TBD | - |
| Security Specifications | 📋 Planned | TBD | - |
| Testing Specifications | 📋 Planned | TBD | - |
| Build/Release Specifications | 📋 Planned | TBD | - |
| Monitoring Specifications | 📋 Planned | TBD | - |

---

## Quick Links

### External Resources

- [OpenShift Airgap Architect](https://github.com/bstrauss84/openshift-airgap-architect/) - Configuration wizard
- [OpenShift Disconnected Installation](https://docs.openshift.com/container-platform/latest/installing/disconnected_install/)
- [oc-mirror Documentation](https://docs.openshift.com/container-platform/latest/installing/disconnected_install/installing-mirroring-installation-images.html)
- [OpenShift Pipelines (Tekton)](https://docs.openshift.com/container-platform/latest/cicd/pipelines/understanding-openshift-pipelines.html)

### Repository Structure

- **docs/** - This documentation directory
- **pipelines/** - Example Tekton pipeline definitions
- **scripts/** - Reusable utility scripts
- **config/** - Example configurations (gitignored actual configs)
- **manifests/** - Example Kubernetes manifests
- **templates/** - YAML templates

---

## Contributing to Documentation

### Adding New Documentation

1. Create document in appropriate location
2. Add entry to this index
3. Update status table
4. Cross-link from related documents
5. Submit PR

### Document Naming Conventions

- Use kebab-case: `my-document-name.md`
- Be descriptive: `operator-api-specifications.md` not `api.md`
- Group by topic: `operator-specs/api-specifications.md`

### Documentation Standards

- **Start with context:** What is this? Who is it for?
- **Use examples:** Show, don't just tell
- **Cross-reference:** Link to related documents
- **Update status:** Mark complete/planned/in-progress
- **Version important docs:** Use semantic versioning

---

## Glossary

- **Reference Architecture:** Example implementation demonstrating patterns
- **Production Operator:** Supported, versioned operator for production use
- **Airgapped/Disconnected:** Environment without internet access
- **Physical Media Transport:** USB drives, encrypted media for data transfer
- **Collection:** Gathering artifacts from internet-connected cluster
- **Import:** Loading artifacts into disconnected cluster
- **Bootstrap:** Installing fresh OpenShift cluster in airgapped environment
- **oc-mirror:** Red Hat tool for mirroring OpenShift content
- **ImageSetConfiguration:** YAML defining what to mirror with oc-mirror

---

## Getting Help

### For Pattern Questions
- **GitHub Issues:** [disconnected-mirror-pipeline/issues](https://github.com/yourorg/disconnected-mirror-pipeline/issues)
- **Tag:** `question`, `pattern`, `guidance`

### For Implementation Questions
- **GitHub Discussions:** [disconnected-mirror-pipeline/discussions](https://github.com/yourorg/disconnected-mirror-pipeline/discussions)
- **Tag:** `implementation`, `how-to`

### For Operator Development
- **Operator Repo Issues:** (when created: `disconnected-platform-operator/issues`)
- **Tag:** `operator`, `development`

### For Upstream Contributions
- **Airgap-Architect Issues:** [openshift-airgap-architect/issues](https://github.com/bstrauss84/openshift-airgap-architect/issues)
- **Tag:** `enhancement`, `integration`

---

**This is THE reference architecture for airgapped release cycles. All implementations should follow this pattern.**
