#!/bin/bash
#read -p "本地起始端口：" portup
#read -p "内网 NAT 地址：" ip
#read -p "远程转发端口：" port
#read -p "清空现在所有转发的 IP (y/n 默认 n )：" delall
portup=23001
port=443
ip=10.0.0.4
#wget -O iplist.txt https://raw.githubusercontent.com/zzfafa/zzfafa/master/iplist
str=23.99.112.18,23.99.106.177,23.99.107.138,23.99.114.57,23.99.120.225,52.175.51.184,52.175.51.210,52.175.54.235,52.175.49.89,52.175.53.142,52.175.54.66,13.70.56.26,52.184.34.57,52.175.120.44,52.175.127.219,23.99.112.56,168.63.155.194,168.63.155.200,23.98.42.68,168.63.152.171,23.99.112.18,23.99.106.177,23.99.107.138,23.99.114.57,23.99.120.225,52.175.51.184,52.175.51.210,52.175.54.235,52.175.49.89,52.175.53.142,52.175.54.66,13.70.56.26,52.184.34.57,52.175.120.44,52.175.127.219,23.99.112.56,168.63.155.194,168.63.155.200,23.98.42.68,168.63.152.171
#$(cat iplist.txt)
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
