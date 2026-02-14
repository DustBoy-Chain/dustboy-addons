#!/command/with-contenv bash
# Initialize DustBoy Chain Node configuration
# Creates data directories, generates secrets, validates chain config

set -e

DATA_DIR="/data"
CONFIG_DIR="${DATA_DIR}/config"
RETH_DIR="${DATA_DIR}/reth"
NODE_DB_DIR="${DATA_DIR}/node-db"
LOG_DIR="${DATA_DIR}/logs"
BUNDLED_CONFIG="/opt/dustboy/chain-config"

echo "[init] DustBoy Chain Node v0.1.0"
echo "[init] Chain ID: 555888 (DustBoy IoT Blockchain)"

# Create data directories
mkdir -p "${CONFIG_DIR}" "${RETH_DIR}" "${NODE_DB_DIR}" "${LOG_DIR}"

# Copy bundled chain config if not already present
for f in genesis.json rollup.json l1-chain-config.json; do
    if [ ! -f "${CONFIG_DIR}/${f}" ] && [ -f "${BUNDLED_CONFIG}/${f}" ]; then
        echo "[init] Installing bundled ${f}"
        cp "${BUNDLED_CONFIG}/${f}" "${CONFIG_DIR}/${f}"
    fi
done

# Generate JWT secret if not present
if [ ! -f "${CONFIG_DIR}/jwt.txt" ]; then
    echo "[init] Generating JWT secret"
    openssl rand -hex 32 > "${CONFIG_DIR}/jwt.txt"
fi

# Generate P2P node key if not present
if [ ! -f "${CONFIG_DIR}/p2p-node-key" ]; then
    echo "[init] Generating P2P node key"
    openssl rand -hex 32 > "${CONFIG_DIR}/p2p-node-key"
fi

# Validate required config files
MISSING=""
for f in genesis.json rollup.json; do
    if [ ! -f "${CONFIG_DIR}/${f}" ]; then
        MISSING="${MISSING} ${f}"
    fi
done

if [ -n "${MISSING}" ]; then
    echo "[init] ERROR: Missing required config files:${MISSING}"
    echo "[init] Place them in ${CONFIG_DIR}/ or include in chain-config/ during build"
    echo "[init] Download from: https://github.com/DustBoy-Chain/dustboy-infra/tree/main/config"
    exit 1
fi

echo "[init] Config validated:"
echo "[init]   genesis.json: $(wc -c < "${CONFIG_DIR}/genesis.json") bytes"
echo "[init]   rollup.json: $(wc -c < "${CONFIG_DIR}/rollup.json") bytes"
echo "[init]   jwt.txt: present"
echo "[init]   p2p-node-key: present"
echo "[init] Data directories ready"

exit 0
