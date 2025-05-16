variable "rg_backend_name" {
  type        = string
  description = "Name of backend resource group"
  default = "rg-backend"
}

variable "rg_backend_location" {
  type        = string
  description = "Location of backend resource groupt"
  default = "westeurope"
}

variable "backend_container_name" {
  type        = string
  description = "Name of backend container"
  default = "backend-container"

}

variable "backend_sa_ak_name" {
  type        = string
  description = "Name of secret which holds primary access key to the backend storage account"
  default = "ak-backend"
}