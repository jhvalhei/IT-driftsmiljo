#!/bin/bash

SECRET="${1}"
USERNAME="${2}"
STUDENTDB="${3}"
DBUSER="${4}"

SERVERNAME=$(az postgres flexible-server list -o table | awk 'NR==3 {print $1}')
KEYVAULTNAME=$(az keyvault list -o table | awk 'NR>2 {print $2}')
USERSECRET=$(az keyvault secret show --vault-name ${KEYVAULTNAME} -n "${STUDENTDB}secret" -o table | awk 'NR==3 {print $2}')

az postgres flexible-server execute -n "${SERVERNAME}" -u "${USERNAME}" -p "${SECRET}" -d "${STUDENTDB}" -q "CREATE USER \"${DBUSER}\" WITH PASSWORD '${USERSECRET}';" --output table
az postgres flexible-server execute -n "${SERVERNAME}" -u "${USERNAME}" -p "${SECRET}" -d "${STUDENTDB}" -q "GRANT ALL PRIVILEGES ON DATABASE \"${STUDENTDB}\" TO \"${DBUSER}\";" --output table


# Executes the sql config files
for z in "${STUDENTDB}"/*DDL*.txt; do
	if [[ -f ${z} ]]; then
		az postgres flexible-server execute -n "${SERVERNAME}" -u "${USERNAME}" -p "${SECRET}" -d "${STUDENTDB}" --file-path "${z}"
	fi
done
for z in "${STUDENTDB}"/*DML*.txt; do
	if [[ -f ${z} ]]; then
		az postgres flexible-server execute -n "${SERVERNAME}" -u "${USERNAME}" -p "${SECRET}" -d "${STUDENTDB}" --file-path "${z}"
	fi

# Grant read and write access
az postgres flexible-server execute -n "${SERVERNAME}" -u "${USERNAME}" -p "${SECRET}" -d "${STUDENTDB}" -q "GRANT pg_read_all_data TO \"${DBUSER}\";" --output table
az postgres flexible-server execute -n "${SERVERNAME}" -u "${USERNAME}" -p "${SECRET}" -d "${STUDENTDB}" -q "GRANT pg_write_all_data TO \"${DBUSER}\";" --output table

done
