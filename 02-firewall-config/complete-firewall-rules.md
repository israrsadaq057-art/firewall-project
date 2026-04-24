**Complete Firewall Rules – A to Z Documentation**



**Author**

\*\*Israr Sadaq\*\*

\- Network and IT Administrator | CCNA | CCNP 

\- Email: israrsadaq057@gmail.com

\- GitHub: github.com/israrsadaq057-art



\---



**1. Table of Contents**



1\. Network Overview

2\. IP Address Reference

3\. Default Policies

4\. Management Access Rules

5\. Inter-VLAN Rules

6\. WAN (Internet) Rules

7\. DMZ Rules

8\. NAT Rules (SNAT \& DNAT)

9\. VPN Rules

10\. IDS/IPS Rules

11\. Logging Rules

12\. QoS Rules

13\. High Availability Rules

14\. Rule Order (Critical)

15\. Complete iptables Script



\---



**2. Network Overview**



**2.1 IP Address Reference Table**



| Zone | VLAN | Network | Gateway | DHCP Range | Purpose |

|------|------|---------|---------|------------|---------|

| Management | N/A | 10.10.1.0/24 | 10.10.1.1 | None | Firewall, switch management |

| Academic | 10 | 10.10.10.0/24 | 10.10.10.1 | 10.10.10.100-200 | Student computers |

| Administration (LAN) | 20 | 10.10.20.0/24 | 10.10.20.1 | None | Staff, internal servers |

| Research | 30 | 10.10.30.0/24 | 10.10.30.1 | None | Research labs |

| Guest | 40 | 10.10.40.0/24 | 10.10.40.1 | 10.10.40.100-150 | Visitor Wi-Fi |

| DMZ | 99 | 172.16.0.0/24 | 172.16.0.1 | None | Public servers |

| VPN Pool | N/A | 10.100.0.0/24 | 10.100.0.1 | 10.100.0.10-200 | Remote VPN users |

| WAN | N/A | 203.0.113.0/24 | 203.0.113.1 | ISP DHCP | Internet |



**2.2 Server IP Reference**



| Server Name | IP Address | Zone | Services | Ports |

|-------------|------------|------|----------|-------|

| FW-Master | 10.10.1.2 | Management | Firewall | 22,443 |

| FW-Backup | 10.10.1.3 | Management | Firewall (CARP) | 22,443 |

| Core-Switch | 10.10.1.5 | Management | Layer 3 Switching | 22,161 |

| DC01 | 10.10.20.10 | LAN | Domain Controller, DNS, DHCP | 53,88,135,139,389,445,636 |

| FS01 | 10.10.20.20 | LAN | File Server | 139,445 |

| MON01 | 10.10.20.30 | LAN | Grafana, Prometheus | 3000,9090 |

| BKP01 | 10.10.20.40 | LAN | Backup Server | 22,873 |

| WEB01 | 172.16.0.10 | DMZ | Web Server | 80,443 |

| MAIL01 | 172.16.0.20 | DMZ | Email Server | 25,143,465,587,993,995 |

| VPN01 | 172.16.0.30 | DMZ | OpenVPN Server | 1194 UDP |



\---



**3. Default Policies**



3.1 iptables Default Policies



\# Set default policies

iptables -P INPUT DROP

iptables -P FORWARD DROP

iptables -P OUTPUT ACCEPT





Chain	Default	Reason

INPUT	DROP	Block all traffic to firewall unless explicitly allowed

FORWARD	DROP	Block all routed traffic unless explicitly allowed

OUTPUT	ACCEPT	Allow firewall to initiate connections (less restrictive)



3.2 IPv6 Default Policies



ip6tables -P INPUT DROP

ip6tables -P FORWARD DROP

ip6tables -P OUTPUT ACCEPT



**4. Management Access Rules (INPUT Chain)**



4.1 Allow Loopback



iptables -A INPUT -i lo -j ACCEPT

iptables -A OUTPUT -o lo -j ACCEPT

4.2 Allow Established Connections



iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

4.3 SSH Access (Admin VLAN only)



Rule #	Source	Destination	Protocol	Port	Action

MGT-01	10.10.20.0/24	10.10.1.2	TCP	22	ACCEPT

MGT-02	10.10.20.0/24	10.10.1.3	TCP	22	ACCEPT

