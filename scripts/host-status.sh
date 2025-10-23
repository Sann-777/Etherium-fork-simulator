#!/bin/bash

echo "📊 HOST: Detailed Node Status Check"
echo "==================================="

for port in 8545 8546 8547; do
    case $port in
        8545) node_name="geth-node-1 (Partition A)";;
        8546) node_name="geth-node-2 (Partition B)";;
        8547) node_name="geth-node-3 (Partition B)";;
    esac
    
    echo ""
    echo "🔍 $node_name:"
    
    # Test basic connectivity first
    version_response=$(curl -s -X POST http://localhost:$port \
        -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"net_version","params":[],"id":1}' 2>/dev/null)
    version=$(echo "$version_response" | jq -r '.result' 2>/dev/null)
    
    if [ "$version" != "1337" ]; then
        echo "   ❌ OFFLINE - Node not responding to RPC"
        continue
    fi
    
    # Get detailed block information
    block_response=$(curl -s -X POST http://localhost:$port \
        -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest", true],"id":1}' 2>/dev/null)
    
    block_number=$(echo "$block_response" | jq -r '.result.number' 2>/dev/null)
    block_hash=$(echo "$block_response" | jq -r '.result.hash' 2>/dev/null)
    block_txs=$(echo "$block_response" | jq -r '.result.transactions | length' 2>/dev/null)
    parent_hash=$(echo "$block_response" | jq -r '.result.parentHash' 2>/dev/null)
    
    if [ -n "$block_number" ] && [ "$block_number" != "null" ]; then
        block_decimal=$((16#${block_number#0x}))
        echo "   ✅ Block: $block_decimal (#$block_number)"
        echo "   🔗 Hash: ${block_hash:0:16}..."
        echo "   📝 Parent: ${parent_hash:0:16}..."
        echo "   💰 Transactions: $block_txs"
        
        # Get peer count
        peers_response=$(curl -s -X POST http://localhost:$port \
            -H "Content-Type: application/json" \
            --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' 2>/dev/null)
        peers=$(echo "$peers_response" | jq -r '.result' 2>/dev/null)
        peers_decimal=$((16#${peers#0x}))
        echo "   📡 Connected peers: $peers_decimal"
    else
        echo "   ⚠️  Online but no block data"
    fi
done

echo ""
echo "💡 Interpretation:"
echo "   - Different block hashes = Chains diverged"
echo "   - Same block numbers but different hashes = Fork occurred"
echo "   - Node showing 'OFFLINE' = Successfully partitioned"
