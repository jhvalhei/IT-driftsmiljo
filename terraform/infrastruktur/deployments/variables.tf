# resource group

variable "rg_dynamic" {
  description = "A map of resource groups names"
  type = map(object({
    name     = string
    location = string
  }))
}

variable "rg_name_static" {
  description = "Static name for resourcegroup used for shared resources"
  type        = string
  default     = "rgstatic001"
}

variable "rg_location_static" {
  description = "Static location for resourcegroup used for shared resources"
  type        = string
  default     = "westeurope"
}


# Module: containers


variable "law_name" {
  description = "Name of the log analytics workspace"
  type        = string
  default     = "acc001"
}

variable "law_sku" {
  description = "Unique identifier for log analytics workspace"
  type        = string
  default     = "PerGB2018"
}

variable "law_retention" {
  description = "Renention of data for logs analytics workspace"
  type        = number
  default     = 30
}

variable "cae_name" {
  description = "Name of the container app enviorment"
  type        = string
  default     = "CA-Enviornment001"
}



variable "container" {
  description = "A map of variables for container"
  type = map(object({
    name           = string
    revmode        = optional(string, "Single")
    regserver      = optional(string, "ghcr.io")
    reguname       = string
    regtoken       = string
    trafficweight  = optional(number, 100)
    latestrevision = optional(bool, true)
    targetport     = optional(number, 5000)
    external       = optional(bool, true)
    image          = string
    cpu            = optional(number, 0.25)
    memory         = optional(string, "0.5Gi")
    rg             = string
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

# Module: database

variable "postgreserver_name" {
  description = "The name of the postgresql server"
  type        = string
  default     = "postgresql-server-001"
}


variable "postgreserver_skuname" {
  description = "Name of the sku for the postgresql server"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgreserver_storage_mb" {
  description = "Maximum storage capacity for the postgresql server"
  type        = number
  default     = 32768
}

variable "postgreserver_storage_tier" {
  description = "Storage toer for the postgresql flexible server"
  type        = string
  default     = "P4"
}

variable "postgreserver_backup_retention" {
  description = "Retention of backup for the postgresql server in days"
  type        = number
  default     = 7
}

variable "postgreserver_redundant_backup" {
  description = "Choose between locally redundant or geo-redundant backup"
  type        = bool
  default     = false
}

variable "postgreserver_auto_grow" {
  description = "Enable auto grow for the posrgresql server"
  type        = bool
  default     = true
}

variable "postgreserver_admin_uname" {
  description = "Username for the administrator user"
  type        = string
}

variable "postgreserver_admin_password" {
  description = "Password for the administrator user"
  type        = string
}

variable "postgreserver_version" {
  description = "Version number of the postgresql server"
  type        = string
  default     = "14"
}

variable "postgreserver_public_network_access" {
  description = "Enable public network access"
  type        = bool
  default     = false
}

variable "postgreserver_zone" {
  description = "The zone for the postgresql flexible server"
  type        = string
  default     = "1"
}

variable "postdb" {
  description = "Variables for a postgresql database"
  type = map(object({
    name            = string
    charset         = string
    collation       = string
    prevent_destroy = bool
  }))
  default = {
    "dfpostdb" = {
      name            = "dfdapostdb"
      charset         = "UTF8"
      collation       = "en_US.utf8"
      prevent_destroy = false
    }
  }
}

# Module: network

variable "nsg_name" {
  description = "Name of the network security group"
  type        = string
  default     = "nsg"
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "vnet"
}

variable "vnet_addresspace" {
  description = "Addresspace for the virtual network"
  type        = set(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "subnet"
}

variable "subnet_address_prefixes" {
  description = "The address prefixes for the subnet"
  type        = set(string)
  default     = ["10.0.2.0/20"]
}
variable "subnetcEnv_address_prefixes" {
  description = "The address prefixes for the subnet"
  type        = set(string)
  default     = ["10.0.32.0/20"]
}

variable "subnet_service_endpoint" {
  description = "The service endpoints for the subnet"
  type        = set(string)
  default     = ["Microsoft.Storage"]
}

variable "subnet_delegation_name" {
  description = "Name of the delegation for the subnet"
  type        = string
  default     = "fs"
}

variable "subnet_service_delegation_name" {
  description = "Name of the delegation service for the subnet"
  type        = string
  default     = "Microsoft.DBforPostgreSQL/flexibleServers"
}

variable "subnet_service_delegation_actions" {
  description = "Sets of actions for the service delegation for the subnet"
  type        = set(string)
  default     = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
}

variable "privdnszone_name" {
  description = "Name of the private dns zone"
  type        = string
  default     = "example.postgres.database.azure.com"
}

variable "privdnslink_name" {
  description = "Name of the link between the private dns zone and the virtual network"
  type        = string
  default     = "exampleVnetZone.com"
}