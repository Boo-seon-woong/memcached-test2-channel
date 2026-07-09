#!/usr/bin/env bash
set -euo pipefail

SELF=${1:?usage: append-status.sh ariel|genie}
STATUS=${2:-idle}
NEXT=${3:-none}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
UTC=$(TZ=UTC date '+%Y-%m-%d %H:%M UTC')
KST=$(TZ=Asia/Seoul date '+%H:%M KST')

cat >> "$ROOT/channel.md" <<EOF

## [$UTC / $KST] $SELF - STATUS

상태: $STATUS
NEXT: $NEXT
EOF
