variable "zone" {
  description = "Target zone"
  type        = string
}

variable "prefix" {
  description = "Resource name prefix"
  type        = string
  default     = "example-07"
}

variable "server_password" {
  description = "Password for server root user"
  type        = string
  sensitive   = true
}

# Server configuration
variable "server_count" {
  description = "Number of servers"
  type        = number
  default     = 2
  validation {
    condition     = var.server_count >= 1 && var.server_count <= 10
    error_message = "Server count must be between 1 and 10."
  }
}

variable "server_os_type" {
  description = "OS type for servers (cloud-init supported)"
  type        = string
  default     = "ubuntu"
  validation {
    condition     = contains(["ubuntu", "debian"], var.server_os_type)
    error_message = "OS type must be one of: ubuntu, debian (cloud-init supported)."
  }
}

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
  default     = 4
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

# NFS configuration
variable "nfs_server_ip" {
  description = "NFS server IP address"
  type        = string
  default     = ""
}

variable "nfs_export_path" {
  description = "NFS export path on the server"
  type        = string
  default     = "/export/shared"
}

variable "nfs_mount_point" {
  description = "Local mount point for NFS"
  type        = string
  default     = "/mnt/shared"
}

# Samba configuration
variable "samba_workgroup" {
  description = "Samba workgroup name"
  type        = string
  default     = "WORKGROUP"
}

variable "samba_server_string" {
  description = "Samba server description string"
  type        = string
  default     = "Samba Server"
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
  description = "VPC Router plan"
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