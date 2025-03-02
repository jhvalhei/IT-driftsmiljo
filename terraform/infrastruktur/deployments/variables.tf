# resource group

variable "rg_dynamic" {
    description = "A map of resource groups names"
    type        = map(object({
        name     = string
        location = string
    }))
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

# Module: containerapp

variable "law_name" {
    description = "Name of the log analytics workspace"
    type = string
    default = "acc001"
}

variable "law_sku" {
    description = "Unique identifier for log analytics workspace"
    type = string
    default = "PerGB2018"
}

variable "law_retention" {
    description = "Renention of data for logs analytics workspace"
    type = number
    default = 30
}

variable "cae_name" {
    description = "Name of the container app enviorment"
    type = string
    default = "CA-Enviornment001"
}

variable "container" {
    description = "A map of variables for container"
    type = map(object({
        name = string
        revmode = string
        image = string
        cpu = number
        memory = string
    }))
    default = {
        "dfcontainer" = {
        name = "dfdc-app"
        revmode = "Single"
        image = "ghcr.io/bachelorgruppe117-ntnu-gjovik/testwebapp-app:latest"
        cpu = 0.25
        memory = "0.5Gi"
        }
    }
}
/**
variable "capp_name" {
    description = "Name of the container app"
    type = string
    default = "c-app001"
}

variable "capp_revmode" {
    description = "Revision mode for the container app"
    type = string
    default = "Single"
}

variable "capp_image" {
    description = "Referance to the contariner image"
    type = string
    default = ""
}

variable "capp_cpu" {
    description = "The amount of vCPU to allocate to the container"
    type = number
    default = 0.25
}

variable "capp_memory" {
    description = "The amount of memory to allocate to the container"
    type = string
    default = "0.5Gi"
}
**/

# Module: database

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
    default = "9.5"
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
        name = "dfdpostdb"
        charset = "UTF8"
        collation = "English_United States.1252"
        prevent_destroy = false
        }
    }
}
/**
variable "postdb_name" {
    description = "Name of the postgresql database"
    type = string
    default = "postgresqldb001"
}

variable "postdb_charset" {
    description = "Charset for the postgresql database"
    type = string
    default = "UTF8"
}

variable "postdb_collation" {
    description = "Set collation for the postgresql database"
    type = string
    default = "English_United States.1252"
}

variable "postdb_prevent_destroy" {
    description = "Enable prevent destroy for the postgresql database"
    type = bool
    default = true
}
**/