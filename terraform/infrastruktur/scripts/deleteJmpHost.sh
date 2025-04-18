#!/bin/bash

# Deletes the jump host and its dependent resources
# Deletion order: vm, nic, ip, disk, nsg, subnet
az vm delete --name jmphost -g rg-globalresources --yes
az network nic delete --name jmphostVMNic -g rg-globalresources
az network public-ip delete --name jmphostpublicIP -g rg-globalresources
DISKNAME=$(az disk list -o table | awk 'NR>2 {print $1}')
az disk delete --disk-name $DISKNAME -g rg-globalresources --yes
az network nsg delete --name jmphostNSG -g rg-globalresources
az network vnet subnet delete --name jmphostsubnet -g rg-globalresources --vnet-name vnet-rg-globalresources
