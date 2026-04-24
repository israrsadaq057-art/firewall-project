#!/bin/bash
# ============================================
# Complete Firewall Deployment Script
# Author: Israr Sadaq
# Date: 2026-04-24
# ============================================

echo "========================================="
echo "   FIREWALL DEPLOYMENT SCRIPT"
echo "   Israr Sadaq - Network Administrator"
echo "========================================="

# Flush existing rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

# Set default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# Management access (Admin VLAN only)
iptables -A INPUT -i eth1.20 -p tcp --dport 22 -j ACCEPT   # SSH
iptables -A INPUT -i eth1.20 -p tcp --dport 443 -j ACCEPT  # HTTPS

# VLAN 10 - Academic (Internet only)
iptables -A FORWARD -i eth1.10 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth1.10 -o eth1.20 -j DROP
iptables -A FORWARD -i eth1.10 -o eth1.30 -j DROP
iptables -A FORWARD -i eth1.10 -o eth1.99 -j DROP

# VLAN 20 - Admin (Full access)
iptables -A FORWARD -i eth1.20 -j ACCEPT

# VLAN 30 - Research (Internet + DMZ)
iptables -A FORWARD -i eth1.30 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth1.30 -o eth1.99 -p tcp --dport 22 -j ACCEPT
iptables -A FORWARD -i eth1.30 -o eth1.99 -p tcp --dport 443 -j ACCEPT

# VLAN 40 - Guest (Internet only)
iptables -A FORWARD -i eth1.40 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth1.40 -o eth1.10 -j DROP
iptables -A FORWARD -i eth1.40 -o eth1.20 -j DROP
iptables -A FORWARD -i eth1.40 -o eth1.30 -j DROP
iptables -A FORWARD -i eth1.40 -o eth1.99 -j DROP

# VLAN 99 - DMZ
iptables -A FORWARD -i eth0 -o eth1.99 -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1.99 -p tcp --dport 443 -j ACCEPT
iptables -A FORWARD -i eth1.99 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth1.99 -o eth1.10 -j DROP
iptables -A FORWARD -i eth1.99 -o eth1.20 -j DROP
iptables -A FORWARD -i eth1.99 -o eth1.30 -j DROP

# NAT Configuration
iptables -t nat -A POSTROUTING -s 10.10.0.0/16 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.16.0.0/24 -o eth0 -j MASQUERADE

# DNAT - Web Server
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 172.16.0.10:80
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 443 -j DNAT --to-destination 172.16.0.10:443
iptables -A FORWARD -i eth0 -o eth1.99 -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1.99 -p tcp --dport 443 -j ACCEPT

# Logging
iptables -A INPUT -j LOG --log-prefix "FW-DROPPED-INPUT: " --log-level 4
iptables -A FORWARD -j LOG --log-prefix "FW-DROPPED-FORWARD: " --log-level 4

# Save rules
iptables-save > /etc/iptables/rules.v4

echo "========================================="
echo "   FIREWALL DEPLOYMENT COMPLETE"
echo "========================================="