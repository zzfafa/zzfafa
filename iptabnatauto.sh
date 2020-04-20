#!/bin/bash
read -p "本地起始端口：" portup
read -p "内网 NAT 地址：" ip
read -p "远程转发端口：" port
read -p "清空现在所有转发的 IP (y/n 默认 n )：" delall
portup=23001
port=443
ip=10.0.0.4
wget -O iplist.txt https://raw.githubusercontent.com/zzfafa/zzfafa/master/iplist
str=$(cat iplist.txt)
OLD_IFS="$IFS"
IFS="," 
strs=($str)

for(( i=0 ;i<${#strs[@]};i++))
do
iptables -t nat -A PREROUTING -p tcp -m tcp --dport $[portup + i] -j DNAT --to-destination ${strs[i]}:$port
iptables -t nat -A PREROUTING -p udp -m udp --dport $[portup + i] -j DNAT --to-destination ${strs[i]}:$port
iptables -t nat -A POSTROUTING -d ${strs[i]} -p tcp -m tcp --dport $port -j SNAT --to-source $ip
iptables -t nat -A POSTROUTING -d ${strs[i]} -p udp -m udp --dport $port -j SNAT --to-source $ip
iptables -I INPUT -p tcp --dport $[portup + i] -j ACCEPT
echo "添加端口 $[portup + i] 转发至 ${strs[i]}:$port 成功"
done
echo "成功添加 $i 个转发 IP"
#iptables -I INPUT -p tcp --dport $[portup]:$[portup + i] -j ACCEPT
#echo "端口已开放 $[portup]:$[portup + i]"

service iptables save
#systemctl restart iptables.service
#systemctl status iptables.service
