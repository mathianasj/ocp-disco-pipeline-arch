# Presentation Diagrams Index

All diagrams have been extracted from the repository markdown files and converted to PNG format (2400x1600px, transparent background).

## Files Generated

Total: **13 diagrams**

---

## Diagram List with Descriptions

### From README.md

**diagram-01-README.png** (38K)
- **Title:** How to Use This Repository
- **Type:** Simple flow diagram
- **Shows:** Three-step process: Learn the Pattern → Adapt Examples → Build Production Operator
- **Use in Slide:** 5 (What This Repository IS)

**diagram-02-README.png** (68K)
- **Title:** The Three-Repository Pattern
- **Type:** Component relationship diagram
- **Shows:** Relationship between Reference Repository, Production Operator, and Upstream Tool
- **Use in Slide:** 6 (The Three-Repository Pattern)

**diagram-03-README.png** (64K)
- **Title:** High-Level Flow
- **Type:** Multi-phase process flow
- **Shows:** Phase 1 (Collection), Phase 2 (Transport), Phase 3 (Import) with components
- **Use in Slide:** 4 (The Solution Overview) or 8 (Complete Architecture)

**diagram-04-README.png** (87K)
- **Title:** Detailed Architecture
- **Type:** Detailed component architecture
- **Shows:** Connected cluster components, Physical media, Disconnected environment components
- **Use in Slide:** 8 (Complete Architecture) - RECOMMENDED PRIMARY DIAGRAM

**diagram-05-README.png** (118K)
- **Title:** End-to-End Sequence Diagram
- **Type:** Sequence/timeline diagram
- **Shows:** Interactions between Airgap-Architect, Connected Cluster, Physical Media, Disconnected Bastion, and New Cluster
- **Use in Slide:** 12 (End-to-End Workflow)

---

### From docs/architecture.md

**diagram-06-architecture.png** (160K)
- **Title:** Three-Zone Architecture (Detailed)
- **Type:** Three-column detailed architecture
- **Shows:** Zone 1 (Connected), Zone 2 (Physical Transport), Zone 3 (Disconnected) with all components and flows
- **Use in Slide:** 8 (Complete Architecture) - ALTERNATIVE DETAILED VIEW
- **Note:** Most comprehensive diagram - excellent for technical deep-dive

---

### From docs/reference-architecture-pattern.md

**diagram-07-reference-architecture-pattern.png** (55K)
- **Title:** Three-Repository Pattern (Pattern Documentation)
- **Type:** Component relationship diagram
- **Shows:** Reference, Production, and Upstream repositories with relationships
- **Use in Slide:** 6 (The Three-Repository Pattern) - ALTERNATIVE VIEW

---

### From docs/repository-strategy.md

**diagram-08-repository-strategy.png** (67K)
- **Title:** Repository Strategy - Three Repositories
- **Type:** Component diagram with relationships
- **Shows:** How Reference Architecture, Production Operator, and Upstream Tool interact
- **Use in Slide:** 6 (The Three-Repository Pattern) - STRATEGY FOCUS

**diagram-09-repository-strategy.png** (55K)
- **Title:** Lifecycle Independence
- **Type:** Flow diagram showing separate lifecycles
- **Shows:** Independent update cycles for Reference vs Production repositories
- **Use in Slide:** 7 (Why Separate Repositories?)

---

### From docs/future-vision-operator-integration.md

**diagram-10-future-vision-operator-integration.png** (122K)
- **Title:** Unified Operator Architecture
- **Type:** Component architecture diagram
- **Shows:** Disconnected Platform Operator with Connected Mode, Airgapped Mode, and Deployment Targets
- **Use in Slide:** 24 (Future Vision - Operator Integration)

---

### From docs/bootstrap-installation.md

**diagram-11-bootstrap-installation.png** (69K)
- **Title:** Bootstrap Installation Process
- **Type:** Process flow
- **Shows:** Steps for bootstrap installation from configuration to deployment
- **Use in Slide:** 21 (Bootstrap Workflow)

**diagram-12-bootstrap-installation.png** (60K)
- **Title:** Bootstrap Workflow Detail
- **Type:** Detailed process diagram
- **Shows:** Detailed steps in bootstrap workflow with decision points
- **Use in Slide:** 21 (Bootstrap Workflow) - ALTERNATIVE DETAILED VIEW

---

### From docs/BOOTSTRAP-QUICKSTART.md

**diagram-13-BOOTSTRAP-QUICKSTART.png** (22K)
- **Title:** Quick Start Flow
- **Type:** Simplified flow diagram
- **Shows:** Simplified bootstrap process for quick reference
- **Use in Slide:** 29 (Getting Started)

---

## Recommended Diagrams by Slide

### Essential Diagrams (Must Use)

1. **Slide 4 (Solution Overview):** `diagram-03-README.png`
2. **Slide 6 (Three-Repository Pattern):** `diagram-02-README.png`
3. **Slide 8 (Complete Architecture):** `diagram-04-README.png` OR `diagram-06-architecture.png` (more detailed)
4. **Slide 12 (End-to-End Workflow):** `diagram-05-README.png`
5. **Slide 24 (Future Vision):** `diagram-10-future-vision-operator-integration.png`

