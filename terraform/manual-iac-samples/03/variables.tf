variable "zone" {
  description = "Target zone"
  type        = string
}

variable "prefix" {
  description = "Resource name prefix"
  type        = string
  default     = "example-06"
}

variable "server_password" {
  description = "Password for server root user"
  type        = string
  sensitive   = true
}

# Web server configuration
variable "web_server_count" {
  description = "Number of web servers"
  type        = number
  default     = 1
  validation {
    condition     = var.web_server_count >= 1 && var.web_server_count <= 10
    error_message = "Web server count must be between 1 and 10."
  }
}

variable "web_server_os_type" {
  description = "OS type for web servers"
  type        = string
  default     = "ubuntu"
  validation {
    condition     = contains(["ubuntu", "debian", "almalinux", "rockylinux"], var.web_server_os_type)
    error_message = "OS type must be one of: ubuntu, debian, almalinux, rockylinux."
  }
}

variable "web_server_core" {
  description = "Number of CPU cores for web servers"
  type        = number
  default     = 2
  validation {
    condition     = contains([1, 2, 4, 8, 16, 32], var.web_server_core)
    error_message = "Web server core must be one of: 1, 2, 4, 8, 16, 32."
  }
}

variable "web_server_memory" {
  description = "Memory size in GB for web servers"
  type        = number
  default     = 6
  validation {
    condition     = contains([1, 2, 4, 6, 8, 16, 32, 64, 128], var.web_server_memory)
    error_message = "Web server memory must be one of: 1, 2, 4, 6, 8, 16, 32, 64, 128."
  }
}

variable "web_server_disk_size" {
  description = "Disk size in GB for web servers"
  type        = number
  default     = 100
  validation {
    condition     = var.web_server_disk_size >= 20 && var.web_server_disk_size <= 4000
    error_message = "Web server disk size must be between 20 and 4000 GB."
  }
}

variable "web_server_disk_plan" {
  description = "Disk plan for web servers (ssd or hdd)"
  type        = string
  default     = "ssd"
  validation {
    condition     = contains(["ssd", "hdd"], var.web_server_disk_plan)
    error_message = "Web server disk plan must be either 'ssd' or 'hdd'."
  }
}

# Network configuration
variable "private_network_cidr" {
  description = "Private network CIDR"
  type        = string
  default     = "192.168.1.0/24"
  validation {
    condition     = can(cidrhost(var.private_network_cidr, 0))
    error_message = "Private network CIDR must be a valid CIDR notation."
  }
}

variable "vpn_ip_range_start" {
  description = "VPN IP range start (offset from network base)"
  type        = number
  default     = 240
  validation {
    condition     = var.vpn_ip_range_start >= 100 && var.vpn_ip_range_start <= 250
    error_message = "VPN IP range start must be between 100 and 250."
  }
}

variable "vpn_ip_range_end" {
  description = "VPN IP range end (offset from network base)"
  type        = number
  default     = 249
  validation {
    condition     = var.vpn_ip_range_end >= 100 && var.vpn_ip_range_end <= 254
    error_message = "VPN IP range end must be between 100 and 254."
  }
}

# Database configuration
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

variable "db_plan" {
  description = "Database plan"
  type        = string
  default     = "10g"
  validation {
    condition     = contains(["10g", "30g", "90g", "240g", "500g", "1t"], var.db_plan)
    error_message = "Database plan must be one of: 10g, 30g, 90g, 240g, 500g, 1t."
  }
}

variable "db_backup_time" {
  description = "Database backup time (HH:MM format)"
  type        = string
  default     = "00:00"
  validation {
    condition     = can(regex("^[0-2][0-9]:[0-5][0-9]$", var.db_backup_time))
    error_message = "Database backup time must be in HH:MM format."
  }
}

# VPN configuration
variable "vpn_pre_shared_secret" {
  description = "VPN pre-shared secret"
  type        = string
  sensitive   = true
}

variable "vpn_username" {
  description = "VPN username"
  type        = string
  default     = "vpnuser"
}

variable "vpn_password" {
  description = "VPN password"
  type        = string
  sensitive   = true
}

# Security configuration
variable "admin_source_networks" {
  description = "List of source networks/IPs allowed for admin access to VPC router"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "vpn_router_plan" {
  description = "VPN Router plan"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium", "highspec"], var.vpn_router_plan)
    error_message = "VPN Router plan must be one of: standard, premium, highspec."
  }
}

# WireGuard configuration
variable "wireguard_enabled" {
  description = "Enable WireGuard VPN"
  type        = bool
  default     = true
}

variable "wireguard_port" {
  description = "WireGuard UDP port"
  type        = number
  default     = 51820
  validation {
    condition     = var.wireguard_port >= 1024 && var.wireguard_port <= 65535
    error_message = "WireGuard port must be between 1024 and 65535."
  }
}

variable "wireguard_peers" {
  description = "List of WireGuard peer configurations"
  type = list(object({
    name       = string
    public_key = string
    ip_address = string
  }))
  default = [
    {
      name       = "client1"
      public_key = "PEER_PUBLIC_KEY_PLACEHOLDER"
      ip_address = "192.168.100.2/32"
    }
  ]
}

variable "wireguard_server_private_key" {
  description = "WireGuard server private key"
  type        = string
  sensitive   = true
  default     = "SERVER_PRIVATE_KEY_PLACEHOLDER"
}

variable "wireguard_server_ip" {
  description = "WireGuard server IP address with CIDR"
  type        = string
  default     = "192.168.100.1/24"
}