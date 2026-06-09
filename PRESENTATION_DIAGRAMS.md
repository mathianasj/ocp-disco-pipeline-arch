# Presentation Diagrams - For Google Slides

This document contains all key diagrams from the repository, formatted for recreation in Google Slides or other presentation tools.

---

## DIAGRAM 1: High-Level Flow (Simple)
**Use for:** Slide 4 - The Solution Overview

**Type:** Linear process flow (5 steps)

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   COLLECT   │ => │   PACKAGE   │ => │  TRANSPORT  │ => │   IMPORT    │ => │  VALIDATE   │
│             │    │             │    │             │    │             │    │             │
│  Artifacts  │    │  Versioned  │    │  Physical   │    │    To       │    │  Integrity  │
│   on CDN    │    │   Archive   │    │    Media    │    │ Disconnected│    │   & Track   │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

**Visual Suggestion for Google Slides:**
- 5 rounded rectangles with right-pointing arrows between them
- Colors: Blue → Green → Gray → Orange → Purple
- Icons: Cloud → Box → USB Drive → Server → Checkmark

---

## DIAGRAM 2: Three-Repository Pattern
**Use for:** Slide 6 - The Three-Repository Pattern

**Type:** Relationship diagram (3 boxes with connections)

```
┌───────────────────────────────┐
│  REFERENCE REPOSITORY         │
│  disconnected-mirror-pipeline │
│                               │
│  • Patterns & Examples        │
│  • Architecture Docs          │
│  • Learning Resource          │
└───────────────────────────────┘
         │                │
         │ Patterns       │ Contributes
         │ Guide          │ to
         ▼                ▼
┌───────────────────────────────┐     ┌───────────────────────────────┐
│  PRODUCTION OPERATOR          │     │  ENHANCED UPSTREAM TOOL       │
│  disconnected-platform-op     │ <=  │  openshift-airgap-architect   │
│                               │     │                               │
│  • Production Code            │     │  • Config Wizard              │
│  • Versioned Releases         │     │  • oc-mirror Integration      │
│  • Supported Product          │     │  • UI-Driven Workflows        │
└───────────────────────────────┘     └───────────────────────────────┘
              ▲
              │ Embedded in
```

