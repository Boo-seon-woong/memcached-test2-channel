## [YYYY-MM-DD HH:MM UTC / HH:MM KST] ariel

### Request: <backend> <env> value=<value> nslots=<nslots>

Run id:

```text
<RUN>
```

Genie command:

```sh
cd ~/2026/ITRC-RDMA/memcached-rdma/common
# stop any old matching memnode first
<memnode command>
```

Ariel command already run or to be run:

```sh
cd ~/2026/ITRC-RDMA/memcached-rdma/results/memcached_test2
KVS_BACKEND=<TCP|RDMA> STOCK_MEM_MB=32768 KVS_VSIZE=<value> NSLOTS=<nslots> ./setup-ariel.sh <nonTEE|SEV>
```

Genie runner command:

```sh
cd ~/2026/dm-prototype/v2-bench
VSIZES=<value> MIXES="RO WO" RUNS=3 TEST_TIME=30 KEYMAX=16384 \
  bash v2-runner.sh <config> <service-ip> 11212 "$RUN"
```

NEXT: genie
