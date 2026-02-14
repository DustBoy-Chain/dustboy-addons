#!/command/with-contenv bash
# Initialize JibChain L1 Node configuration
# Creates data directories, copies chain config, generates JWT

set -e

DATA_DIR="/data"
GETH_DIR="${DATA_DIR}/geth"
CL_DIR="${DATA_DIR}/lighthouse"
CONFIG_DIR="${DATA_DIR}/config"
BUNDLED="/opt/jibchain/chain-config"

echo "[init] JibChain L1 Node v0.1.0"
echo "[init] Chain ID: 8899 (JibChain)"

# Create data directories
mkdir -p "${GETH_DIR}" "${CL_DIR}" "${CONFIG_DIR}"

# Copy bundled chain config if not present
# EL config
for f in genesis.json el_nodes.list; do
    if [ ! -f "${CONFIG_DIR}/${f}" ] && [ -f "${BUNDLED}/${f}" ]; then
        echo "[init] Installing ${f}"
        cp "${BUNDLED}/${f}" "${CONFIG_DIR}/${f}"
    fi
done

# CL config — Lighthouse needs testnet-dir with specific files
CL_TESTNET="${CONFIG_DIR}/testnet"
mkdir -p "${CL_TESTNET}"
for f in cl-config.yaml genesis.ssz deploy_block.txt deposit_contract_block.txt deposit_contract.txt cl_nodes.list boot_enr.txt; do
    src="${BUNDLED}/${f}"
    # cl-config.yaml goes as config.yaml in testnet dir
    if [ "${f}" = "cl-config.yaml" ]; then
        dst="${CL_TESTNET}/config.yaml"
    elif [ "${f}" = "cl_nodes.list" ] || [ "${f}" = "boot_enr.txt" ]; then
        dst="${CL_TESTNET}/${f}"
    else
        dst="${CL_TESTNET}/${f}"
    fi
    if [ ! -f "${dst}" ] && [ -f "${src}" ]; then
        echo "[init] Installing ${f} -> $(basename ${dst})"
        cp "${src}" "${dst}"
    fi
done

# Generate JWT secret if not present
if [ ! -f "${CONFIG_DIR}/jwt.hex" ]; then
    echo "[init] Generating JWT secret"
    openssl rand -hex 32 > "${CONFIG_DIR}/jwt.hex"
fi

# Initialize Geth if not already done
if [ ! -d "${GETH_DIR}/geth/chaindata" ]; then
    echo "[init] Initializing Geth database with genesis..."
    geth --datadir "${GETH_DIR}" init "${CONFIG_DIR}/genesis.json"
    echo "[init] Geth initialized"
else
    echo "[init] Geth database already exists"
fi

echo "[init] Config validated:"
echo "[init]   genesis.json: $(wc -c < "${CONFIG_DIR}/genesis.json") bytes"
echo "[init]   genesis.ssz: $(wc -c < "${CL_TESTNET}/genesis.ssz") bytes"
echo "[init]   jwt.hex: present"
echo "[init]   bootnodes: $(wc -l < "${CONFIG_DIR}/el_nodes.list") EL nodes"
echo "[init] Ready"

exit 0
