#!/usr/bin/env bash
LO_STATE=$(ip a | grep LOOPBACK | awk '{print $9}')
DATE=$(date +'[%D %T]')

if [[ $LO_STATE == "DOWN" ]]; then
  echo "$DATE At the moment LoopBack interface state is: $LO_STATE" >> /var/log/script-logs
  echo "$DATE Setting up things..." >> /var/log/script-logs
  ip link set lo up
  echo "$DATE Done!" >> /var/log/script-logs
  LO_STATE=$(ip a | grep LOOPBACK | awk '{print $9}')
  echo "$DATE After enabling, loopBack interface state is: $LO_STATE" >> /var/log/script-logs
fi
