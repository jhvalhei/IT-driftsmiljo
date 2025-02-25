variable "containerapp-name" {
    type = string
    description = "name of container app"
}

variable "location" {
  type        = string
  description = "location of resource"
  default     = "westeurope"
}