**# Incident Response Plan – Firewall Security**



\## Author: Israr Sadaq



\## Severity Levels



| Level | Name | Response Time |

|-------|------|---------------|

| 1 | Critical | 15 minutes |

| 2 | High | 30 minutes |

| 3 | Medium | 2 hours |

| 4 | Low | 24 hours |



\## Response Steps



**1. Detection**



\# Monitor logs

tail -f /var/log/syslog | grep "FW-DROPPED"

tail -f /var/log/snort/alert

**2. Analysis**



\# Find attacking IPs

grep "DPT=" /var/log/syslog | awk '{print $13}' | sort | uniq -c | sort -nr

**3. Containment**



\# Block attacking IP

iptables -A INPUT -s <ATTACKER\_IP> -j DROP

**4. Eradication**



\# Save to persistent list

echo "<ATTACKER\_IP>" >> /etc/blocked-ips.txt

**5. Recovery**



systemctl restart iptables

**6. Lessons Learned**

Document the incident.



Emergency Contacts

Role	Name	Phone	Email

Primary	Israr Sadaq	+49 15215267799	israrsadaq057@gmail.com



