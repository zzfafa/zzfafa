#!/bin/bash
for i in `ifconfig | grep -o ^[a-z0-9]*`
do
ifconfig $i|sed -n 2p|awk '{ print $2 }'|tr -d 'addr:'
done
