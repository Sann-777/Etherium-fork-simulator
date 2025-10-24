# 🛠️ Setup Guide

## Prerequisites

- **Docker** & **Docker Compose**
- **curl** and **jq** for JSON processing
- **Git** for version control

## Quick Installation

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/eth-fork-simulator.git
cd eth-fork-simulator
```

### 2. Verify Dependencies
```bash
# Check Docker
docker --version
docker-compose --version

# Check tools
curl --version
jq --version
```

### 3. Make Scripts Executable
```bash
chmod +x scripts/*.sh
```

## 🚀 Running the Simulation

### Option 1: Complete Automated Simulation
```bash
# Start everything and run full test
./scripts/host-best-fork-simulation.sh
```

### Option 2: Manual Step-by-Step
```bash
# 1. Start infrastructure
docker-compose up -d

# 2. Initialize nodes
docker exec fork-controller sh /app/scripts/init-nodes.sh

# 3. Check status
./scripts/host-status.sh

# 4. Create partition
./scripts/host-partition.sh

# 5. Generate transactions
./scripts/host-generate-txs.sh

# 6. Monitor divergence (wait 30 seconds)
sleep 30

# 7. Reconnect and observe
./scripts/host-reconnect.sh

# 8. Verify consensus
./scripts/host-status.sh
```

## 📊 Expected Output

### Successful Fork Simulation
```
🎯 FORK SIMULATION RESULTS:
✅ Network partition created and maintained
✅ Transactions generated on separate partitions
✅ Chain divergence observed (different block hashes)
✅ Network reconnected successfully  
✅ Consensus achieved (all nodes synchronized)
```

### Verification Steps
1. **During partition**: Node 1 shows "OFFLINE" or stops responding
2. **After transactions**: Different block hashes across partitions
3. **After reconnect**: All nodes show same block height

## 🐛 Troubleshooting

### Common Issues

**Nodes not starting:**
```bash
# Check Docker logs
docker logs geth-node-1
docker logs geth-node-2
docker logs geth-node-3

# Restart if needed
docker-compose restart
```

**Script permission errors:**
```bash
chmod +x scripts/*.sh
```

**jq command errors:**
```bash
# Install jq if missing
sudo apt-get install jq  # Ubuntu/Debian
brew install jq          # macOS
```

**Port conflicts:**
```bash
# Check what's using ports 8545-8547
netstat -tulpn | grep :854
```

### Network Issues

**Partition not working:**
```bash
# Manual partition test
docker network disconnect eth-fork-net geth-node-1
docker exec geth-node-1 ping geth-node-2  # Should fail
```

**Nodes not communicating:**
```bash
# Check peer counts
curl -s -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' | jq
```

## 🧹 Cleanup

```bash
# Stop and remove everything
docker-compose down

# Remove Docker network
docker network rm eth-fork-net 2>/dev/null || true

# Remove any dangling containers
docker rm -f $(docker ps -aq) 2>/dev/null || true
```

## 🔧 Advanced Configuration

### Custom Block Time
Edit `docker-compose.yml`:
```yaml
command:
  - --dev
  - --dev.period=5  # Change from 2 to 5 seconds
```

### Additional RPC Methods
Add to http.api:
```yaml
- --http.api=eth,net,web3,debug,admin,personal,txpool
```

### Resource Limits
```yaml
deploy:
  resources:
    limits:
      memory: 1G
      cpus: '0.5'
```

## 📞 Support

If you encounter issues:
1. Check the [troubleshooting section](#-troubleshooting)
2. Review Docker logs for error messages
3. Ensure all prerequisites are installed
4. Verify script permissions are correct

For this specific project, create issues on GitHub for assistance.
```

## 5. **Create Screenshot Directory and Instructions**

```bash
# Create directory for screenshots
mkdir -p SCREENSHOTS

# Create screenshot guide
cat > SCREENSHOTS/README.md << 'EOF'
# 📸 Portfolio Screenshots

Capture these screenshots for your portfolio:

## Essential Proof Shots

1. **`fork-simulation-proof.png`**
   - Run: `./scripts/host-best-fork-simulation.sh`
   - Capture: Output showing fork and consensus

2. **`docker-containers-running.png`**  
   - Run: `docker ps`
   - Capture: All 4 containers running

3. **`transaction-success.png`**
   - Run: `./scripts/host-generate-txs.sh`
   - Capture: Transaction hashes being generated

4. **`network-partition-proof.png`**
   - Run: `./scripts/host-partition.sh`
   - Capture: "Partition successful" message

## Bonus Shots

5. **`block-divergence.png`**
   - During partition, run `./scripts/host-status.sh`
   - Capture: Different block hashes

6. **`git-history.png`**
   - Run: `git log --oneline -10`
   - Capture: Progressive commit history

## Tips for Great Screenshots
- Use **light theme** for better readability
- **Full terminal window** showing commands and output
- **Clear, high-resolution** images
- **Annotate** important parts if needed
- **Multiple angles** of the same success
EOF
```

## 6. **Final Setup Commands**

```bash
# Create all documentation files
touch README.md ARCHITECTURE.md LEARNING_JOURNEY.md SETUP_GUIDE.md

# Copy the content above into each file
# (You'll need to paste the content manually or use a script)

# Create screenshot directory
mkdir -p SCREENSHOTS
touch SCREENSHOTS/README.md

# Make final commit
git add .
git commit -m "docs: complete portfolio documentation and project showcase

- Comprehensive README with project overview and technical details
- Architecture decisions documenting technical choices
- Learning journey showing growth and problem-solving
- Setup guide for reproducibility and demonstration
- Screenshot directory for portfolio evidence
- Ready for Ethereum Foundation DevOps intern application"

git push origin main
```
