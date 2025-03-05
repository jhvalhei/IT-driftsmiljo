variable "rg_name_dynamic" {
    description = "Name of the resource group"
    type = string
    default = "rgname001"
}

variable "rg_name_static" {
    description = "Static name for resourcegroup used for shared resources"
    type = string
    default = "rgname001"
}

variable "rg_location_static" {
    description = "Static location for resourcegroup used for shared resources"
    type = string
    default = "westeurope"
}

variable "law_name" {
    description = "Name of the log analytics workspace"
    type = string
    default = "acc001"
}

variable "law_sku" {
    description = "Unique identifier for log analytics workspace"
    type = string
    default = "PerGB2018"
}

variable "law_retention" {
    description = "Renention of data for logs analytics workspace"
    type = number
    default = 30
}

variable "cae_name" {
    description = "Name of the container app enviorment"
    type = string
    default = "CA-Enviornment001"
}

variable "container" {
        description = "A map of variables for container"
        type = map(object({
            name = string
            revmode = string
            regserver = string
            reguname = string
            regtoken = string
            image = string
            cpu = number
            memory = string
            rg = string
        }))
        default = {
          "dfcontainer" = {
            name = "dfcc-app"
            revmode = "Single"
            regserver = "ghcr.io"
            reguname = "test"
            regtoken = "test"
            image = "ghcr.io/bachelorgruppe117-ntnu-gjovik/testwebapp-app:latest"
            cpu = 0.25
            memory = "0.5Gi"
            rg = "rgstatic001"
          }
        }
    }

/**
variable "capp_name" {
    description = "Name of the container app"
    type = string
    default = "c-app001"
}

variable "capp_revmode" {
    description = "Revision mode for the container app"
    type = string
    default = "Single"
}

variable "capp_image" {
    description = "Referance to the contariner image"
    type = string
    default = ""
}

variable "capp_cpu" {
    description = "The amount of vCPU to allocate to the container"
    type = number
    default = 0.25
}

variable "capp_memory" {
    description = "The amount of memory to allocate to the container"
    type = string
    default = "0.5Gi"
}
**/