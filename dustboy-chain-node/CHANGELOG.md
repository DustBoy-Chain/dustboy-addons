# Changelog

## 0.1.0

- Initial release
- Packages op-reth, op-node, and da-server as a single HA add-on
- s6-overlay manages all three services with dependency ordering
- User-configurable L1 RPC, P2P peer, DA credentials, and log level
- Persistent storage for chain data across HA restarts
- Auto-generates JWT secret and P2P node key on first run