MGT-03	Any	Any	TCP	22	DROP



iptables -A INPUT -s 10.10.20.0/24 -d 10.10.1.2 -p tcp --dport 22 -j ACCEPT

iptables -A INPUT -s 10.10.20.0/24 -d 10.10.1.3 -p tcp --dport 22 -j ACCEPT

iptables -A INPUT -p tcp --dport 22 -j DROP

4.4 HTTPS Web GUI Access



iptables -A INPUT -s 10.10.20.0/24 -d 10.10.1.2 -p tcp --dport 443 -j ACCEPT

iptables -A INPUT -s 10.10.20.0/24 -d 10.10.1.3 -p tcp --dport 443 -j ACCEPT

iptables -A INPUT -p tcp --dport 443 -j DROP

4.5 ICMP (Ping) – Limited



iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/second -j ACCEPT

iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

**5. Inter-VLAN Rules (FORWARD Chain)**



5.1 VLAN 10 – Academic (Students)

Rule #	Source	Destination	Protocol	Port	Action	Reason

ACC-01	10.10.10.0/24	Any	Any	Any	ACCEPT	Internet access

ACC-02	10.10.10.0/24	10.10.20.0/24	Any	Any	DROP	Block to Admin

ACC-03	10.10.10.0/24	10.10.30.0/24	Any	Any	DROP	Block to Research

ACC-04	10.10.10.0/24	10.10.40.0/24	Any	Any	DROP	Block to Guest

ACC-05	10.10.10.0/24	172.16.0.0/24	Any	Any	DROP	Block to DMZ



\# Internet access

iptables -A FORWARD -s 10.10.10.0/24 -o eth0 -j ACCEPT



\# Block internal access

iptables -A FORWARD -s 10.10.10.0/24 -d 10.10.20.0/24 -j DROP

iptables -A FORWARD -s 10.10.10.0/24 -d 10.10.30.0/24 -j DROP

iptables -A FORWARD -s 10.10.10.0/24 -d 10.10.40.0/24 -j DROP

iptables -A FORWARD -s 10.10.10.0/24 -d 172.16.0.0/24 -j DROP

5.2 VLAN 20 – Administration (Staff)

Rule #	Source	Destination	Protocol	Port	Action	Reason

ADM-01	10.10.20.0/24	Any	Any	Any	ACCEPT	Full access



iptables -A FORWARD -s 10.10.20.0/24 -j ACCEPT

5.3 VLAN 30 – Research

Rule #	Source	Destination	Protocol	Port	Action	Reason

RES-01	10.10.30.0/24	Any	Any	Any	ACCEPT	Internet access

RES-02	10.10.30.0/24	172.16.0.0/24	TCP	22	ACCEPT	SSH to DMZ

RES-03	10.10.30.0/24	172.16.0.0/24	TCP	443	ACCEPT	HTTPS to DMZ

RES-04	10.10.30.0/24	10.10.20.0/24	Any	Any	DROP	Block to Admin



iptables -A FORWARD -s 10.10.30.0/24 -o eth0 -j ACCEPT

iptables -A FORWARD -s 10.10.30.0/24 -d 172.16.0.0/24 -p tcp --dport 22 -j ACCEPT

iptables -A FORWARD -s 10.10.30.0/24 -d 172.16.0.0/24 -p tcp --dport 443 -j ACCEPT

iptables -A FORWARD -s 10.10.30.0/24 -d 10.10.20.0/24 -j DROP

5.4 VLAN 40 – Guest

Rule #	Source	Destination	Protocol	Port	Action	Reason

GUE-01	10.10.40.0/24	Any (WAN)	Any	Any	ACCEPT	Internet only

GUE-02	10.10.40.0/24	10.10.0.0/16	Any	Any	DROP	Block internal

GUE-03	10.10.40.0/24	172.16.0.0/24	Any	Any	DROP	Block DMZ



iptables -A FORWARD -s 10.10.40.0/24 -o eth0 -j ACCEPT

iptables -A FORWARD -s 10.10.40.0/24 -d 10.10.0.0/16 -j DROP

iptables -A FORWARD -s 10.10.40.0/24 -d 172.16.0.0/24 -j DROP

5.5 VLAN 99 – DMZ

Rule #	Source	Destination	Protocol	Port	Action	Reason

