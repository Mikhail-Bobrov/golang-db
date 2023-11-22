#!/bin/bash

read -p "Enter input file-name: " file
read -p "Enter output file-name: " file_out



uid1=$(jq '.panels[1].datasource.uid' $file)
echo $uid1
cat $file | jq -c | sed  's/"datasource":{"type":"prometheus","uid":'$uid1'}/"datasource":"Prometheus"/g' | jq > $file_out
uid2=$(jq '.uid' $file_out)
echo $uid2
uid3=$(echo $uid2 | sed  's/"/9"/2')
echo $uid3
tmp=$(mktemp)
jq '.uid = '${uid3}' ' $file_out > "$tmp" && mv "$tmp" $file_out
