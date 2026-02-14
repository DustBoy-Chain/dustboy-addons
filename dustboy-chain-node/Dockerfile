# DustBoy Chain Node — HA Add-on
# Multi-stage build: extract binaries from proven production images

# All ARGs must be declared before any FROM to be visible across stages
ARG OP_RETH_VERSION=v1.5.1
ARG OP_NODE_IMAGE=ghcr.io/otternode-io/ott-op-stack-1103
ARG DA_SERVER_IMAGE=us-docker.pkg.dev/oplabs-tools-artifacts/images/da-server:latest
ARG BUILD_FROM

# Stage 1: op-reth (Rust, glibc-linked)
FROM ghcr.io/paradigmxyz/op-reth:${OP_RETH_VERSION} AS op-reth-bin

# Stage 2: op-node (Go, statically linked)
FROM ${OP_NODE_IMAGE} AS opstack-bin

# Stage 3: da-server (Go, statically linked)
FROM ${DA_SERVER_IMAGE} AS da-server-bin

# Final stage: HA Debian base image with s6-overlay (glibc native)
FROM ${BUILD_FROM}

# Install runtime dependencies (Debian apt)
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    jq \
    openssl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy binaries from build stages
COPY --from=op-reth-bin /usr/local/bin/op-reth /usr/local/bin/op-reth
COPY --from=opstack-bin /app/op-node /usr/local/bin/op-node
COPY --from=da-server-bin /usr/local/bin/da-server /usr/local/bin/da-server

# Bundle chain config (genesis.json, rollup.json, l1-chain-config.json)
COPY chain-config/ /opt/dustboy/chain-config/

# Copy s6-overlay service definitions and scripts
COPY rootfs /

# Ensure all scripts are executable
RUN chmod +x /etc/s6-overlay/scripts/* /usr/bin/healthcheck.sh 2>/dev/null || true
RUN find /etc/s6-overlay/s6-rc.d -name "run" -exec chmod +x {} \;

LABEL \
    io.hass.version="0.1.0" \
    io.hass.type="addon" \
    io.hass.arch="aarch64"
