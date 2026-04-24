\# Enterprise Firewall Project



\## Author

\*\*Israr Sadaq\*\*

\- Network Administrator

\- CCNA Certified

\- CCNP (In Progress)



\## Project Overview

Complete enterprise firewall solution for academic institution with 500+ users.



\## Network Design



| VLAN | Name | Subnet | Purpose |

|------|------|--------|---------|

| 10 | Academic | 10.10.10.0/24 | Students (300 users) |

| 20 | Administration | 10.10.20.0/24 | Staff (50 users) |

| 30 | Research | 10.10.30.0/24 | Labs (100 users) |

| 40 | Guest | 10.10.40.0/24 | Visitors (50 users) |

| 99 | DMZ | 172.16.0.0/24 | Public servers |



\## Technologies Used

\- iptables / pfSense

\- VLANs

\- NAT (SNAT, DNAT)

\- OpenVPN

\- Snort IDS/IPS

\- CARP High Availability

\- Prometheus + Grafana Monitoring



\## Repository Structure

