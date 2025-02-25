variable "resource_group_location" {
  type        = string
  default     = "westeurope"
  description = "Lokasjonen av resource group."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg"
  description = "Prefikset til ressursgruppens navn som kombineres med en tilfeldig ID, slik at navnet blir unikt i Azure."
}
