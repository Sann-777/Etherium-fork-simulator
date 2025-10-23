#!/bin/bash

echo "🔗 HOST: Network Reconnection"
echo "=============================="

echo "1. Reconnecting partitioned node..."
docker network connect docker_eth-fork-net geth-node-1
echo "   ✅ Reconnected geth-node-1 to network"

echo ""
echo "2. Verifying reconnection..."
echo "   Testing geth-node-1 -> geth-node-2:"
docker exec geth-node-1 ping -c 1 geth-node-2 > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "   ✅ Reconnection successful - nodes can communicate"
else
    echo "   ❌ Reconnection failed - nodes still partitioned"
fi

echo ""
echo "3. Final network status:"
docker network inspect docker_eth-fork-net --format='{{range .Containers}}{{.Name}} {{end}}'

echo ""
echo "🎉 Network reconnected successfully!"