DMZ-01	172.16.0.0/24	Any	Any	Any	ACCEPT	Internet for updates

DMZ-02	Any	172.16.0.10	TCP	80	ACCEPT	HTTP to web server

DMZ-03	Any	172.16.0.10	TCP	443	ACCEPT	HTTPS to web server

DMZ-04	Any	172.16.0.20	TCP	25	ACCEPT	SMTP to mail server

DMZ-05	Any	172.16.0.20	TCP	143	ACCEPT	IMAP to mail server

DMZ-06	Any	172.16.0.30	UDP	1194	ACCEPT	OpenVPN

DMZ-07	172.16.0.0/24	10.10.0.0/16	Any	Any	DROP	Block DMZ to internal



\# DMZ to internet

iptables -A FORWARD -s 172.16.0.0/24 -o eth0 -j ACCEPT



\# DMZ to internal – BLOCKED (CRITICAL)

iptables -A FORWARD -s 172.16.0.0/24 -d 10.10.0.0/16 -j DROP



\# Web server access

iptables -A FORWARD -d 172.16.0.10 -p tcp --dport 80 -j ACCEPT

iptables -A FORWARD -d 172.16.0.10 -p tcp --dport 443 -j ACCEPT



\# Mail server access

iptables -A FORWARD -d 172.16.0.20 -p tcp --dport 25 -j ACCEPT

iptables -A FORWARD -d 172.16.0.20 -p tcp --dport 143 -j ACCEPT



\# VPN access

iptables -A FORWARD -d 172.16.0.30 -p udp --dport 1194 -j ACCEPT



**6. WAN (Internet) Rules**



Rule #	Source	Destination	Protocol	Port	Action	Reason

WAN-01	Any	Any	Any	Any	DROP	Default block

WAN-02	Any	172.16.0.10	TCP	80	ACCEPT	Public web

WAN-03	Any	172.16.0.10	TCP	443	ACCEPT	Public web (HTTPS)

WAN-04	Any	172.16.0.20	TCP	25	ACCEPT	Public email

WAN-05	Any	172.16.0.30	UDP	1194	ACCEPT	VPN



\# Default block

iptables -A INPUT -i eth0 -j DROP

iptables -A FORWARD -i eth0 -j DROP



\# Allow specific services (handled by DNAT, but need FORWARD rules)

iptables -A FORWARD -i eth0 -o eth1.99 -p tcp --dport 80 -j ACCEPT

iptables -A FORWARD -i eth0 -o eth1.99 -p tcp --dport 443 -j ACCEPT

iptables -A FORWARD -i eth0 -o eth1.99 -p tcp --dport 25 -j ACCEPT

iptables -A FORWARD -i eth0 -o eth1.99 -p udp --dport 1194 -j ACCEPT



**7. NAT Rules**



7.1 SNAT (Outbound NAT)

Rule #	Source	Destination	NAT Action	Purpose

NAT-01	10.10.0.0/16	Any	MASQUERADE	Internal internet access

NAT-02	172.16.0.0/24	Any	MASQUERADE	DMZ internet access



iptables -t nat -A POSTROUTING -s 10.10.0.0/16 -o eth0 -j MASQUERADE

iptables -t nat -A POSTROUTING -s 172.16.0.0/24 -o eth0 -j MASQUERADE

7.2 DNAT (Port Forwarding)

Rule #	Public IP:Port	Private IP:Port	Protocol	Purpose

NAT-03	203.0.113.1:80	172.16.0.10:80	TCP	Web Server HTTP

NAT-04	203.0.113.1:443	172.16.0.10:443	TCP	Web Server HTTPS

NAT-05	203.0.113.1:25	172.16.0.20:25	TCP	SMTP

NAT-06	203.0.113.1:143	172.16.0.20:143	TCP	IMAP

NAT-07	203.0.113.1:1194	172.16.0.30:1194	UDP	OpenVPN



iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 172.16.0.10:80

iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 443 -j DNAT --to-destination 172.16.0.10:443

iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 25 -j DNAT --to-destination 172.16.0.20:25

iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 143 -j DNAT --to-destination 172.16.0.20:143

iptables -t nat -A PREROUTING -i eth0 -p udp --dport 1194 -j DNAT --to-destination 172.16.0.30:1194



