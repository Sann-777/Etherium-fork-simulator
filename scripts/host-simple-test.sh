#!/bin/bash

echo "🧪 SIMPLE: Test Basic Node Connectivity"
echo "======================================"

for port in 8545 8546 8547; do
    echo "Testing port $port:"
    
    # Test basic connectivity
    response=$(curl -s -X POST http://localhost:$port \
        -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"net_version","params":[],"id":1}' 2>/dev/null)
    
    version=$(echo "$response" | jq -r '.result' 2>/dev/null)
    
    if [ "$version" = "1337" ]; then
        echo "   ✅ Connected - Network ID: $version"
        
        # Get block number
        block_response=$(curl -s -X POST http://localhost:$port \
            -H "Content-Type: application/json" \
            --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' 2>/dev/null)
        block=$(echo "$block_response" | jq -r '.result' 2>/dev/null)
        echo "   📦 Current block: $block"
    else
        echo "   ❌ Not responding or wrong network ID"
        echo "   Raw response: $response"
    fi
    echo ""
done
