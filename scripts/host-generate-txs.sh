#!/bin/bash

echo "💸 HOST: Transaction Generation on Partitions"
echo "============================================="

# Function to check if node is responsive
check_node_ready() {
    local port=$1
    local node_name=$2
    
    echo "   Checking $node_name (port $port)..."
    response=$(curl -s -X POST http://localhost:$port \
        -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"net_version","params":[],"id":1}' 2>/dev/null)
    
    version=$(echo "$response" | jq -r '.result' 2>/dev/null)
    
    if [ "$version" = "1337" ]; then
        echo "   ✅ $node_name is responsive"
        return 0
    else
        echo "   ❌ $node_name is not responding"
        return 1
    fi
}

# Function to send actual transaction
send_transaction() {
    local port=$1
    local partition_name=$2
    
    echo "   Sending transaction to $partition_name (port $port)..."
    
    # Get the first account (dev mode has pre-funded accounts)
    accounts_response=$(curl -s -X POST http://localhost:$port \
        -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}' 2>/dev/null)
    
    accounts=$(echo "$accounts_response" | jq -r '.result[0]' 2>/dev/null)
    
    if [ -z "$accounts" ] || [ "$accounts" = "null" ]; then
        echo "      ❌ No accounts found"
        return
    fi
    
    echo "      Using account: ${accounts:0:10}..."
    
    # Send a transaction (to zero address with small value)
    tx_response=$(curl -s -X POST http://localhost:$port \
        -H "Content-Type: application/json" \
        --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_sendTransaction\",\"params\":[{\"from\": \"$accounts\", \"to\": \"0x0000000000000000000000000000000000000000\", \"value\": \"0x100\"}],\"id\":1}" 2>/dev/null)
    
    tx_hash=$(echo "$tx_response" | jq -r '.result' 2>/dev/null)
    
    if [ -n "$tx_hash" ] && [ "$tx_hash" != "null" ]; then
        echo "      ✅ Transaction sent: ${tx_hash:0:16}..."
    else
        echo "      ❌ Failed to send transaction"
        echo "      Error response: $tx_response"
    fi
}

echo "1. Checking node status after partition..."
check_node_ready 8545 "Partition A (geth-node-1)"
check_node_ready 8546 "Partition B (geth-node-2)"
check_node_ready 8547 "Partition B (geth-node-3)"

echo ""
echo "2. Generating actual transactions..."
echo "   Note: In dev mode, nodes auto-mine but need unlocked accounts"

# For dev mode, we need to use personal_sendTransaction or unlock accounts
echo "   Using eth_sendTransaction (may fail if accounts locked)..."
send_transaction 8545 "Partition A"
send_transaction 8546 "Partition B"

echo ""
echo "3. Checking block divergence..."
echo "   Waiting 15 seconds for transactions to be mined..."
sleep 15

echo ""
echo "📊 Current block status with transaction counts:"
for port in 8545 8546 8547; do
    node_name=""
    case $port in
        8545) node_name="Partition A (geth-node-1)";;
        8546) node_name="Partition B (geth-node-2)";;
        8547) node_name="Partition B (geth-node-3)";;
    esac
    
    # Get block number
    block_response=$(curl -s -X POST http://localhost:$port \
        -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' 2>/dev/null)
    block=$(echo "$block_response" | jq -r '.result' 2>/dev/null)
    
    # Get transaction count in latest block
    tx_response=$(curl -s -X POST http://localhost:$port \
        -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"eth_getBlockTransactionCountByNumber","params":["latest"],"id":1}' 2>/dev/null)
    tx_count=$(echo "$tx_response" | jq -r '.result' 2>/dev/null)
    
    if [ -n "$block" ] && [ "$block" != "null" ]; then
        block_decimal=$((16#${block#0x}))
        tx_count_decimal=$((16#${tx_count#0x}))
        echo "   $node_name:"
        echo "      Block: $block_decimal (#$block)"
        echo "      Transactions in latest block: $tx_count_decimal"
    else
        echo "   $node_name: ❌ NOT RESPONDING"
        echo "   Response: $block_response"
    fi
done

echo ""
echo "🎉 Transaction generation complete!"
echo "💡 If transactions failed, nodes might need account unlocking"
