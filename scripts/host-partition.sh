#!/bin/bash

echo "🔀 HOST: Network Partition Control"
echo "==================================="

echo "1. Current network status:"
docker network inspect docker_eth-fork-net --format='{{range .Containers}}{{.Name}} {{end}}'

echo ""
echo "2. Creating partition..."
docker network disconnect docker_eth-fork-net geth-node-1
echo "   ✅ Disconnected geth-node-1 from network"

echo ""
echo "3. Verifying partition..."
echo "   Testing geth-node-1 -> geth-node-2:"
docker exec geth-node-1 ping -c 1 geth-node-2 > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "   ❌ Partition failed - nodes can still communicate"
else
    echo "   ✅ Partition successful - nodes cannot communicate"
fi

echo ""
echo "4. Final network status:"
docker network inspect docker_eth-fork-net --format='{{range .Containers}}{{.Name}} {{end}}'

echo ""
echo "🎉 Partition created successfully!"
echo "💡 Run from host: ./scripts/host-generate-txs.sh"
