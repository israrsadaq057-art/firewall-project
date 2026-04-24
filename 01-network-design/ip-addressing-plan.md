\# IP Addressing Plan



\## Public IP Space



| Interface | IP Address | Purpose |

|-----------|------------|---------|

| WAN (Firewall) | 203.0.113.1/24 | Internet Gateway |

| Public Web Server | 203.0.113.10 | HTTP/HTTPS |

| Public Mail Server | 203.0.113.20 | SMTP/IMAP |

| OpenVPN Gateway | 203.0.113.30 | VPN Remote Access |



\## Private IP Space (Internal)



| VLAN | Name | Subnet | Gateway | DHCP Range | Users |

|------|------|--------|---------|------------|-------|

| 10 | Academic | 10.10.10.0/24 | 10.10.10.1 | 10.10.10.100-200 | 300 |

| 20 | Administration | 10.10.20.0/24 | 10.10.20.1 | None (Static) | 50 |

| 30 | Research | 10.10.30.0/24 | 10.10.30.1 | None (Static) | 100 |

| 40 | Guest | 10.10.40.0/24 | 10.10.40.1 | 10.10.40.100-150 | 50 |

| 99 | DMZ | 172.16.0.0/24 | 172.16.0.1 | None (Static) | N/A |



\## VPN Pool



| Range | Purpose |

|-------|---------|

| 10.100.0.0/24 | OpenVPN remote users |



\## Management Network



| Device | IP Address | VLAN |

|--------|------------|------|

| Firewall Master | 10.10.1.2 | Management |

| Firewall Backup | 10.10.1.3 | Management |

| Virtual IP (CARP) | 10.10.1.1 | Management |

| Core Switch | 10.10.1.5 | Management |

