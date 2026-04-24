**Firewall Monitoring Setup**



Prometheus Node Exporter





wget https://github.com/prometheus/node\_exporter/releases/download/v1.7.0/node\_exporter-1.7.0.linux-amd64.tar.gz

tar xvf node\_exporter-1.7.0.linux-amd64.tar.gz

sudo mv node\_exporter-1.7.0.linux-amd64/node\_exporter /usr/local/bin/



**Grafana Dashboard**

URL: http://10.10.20.30:3000

Login: admin / admin



**Telegram Alerts**



BOT\_TOKEN="YOUR\_BOT\_TOKEN"

CHAT\_ID="YOUR\_CHAT\_ID"



tail -f /var/log/syslog | while read line; do

&#x20;   if echo "$line" | grep -q "DROP"; then

&#x20;       curl -s -X POST https://api.telegram.org/bot$BOT\_TOKEN/sendMessage \\

&#x20;           -d chat\_id=$CHAT\_ID -d text="Firewall Alert: $line"

&#x20;   fi

done

