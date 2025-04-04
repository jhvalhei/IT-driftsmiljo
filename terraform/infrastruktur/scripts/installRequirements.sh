#!/bin/bash

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
sudo apt install postgresql --yes
az login --service-principal --username "${1}" --password "${2}" --tenant "${3}"
az config set extension.dynamic_install_allow_preview=true
az config set extension.use_dynamic_install=yes_without_prompt
az extension add --name rdbms-connect
az extension add --upgrade -n rdbms-connect
