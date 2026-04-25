#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARTIFACTS_DIR="${ROOT_DIR}/artifacts"
BUILD_DIR="${ROOT_DIR}/.build/pillow-layer"
RUNTIME_IMAGE="public.ecr.aws/sam/build-python3.12:latest"

mkdir -p "${ARTIFACTS_DIR}"
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}/python"

docker run --rm \
  -v "${ROOT_DIR}:/var/task" \
  "${RUNTIME_IMAGE}" \
  /bin/sh -lc "python -m pip install --upgrade pip && python -m pip install pillow -t /var/task/.build/pillow-layer/python"

cd "${BUILD_DIR}"
zip -qr "${ARTIFACTS_DIR}/pillow_layer.zip" python

echo "Created ${ARTIFACTS_DIR}/pillow_layer.zip"
