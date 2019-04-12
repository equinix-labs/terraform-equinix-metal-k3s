#!/bin/bash

echo "[controllers]" | tee deploy_demo/inventory.yaml && \

for host in `cd ../ ; terraform state list | grep primary | xargs -n1 -I% terraform state show % | grep network.0.address | awk '{print $3}'` ; do \
	echo root@$host | tee -a deploy_demo/inventory.yaml ; done
