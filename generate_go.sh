#!/bin/bash
# Generate protobuf Go code (Unix-like) - Supports nested directory structure
# Recursively finds and generates all .proto files

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROTO_DIR="$SCRIPT_DIR/proto"
OUT_DIR="$SCRIPT_DIR/pb/golang"

echo "=========================================="
echo "  Protobuf Go Code Generator"
echo "=========================================="
echo "Proto Directory: $PROTO_DIR"
echo "Output Directory: $OUT_DIR"
echo

# Create output directory
mkdir -p "$OUT_DIR"

# Change to proto directory
cd "$PROTO_DIR"

# Generation counters
total_files=0
success_count=0
error_count=0

# Find all .proto files recursively
echo "Searching for .proto files..."
echo

while IFS= read -r -d '' proto_file; do
    ((total_files++)) || true

    # Get relative path from proto directory
    rel_path="${proto_file#$PROTO_DIR/}"

    echo "[$total_files] Generating: $rel_path"

    # Generate proto file
    if protoc --proto_path=. --go_out="$OUT_DIR" --go_opt=paths=source_relative "$rel_path" 2>/dev/null; then
        echo "    [OK]"
        ((success_count++)) || true
    else
        echo "    [FAILED]"
        ((error_count++)) || true
    fi
    echo
done < <(find . -name "*.proto" -type f -print0)

# Check if any files were found
if [ $total_files -eq 0 ]; then
    echo "[WARNING] No .proto files found in $PROTO_DIR"
    echo
    exit 1
fi

# Output statistics
echo "=========================================="
echo "  Generation Complete"
echo "=========================================="
echo "Total Files: $total_files"
echo "Succeeded: $success_count"
echo "Failed: $error_count"
echo

if [ $error_count -eq 0 ]; then
    if [ $total_files -gt 0 ]; then
        echo "[SUCCESS] All Protobuf files generated successfully!"
        echo "Output: $OUT_DIR"
    else
        echo "[WARNING] No files to generate"
    fi
else
    echo "[ERROR] Some files failed to generate, please check errors"
    exit 1
fi

echo
