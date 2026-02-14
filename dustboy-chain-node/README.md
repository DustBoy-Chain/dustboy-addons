# DustBoy Chain Node

Home Assistant add-on for running a DustBoy Chain (Chain ID 555888) replica node.

## What it does

Runs a full OP Stack L2 replica node that syncs with the DustBoy Chain production network. Three services run inside a single container, managed by s6-overlay:

- **op-reth** — Execution layer (Rust Ethereum client)
- **op-node** — Consensus layer (L1 derivation + P2P gossip)
- **da-server** — Alt-DA blob retrieval from S3-compatible storage

## Requirements

- Raspberry Pi 5 (8 GB) or equivalent aarch64 hardware
- ~10 GB storage for chain data
- DA S3 credentials (Cloudflare R2 access)
- Network access to JibChain L1 RPC and DustBoy Chain P2P

## Installation

### 1. Add the repository

Go to **Settings > Add-ons > Add-on Store > Repositories** and add:

```
https://github.com/DustBoy-Chain/dustboy-infra
```

### 2. Place chain config files

Before first start, copy `genesis.json` and `rollup.json` into the add-on's data directory, or include them in `chain-config/` before building.

These files are available at:
https://github.com/DustBoy-Chain/dustboy-infra/tree/main/config

### 3. Configure

In the add-on configuration tab, set:

- **L1 RPC URL** — JibChain L1 endpoint (default: public RPC)
- **DA S3** credentials — for blob retrieval
- Other settings have sensible defaults

### 4. Start

The add-on will generate a JWT secret and P2P key on first run, then start syncing.

## Migrating from docker-compose

If you already have chain data from a docker-compose setup:

1. Stop the existing containers
2. Copy op-reth data to the add-on's `/data/reth/` directory
3. Copy node-db to `/data/node-db/`
4. Copy config files to `/data/config/`
5. Start the add-on

## Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 9545 | TCP | L2 JSON-RPC |
| 9546 | TCP | L2 WebSocket |
| 30301 | TCP/UDP | op-reth P2P |
| 9222 | TCP/UDP | op-node P2P |

## Architecture

```
                    ┌─────────────────────────────────┐
                    │     DustBoy Chain Node Add-on    │
                    │                                  │
  L2 RPC ──────────┤  op-reth (:8545)                 │
                    │    ↑ authrpc (:8551)             │
                    │    │                             │
                    │  op-node (:8547)                 │
                    │    ↑ DA requests                 │
                    │    │                             │
                    │  da-server (:3100)               │
                    └────┬─────────────┬──────────────┘
                         │             │
                    JibChain L1    Cloudflare R2
                    (L1 RPC)      (DA blobs)
```
