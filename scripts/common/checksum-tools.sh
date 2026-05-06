#!/bin/bash
# checksum-tools.sh - Checksum generation and verification utilities

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Generate checksums for a directory
generate_checksums() {
  local target_dir="$1"
  local checksum_file="${2:-CHECKSUMS.sha256}"

  echo -e "${YELLOW}Generating checksums for: $target_dir${NC}"

  cd "$target_dir"

  # Generate checksums for all files, excluding the checksum file itself
  find . -type f ! -name "$checksum_file" ! -path "*/.*" -exec sha256sum {} \; > "$checksum_file"

  local file_count
  file_count=$(wc -l < "$checksum_file")

  echo -e "${GREEN}✓ Generated checksums for $file_count files${NC}"
  echo "Checksum file: $target_dir/$checksum_file"

  return 0
}

# Verify checksums for a directory
verify_checksums() {
  local target_dir="$1"
  local checksum_file="${2:-CHECKSUMS.sha256}"

  echo -e "${YELLOW}Verifying checksums for: $target_dir${NC}"

  cd "$target_dir"

  if [ ! -f "$checksum_file" ]; then
    echo -e "${RED}✗ Checksum file not found: $checksum_file${NC}"
    return 1
  fi

  local total_files
  total_files=$(wc -l < "$checksum_file")
  echo "Verifying $total_files files..."

  if sha256sum -c "$checksum_file" 2>&1 | tee checksum_verify.log; then
    echo -e "${GREEN}✓ All checksums verified successfully${NC}"
    rm -f checksum_verify.log
    return 0
  else
    echo -e "${RED}✗ Checksum verification FAILED${NC}"
    echo "See checksum_verify.log for details"
    return 1
  fi
}

# Calculate checksum for a single file
file_checksum() {
  local file_path="$1"

  if [ ! -f "$file_path" ]; then
    echo -e "${RED}✗ File not found: $file_path${NC}"
    return 1
  fi

  sha256sum "$file_path" | awk '{print $1}'
}

# Compare two checksum files
compare_checksums() {
  local checksum_file1="$1"
  local checksum_file2="$2"

  if [ ! -f "$checksum_file1" ] || [ ! -f "$checksum_file2" ]; then
    echo -e "${RED}✗ One or both checksum files not found${NC}"
    return 1
  fi

  echo "Comparing checksums..."
  echo "File 1: $checksum_file1"
  echo "File 2: $checksum_file2"

  # Sort both files and compare
  if diff <(sort "$checksum_file1") <(sort "$checksum_file2") > /dev/null; then
    echo -e "${GREEN}✓ Checksums match${NC}"
    return 0
  else
    echo -e "${YELLOW}⚠ Checksums differ${NC}"
    echo "Differences:"
    diff <(sort "$checksum_file1") <(sort "$checksum_file2") || true
    return 1
  fi
}

# Usage information
usage() {
  cat <<EOF
Checksum Tools - Generate and verify SHA256 checksums

Usage: $0 <command> [arguments]

Commands:
  generate <directory> [checksum_file]   Generate checksums for directory
  verify <directory> [checksum_file]     Verify checksums in directory
  file <file_path>                       Calculate checksum for single file
  compare <file1> <file2>                Compare two checksum files

Examples:
  $0 generate /path/to/mirror-archive
  $0 verify /path/to/mirror-archive
  $0 file /path/to/archive.tar.gz
  $0 compare old-checksums.txt new-checksums.txt

EOF
}

# Main execution
main() {
  if [ $# -lt 1 ]; then
    usage
    exit 1
  fi

  local command="$1"
  shift

  case "$command" in
    generate)
      if [ $# -lt 1 ]; then
        echo "Error: directory required"
        usage
        exit 1
      fi
      generate_checksums "$@"
      ;;
    verify)
      if [ $# -lt 1 ]; then
        echo "Error: directory required"
        usage
        exit 1
      fi
      verify_checksums "$@"
      ;;
    file)
      if [ $# -lt 1 ]; then
        echo "Error: file path required"
        usage
        exit 1
      fi
      file_checksum "$@"
      ;;
    compare)
      if [ $# -lt 2 ]; then
        echo "Error: two checksum files required"
        usage
        exit 1
      fi
      compare_checksums "$@"
      ;;
    *)
      echo "Error: Unknown command: $command"
      usage
      exit 1
      ;;
  esac
}

# Run main if script is executed directly
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
  main "$@"
fi
