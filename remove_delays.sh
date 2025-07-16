#!/bin/bash
PREFIX="clab-3R-3S-12C-topology"

remove_delay_eth_numbered() {
    local container=$1
    
    interfaces=$(docker exec $container bash -c "ls /sys/class/net | grep -E '^eth[0-9]+'")
    for iface in $interfaces; do
        echo " → $container: removing delay on $iface"
        docker exec $container tc qdisc del dev $iface root || true
    done
}

echo "Removing all delays (only eth0/eth1/eth2…)"

 
# SWITCHES
 
for sw in S1 S2 S3; do
    container="${PREFIX}-${sw}"
    remove_delay_eth_numbered $container
done

 
# CLIENTS
 
for c in {1..12}; do
    container="${PREFIX}-C${c}"
    remove_delay_eth_numbered $container
done

 
# ROUTERS
 
for r in R1 R2 R3; do
    container="${PREFIX}-${r}"
    remove_delay_eth_numbered $container
done

