variable "rg_name_storage" {
  description = "Name of the storage resource group"
  type = string
}

variable "rg_location_storage" {
    description = "Location of the storage resource group"
    type = string
}

variable "rootPath" {
  description = "Absolute path to infrastructure project"
  type        = string
}

variable "ctemplatePath" {
  description = "Path to container template file"
  type        = string
  default     = "/terraform/infrastruktur/templates/containerObj.json"
}

variable "dbtemplatePath" {
  description = "Path to database template file"
  type        = string
  default     = "/terraform/infrastruktur/templates/databaseObj.json"
}

variable "tfvarsPath" {
  description = "Path to .tfvars.json file"
  type        = string
  default     = "/terraform/infrastruktur/terraform.tfvars.json"
}