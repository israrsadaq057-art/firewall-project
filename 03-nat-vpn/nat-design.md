**NAT Design – Enterprise Firewall**



\## Author: Israr Sadaq



**## NAT Types Used**



| Type | Purpose | Direction | iptables Chain |

|------|---------|-----------|----------------|

| SNAT | Internet access for internal networks | LAN → WAN | POSTROUTING |

| DNAT | Port forwarding to DMZ servers | WAN → DMZ | PREROUTING |

| Masquerade | Dynamic SNAT for DHCP | LAN → WAN | POSTROUTING |



**## SNAT Rules**



| Source Network | Destination | Translation | Purpose |

|----------------|-------------|-------------|---------|

| 10.10.10.0/24 | Any | WAN IP | Academic |

| 10.10.20.0/24 | Any | WAN IP | Administration |

| 10.10.30.0/24 | Any | WAN IP | Research |

| 10.10.40.0/24 | Any | WAN IP | Guest |

| 172.16.0.0/24 | Any | WAN IP | DMZ |





iptables -t nat -A POSTROUTING -s 10.10.0.0/16 -o eth0 -j MASQUERADE

iptables -t nat -A POSTROUTING -s 172.16.0.0/24 -o eth0 -j MASQUERADE



**DNAT Rules (Port Forwarding)**

Public IP:Port	Private IP:Port	Protocol	Service

203.0.113.1:80	172.16.0.10:80	TCP	HTTP

203.0.113.1:443	172.16.0.10:443	TCP	HTTPS

203.0.113.1:25	172.16.0.20:25	TCP	SMTP

203.0.113.1:143	172.16.0.20:143	TCP	IMAP

203.0.113.1:1194	172.16.0.30:1194	UDP	OpenVPN



iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 172.16.0.10:80

iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 443 -j DNAT --to-destination 172.16.0.10:443

iptables -t nat -A PREROUTING -i eth0 -p udp --dport 1194 -j DNAT --to-destination 172.16.0.30:1194

Verification Commands



iptables -t nat -L -v -n

conntrack -L



