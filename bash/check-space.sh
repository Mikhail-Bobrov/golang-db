#!/bin/bash
set -e

THRESHOLD=10 # in GB

calculateFreeSpace() {
    freeKiloBlocks=$(df -k --output=avail "$PWD" | tail -n1)
    freeGb=$((freeKiloBlocks/1000000))
    df -h "${PWD}"
    echo Free space: ${freeGb}GB, threshold: ${THRESHOLD}GB
}

calculateFreeSpace

if [ ${freeGb} -lt ${THRESHOLD} ]; then
    echo Less than ${THRESHOLD}GBs free. Prune all docker items starting...
    docker -v
    docker system prune -f -a --filter until=24h
    calculateFreeSpace
    exit 0
fi;

echo "Everything Ok. Nothing to do"
