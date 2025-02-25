#!/bin/bash

if [[ -n $1 ]]; then

    echo "variable \"${1}-containerapp-name\" {
    type = string
    Description = "Name of container app"  
}"

else
    echo "Trenger navn på studentoppgave"
fi