**8. VPN Rules (OpenVPN)**



Rule #	Source	Destination	Protocol	Port	Action

VPN-01	10.100.0.0/24	Any	Any	Any	ACCEPT

bash

iptables -A FORWARD -s 10.100.0.0/24 -j ACCEPT

iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE



**9. IDS/IPS Rules (Snort)**



\# Port scan detection

iptables -A INPUT -p tcp --tcp-flags FIN,SYN,RST,ACK SYN -m limit --limit 5/min -j LOG --log-prefix "SCAN: "



\# SSH brute force detection

iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set

iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 -j DROP



**10. Logging Rules**



\# Log dropped packets (rate limited)

iptables -A INPUT -m limit --limit 10/min -j LOG --log-prefix "FW-DROP-INPUT: " --log-level 4

iptables -A FORWARD -m limit --limit 10/min -j LOG --log-prefix "FW-DROP-FORWARD: " --log-level 4



\# Log accepted connections (for audit)

iptables -A INPUT -p tcp --dport 22 -j LOG --log-prefix "SSH-ACCESS: "

iptables -A FORWARD -p tcp --dport 80 -j LOG --log-prefix "HTTP-ACCESS: "



**11. QoS Rules (Traffic Shaping)**



\# Guest VLAN rate limiting (10 Mbps)

tc qdisc add dev eth1.40 root handle 1: htb default 30

tc class add dev eth1.40 parent 1: classid 1:1 htb rate 100mbit

tc class add dev eth1.40 parent 1:1 classid 1:10 htb rate 10mbit ceil 20mbit

tc filter add dev eth1.40 protocol ip parent 1:0 prio 1 u32 match ip src 10.10.40.0/24 flowid 1:10



**12. Rule Order (Critical)**



Rules are processed top to bottom. First match wins. The correct order is:



Allow established connections (most important)



Allow loopback



Allow management access (SSH, HTTPS)



Allow specific services (HTTP, HTTPS, DNS, etc.)



Allow inter-VLAN traffic (Academic, Research, etc.)



Default DROP (implied at end)



\# Correct order

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -A INPUT -i lo -j ACCEPT

iptables -A INPUT -s 10.10.20.0/24 -p tcp --dport 22 -j ACCEPT

iptables -A INPUT -p tcp --dport 80 -j ACCEPT

\# ... more allow rules ...

\# Default DROP is implicit (no need to write)



**13. Complete iptables Script**



\#!/bin/bash

\# ============================================

\# COMPLETE FIREWALL RULES SCRIPT

\# Author: Israr Sadaq

\# Date: 2026-04-24

\# ============================================



\# Flush all existing rules

iptables -F

iptables -X

iptables -t nat -F

iptables -t nat -X

iptables -t mangle -F

iptables -t mangle -X



\# ============================================

\# DEFAULT POLICIES

\# ============================================

iptables -P INPUT DROP

iptables -P FORWARD DROP

iptables -P OUTPUT ACCEPT



\# ============================================

\# ALLOW LOOPBACK

\# ============================================

iptables -A INPUT -i lo -j ACCEPT

iptables -A OUTPUT -o lo -j ACCEPT



\# ============================================

\# ALLOW ESTABLISHED CONNECTIONS

\# ============================================

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT



\# ============================================

\# MANAGEMENT ACCESS

\# ============================================

iptables -A INPUT -s 10.10.20.0/24 -p tcp --dport 22 -j ACCEPT

iptables -A INPUT -s 10.10.20.0/24 -p tcp --dport 443 -j ACCEPT



\# ============================================

\# ICMP (PING)

\# ============================================

iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/second -j ACCEPT



\# ============================================

\# INTER-VLAN RULES

\# ============================================



\# VLAN 10 - Academic (Internet only)

iptables -A FORWARD -s 10.10.10.0/24 -o eth0 -j ACCEPT

iptables -A FORWARD -s 10.10.10.0/24 -d 10.10.20.0/24 -j DROP

iptables -A FORWARD -s 10.10.10.0/24 -d 10.10.30.0/24 -j DROP

iptables -A FORWARD -s 10.10.10.0/24 -d 172.16.0.0/24 -j DROP



\# VLAN 20 - Admin (Full access)

iptables -A FORWARD -s 10.10.20.0/24 -j ACCEPT



