# 3R-3S-12C Multi-Area OSPF Lab

This project simulates a multi-area OSPF network topology using [Containerlab](https://containerlab.dev/) with:
- 3 FRRouting-based routers (R1–R3)
- 3 Arista cEOS switches (S1–S3)
- 12 Debian-based clients (C1–C12)

---

##  Topology Overview

- **OSPF** is configured between routers (multi-area setup).
- Clients connect to switches but are configured with static IPs for testing.
- Switches use the Arista cEOS image to simulate L2 behavior.

###  Topology Graph

A visual representation of the network topology:

*(Add your topology graph screenshot here)*

---

##  Setup Instructions

###  1. Install dependencies

Install:
- Docker
- Containerlab

```bash
sudo apt update
bash -c "$(curl -sL https://get.containerlab.dev)"
```

---

###  2. Build custom client image

```bash
docker build -t my-client:latest -f client.Dockerfile .
```

---

###  3. Deploy the topology

```bash
sudo containerlab deploy -t 3R-3S-12C.clab.yml
```

---

###  4. Initialize clients

Assign static IPs to all 12 clients:

```bash
./client-init.sh
```

---

###  5. Test the lab

Run connectivity checks:

```bash
./client-ping-matrix.sh
```

---

###  6. View the topology graph

```bash
sudo containerlab graph -t ./3R-3S-12C.clab.yml
```

---

###  7. Apply delays

This lab supports optional network delay simulation using tc netem.

Default delays:

Normal links → 5 ms one-way (~10 ms RTT)

Special CH nodes (C1, C5, C9) → 1 ms one-way (~2 ms RTT)

```bash
./scripts/apply_delays.sh
```

---

###  8. Remove delays

Cleans up all delays.

```bash
./scripts/remove_delays.sh
```

---

###  9. Verify delays

Check the active delay settings on any container:

```bash
docker exec clab-3R-3S-12C-topology-C1 tc qdisc show
```

Ping between clients to confirm RTT:

```bash
docker exec clab-3R-3S-12C-topology-C2 ping -c 3 clab-3R-3S-12C-topology-C3
```
