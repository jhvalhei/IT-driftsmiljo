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

variable "email_name" {
    description = "Name of the email receiver for alerts"
    type = string
}

variable "email_address" {
    description = "Email address of the email receiver for alerts"
    type = string
}

variable "sms_name" {
    description = "Name of the sms receiver for alerts"
    type = string
}

variable "sms_number" {
    description = "Number for the sms receiver for alerts"
    type = number
}

variable "capp_ids" {
    description = "The ids for the container apps"
    type = map(string)
}

variable "postdb_ids" {
    description = "The ids for the PostgreSQL databases"
    type = map(string)
}
