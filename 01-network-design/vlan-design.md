\# VLAN Design – Enterprise Network



\## Overview

This document describes the complete VLAN design for an academic institution with 500+ users across 6 buildings.



\## VLAN Table



| VLAN ID | Name | Subnet | Gateway | DHCP | Users | Purpose |

|---------|------|--------|---------|------|-------|---------|

| 10 | Academic | 10.10.10.0/24 | 10.10.10.1 | Yes (100-200) | 300 | Student computers, labs |

| 20 | Administration | 10.10.20.0/24 | 10.10.20.1 | No (Static) | 50 | Staff computers, servers |

| 30 | Research | 10.10.30.0/24 | 10.10.30.1 | No (Static) | 100 | Research labs, equipment |

| 40 | Guest | 10.10.40.0/24 | 10.10.40.1 | Yes (100-150) | 50 | Visitor Wi-Fi |

| 99 | DMZ | 172.16.0.0/24 | 172.16.0.1 | No (Static) | N/A | Public servers |



\## Inter-VLAN Communication Matrix



| Source → Destination | Academic (10) | Admin (20) | Research (30) | Guest (40) | DMZ (99) | Internet |

|---------------------|---------------|------------|---------------|------------|----------|----------|

| Academic (10) | - | BLOCK | BLOCK | BLOCK | BLOCK | ALLOW |

| Admin (20) | ALLOW | - | ALLOW | BLOCK | ALLOW | ALLOW |

| Research (30) | BLOCK | BLOCK | - | BLOCK | ALLOW (SSH/HTTPS) | ALLOW |

| Guest (40) | BLOCK | BLOCK | BLOCK | - | BLOCK | ALLOW (Rate Limit) |

| DMZ (99) | BLOCK | BLOCK | BLOCK | BLOCK | - | ALLOW (Updates only) |



\## Linux VLAN Commands



```bash

\# Create VLAN interfaces on eth1 (LAN interface)

ip link add link eth1 name eth1.10 type vlan id 10

ip link add link eth1 name eth1.20 type vlan id 20

ip link add link eth1 name eth1.30 type vlan id 30

ip link add link eth1 name eth1.40 type vlan id 40

ip link add link eth1 name eth1.99 type vlan id 99



\# Assign IP addresses

ip addr add 10.10.10.1/24 dev eth1.10

ip addr add 10.10.20.1/24 dev eth1.20

ip addr add 10.10.30.1/24 dev eth1.30

ip addr add 10.10.40.1/24 dev eth1.40

ip addr add 172.16.0.1/24 dev eth1.99



\# Bring interfaces up

ip link set eth1.10 up

ip link set eth1.20 up

ip link set eth1.30 up

ip link set eth1.40 up

ip link set eth1.99 up



\# Verify

ip link show | grep eth1

Cisco Switch VLAN Configuration

cisco

! Create VLANs

vlan 10

&#x20;name Academic

vlan 20

&#x20;name Administration

vlan 30

&#x20;name Research

vlan 40

&#x20;name Guest

vlan 99

&#x20;name DMZ



! Configure trunk to firewall

interface GigabitEthernet0/48

&#x20;switchport mode trunk

&#x20;switchport trunk allowed vlan 10,20,30,40,99

&#x20;description Trunk\_to\_Firewall



! Assign access ports to VLANs

interface range GigabitEthernet0/1-24

&#x20;switchport mode access

&#x20;switchport access vlan 10

&#x20;description Academic\_PCs



! Verify

show vlan brief

show interfaces trunk

DHCP Configuration

Academic VLAN10

text

Range: 10.10.10.100 - 10.10.10.200

DNS: 10.10.20.10, 8.8.8.8

Gateway: 10.10.10.1

Lease Time: 8 hours

Guest VLAN40

text

Range: 10.10.40.100 - 10.10.40.150

DNS: 8.8.8.8, 8.8.4.4

Gateway: 10.10.40.1

Lease Time: 2 hours

Bandwidth Limit: 10 Mbps



