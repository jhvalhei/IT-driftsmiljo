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

variable "regtoken" {
  type = string
}

    variable "container" {
        description = "A map of variables for container"
        type = map(object({
            name = string
            revmode = optional(string,"Single")
            regserver = optional(string,"ghcr.io")
            reguname = optional(string,"danielthorland"
            trafficweight = optional(number,100)
            latestrevision = optional(bool,true)
            targetport = optional(number,5000)
            external = optional(bool,true)
            image = string
            cpu = optional(number,0.25)
            memory = optional(string,"0.5Gi")
            rg = string
        }))
        /*
        default = {
          "dfcontainer" = {
            name = "dfmc-app"
            revmode = optional(string,"Single")
            regserver = optional(string,"ghcr.io")
            reguname = "test"
            regtoken = "test"
            trafficweight = optional(number,100)
            latestrevision = true
            targetport = 5000
            external = true
            image = "ghcr.io/bachelorgruppe117-ntnu-gjovik/testwebapp-app:latest"
            cpu = 0.25
            memory = "0.5Gi"
            rg = "rgstatic001"
          }
        }
        */
}