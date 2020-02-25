#!/bin/bash
read -p "本地起始端口：" portup
read -p "内网 NAT 地址：" ip
read -p "远程转发端口：" port
read -p "待转发的 ip 地址(以,号分隔)：" str
read -p "清空现在所有转发的 IP (y/n 默认 n )：" delall
OLD_IFS="$IFS"
IFS="," 
strs=($str)
if [ $delall == "y" ]; then
  iptables -t nat -F
  echo "已清空现在所有转发的 IP"
fi

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

iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
service iptables save
systemctl enable iptables.service
systemctl stop iptables
systemctl start iptables
systemctl restart iptables
systemctl reload iptables
