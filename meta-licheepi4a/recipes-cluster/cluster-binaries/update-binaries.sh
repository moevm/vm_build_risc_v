#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FILES_DIR="$SCRIPT_DIR/files"
GRPC_DIR="${GRPC_SERVER_DIR:-$(cd "$SCRIPT_DIR/../../../../grpc_server" && pwd)}"

mkdir -p "$FILES_DIR"

cp "$GRPC_DIR/worker/bazel-bin/worker" "$FILES_DIR/worker"
cp "$GRPC_DIR/controller/bazel-bin/cmd/grpc_server/grpc_server_/grpc_server" "$FILES_DIR/controller"
cp "$GRPC_DIR/controller/internal/service/config/categories.json" "$FILES_DIR/"
cp "$GRPC_DIR/controller/internal/service/config/providers.json" "$FILES_DIR/"
cp "$GRPC_DIR/test/virtual_load_network/configs/worker.env" "$FILES_DIR/"
cp "$GRPC_DIR/test/virtual_load_network/configs/controller.env" "$FILES_DIR/"
cp "$GRPC_DIR/test/virtual_load_network/configs/policy.toml" "$FILES_DIR/"

echo "Binaries and configs copied to $FILES_DIR"
