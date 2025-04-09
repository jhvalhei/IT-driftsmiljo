#!/bin/bash

# Arguments:
# 1. Name of the student project
# 2. Username for the database
# 3. App id for the service principal
# 4. Password for the service principal
# 5. Tenant id for the azure tenant

if [[ $# -ne 5 ]]; then
	echo "Illegal number of parameters. Use: <student-project-name> <database-username> <service-principal-app-id> <service-principal-password> <tenant-id>" >&2
	exit 2
fi

STUDENTFOLDER=${1}
USERNAME=${2}
AZUNAME=${3}
AZPASS=${4}
TENANT=${5}
VM_NAME="jmphost"
SUBNET="jmphostsubnet"
STUDENTFOLDERPATH="../../../studentOppgaver/${STUDENTFOLDER}"
VM_IMAGE="Canonical:0001-com-ubuntu-minimal-jammy:minimal-22_04-lts-gen2:latest"

az login --service-principal --username ${AZUNAME} --password ${AZPASS} --tenant ${TENANT}
KEYVAULTNAME=$(az keyvault list -o table | awk 'NR>2 {print $2}')
SECRET=$(az keyvault secret show --vault-name ${KEYVAULTNAME} -n db-server-admin-secret -o table | awk 'NR==3 {print $2}')
RESOURCE_GROUP_NAME=$(az group list -o table | awk '/rgstatic/ {print $1}')
VNET=$(az network vnet list -o table | awk '/'"${RESOURCE_GROUP_NAME}"'/ {print $1}')

# Creates a jump host vm and dependable resources in azure
az vm create \
	--resource-group "${RESOURCE_GROUP_NAME}" \
	--name "${VM_NAME}" \
	--image "${VM_IMAGE}" \
	--admin-username "${USERNAME}" \
	--vnet-name "${VNET}" \
	--subnet "${SUBNET}" \
	--assign-identity \
	--generate-ssh-keys \
	--public-ip-sku Standard

az vm extension set \
	--publisher Microsoft.Azure.ActiveDirectory \
	--name AADSSHLoginForLinux \
	--resource-group "${RESOURCE_GROUP_NAME}" \
	--vm-name "${VM_NAME}"

IP_ADDRESS=$(az vm show --show-details --resource-group "${RESOURCE_GROUP_NAME}" --name "${VM_NAME}" --query publicIps --output tsv)

# Securly transfers the sql config files to the jump host
if [[ -d ${STUDENTFOLDERPATH} ]]; then
	for n in "${STUDENTFOLDERPATH}"/*.txt; do # Optional: switch to .sql if desirable
		if [[ -f ${n} ]] && [[ ${n} == *DDL* || ${n} == *DML* ]]; then
			STUDENTDB="$(echo "${STUDENTFOLDER}" | awk '{print tolower($0)}')_db"
			ssh -o StrictHostKeyChecking=no "${USERNAME}"@"${IP_ADDRESS}" "mkdir -p ${STUDENTDB}" && scp -o StrictHostKeyChecking=no "${n}" "${USERNAME}"@"${IP_ADDRESS}":/home/"${USERNAME}"/"${STUDENTDB}"/
		fi
	done
fi

# Installs the necessary requirements on the jump host
ssh -o StrictHostKeyChecking=no "${USERNAME}"@"${IP_ADDRESS}" "bash -s" -- "${AZUNAME}" "${AZPASS}" "${TENANT}" <./installRequirements.sh

# Executes the sql query configs
ssh -o StrictHostKeyChecking=no "${USERNAME}"@"${IP_ADDRESS}" "bash -s" -- "${SECRET}" "${USERNAME}" "${STUDENTDB}" <./executeSqlConfig.sh

# Deletes the jump host and its dependent resources
./deleteJmpHost.sh
