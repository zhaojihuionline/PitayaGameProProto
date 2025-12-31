#!/bin/bash
# Generate protobuf C# code (Unix-like) - Supports nested directory structure
# Recursively finds and generates all .proto files

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROTO_DIR="$SCRIPT_DIR/proto"
OUT_DIR="$SCRIPT_DIR/pb/csharp"

# Unity project paths
UNITY_PROTOS_ROOT="D:/Company/UnityPitayaGamePro/Assets/Scripts/Protocol/protos"
UNITY_PROTO_DIR="$UNITY_PROTOS_ROOT/pb/csharp"
UNITY_PROTO_SRC_DIR="$UNITY_PROTOS_ROOT/proto"

echo "=========================================="
echo "  Protobuf C# Code Generator"
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

    # Extract directory path (remove file name)
    dir_path=$(dirname "$rel_path")

    echo "[$total_files] Generating: $rel_path"
    echo "    Output Dir: $dir_path"

    # Create output directory matching proto structure
    mkdir -p "$OUT_DIR/$dir_path"

    # Generate proto file to matching directory structure
    if protoc --proto_path=. --csharp_out="$OUT_DIR/$dir_path" "$rel_path" 2>/dev/null; then
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

# Check results and copy to Unity
if [ $error_count -gt 0 ]; then
    echo "[ERROR] Some files failed to generate, please check errors above"
    exit 1
fi

if [ $total_files -eq 0 ]; then
    echo "[WARNING] No .proto files found"
    exit 1
fi

echo "[SUCCESS] All Protobuf C# files generated successfully!"
echo "Output: $OUT_DIR"
echo

# Copy to Unity project
echo "=========================================="
echo "  Copying to Unity Project"
echo "=========================================="
echo "Target pb/csharp: $UNITY_PROTO_DIR"
echo "Target proto:     $UNITY_PROTO_SRC_DIR"
echo

# Check if Unity project directory exists
if [ ! -d "$UNITY_PROTOS_ROOT" ]; then
    echo "[ERROR] Unity project directory not found!"
    echo "Please check the path: $UNITY_PROTOS_ROOT"
    echo
    exit 1
fi

# Clean target pb/csharp directory
if [ -d "$UNITY_PROTO_DIR" ]; then
    echo "Cleaning pb/csharp directory..."
    rm -rf "$UNITY_PROTO_DIR" 2>/dev/null || {
        echo "[WARNING] Failed to clean pb/csharp directory, it may be in use"
        echo "Attempting to continue..."
    }
else
    echo "[OK] pb/csharp directory already clean"
fi

# Clean target proto directory
if [ -d "$UNITY_PROTO_SRC_DIR" ]; then
    echo "Cleaning proto directory..."
    rm -rf "$UNITY_PROTO_SRC_DIR" 2>/dev/null || {
        echo "[WARNING] Failed to clean proto directory, it may be in use"
        echo "Attempting to continue..."
    }
else
    echo "[OK] proto directory already clean"
fi

# Create target directories
mkdir -p "$UNITY_PROTO_DIR"
mkdir -p "$UNITY_PROTO_SRC_DIR"

# Copy pb/csharp files (generated C# files)
echo "Copying pb/csharp files..."
if cp -r "$OUT_DIR/." "$UNITY_PROTO_DIR/"; then
    echo "[OK] pb/csharp files copied successfully"
else
    echo "[ERROR] Failed to copy pb/csharp files to Unity project"
    exit 1
fi

# Copy proto files (source .proto files)
echo "Copying proto files..."
if cp -r "$PROTO_DIR/." "$UNITY_PROTO_SRC_DIR/"; then
    echo "[OK] proto files copied successfully"
else
    echo "[ERROR] Failed to copy proto files to Unity project"
    exit 1
fi

echo
echo "[SUCCESS] All files copied to Unity project!"
echo "  - pb/csharp/ (generated C# files)"
echo "  - proto/     (source .proto files)"
echo
