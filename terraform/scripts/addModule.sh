#!/bin/bash

if [[ -n $1 ]]; then

    echo "module \"container_app\" {
    source = \"../modules/containers\"
    containerapp-name = var.${1}-containerapp-name
    }"

else
    echo "Trenger navn på studentoppgave"
fi