\# VLAN 30 - Research (Internet + DMZ SSH/HTTPS)

iptables -A FORWARD -s 10.10.30.0/24 -o eth0 -j ACCEPT

iptables -A FORWARD -s 10.10.30.0/24 -d 172.16.0.0/24 -p tcp --dport 22 -j ACCEPT

iptables -A FORWARD -s 10.10.30.0/24 -d 172.16.0.0/24 -p tcp --dport 443 -j ACCEPT

iptables -A FORWARD -s 10.10.30.0/24 -d 10.10.20.0/24 -j DROP



\# VLAN 40 - Guest (Internet only)

iptables -A FORWARD -s 10.10.40.0/24 -o eth0 -j ACCEPT

iptables -A FORWARD -s 10.10.40.0/24 -d 10.10.0.0/16 -j DROP

iptables -A FORWARD -s 10.10.40.0/24 -d 172.16.0.0/24 -j DROP



\# VLAN 99 - DMZ

iptables -A FORWARD -s 172.16.0.0/24 -o eth0 -j ACCEPT

iptables -A FORWARD -s 172.16.0.0/24 -d 10.10.0.0/16 -j DROP



\# ============================================

\# PORT FORWARDING (DMZ)

\# ============================================

iptables -A FORWARD -d 172.16.0.10 -p tcp --dport 80 -j ACCEPT

iptables -A FORWARD -d 172.16.0.10 -p tcp --dport 443 -j ACCEPT

iptables -A FORWARD -d 172.16.0.20 -p tcp --dport 25 -j ACCEPT

iptables -A FORWARD -d 172.16.0.20 -p tcp --dport 143 -j ACCEPT

iptables -A FORWARD -d 172.16.0.30 -p udp --dport 1194 -j ACCEPT



\# ============================================

\# NAT RULES

\# ============================================



\# SNAT (Outbound)

iptables -t nat -A POSTROUTING -s 10.10.0.0/16 -o eth0 -j MASQUERADE

iptables -t nat -A POSTROUTING -s 172.16.0.0/24 -o eth0 -j MASQUERADE



\# DNAT (Port Forwarding)

iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 172.16.0.10:80

iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 443 -j DNAT --to-destination 172.16.0.10:443

iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 25 -j DNAT --to-destination 172.16.0.20:25

iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 143 -j DNAT --to-destination 172.16.0.20:143

iptables -t nat -A PREROUTING -i eth0 -p udp --dport 1194 -j DNAT --to-destination 172.16.0.30:1194



\# ============================================

\# LOGGING

\# ============================================

iptables -A INPUT -m limit --limit 10/min -j LOG --log-prefix "FW-DROP-INPUT: " --log-level 4

iptables -A FORWARD -m limit --limit 10/min -j LOG --log-prefix "FW-DROP-FORWARD: " --log-level 4



\# ============================================

\# SAVE RULES

\# ============================================

iptables-save > /etc/iptables/rules.v4



echo "Firewall rules applied successfully"

14\. Rule Statistics and Monitoring

bash

\# View all rules with hit counts

iptables -L -v -n --line-numbers



\# View NAT rules

iptables -t nat -L -v -n



\# View specific chain

iptables -L FORWARD -v -n



\# Monitor dropped packets in real-time

watch -n 1 'iptables -L -v -n | grep -A 5 "Chain"'



\# View logs

tail -f /var/log/syslog | grep "FW-DROP"

15\. Rule Summary Table

Zone	Source	Destination	Action	Rules Count

Management	Admin VLAN	Firewall	ALLOW	2

Academic	10.10.10.0/24	Internet	ALLOW	1

Academic	10.10.10.0/24	Internal	DENY	4

Admin	10.10.20.0/24	Any	ALLOW	1

Research	10.10.30.0/24	Internet	ALLOW	1

Research	10.10.30.0/24	DMZ	ALLOW (limited)	2

Guest	10.10.40.0/24	Internet	ALLOW	1

Guest	10.10.40.0/24	Internal	DENY	2

DMZ	172.16.0.0/24	Internet	ALLOW	1

DMZ	172.16.0.0/24	Internal	DENY	1

WAN	Any	DMZ (web)	ALLOW	5

WAN	Any	Any (other)	DENY	1

