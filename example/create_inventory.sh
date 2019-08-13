#!/bin/bash

echo "[controllers]" | tee demos/inventory.yaml && \

#for host in `cd ../ ; terraform state list | grep primary | xargs -n1 -I% terraform state show % | grep network.0.address | awk '{print $3}'` ; do \
for host in `cd ../ ; grep access_public_ipv4 terraform.tfstate | awk '{print $2}' | sed -e 's|"||g' -e 's|,||g'`; do
	echo root@$host | tee -a demos/inventory.yaml ; done
