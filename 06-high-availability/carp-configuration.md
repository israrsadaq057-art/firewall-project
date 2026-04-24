**CARP High Availability Configuration**



**CARP Virtual IP**



| Setting | Value |

|---------|-------|

| Virtual IP | 10.10.1.1/24 |

| Master | 10.10.1.2 |

| Backup | 10.10.1.3 |

| Password | securecarp123 |



**Master Firewall Configuration**





ifconfig carp1 create

ifconfig carp1 vhid 1 pass securecarp123 10.10.1.1/24



**Backup Firewall Configuration**



ifconfig carp1 create

ifconfig carp1 vhid 1 advskew 100 pass securecarp123 10.10.1.1/24



**Verify CARP Status**



ifconfig carp1

