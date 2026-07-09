# memcached-test2-channel

ariel and genie coordination channel for `ITRC-RDMA/memcached_test2` two-server
experiments. This repository is intentionally smaller than `dm-proto-channel`:
it is only for row-by-row orchestration, command handoff, raw-result transfer,
and status reporting.

## Roles

| role | host | responsibility |
|---|---|---|
| ariel | `10.99.0.1` host, `10.99.0.3` SEV guest | starts stock/reference service and KVS compute, chooses backend/value/nslots rows |
| genie | `10.99.0.2` | starts TCP/RDMA memory node, runs `v2-runner.sh`, returns raw output |
| admin | human operator | resolves conflicts and approves changes to the protocol |

## Layout

| path | purpose |
|---|---|
| `channel.md` | append-only conversation log |
| `transfer/` | scripts, small bundles, raw result archives, and `SHA256SUMS` |
| `runs/` | optional run manifests or copied summaries |
| `state/` | small current-state files for automation; do not treat as authoritative results |
| `templates/` | reusable channel entry formats |
| `tools/` | local helper scripts |

## Protocol

1. Pull before writing:
   ```sh
   git pull --rebase
   ```
2. Append to `channel.md`; do not edit old entries except to fix a fresh,
   unpushed typo.
3. Every real entry ends with exactly one `NEXT:` line:
   `NEXT: ariel`, `NEXT: genie`, or `NEXT: none (reason)`.
4. Commit messages use `[ariel]`, `[genie]`, or `[admin]` prefixes.
5. Files added under `transfer/` require:
   ```sh
   ./tools/update-sha256.sh
   ```
6. Report command output as fenced code blocks. Summaries without the command
   and key output are not enough for experiment evidence.

## Experiment Invariant

KVS rows are valid only when the memory node and compute node use the same
layout:

```text
backend, value size, nslots, environment
```

Changing any of `backend`, `value size`, `nslots`, `nonTEE/SEV` requires a new
sequence:

```text
genie: start matching memnode
ariel: run setup-ariel.sh to attach compute
genie: run v2-runner for that one value
```

Mix changes (`RO`/`WO`), repeated runs, and `TEST_TIME` changes do not require a
new attach as long as backend/value/nslots/environment are unchanged.

## Main Comparison

`stock-TCP-remote-*` is a remote-client stock memcached reference, not a
remote-memory baseline. Main remote-memory comparison is:

```text
KVS-TCP-backend-remote-* vs KVS-RDMA-remote-*
```

## Initial Setup After Remote Creation

After the human creates the remote repository, each host can use:

```sh
cd ~/2026
git clone <remote-url> memcached-test2-channel
```

or, if this local repo is the source:

```sh
cd ~/2026/memcached-test2-channel
git remote add origin <remote-url>
git push -u origin main
```
