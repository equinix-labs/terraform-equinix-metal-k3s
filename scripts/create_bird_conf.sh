#!/bin/bash

json=$(curl -s https://metadata.packet.net/metadata)
MY_PRIVATE_IP=$(echo $json | jq -r ".network.addresses[] | select(.public == false) | .address")
MY_PRIVATE_GW=$(echo $json | jq -r ".network.addresses[] | select(.public == false) | .gateway")

ELASTIC_IP=$1

if grep --quiet 'lo:0' /etc/network/interfaces; then
echo "lo:0 config already exists"
else
echo "
auto lo:0
  iface lo:0 inet static
  address $ELASTIC_IP
  netmask 255.255.255.255" >> /etc/network/interfaces
fi

read -r -d '' CONF  << EOM
filter packet_bgp {
  if net = $ELASTIC_IP/32 then accept;
}

router id $MY_PRIVATE_IP;

protocol direct {
  interface "lo"; # Restrict network interfaces BIRD works with
}

protocol kernel {
  learn;
  persist; # Don't remove routes on bird shutdown
  scan time 10; # Scan kernel routing table every 20 seconds
  import all; # Default is import all
  export none; # Default is export none
}

protocol device {
  scan time 5; # Scan interfaces every 10 seconds
}

protocol bgp {
  export filter packet_bgp;
  local as 65000;
  neighbor $MY_PRIVATE_GW as 65530;
}
EOM

echo -e "$CONF" > /etc/bird/bird.conf

sysctl net.ipv4.ip_forward=1
ifup lo:0
service bird restart


