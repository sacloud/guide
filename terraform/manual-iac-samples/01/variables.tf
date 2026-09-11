variable "prefix" {
  description = "Resource name prefix"
  type        = string
  default     = "example-02"
}

variable "server_password" {
  description = "Password for server root user"
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "Domain name for GSLB health check"
  type        = string
  default     = "example.com"
}

variable "os_type" {
  description = "Operating system type for servers"
  type        = string
  default     = "almalinux"
  validation {
    condition     = contains(["ubuntu", "debian", "rockylinux", "almalinux", "miraclelinux", "windows2019", "windows2022", "windows2025"], var.os_type)
    error_message = "OS type must be one of: ubuntu, debian, rockylinux, almalinux, miraclelinux, windows2019, windows2022, windows2025."
  }
}

variable "archive_ostype" {
  description = "Archive OS type (for specific versions). Leave empty to use latest of os_type."
  type        = string
  default     = ""
}

variable "archive_name_filter" {
  description = "Additional filter for archive name (for specific versions)"
  type        = string
  default     = ""
}

# Locals for region management
locals {
  # Use direct subnet configuration without region mapping
  primary_subnet   = var.primary_subnet_cidr
  secondary_subnet = var.secondary_subnet_cidr

  # Validation: regions must be different
  regions_are_different = var.primary_region != var.secondary_region
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "dbuser"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "primary_region" {
  description = "Primary region for master database and main services"
  type        = string
}

variable "secondary_region" {
  description = "Secondary region for slave database and disaster recovery"
  type        = string
}

variable "primary_subnet_cidr" {
  description = "CIDR block for primary region subnet"
  type        = string
  default     = "192.168.0.0/24"
  validation {
    condition     = can(cidrhost(var.primary_subnet_cidr, 0))
    error_message = "primary_subnet_cidr must be a valid CIDR block."
  }
}

variable "secondary_subnet_cidr" {
  description = "CIDR block for secondary region subnet"
  type        = string
  default     = "192.168.1.0/24"
  validation {
    condition     = can(cidrhost(var.secondary_subnet_cidr, 0))
    error_message = "secondary_subnet_cidr must be a valid CIDR block."
  }
}

# Server specification variables
variable "server_core" {
  description = "Number of CPU cores for servers"
  type        = number
  default     = 2
  validation {
    condition     = contains([1, 2, 4, 8, 16, 32], var.server_core)
    error_message = "Server core must be one of: 1, 2, 4, 8, 16, 32."
  }
}

variable "server_memory" {
  description = "Memory size in GB for servers"
  type        = number
  default     = 2
  validation {
    condition     = contains([1, 2, 4, 8, 16, 32, 64, 128], var.server_memory)
    error_message = "Server memory must be one of: 1, 2, 4, 8, 16, 32, 64, 128."
  }
}

variable "server_disk_size" {
  description = "Disk size in GB for servers"
  type        = number
  default     = 100
  validation {
    condition     = var.server_disk_size >= 20 && var.server_disk_size <= 4000
    error_message = "Server disk size must be between 20 and 4000 GB."
  }
}

variable "server_disk_plan" {
  description = "Disk plan for servers (ssd or hdd)"
  type        = string
  default     = "ssd"
  validation {
    condition     = contains(["ssd", "hdd"], var.server_disk_plan)
    error_message = "Server disk plan must be either 'ssd' or 'hdd'."
  }
}

# Database specification variables
variable "db_plan" {
  description = "Database plan specification"
  type        = string
  default     = "90g"
  validation {
    condition = contains([
      "10g", "30g", "90g", "240g", "500g", "1t"
    ], var.db_plan)
    error_message = "Database plan must be one of: 10g, 30g, 90g, 240g, 500g, 1t."
  }
}

variable "db_backup_time" {
  description = "Database backup time (HH:MM format)"
  type        = string
  default     = "02:00"
  validation {
    condition     = can(regex("^([01]?[0-9]|2[0-3]):[0-5][0-9]$", var.db_backup_time))
    error_message = "Database backup time must be in HH:MM format (e.g., 02:00)."
  }
}