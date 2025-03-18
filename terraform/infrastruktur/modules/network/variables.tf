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
  default     = ["10.0.2.0/24"]
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