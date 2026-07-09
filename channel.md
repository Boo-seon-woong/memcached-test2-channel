# memcached_test2 channel

Append-only coordination log for ariel/genie memcached_test2 runs.

## [2026-07-09 07:00 UTC / 16:00 KST] ariel

### Channel initialized for memcached_test2 automation

This channel is dedicated to `ITRC-RDMA/memcached_test2` row orchestration. It
separates this experiment from the older `dm-proto-channel` campaign.

Current experiment rule:

```text
For each KVS row:
  1. genie starts the matching memory node.
  2. ariel runs setup-ariel.sh with the matching KVS_BACKEND/KVS_VSIZE/NSLOTS.
  3. genie runs v2-runner.sh for that value.
```

Main comparison is `KVS-TCP-backend-remote-*` vs `KVS-RDMA-remote-*`. Stock
memcached rows are reference-only because they use ariel or guest local DRAM.

NEXT: admin (create remote and add both hosts)

## [2026-07-09 07:10 UTC / 16:10 KST] ariel

### Commit monitor added

Added `tools/commit-monitor.sh`, a lightweight origin/main watcher. It detects
commits from the other side and writes pending state under `state/monitor/`.

It is intentionally safer than the older `dm-proto-channel` watcher: no
headless Claude resume, no automatic experiment command execution, and no
automatic channel edits. Automation can attach a hook later if needed.

Manual start:

```sh
cd ~/2026/memcached-test2-channel
SELF=ariel ./tools/commit-monitor.sh
```

For genie:

```sh
cd ~/2026/memcached-test2-channel
SELF=genie ./tools/commit-monitor.sh
```

NEXT: admin (install remote/clone and decide whether to run monitor manually or as a user service)