### Optional Diagrams (Enhanced Slides)

6. **Slide 7 (Why Separate Repos):** `diagram-09-repository-strategy.png`
7. **Slide 21 (Bootstrap Workflow):** `diagram-11-bootstrap-installation.png`
8. **Slide 29 (Getting Started):** `diagram-13-BOOTSTRAP-QUICKSTART.png`

---

## Technical Details

**Image Specifications:**
- **Format:** PNG
- **Resolution:** 2400 x 1600 pixels
- **Background:** Transparent
- **DPI:** 96
- **Color depth:** 32-bit RGBA

**Generation:**
- **Tool:** Mermaid CLI (mmdc) v10.x
- **Source:** Mermaid code blocks from repository markdown files
- **Extraction:** Python script (`scripts/common/extract_mermaid.py`)

---

## Usage in Google Slides

### Import Instructions:

1. **Insert → Image → Upload from computer**
2. Navigate to `presentation-diagrams/` folder
3. Select the PNG file you want
4. Resize and position as needed

### Styling Tips:

1. **Maintain aspect ratio** when resizing (hold Shift while dragging)
2. **Add drop shadow** for depth: Format Options → Drop shadow (low opacity)
3. **Crop if needed** to focus on specific sections
4. **Layer text boxes** over diagrams for callouts
5. **Use animations** to reveal complex diagrams step-by-step

### Color Coordination:

All diagrams use the repository's color scheme:
- **Blue tones:** Connected environments, reference materials
- **Orange/Yellow tones:** Disconnected environments, production
- **Green tones:** Success states, completed processes
- **Gray tones:** Transport, neutral states

---

## Diagram Quality Notes

### Highest Quality (Best for Large Slides):
- `diagram-06-architecture.png` (160K) - Most detailed
- `diagram-05-README.png` (118K) - Sequence diagram
- `diagram-10-future-vision-operator-integration.png` (122K) - Future architecture

### Good for Overview Slides:
- `diagram-04-README.png` (87K) - Balanced detail
- `diagram-02-README.png` (68K) - Clear relationships
- `diagram-03-README.png` (64K) - Process flow

### Good for Summary Slides:
- `diagram-13-BOOTSTRAP-QUICKSTART.png` (22K) - Simple and clear
- `diagram-01-README.png` (38K) - Basic concept

---

## Regenerating Diagrams

If you need to regenerate with different settings:

```bash
# Extract Mermaid code blocks
python3 scripts/common/extract_mermaid.py

# Convert to PNG with custom size
cd presentation-diagrams
mmdc -i diagram-XX.mmd -o diagram-XX.png -b transparent -w 3000 -H 2000

# Batch convert all
for file in *.mmd; do 
    mmdc -i "$file" -o "${file%.mmd}.png" -b transparent -w 2400 -H 1600
done
```

### Custom Size Options:
- **Standard:** `-w 2400 -H 1600` (current)
- **HD:** `-w 1920 -H 1080`
- **4K:** `-w 3840 -H 2160`
- **Print:** `-w 4800 -H 3200`

---

## Source Files

All source `.mmd` files are included in this directory:
- `diagram-01-README.mmd` through `diagram-13-BOOTSTRAP-QUICKSTART.mmd`

You can edit these files directly and regenerate PNGs if you need to modify diagrams.

---

## Diagram Metadata

| Diagram | Source File | Type | Complexity | Recommended Use |
|---------|-------------|------|------------|-----------------|
| 01 | README.md | Flow | Simple | Overview |
| 02 | README.md | Relationship | Medium | Pattern explanation |
| 03 | README.md | Multi-phase | Medium | Process overview |
| 04 | README.md | Architecture | High | Main architecture |
| 05 | README.md | Sequence | High | Workflow timeline |
| 06 | architecture.md | Architecture | Very High | Technical deep-dive |
| 07 | reference-arch | Relationship | Medium | Pattern documentation |
| 08 | repository-strategy | Relationship | Medium | Strategy explanation |
| 09 | repository-strategy | Flow | Low | Lifecycle comparison |
| 10 | future-vision | Architecture | High | Future roadmap |
| 11 | bootstrap | Process | Medium | Installation guide |
| 12 | bootstrap | Process | High | Detailed installation |
| 13 | bootstrap-quickstart | Flow | Low | Quick reference |

---

## Additional Notes

1. **All diagrams are ready for use** in Google Slides without modification
2. **Transparent backgrounds** allow overlay on colored slide backgrounds
3. **High resolution** ensures quality when projected
4. **Source .mmd files** included for future edits
5. **Consistent styling** across all diagrams from repository theme

---

**Generated:** 2026-06-09
**Tool Version:** mermaid-cli v10.x
**Total File Size:** ~1.1 MB (all PNGs)
