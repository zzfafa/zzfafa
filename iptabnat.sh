#!/bin/bash
read -p "本地起始端口：" portup
read -p "内网 NAT 地址：" ip
read -p "远程转发端口：" port
read -p "待转发的 ip 地址(以,号分隔)：" str
OLD_IFS="$IFS"
IFS="," 
strs=($str)

for(( i=0 ;i<${#strs[@]};i++))
do
iptables -t nat -A PREROUTING -p tcp -m tcp --dport $[portup + i] -j DNAT --to-destination ${strs[i]}:$port
iptables -t nat -A PREROUTING -p udp -m udp --dport $[portup + i] -j DNAT --to-destination ${strs[i]}:$port
iptables -t nat -A POSTROUTING -d ${strs[i]} -p tcp -m tcp --dport $port -j SNAT --to-source $ip
iptables -t nat -A POSTROUTING -d ${strs[i]} -p udp -m udp --dport $port -j SNAT --to-source $ip
done
