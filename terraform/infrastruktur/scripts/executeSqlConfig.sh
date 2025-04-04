#!/bin/bash

SECRET="${1}"
USERNAME="${2}"
STUDENTDB="${3}"
SERVERNAME=$(az postgres flexible-server list -o table | awk 'NR==3 {print $1}')

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
done
