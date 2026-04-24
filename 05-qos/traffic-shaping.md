**QoS / Traffic Shaping Configuration**



**Guest VLAN Rate Limiting (10 Mbps)**





tc qdisc add dev eth1.40 root handle 1: htb default 30

tc class add dev eth1.40 parent 1: classid 1:1 htb rate 100mbit

tc class add dev eth1.40 parent 1:1 classid 1:10 htb rate 10mbit ceil 20mbit

tc filter add dev eth1.40 protocol ip parent 1:0 prio 1 u32 match ip dst 0.0.0.0/0 flowid 1:10



**Verify QoS**



tc -s qdisc show dev eth1.40

tc -s class show dev eth1.40

