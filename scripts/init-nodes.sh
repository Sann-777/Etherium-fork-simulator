#!/bin/bash

echo "🚀 Ethereum Fork Simulator - Node Initialization"
echo "================================================"

# Install curl in Alpine container (if needed)
if ! command -v curl &> /dev/null; then
    echo "📦 Installing curl..."
    apk add --no-cache curl jq
fi

# Function to check if node is ready
wait_for_node() {
    local node_name=$1
    local rpc_url=$2
    local max_attempts=5
    local attempt=1
    
    echo "⏳ Waiting for $node_name to be ready..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s -X POST $rpc_url \
            -H "Content-Type: application/json" \
            --data '{"jsonrpc":"2.0","method":"net_version","params":[],"id":1}' > /dev/null 2>&1; then
            echo "✅ $node_name is ready!"
            return 0
        fi
        
        echo "   Attempt $attempt/$max_attempts: $node_name not ready yet..."
        sleep 3
        ((attempt++))
    done
    
    echo "❌ $node_name failed to start within timeout"
    return 1
}

echo "1. Testing network connectivity..."
docker exec fork-controller ping -c 1 geth-node-1
docker exec fork-controller ping -c 1 geth-node-2
docker exec fork-controller ping -c 1 geth-node-3

echo ""
echo "2. Waiting for all Geth nodes to be ready..."
wait_for_node "geth-node-1" "http://geth-node-1:8545"
wait_for_node "geth-node-2" "http://geth-node-2:8545" 
wait_for_node "geth-node-3" "http://geth-node-3:8545"

echo ""
echo "3. Quick status check..."
for i in 1 2 3; do
    echo "--- geth-node-$i ---"
    curl -s -X POST http://geth-node-$i:8545 \
        -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | \
        grep -o '"result":"[^"]*"' | cut -d'"' -f4
done

echo ""
echo "🎉 If you see block numbers above, nodes are working!"
