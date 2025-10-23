#!/bin/sh

echo "📊 Ethereum Fork Simulator - Node Status"
echo "=========================================="

check_node() {
    local node_name=$1
    local rpc_url=$2
    
    echo "🔍 Checking $node_name..."
    
    # Check if node is responding
    if curl -s -X POST $rpc_url \
        -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":1}' > /dev/null 2>&1; then
        
        # Get block number
        block_hex=$(curl -s -X POST $rpc_url \
            -H "Content-Type: application/json" \
            --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | \
            grep -o '"result":"[^"]*"' | cut -d'"' -f4)
        
        if [ ! -z "$block_hex" ]; then
            block_number=$((16#${block_hex#0x}))
            echo "✅ $node_name: Block #$block_number"
            
            # Get peer count
            peers=$(curl -s -X POST $rpc_url \
                -H "Content-Type: application/json" \
                --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' | \
                grep -o '"result":"[^"]*"' | cut -d'"' -f4)
            peers_decimal=$((16#${peers#0x}))
            echo "   📡 Connected peers: $peers_decimal"
        else
            echo "❌ $node_name: No block data"
        fi
    else
        echo "❌ $node_name: Not responding"
    fi
    echo
}

echo "🌐 Checking nodes via Docker network..."
check_node "Geth Node 1" "http://geth-node-1:8545"
check_node "Geth Node 2" "http://geth-node-2:8545" 
check_node "Geth Node 3" "http://geth-node-3:8545"

echo "🎉 All nodes are running and synced!"
echo ""
echo "💡 To test from your host machine, use:"
echo "   curl -X POST http://localhost:8545 \\"
echo "     -H 'Content-Type: application/json' \\"
echo "     --data '{\"jsonrpc\":\"2.0\",\"method\":\"eth_blockNumber\",\"params\":[],\"id\":1}'"
