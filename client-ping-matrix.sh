#!/bin/bash
echo "Testing full client-to-client ping matrix..."
echo

TOPOLOGY="clab-3R-3S-12C-topology"

# Define client IP groups
C1_IPS=("10.0.1.3" "10.0.1.4" "10.0.1.5" \
        "10.0.2.2" "10.0.2.3" "10.0.2.4" "10.0.2.5" \
        "10.0.3.2" "10.0.3.3" "10.0.3.4" "10.0.3.5")

ping_test() {
  SRC=$1
  DST_IP=$2
  DST_NAME=$3
  docker exec -i $TOPOLOGY-$SRC ping -c 1 -W 1 $DST_IP &> /dev/null && \
    echo "  → $DST_NAME ($DST_IP): Success" || \
    echo "  → $DST_NAME ($DST_IP): Failure"
}

test_from_client() {
  SRC=$1
  SRC_IP=$2
  echo "From $SRC:"
  for DST_IP in "${ALL_IPS[@]}"; do
    # Skip itself
    if [[ "$DST_IP" == "$SRC_IP" ]]; then continue; fi
    # Derive client name from IP
    DST_NAME="C$(echo $DST_IP | awk -F'.' '{print $4-1}')"
    ping_test $SRC $DST_IP $DST_NAME
  done
  echo
}

# All IPs of clients
ALL_IPS=("10.0.1.2" "10.0.1.3" "10.0.1.4" "10.0.1.5"
         "10.0.2.2" "10.0.2.3" "10.0.2.4" "10.0.2.5"
         "10.0.3.2" "10.0.3.3" "10.0.3.4" "10.0.3.5")

# Client name → IP mapping
CLIENT_IPS=(
  "C1:10.0.1.2"
  "C2:10.0.1.3"
  "C3:10.0.1.4"
  "C4:10.0.1.5"
  "C5:10.0.2.2"
  "C6:10.0.2.3"
  "C7:10.0.2.4"
  "C8:10.0.2.5"
  "C9:10.0.3.2"
  "C10:10.0.3.3"
  "C11:10.0.3.4"
  "C12:10.0.3.5"
)

# Loop each client and test connectivity to all others
for ENTRY in "${CLIENT_IPS[@]}"; do
  CLIENT_NAME=$(echo "$ENTRY" | cut -d':' -f1)
  CLIENT_IP=$(echo "$ENTRY" | cut -d':' -f2)
  test_from_client $CLIENT_NAME $CLIENT_IP
done
