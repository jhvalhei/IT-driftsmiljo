variable "rg_backend_name" {
  type        = string
  description = "Name of backend resource group"
}

variable "rg_backend_location" {
  type        = string
  description = "Location of backend resource groupt"
}

variable "backend_container_name" {
  type        = string
  description = "Name of backend container"
}

variable "backend_sa_ak_name" {
  type        = string
  description = "Name of secret which holds primary access key to the backend storage account"
}