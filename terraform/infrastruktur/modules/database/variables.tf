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

variable "postgreserver_name" {
    description = "The name of the postgresql server"
    type = string
    default = "postgresql-server-001"
}

variable "postgreserver_skuname" {
    description = "Name of the sku for the postgresql server"
    type = string
    default = "B_Gen5_2"
}

variable "postgreserver_storage_mb" {
    description = "Maximum storage capacity for the postgresql server"
    type = number
    default = 5120
}

variable "postgreserver_backup_retention" {
    description = "Retention of backup for the postgresql server in days"
    type = number
    default = 7
}

variable "postgreserver_redundant_backup" {
    description = "Choose between locally redundant or geo-redundant backup"
    type = bool
    default = false
}

variable "postgreserver_auto_grow" {
    description = "Enable auto grow for the posrgresql server"
    type = bool
    default = true  
}

variable "postgreserver_admin_uname" {
    description = "Username for the administrator user"
    type = string
    default = "ntnuadmin"
}

variable "postgreserver_admin_password" {
    description = "Password for the administrator user"
    type = string
    default = "hvordanskaljegloggemeginnpådennebrukeren"
}

variable "postgreserver_version" {
    description = "Version number of the postgresql server"
    type = string
    default = "14"
}

variable "postgreserver_ssl" {
    description = "Enable SSL enforcement for the postgrespl server"
    type = bool
    default = true
}

variable "postdb" {
    description = "Variables for a postgresql database"
    type = map(object({
        name = string
        charset = string
        collation = string
        prevent_destroy = bool
    }))
    default = {
        "dfpostdb" = {
        name = "dfdapostdb"
        charset = "UTF8"
        collation = "English_United States.1252"
        prevent_destroy = false
        }
    }
}