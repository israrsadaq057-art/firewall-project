\# Firewall Zones Design



\## Zone Definitions



| Zone | Color | Trust Level | Interfaces | Description |

|------|-------|-------------|------------|-------------|

| WAN | Red | Untrusted | eth0 | Internet connection |

| LAN | Green | Trusted | eth1.20 | Internal trusted network |

| Academic | Yellow | Limited | eth1.10 | Student network |

| Research | Purple | Medium | eth1.30 | Research labs |

| Guest | Orange | Low | eth1.40 | Visitor network |

| DMZ | Brown | Isolated | eth1.99 | Public servers |



\## Zone-to-Zone Default Policies



| Source Zone | Destination Zone | Default Action | Exceptions |

|-------------|------------------|----------------|------------|

| WAN | Any | DENY | HTTP/HTTPS to DMZ |

| LAN | Any | ALLOW | None |

| Academic | WAN | ALLOW | None |

| Academic | LAN/DMZ | DENY | None |

| Guest | WAN | ALLOW | Rate limited |

| Guest | Any Internal | DENY | None |

| DMZ | WAN | ALLOW | For updates |

| DMZ | LAN | DENY | None |

| Research | WAN | ALLOW | None |

| Research | DMZ | ALLOW | SSH/HTTPS only |



\## Complete iptables Rules



\### Default Policies



```bash

iptables -P INPUT DROP

iptables -P FORWARD DROP

iptables -P OUTPUT ACCEPT



Allow Established Connections

bash

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

Management Access (Admin VLAN only)

bash

iptables -A INPUT -i eth1.20 -p tcp --dport 22 -j ACCEPT   # SSH

iptables -A INPUT -i eth1.20 -p tcp --dport 443 -j ACCEPT  # HTTPS Web GUI

VLAN 10 – Academic (Students)

bash

\# Internet access only

iptables -A FORWARD -i eth1.10 -o eth0 -j ACCEPT



\# Block access to other VLANs

iptables -A FORWARD -i eth1.10 -o eth1.20 -j DROP

iptables -A FORWARD -i eth1.10 -o eth1.30 -j DROP

iptables -A FORWARD -i eth1.10 -o eth1.40 -j DROP

iptables -A FORWARD -i eth1.10 -o eth1.99 -j DROP

VLAN 20 – Administration (Staff)

bash

\# Full access to everything

iptables -A FORWARD -i eth1.20 -j ACCEPT

VLAN 30 – Research (Labs)

bash

\# Internet access

iptables -A FORWARD -i eth1.30 -o eth0 -j ACCEPT



\# SSH and HTTPS access to DMZ servers

iptables -A FORWARD -i eth1.30 -o eth1.99 -p tcp --dport 22 -j ACCEPT

iptables -A FORWARD -i eth1.30 -o eth1.99 -p tcp --dport 443 -j ACCEPT



\# Block access to Admin VLAN

iptables -A FORWARD -i eth1.30 -o eth1.20 -j DROP

VLAN 40 – Guest (Visitors)

bash

\# Internet only (rate limited via QoS)

iptables -A FORWARD -i eth1.40 -o eth0 -j ACCEPT



\# Block all internal access

iptables -A FORWARD -i eth1.40 -o eth1.10 -j DROP

iptables -A FORWARD -i eth1.40 -o eth1.20 -j DROP

iptables -A FORWARD -i eth1.40 -o eth1.30 -j DROP

iptables -A FORWARD -i eth1.40 -o eth1.99 -j DROP

VLAN 99 – DMZ (Public Servers)

bash

\# Web server (HTTP/HTTPS) – allow from internet

iptables -A FORWARD -i eth0 -o eth1.99 -p tcp --dport 80 -j ACCEPT

iptables -A FORWARD -i eth0 -o eth1.99 -p tcp --dport 443 -j ACCEPT



\# DMZ servers can access internet for updates

iptables -A FORWARD -i eth1.99 -o eth0 -j ACCEPT



\# Block DMZ from initiating connections to internal networks

iptables -A FORWARD -i eth1.99 -o eth1.10 -j DROP

iptables -A FORWARD -i eth1.99 -o eth1.20 -j DROP

iptables -A FORWARD -i eth1.99 -o eth1.30 -j DROP

iptables -A FORWARD -i eth1.99 -o eth1.40 -j DROP

Logging

bash

\# Log dropped packets for analysis

iptables -A INPUT -j LOG --log-prefix "FW-DROPPED-INPUT: " --log-level 4

iptables -A FORWARD -j LOG --log-prefix "FW-DROPPED-FORWARD: " --log-level 4



\# Rate limiting for logs (avoid flooding)

iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "FW-LIMIT: "

Save Rules

bash

iptables-save > /etc/iptables/rules.v4

ip6tables-save > /etc/iptables/rules.v6

Rule Order (Important)

Rules are processed in order. First match wins. The order above is correct:



Allow established connections (most critical)



Allow management access



Allow specific VLAN traffic



Default DROP (implicit at end)



Verification Commands

bash

\# View all rules with counters

iptables -L -v -n --line-numbers



\# View NAT rules

iptables -t nat -L -v -n



\# View specific chain

iptables -L FORWARD -v -n



\# View rule hit counts

watch -n 1 'iptables -L -v -n | grep -A 5 "Chain"'







