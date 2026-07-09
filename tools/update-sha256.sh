#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../transfer"
find . -type f ! -name SHA256SUMS -printf '%P\0' | sort -z | xargs -0 --no-run-if-empty sha256sum > SHA256SUMS
