#!/bin/bash
PREFIX="clab-3R-3S-12C-topology"

apply_delay_eth_numbered() {
    local container=$1
    local delay=$2
    
    interfaces=$(docker exec $container bash -c "ls /sys/class/net | grep -E '^eth[0-9]+'")
    for iface in $interfaces; do
        echo " → $container: applying ${delay} delay on $iface"
        docker exec $container tc qdisc add dev $iface root netem delay $delay || true
    done
}

echo "Applying delays.."

# SWITCHES
for sw in S1 S2 S3; do
    container="${PREFIX}-${sw}"
    apply_delay_eth_numbered $container "10ms"
done

# CLIENTS
for c in {1..12}; do
    container="${PREFIX}-C${c}"
    apply_delay_eth_numbered $container "10ms"
done

# CLUSTER HEADS
# CH nodes: C1, C5, C9 : eth1 overridden with low delay (start at 1ms)
for ch in C1 C5 C9; do
    container="${PREFIX}-${ch}"
    echo "Overriding delay for CH ($ch) → 1ms on eth1"
    docker exec $container tc qdisc change dev eth1 root netem delay 1ms || true
done

# INTER-CLUSTER ROUTERS
# R1 ↔ R2 ↔ R3 links → 100ms delay
for r in R1 R2 R3; do
    container="${PREFIX}-${r}"
    echo " → Adding 100ms inter-cluster delay for $container"
    apply_delay_eth_numbered $container "100ms"
done