**Visual Suggestion for Google Slides:**
- Top box: Light yellow/cream background (#fff4e1)
- Bottom left box: Light green background (#e1ffe1)
- Bottom right box: Light blue background (#e1f5ff)
- Arrows: Dashed from Reference to Production, solid from Upstream to Production
- Labels on arrows: "Patterns Guide", "Embedded in", "Contributes to"

---

## DIAGRAM 3: Three-Zone Architecture
**Use for:** Slide 8 - Complete Architecture

**Type:** Three-column layout with components in each zone

```
╔════════════════════════════════╗    ╔══════════════════╗    ╔════════════════════════════════╗
║   ZONE 1: CONNECTED           ║    ║  ZONE 2:         ║    ║  ZONE 3: DISCONNECTED         ║
║   (INTERNET ACCESS)            ║    ║  PHYSICAL        ║    ║  (AIR-GAPPED)                 ║
╠════════════════════════════════╣    ║  TRANSPORT       ║    ╠════════════════════════════════╣
║                                ║    ╠══════════════════╣    ║                                ║
║  ┌──────────────────────────┐ ║    ║                  ║    ║  ┌──────────────────────────┐ ║
║  │ Red Hat CDN & Registries │ ║    ║  ┌────────────┐  ║    ║  │ Bastion Node             │ ║
║  └──────────────────────────┘ ║    ║  │ Encrypted  │  ║    ║  │ or Existing Cluster      │ ║
║              ▼                 ║    ║  │    USB     │  ║    ║  └──────────────────────────┘ ║
║  ┌──────────────────────────┐ ║    ║  │   Drive    │  ║    ║              ▼                 ║
║  │ Airgap-Architect Wizard  │ ║    ║  │            │  ║    ║  ┌──────────────────────────┐ ║
║  │ (Config Generation)      │ ║    ║  │  Chain of  │  ║    ║  │ Verify Checksums         │ ║
║  └──────────────────────────┘ ║    ║  │  Custody   │  ║    ║  └──────────────────────────┘ ║
║              ▼                 ║    ║  └────────────┘  ║    ║              ▼                 ║
║  ┌──────────────────────────┐ ║    ║                  ║    ║  ┌──────────────────────────┐ ║
║  │ Tekton Pipeline          │ ║    ║     1-7 Days     ║    ║  │ Import Pipeline          │ ║
║  │ • oc-mirror              │ ║    ║    Transport     ║    ║  │ • oc-mirror import       │ ║
║  │ • Package artifacts      │ ║    ║                  ║    ║  │ • Populate registry      │ ║
║  └──────────────────────────┘ ║    ║                  ║    ║  └──────────────────────────┘ ║
║              ▼                 ║    ║                  ║    ║              ▼                 ║
║  ┌──────────────────────────┐ ║    ║                  ║    ║  ┌──────────────────────────┐ ║
║  │ Mirror Registry (Quay)   │ ║    ║                  ║    ║  │ Local Mirror Registry    │ ║
║  └──────────────────────────┘ ║    ║                  ║    ║  └──────────────────────────┘ ║
║              ▼                 ║    ║                  ║    ║              ▼                 ║
║  ┌──────────────────────────┐ ║ => ║                  ║ => ║  ┌──────────────────────────┐ ║
║  │ Versioned Archive        │ ║    ║                  ║    ║  │ Bootstrap New Cluster    │ ║
║  │ v2026.05.06.001.tar.gz   │ ║    ║                  ║    ║  │ OR Update Existing       │ ║
║  └──────────────────────────┘ ║    ║                  ║    ║  └──────────────────────────┘ ║
╚════════════════════════════════╝    ╚══════════════════╝    ╚════════════════════════════════╝
```

**Visual Suggestion for Google Slides:**
- Use 3 columns with different background colors:
  - Zone 1: Light blue (#e1f5ff)
  - Zone 2: Light gray (#f0f0f0)
  - Zone 3: Light yellow (#fff4e1)
- Stack boxes vertically within each zone
- Use thick arrows (=>) between zones
- Add icons: Cloud (Zone 1), USB drive (Zone 2), Lock (Zone 3)

---

## DIAGRAM 4: Collection Pipeline Detail
**Use for:** Slide 9 - Zone 1 Connected Cluster

**Type:** Vertical flow with components

```
                    CONNECTED CLUSTER
                    ─────────────────

┌─────────────────────────────────────────────────┐
│          Red Hat CDN & Registries               │
│     registry.redhat.io, quay.io/openshift       │
└─────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│    OpenShift Airgap Architect                   │
│    Configuration Wizard                         │
│                                                  │
│    Output: imageset-config.yaml                 │
└─────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│    Tekton Collection Pipeline                   │
│    ┌───────────────────────────────────────┐   │
│    │  1. Version Tag Generation            │   │
│    │  2. oc-mirror Collect                 │   │
│    │  3. Helm Chart Collection             │   │
│    │  4. Operator Catalog Mirror           │   │
│    │  5. Generate Manifest                 │   │
│    │  6. Package Archive                   │   │
│    │  7. Checksum Generation               │   │
│    └───────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│    Mirror Registry (Quay)                       │
│    Staging for collected images                 │
└─────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│    Versioned Archive                            │
│    mirror-v2026.05.06.001.tar.gz                │
│                                                  │
│    ├── VERSION                                  │
│    ├── MANIFEST.yaml                            │
│    ├── CHECKSUMS.sha256                         │
│    ├── images/                                  │
│    ├── operators/                               │
│    ├── helm-charts/                             │
│    └── artifacts/                               │
└─────────────────────────────────────────────────┘
```

**Visual Suggestion for Google Slides:**
- Vertical stack of boxes with downward arrows
- Use consistent blue theme for connected zone
- Highlight the Tekton pipeline section with a border
- Show the archive as an expandable box with folder structure

---

## DIAGRAM 5: Import Pipeline Detail
**Use for:** Slide 11 - Zone 3 Disconnected Environment

**Type:** Vertical flow with validation steps

```
              DISCONNECTED ENVIRONMENT
              ────────────────────────

┌─────────────────────────────────────────────────┐
│    Physical Media Mount                         │
│    /mnt/usb/mirror-v2026.05.06.001.tar.gz      │
└─────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│    Extract & Verify                             │
│    • Extract archive                            │
│    • Verify all checksums                       │
│    • Validate manifest schema                   │
│                                                  │
│    ❌ Fail if checksums don't match             │
└─────────────────────────────────────────────────┘
                      │
                      ▼ (checksums OK)
┌─────────────────────────────────────────────────┐
│    Bastion Registry Setup                       │
│    • Install mirror-registry (if needed)        │
│    • Configure authentication                   │
│    • Verify registry health                     │
└─────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│    Import Pipeline                              │
│    ┌───────────────────────────────────────┐   │
│    │  1. oc-mirror Import to Registry      │   │
│    │  2. Helm Chart Import                 │   │
│    │  3. Operator Catalog Import           │   │
│    │  4. Artifact Distribution             │   │
│    │  5. Validation Tests                  │   │
│    └───────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│    Local Mirror Registry (Quay)                 │
│    quay.bastion.example.com:8443                │
│                                                  │
│    • OpenShift platform images                  │
│    • Operator catalogs                          │
│    • Application images                         │
└─────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│    Bootstrap / Update                           │
│                                                  │
│    Option A: Bootstrap New Cluster              │
│    • Generate install-config.yaml               │
│    • Run openshift-install                      │
│                                                  │
│    Option B: Update Existing Cluster            │
│    • Apply ImageContentSourcePolicy             │
│    • Update operator subscriptions              │
└─────────────────────────────────────────────────┘
```

**Visual Suggestion for Google Slides:**
- Vertical stack with validation gate icons
- Use orange/yellow theme for disconnected zone
- Show decision point: Checksum verification
- Highlight two deployment options at the bottom

---

## DIAGRAM 6: End-to-End Sequence
**Use for:** Slide 12 - End-to-End Workflow

**Type:** Sequence diagram (participant interactions over time)

```
Airgap-      Connected     Physical      Disconnected    New
Architect    Cluster       Media         Bastion         Cluster
   │             │            │               │              │
   │             │            │               │              │
   │ Generate    │            │               │              │
   │ Config      │            │               │              │
   ├────────────>│            │               │              │
   │             │            │               │              │
   │             │ Run        │               │              │
   │             │ Collection │               │              │
   │             │ Pipeline   │               │              │
   │             ├─┐          │               │              │
   │             │ │ Collect  │               │              │
   │             │ │ Mirror   │               │              │
   │             │ │ Package  │               │              │
   │             │<┘          │               │              │
   │             │            │               │              │
   │             │ Create     │               │              │
   │             │ Archive    │               │              │
   │             ├───────────>│               │              │
   │             │            │               │              │
   │             │            │ Physical      │              │
   │             │            │ Transport     │              │
   │             │            │ (1-7 days)    │              │
   │             │            ├──────────────>│              │
   │             │            │               │              │
   │             │            │               │ Verify       │
   │             │            │               │ Checksums    │
   │             │            │               ├─┐            │
   │             │            │               │ │            │
   │             │            │               │<┘            │
   │             │            │               │              │
   │             │            │               │ Import to    │
   │             │            │               │ Registry     │
   │             │            │               ├─┐            │
   │             │            │               │ │            │
   │             │            │               │<┘            │
   │             │            │               │              │
   │             │            │               │ Bootstrap    │
   │             │            │               │ Install      │
   │             │            │               ├─────────────>│
   │             │            │               │              │
   │             │            │               │              │ Pull
   │             │            │               │              │ Images
   │             │            │               │<─────────────┤
   │             │            │               │              │
   │             │            │               │              │ Cluster
   │             │            │               │              │ Ready
   │             │            │               │              │
```

**Visual Suggestion for Google Slides:**
- Use swimlanes for each participant (5 columns)
- Time flows from top to bottom
- Arrows show message/data flow between participants
- Add duration labels: "2-4 hours", "1-7 days", "2-4 hours"
- Highlight the physical transport phase with different color

---

## DIAGRAM 7: Version Format
**Use for:** Slide 13 - Version Tracking

**Type:** Format breakdown diagram

```
┌──────────────────────────────────────────────────────────┐
│    Version Format: v{YYYY.MM.DD}.{BUILD}-{TRIGGER}       │
└──────────────────────────────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        │             │             │
        ▼             ▼             ▼
┌─────────────┐ ┌──────────┐ ┌────────────┐
│    Date     │ │  Build   │ │  Trigger   │
│             │ │  Number  │ │   Type     │
│  YYYY.MM.DD │ │   001    │ │  manual    │
│             │ │   ...    │ │  scheduled │
│  2026.05.06 │ │   999    │ │  event     │
└─────────────┘ └──────────┘ └────────────┘

EXAMPLES:
─────────────────────────────────────────────────────────
v2026.05.06.001-manual      First manual run on May 6
v2026.05.06.002-scheduled   Second run (scheduled)
v2026.05.13.001-event       Event-driven trigger
v2026.05.20.001-incremental Incremental update
```

**Visual Suggestion for Google Slides:**
- Top: Full format in large text box
- Middle: Breakdown into 3 components with arrows
- Bottom: Example table with 4 rows
- Use monospace font for version strings

---

## DIAGRAM 8: Archive Structure Tree
**Use for:** Slide 14 - Archive Structure

**Type:** Directory tree visualization

```
📦 mirror-v2026.05.06.001.tar.gz (300GB+ compressed)
│
└─📁 mirror-v2026.05.06.001/
   │
   ├─📄 VERSION                    # v2026.05.06.001-manual
   ├─📄 MANIFEST.yaml              # Complete artifact manifest
   ├─📄 CHECKSUMS.sha256           # SHA256 checksums
   ├─📄 README.txt                 # Import instructions
   │
   ├─📁 images/                    # Container images
   │  └─📁 oc-mirror-workspace/
   │     ├─📁 mirror/              # Image layers and manifests
   │     └─📁 results-*/           # ImageContentSourcePolicy
   │
   ├─📁 operators/                 # Operator catalogs
   │  ├─📁 redhat-operators/
   │  └─📁 certified-operators/
   │
   ├─📁 helm-charts/               # Helm chart packages
   │  ├─📦 nginx-1.2.3.tgz
   │  └─📦 postgresql-12.1.0.tgz
   │
   ├─📁 artifacts/                 # Tools and binaries
   │  ├─📁 binaries/
   │  │  ├─📦 openshift-install-linux-4.15.12.tar.gz
   │  │  ├─📦 openshift-client-linux-4.15.12.tar.gz
   │  │  ├─📦 oc-mirror.tar.gz
   │  │  ├─📦 mirror-registry.tar.gz
   │  │  └─📦 helm-v3.14.0-linux-amd64.tar.gz
   │  ├─📁 configs/
   │  │  └─📄 imageset-config.yaml
   │  └─📁 docs/
   │     └─📄 bootstrap-installation.md
   │
   └─📁 import-scripts/            # Automation scripts
      ├─📄 bootstrap-import.sh     # Main import script
      └─📄 verify-import.sh        # Verification helper
```

**Visual Suggestion for Google Slides:**
- Use SmartArt hierarchy or create custom tree with shapes
- Use different icons: 📦 for archives, 📁 for folders, 📄 for files
- Color code by type: Blue (images), Green (operators), Orange (artifacts)
- Add file sizes next to important items

---

## DIAGRAM 9: Full vs Incremental Collections
**Use for:** Slide 15 - Collection Types

**Type:** Comparison diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    FULL COLLECTION                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌────────────────────────────────────────────────────────┐   │
│  │  Complete, self-contained artifact set                 │   │
│  │                                                          │   │
│  │  • All platform images                                  │   │
│  │  • All operator catalogs                                │   │
│  │  • All Helm charts                                      │   │
│  │  • All tools and binaries                               │   │
│  │  • Complete documentation                               │   │
│  └────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Size:      ~300GB+                                            │
│  Frequency: Monthly or new deployments                         │
│  Use Case:  Bootstrap from scratch                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                 INCREMENTAL COLLECTION                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌────────────────────────────────────────────────────────┐   │
│  │  Delta updates only (references base version)          │   │
│  │                                                          │   │
│  │  • Changed images only                                  │   │
│  │  • New operator versions                                │   │
│  │  • Updated Helm charts                                  │   │
│  │  • No duplicate binaries                                │   │
│  │  • References: v2026.05.06.001 (base)                  │   │
│  └────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Size:      ~120GB (60% reduction)                             │
│  Frequency: Weekly or after updates                            │
│  Use Case:  Update existing deployment                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

STRATEGY: Monthly full collection + Weekly incrementals
```

**Visual Suggestion for Google Slides:**
- Two large boxes stacked vertically
- Full collection: Green background
- Incremental: Blue background
- Use icons: Full box vs. partially filled box
- Highlight the 60% size reduction with a callout

---

## DIAGRAM 10: User Journey Paths
**Use for:** Slide 23 - Four User Paths

**Type:** Decision tree / pathway diagram

```
                    START: What do you want to do?
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
        ▼                       ▼                       ▼
┌───────────────┐       ┌───────────────┐      ┌───────────────┐
│   PATH A:     │       │   PATH B:     │      │   PATH C:     │
│    LEARN      │       │     USE       │      │    BUILD      │
├───────────────┤       ├───────────────┤      ├───────────────┤
│ Time: 2-4 hrs │       │ Time: 1-2 days│      │ Time: 8-12 wk │
│               │       │               │      │               │
│ 1. Read docs  │       │ 1. Deploy ref │      │ 1. Learn      │
│ 2. Review     │       │ 2. Generate   │      │ 2. Review     │
│    patterns   │       │    config     │      │    specs      │
│ 3. Explore    │       │ 3. Run        │      │ 3. Create     │
│    examples   │       │    pipeline   │      │    operator   │
│               │       │ 4. Test E2E   │      │ 4. Implement  │
│               │       │               │      │ 5. Release    │
└───────────────┘       └───────────────┘      └───────────────┘
        │                       │                       │
        ▼                       ▼                       ▼
   Deep           Working airgapped      Production
   Understanding  release cycle         operator v1.0


                        ▼
                ┌───────────────┐
                │   PATH D:     │
                │  BOOTSTRAP    │
                ├───────────────┤
                │ Time: 4-8 hrs │
                │               │
                │ 1. Obtain     │
                │    archive    │
                │ 2. Transfer   │
                │    media      │
                │ 3. Install    │
                │    registry   │
                │ 4. Import     │
                │    artifacts  │
                │ 5. Bootstrap  │
                │    cluster    │
                └───────────────┘
                        │
                        ▼
                Fresh OpenShift
                cluster in airgap
```

**Visual Suggestion for Google Slides:**
- Four columns or quadrants
- Different colors for each path: Blue (Learn), Green (Use), Orange (Build), Purple (Bootstrap)
- Show duration prominently at top of each path
- Use numbered steps
- End outcome in bold at bottom

---

## DIAGRAM 11: Future Operator Architecture
**Use for:** Slide 24 - Future Vision - Operator Integration

**Type:** Component architecture diagram

```
┌─────────────────────────────────────────────────────────────┐
│         DISCONNECTED PLATFORM OPERATOR                      │
│                                                             │
│  ┌────────────────┐         ┌─────────────────────────┐   │
│  │  Adaptive UI   │<───────>│  Controller Manager     │   │
│  │                │         │  • Environment Detection│   │
│  │  Connected     │         │  • CRD Reconciliation   │   │
│  │  Mode UI       │         │  • Health Monitoring    │   │
│  │                │         │  • Status Reporting     │   │
│  │  Airgapped     │         └─────────────────────────┘   │
│  │  Mode UI       │                    │                   │
│  └────────────────┘                    │                   │
└─────────────────────────────────────────┼───────────────────┘
                                         │
        ┌────────────────────────────────┼────────────────────────────────┐
        │                                │                                │
        ▼                                ▼                                ▼
┌───────────────────┐         ┌──────────────────┐          ┌──────────────────┐
│ Connected Mode    │         │ Airgapped Mode   │          │ Embedded         │
│ Components        │         │ Components       │          │ Components       │
├───────────────────┤         ├──────────────────┤          ├──────────────────┤
│                   │         │                  │          │                  │
│ • Airgap-Architect│         │ • Import Pipeline│          │ • Airgap-Arch    │
│   Config Gen      │         │ • Bootstrap Ctrl │          │   (embedded)     │
│ • Tekton Pipeline │         │ • Registry Mgmt  │          │ • oc-mirror      │
│ • ArgoCD/GitOps   │         │ • Cluster Deploy │          │ • Helm           │
│ • Storage Mgmt    │         │ • Version Track  │          │                  │
└───────────────────┘         └──────────────────┘          └──────────────────┘
```

**Visual Suggestion for Google Slides:**
- Top box: Operator core (Dark blue)
- Three boxes below: Connected (Light blue), Airgapped (Light orange), Embedded (Light green)
- Show bidirectional connection between UI and Controller
- List key components in each section

---

## DIAGRAM 12: Technology Stack
**Use for:** Slide 16 - Technology Stack

**Type:** Layered stack diagram

```
┌─────────────────────────────────────────────────────────────┐
│              APPLICATION LAYER                              │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐           │
│  │ OpenShift  │  │ Operators  │  │Application │           │
│  │ Platform   │  │            │  │  Workloads │           │
│  └────────────┘  └────────────┘  └────────────┘           │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│              ORCHESTRATION LAYER                            │
│  ┌──────────────────────┐    ┌──────────────────────┐     │
│  │ OpenShift Pipelines  │    │ OpenShift GitOps     │     │
│  │ (Tekton)             │    │ (ArgoCD)             │     │
│  └──────────────────────┘    └──────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│              MIRRORING & STORAGE LAYER                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  oc-mirror   │  │  Red Hat     │  │    Helm      │     │
│  │              │  │   Quay       │  │              │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│              CONFIGURATION & TOOLING LAYER                  │
│  ┌──────────────────────┐    ┌──────────────────────┐     │
│  │ Airgap-Architect     │    │  Bash/Shell Scripts  │     │
│  │ (Config Wizard)      │    │  (Utilities)         │     │
│  └──────────────────────┘    └──────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│              INFRASTRUCTURE LAYER                           │
│               OpenShift / Kubernetes                        │
└─────────────────────────────────────────────────────────────┘
```

**Visual Suggestion for Google Slides:**
- Five horizontal layers stacked vertically
- Different colors for each layer
- Use icons for each component
- Foundation (Kubernetes) at bottom, Applications at top

---

## ICON SUGGESTIONS

For enhanced visual appeal in Google Slides, use these icons:

**General:**
- 🌐 Internet / Connected
- 🔒 Locked / Disconnected / Airgapped
- ✅ Checkmark / Validated
- ❌ X / Failed / Blocked
- 📦 Package / Archive
- 💾 USB Drive / Physical Media
- 🔄 Sync / Process
- 📊 Dashboard / Monitoring
- 🚀 Deploy / Launch

**Components:**
- ☁️ Cloud / Red Hat CDN
- 🗄️ Registry / Storage
- ⚙️ Configuration / Settings
- 🔧 Tools / Utilities
- 📝 Manifest / Documentation
- 🏗️ Build / Pipeline
- 🔐 Security / Encryption
- 📋 Checklist / Tasks

**Workflow:**
- ➡️ Next step / Flow
- ↔️ Bidirectional / Sync
- ⬇️ Download / Import
- ⬆️ Upload / Export
- 🔄 Circular / Recurring

---

## COLOR PALETTE

Consistent color scheme for all diagrams:

**Zone/Environment Colors:**
- Connected Zone: `#e1f5ff` (Light Blue)
- Physical Transport: `#f0f0f0` (Light Gray)
- Disconnected Zone: `#fff4e1` (Light Yellow/Cream)

**Repository Colors:**
- Reference Repository: `#fff4e1` (Light Yellow)
- Production Operator: `#e1ffe1` (Light Green)
- Upstream Tool: `#e1f5ff` (Light Blue)

**Status Colors:**
- Success / Complete: `#00aa00` (Green)
- Warning / Pending: `#ffaa00` (Orange)
- Error / Failed: `#cc0000` (Red)
- Information: `#0066cc` (Blue)

**Component Colors:**
- Pipeline: `#4a90e2` (Blue)
- Registry: `#7b68ee` (Purple)
- Storage: `#50c878` (Emerald)
- Security: `#ff6b6b` (Red)

---

## NOTES FOR GOOGLE SLIDES IMPORT

1. **Mermaid to Google Slides:**
   - Mermaid diagrams from README.md can be rendered at: https://mermaid.live/
   - Take screenshots and import as images
   - Or recreate using Google Slides SmartArt

2. **ASCII to Shapes:**
   - Convert ASCII boxes to rounded rectangle shapes
   - Use connector lines for arrows
   - Group related components

3. **Consistent Styling:**
   - Use the same fonts throughout (Recommended: Open Sans or Roboto)
   - Keep spacing consistent (20px between components)
   - Use shadows sparingly for depth

4. **Animation Suggestions:**
   - Slide 4: Animate each step appearing left to right
   - Slide 6: Fade in each repository box
   - Slide 12: Animate sequence diagram messages top to bottom
   - Slide 23: Fade in each user path

5. **Templates:**
   - Use master slides for consistent headers/footers
   - Create a "diagram" master with centered content area
   - Create a "content" master with left-aligned bullet points

---

## ADDITIONAL VISUAL ELEMENTS

**Callout Boxes:**
Use for emphasis on slides:
- "Key Principle" boxes (yellow background)
- "Security Note" boxes (red border)
- "Pro Tip" boxes (green background)
- "Future Vision" boxes (blue background)

**Data Visualizations:**
- Slide 15: Pie chart showing size comparison (300GB vs 120GB)
- Slide 28: Bar chart for success metrics
- Slide 17: Gantt chart for implementation phases

---

END OF DIAGRAM REFERENCE
