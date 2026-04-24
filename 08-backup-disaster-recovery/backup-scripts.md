**Backup \& Disaster Recovery**



Backup Script (/usr/local/bin/backup-firewall.sh)





\#!/bin/bash

BACKUP\_DIR="/backup/firewall"

DATE=$(date +%Y%m%d\_%H%M%S)



mkdir -p $BACKUP\_DIR

iptables-save > $BACKUP\_DIR/iptables-rules-$DATE.v4

cp /etc/wireguard/wg0.conf $BACKUP\_DIR/wireguard-$DATE.conf



\# Keep last 30 days

find $BACKUP\_DIR -type f -mtime +30 -delete



echo "Backup completed at $DATE"



**Restore Script (/usr/local/bin/restore-firewall.sh)**



\#!/bin/bash

if \[ -f /backup/firewall/iptables-rules-latest.v4 ]; then

&#x20;   iptables-restore < /backup/firewall/iptables-rules-latest.v4

&#x20;   echo "Firewall rules restored"

fi

**Schedule Backup (cron)**



0 2 \* \* \* /usr/local/bin/backup-firewall.sh

