#!/bin/bash

if [[ -n $1 ]]; then

    echo "resource \"azurerm_container_app\" \"example\" {
  name                         = var.${1}-containerAppName
  container_app_environment_id = azurerm_container_app_environment.example.id
  resource_group_name          = azurerm_resource_group.example.name
  revision_mode                = "Single"

  template {
    container {
      name   = var.containerName
      image  = var.containerImage
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
}"

else
    echo "Trenger navn på studentoppgave"
fi
