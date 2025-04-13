variable "rg_dynamic" {
  description = "A map of resource groups variables"
  type = map(object({
    name     = string
    location = optional(string, "westeurope")
  }))
}

variable "rg_name_dynamic" {
  description = "Name of the resource group"
  type        = string
  default     = "rgname001"
}

variable "rg_name_global" {
  description = "Name of reasource group for global resources"
  type        = string
  default     = "rg-globalresources"
}

variable "rg_location_global" {
  description = "Location of reasource group for global resources"
  type        = string
  default     = "westeurope"
}

variable "rg_name_storage" {
  description = "Name for storage rg"
  type        = string
}

variable "rg_location_storage" {
  description = "Location for storage rg"
  type        = string
  default     = "westeurope"
}

# Identity - KEY NAME OF EACH OBJECT MUST BE IDENTICAL TO CONTAINER APP NAME
variable "capp_identity" {
  description = "Identity for each container"
  type = map(object({ # key name: <cAppName_id>
    name = string     # 
  }))
}




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

variable "cenv_subnet_id" {
  description = "The id of the subnet"
  type        = string
}
/*
variable "dbserversecretId" {
  description = "ID of db secret"
  type = string
}
*/
variable "reguname" {
  description = "Username for github container registry"
  type        = string
}

variable "regtoken" {
  description = "Password for github container registry"
  type        = string
}

variable "capp_with_db" {
  description = "A map of variables for container"
  type = map(object({
    name                 = string
    revmode              = optional(string, "Single")
    regserver            = optional(string, "ghcr.io")
    trafficweight        = optional(number, 100)
    latestrevision       = optional(bool, true)
    targetport           = optional(number, 8080)
    external             = optional(bool, true)
    ip_restriction_range = optional(string, "0.0.0.0/0") # 0.0.0.0/0 = all ip addresses
    image                = string
    cpu                  = optional(number, 0.25)
    memory               = optional(string, "0.5Gi")
  }))
}

variable "capp_without_db" {
  description = "A map of variables for container"
  type = map(object({
    name                 = string
    revmode              = optional(string, "Single")
    regserver            = optional(string, "ghcr.io")
    trafficweight        = optional(number, 100)
    latestrevision       = optional(bool, true)
    targetport           = optional(number, 8080)
    external             = optional(bool, true)
    ip_restriction_range = optional(string, "0.0.0.0/0") # 0.0.0.0/0 = all ip addresses
    image                = string
    cpu                  = optional(number, 0.25)
    memory               = optional(string, "0.5Gi")
  }))
}


