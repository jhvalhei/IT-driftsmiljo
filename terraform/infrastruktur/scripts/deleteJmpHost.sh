#!/bin/bash

# Deletes the jump host and its dependent resources
# Deletion order: vm, nic, ip, disk, nsg, subnet
az vm delete --name jmphost -g rgstatic001 --yes
az network nic delete --name jmphostVMNic -g rgstatic001
az network public-ip delete --name jmphostpublicIP -g rgstatic001
DISKNAME=$(az disk list -o table | awk 'NR>2 {print $1}')
az disk delete --disk-name $DISKNAME -g rgstatic001 --yes
az network nsg delete --name jmphostNSG -g rgstatic001
az network vnet subnet delete --name jmphostsubnet -g rgstatic001 --vnet-name vnet-rgstatic001
