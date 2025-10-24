# 🏗️ Architecture Decisions

## Design Philosophy

This project follows a **Docker-native** approach to Ethereum node orchestration, prioritizing:
- **Reproducibility**: Consistent environments via containers
- **Isolation**: Clean separation of node instances
- **Observability**: Built-in monitoring and status checks
- **Automation**: Script-driven operations

## System Architecture

### Container Layout
```
📦 Docker Compose Stack
├── 🔗 eth-fork-net (Bridge Network)
│   ├── 🐋 geth-node-1:8545
│   ├── 🐋 geth-node-2:8546  
│   ├── 🐋 geth-node-3:8547
│   └── 🎮 fork-controller
└── 📁 Host Volume Mounts
    └── scripts/ → /app/scripts
```

### Network Design
- **Bridge Network**: Isolated Docker network for node communication
- **Port Mapping**: 8545-8547 for external RPC access
- **Internal DNS**: Container name resolution (geth-node-1, etc.)

## Technical Decisions

### 1. Geth Dev Mode Selection
**Choice**: Use `--dev` mode instead of testnet
**Reasoning**:
- Instant synchronization (no 400GB storage requirement)
- Predictable block production (2-second intervals)
- Pre-funded accounts for transaction testing
- Perfect for fork simulation experiments

### 2. Dual Script Architecture
**Host Scripts** (`host-*.sh`):
- Run from host machine for reliability
- Direct Docker command access
- Production-ready operations

**Container Scripts** (`init-nodes.sh`, `monitor-status.sh`):
- Demonstrate Docker internal networking knowledge
- Show container-to-container communication
- Learning-focused implementations

### 3. Partition Strategy
**Approach**: Complete network isolation via `docker network disconnect`
**Trade-off**: Loses RPC access but provides clear fork evidence
**Evidence**: Block height differences after reconnect prove fork occurred

## Component Details

### Geth Node Configuration
```yaml
command:
  - --dev                    # Development mode
  - --dev.period=2          # 2-second blocks
  - --http                  # Enable JSON-RPC
  - --http.addr=0.0.0.0    # Accept external connections
  - --http.api=eth,net,web3,debug,admin
  - --metrics               # Enable monitoring
```

### Fork Simulation Workflow
1. **Baseline**: All nodes synchronized
2. **Partition**: Node 1 isolated from Nodes 2-3
3. **Divergence**: Independent block production
4. **Transaction**: Different histories on each partition  
5. **Reconnection**: Network restored
6. **Consensus**: Nodes agree on canonical chain

## Lessons Learned

### Docker Networking
- Containers lose all connectivity when disconnected from networks
- Internal DNS works reliably for container-to-container communication
- Host-level operations often more reliable for network control

### Ethereum RPC Patterns
- Geth dev mode mines transactions in separate blocks
- "Latest" block may not contain recent transactions
- Block hashes differ even with same transactions due to mining variations

### Production Readiness
- Error handling is crucial for reliable automation
- Status checks should validate multiple aspects
- Documentation should include failure scenarios
