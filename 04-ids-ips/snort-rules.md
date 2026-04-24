**# Snort IDS/IPS Rules**



\## Author: Israr Sadaq



**## Custom Rules**



**### Port Scan Detection**



alert tcp $HOME\_NET any -> $HOME\_NET 1:1024 (

&#x20;   msg:"Port scan detected";

&#x20;   flags:S;

&#x20;   threshold:type both, track by\_src, count 5, seconds 10;

&#x20;   sid:1000001;

)

**SSH Brute Force Detection**



alert tcp $HOME\_NET any -> $HOME\_NET 22 (

&#x20;   msg:"SSH brute force";

&#x20;   detection\_filter:track by\_src, count 10, seconds 60;

&#x20;   sid:1000002;

)

**Malware Callback Detection**



alert tcp $HOME\_NET any -> !$HOME\_NET 1:65535 (

&#x20;   msg:"Possible malware callback";

&#x20;   content:"|16 03|";

&#x20;   depth:2;

&#x20;   sid:1000003;

)

**Running Snort**



\# IDS Mode

snort -A console -c /etc/snort/snort.conf -i eth0



\# IPS Mode (inline)

snort -Q -c /etc/snort/snort.conf -i eth1.10:eth1.20



\# View alerts

tail -f /var/log/snort/alert

