#!/bin/bash
# DustBoy Chain Node healthcheck
# Verifies op-reth is responding and syncing

RPC_RESPONSE=$(curl -sf -X POST \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
    http://127.0.0.1:9545 2>/dev/null)

if [ $? -ne 0 ]; then
    echo "UNHEALTHY: op-reth RPC not responding"
    exit 1
fi

BLOCK_HEX=$(echo "${RPC_RESPONSE}" | jq -r '.result // empty')
if [ -z "${BLOCK_HEX}" ]; then
    echo "UNHEALTHY: no block number in response"
    exit 1
fi

BLOCK_DEC=$((${BLOCK_HEX}))
echo "HEALTHY: block ${BLOCK_DEC}"
exit 0
