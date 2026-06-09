#!/usr/bin/env python3
"""Extract Mermaid diagrams from markdown files and save as separate .mmd files"""

import re
import os
from pathlib import Path

# Files to process
files_to_process = [
    "README.md",
    "docs/architecture.md",
    "docs/reference-architecture-pattern.md",
    "docs/repository-strategy.md",
    "docs/future-vision-operator-integration.md",
    "docs/bootstrap-installation.md",
    "docs/BOOTSTRAP-QUICKSTART.md",
]

# Output directory
output_dir = Path("presentation-diagrams")
output_dir.mkdir(exist_ok=True)

diagram_count = 1

def extract_mermaid_blocks(file_path):
    """Extract all mermaid code blocks from a markdown file"""
    global diagram_count

    with open(file_path, 'r') as f:
        content = f.read()

    # Pattern to match mermaid code blocks
    pattern = r'```mermaid\n(.*?)```'
    matches = re.findall(pattern, content, re.DOTALL)

    basename = Path(file_path).stem

    for i, mermaid_code in enumerate(matches, 1):
        output_file = output_dir / f"diagram-{diagram_count:02d}-{basename}.mmd"

        with open(output_file, 'w') as f:
            f.write(mermaid_code.strip())

        print(f"  → Created {output_file.name}")
        diagram_count += 1

    return len(matches)

# Process all files
print("Extracting Mermaid diagrams...\n")

total_diagrams = 0
for file_path in files_to_process:
    if os.path.exists(file_path):
        print(f"Processing: {file_path}")
        count = extract_mermaid_blocks(file_path)
        total_diagrams += count
        if count == 0:
            print("  (no diagrams found)")

print(f"\n✓ Extraction complete!")
print(f"  Total diagrams: {total_diagrams}")
print(f"  Output directory: {output_dir}/")
