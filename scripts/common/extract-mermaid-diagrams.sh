#!/bin/bash
# Extract and convert Mermaid diagrams from markdown files to PNG

set -e

OUTPUT_DIR="presentation-diagrams"
TEMP_DIR="/tmp/mermaid-extract-$$"

# Create directories
mkdir -p "$OUTPUT_DIR"
mkdir -p "$TEMP_DIR"

# Counter for diagram numbering
diagram_num=1

# Function to extract and convert Mermaid diagrams from a file
extract_from_file() {
    local file=$1
    local basename=$(basename "$file" .md)

    echo "Processing: $file"

    # Extract all mermaid code blocks
    awk '
        /```mermaid/ { in_mermaid=1; diagram++; next }
        /```/ && in_mermaid { in_mermaid=0; next }
        in_mermaid { print }
    ' "$file" | csplit -s -z -f "$TEMP_DIR/diagram-" - '/^$/' '{*}' 2>/dev/null || true

    # Convert each extracted diagram
    for mmd_file in "$TEMP_DIR"/diagram-*; do
        if [ -s "$mmd_file" ]; then
            output_name=$(printf "diagram-%02d-%s.png" $diagram_num "$basename")
            echo "  → Creating $output_name"

            # Convert to PNG using mermaid-cli
            mmdc -i "$mmd_file" -o "$OUTPUT_DIR/$output_name" -b transparent -w 1920 -H 1080 2>/dev/null || {
                echo "    ✗ Failed to convert diagram $diagram_num"
                continue
            }

            diagram_num=$((diagram_num + 1))
        fi
    done

    # Cleanup temp files for this file
    rm -f "$TEMP_DIR"/diagram-*
}

# Process all files with Mermaid diagrams
echo "Extracting Mermaid diagrams..."
echo

extract_from_file "README.md"
extract_from_file "docs/architecture.md"
extract_from_file "docs/reference-architecture-pattern.md"
extract_from_file "docs/repository-strategy.md"
extract_from_file "docs/future-vision-operator-integration.md"
extract_from_file "docs/bootstrap-installation.md"
extract_from_file "docs/BOOTSTRAP-QUICKSTART.md"

# Cleanup
rm -rf "$TEMP_DIR"

echo
echo "✓ Extraction complete!"
echo "  Total diagrams: $((diagram_num - 1))"
echo "  Output directory: $OUTPUT_DIR/"
echo
echo "Generated files:"
ls -lh "$OUTPUT_DIR"/*.png 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}'
