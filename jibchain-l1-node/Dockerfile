# JibChain L1 Node — HA Add-on
# Multi-stage build: extract binaries from production images

ARG GETH_IMAGE=ethereum/client-go:release-1.15
# NOTE: Use lighthouse-gnumalloc:v5.0.0 (built without jemalloc) for Pi 5
# which has 16KB pages. Standard sigp/lighthouse uses jemalloc compiled for
# 4KB pages and crashes on Pi 5 with "Unsupported system page size".
# Build with: --no-default-features (disables jemalloc, uses system allocator)
ARG LIGHTHOUSE_IMAGE=lighthouse-gnumalloc:v5.0.0
ARG BUILD_FROM

# Stage 1: Geth (Go, statically linked)
FROM ${GETH_IMAGE} AS geth-bin

# Stage 2: Lighthouse (Rust, glibc-linked)
FROM ${LIGHTHOUSE_IMAGE} AS lighthouse-bin

# Final stage: HA Debian base with glibc
FROM ${BUILD_FROM}

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    jq \
    openssl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy binaries from build stages
COPY --from=geth-bin /usr/local/bin/geth /usr/local/bin/geth
COPY --from=lighthouse-bin /usr/local/bin/lighthouse /usr/local/bin/lighthouse

# Bundle chain config (genesis.json, genesis.ssz, CL config, bootnodes)
COPY chain-config/ /opt/jibchain/chain-config/

# Copy s6-overlay service definitions and scripts
COPY rootfs /

# Ensure all scripts are executable
RUN chmod +x /etc/s6-overlay/scripts/* 2>/dev/null || true
RUN find /etc/s6-overlay/s6-rc.d -name "run" -exec chmod +x {} \;

LABEL \
    io.hass.version="0.1.0" \
    io.hass.type="addon" \
    io.hass.arch="aarch64"
