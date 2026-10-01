variable "zone" {
  description = "Target zone"
  type        = string
}

variable "prefix" {
  description = "Resource name prefix"
  type        = string
  default     = "example-03"
}

variable "server_password" {
  description = "Password for server root user"
  type        = string
  sensitive   = true
}

variable "api_key_id" {
  description = "API key ID for auto scale operations"
  type        = string
}

variable "min_size" {
  description = "Minimum number of servers"
  type        = number
  default     = 2
}

variable "change_count" {
  description = "Number of servers to add/remove during scaling"
  type        = number
  default     = 1
}

variable "cpu_threshold_scaling" {
  description = "Enable CPU threshold scaling"
  type        = bool
  default     = true
}

variable "cpu_threshold_up" {
  description = "CPU threshold for scale up"
  type        = number
  default     = 80
}

variable "cpu_threshold_down" {
  description = "CPU threshold for scale down"
  type        = number
  default     = 20
}

variable "router_threshold_scaling" {
  description = "Enable router threshold scaling"
  type        = bool
  default     = false
}

variable "router_threshold_up" {
  description = "Router threshold for scale up (Mbps)"
  type        = number
  default     = 100
}

variable "router_threshold_down" {
  description = "Router threshold for scale down (Mbps)"
  type        = number
  default     = 10
}

variable "scale_up_hour" {
  description = "Hour for scheduled scale up"
  type        = number
  default     = 8
}

variable "scale_up_minute" {
  description = "Minute for scheduled scale up"
  type        = number
  default     = 0
}

variable "scale_down_hour" {
  description = "Hour for scheduled scale down"
  type        = number
  default     = 18
}

variable "scale_down_minute" {
  description = "Minute for scheduled scale down"
  type        = number
  default     = 0
}

# Server specification variables

variable "server_core" {
  description = "Number of CPU cores for auto scale servers"
  type        = number
  default     = 2
  validation {
    condition     = contains([1, 2, 4, 8, 16, 32], var.server_core)
    error_message = "Server core must be one of: 1, 2, 4, 8, 16, 32."
  }
}

variable "server_memory" {
  description = "Memory size in GB for auto scale servers"
  type        = number
  default     = 2
  validation {
    condition     = contains([1, 2, 4, 8, 16, 32, 64, 128], var.server_memory)
    error_message = "Server memory must be one of: 1, 2, 4, 8, 16, 32, 64, 128."
  }
}

variable "server_disk_size" {
  description = "Disk size in GB for auto scale servers"
  type        = number
  default     = 100
  validation {
    condition     = var.server_disk_size >= 20 && var.server_disk_size <= 4000
    error_message = "Server disk size must be between 20 and 4000 GB."
  }
}

variable "server_disk_plan" {
  description = "Disk plan for auto scale servers (ssd or hdd)"
  type        = string
  default     = "ssd"
  validation {
    condition     = contains(["ssd", "hdd"], var.server_disk_plan)
    error_message = "Server disk plan must be either 'ssd' or 'hdd'."
  }
}

# Initial server disk source configuration (REQUIRED - either disk_id or archive_id must be specified)
variable "initial_server_disk_id" {
  description = "Source disk ID for initial server"
  type        = string
  default     = ""
}

variable "initial_server_archive_id" {
  description = "Source archive ID for initial server (e.g., Ubuntu 26.04, Rocky Linux)"
  type        = string
  default     = ""
}

# Auto scale clone source configuration (optional - will use initial server disk if not specified)
variable "clone_source_disk_id" {
  description = "Source disk ID for auto scale cloning (defaults to initial server disk)"
  type        = string
  default     = ""
}

variable "clone_source_archive_id" {
  description = "Source archive ID for auto scale cloning (defaults to initial server disk)"
  type        = string
  default     = ""
}

# Validation to ensure at least one initial server source is specified
locals {
  initial_server_source_specified = var.initial_server_disk_id != "" || var.initial_server_archive_id != ""
  clone_source_specified          = var.clone_source_disk_id != "" || var.clone_source_archive_id != ""
}

# Enhanced Load Balancer configuration
variable "elb_plan" {
  description = "Enhanced Load Balancer plan"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "highspec"], var.elb_plan)
    error_message = "ELB plan must be either 'standard' or 'highspec'."
  }
}

variable "elb_vip_port" {
  description = "Virtual IP port for Enhanced Load Balancer"
  type        = number
  default     = 80
  validation {
    condition     = var.elb_vip_port >= 1 && var.elb_vip_port <= 65535
    error_message = "ELB VIP port must be between 1 and 65535."
  }
}

variable "elb_delay_loop" {
  description = "Health check delay loop in seconds"
  type        = number
  default     = 10
  validation {
    condition     = var.elb_delay_loop >= 5 && var.elb_delay_loop <= 300
    error_message = "ELB delay loop must be between 5 and 300 seconds."
  }
}

variable "elb_sorry_server" {
  description = "Sorry server IP address (optional)"
  type        = string
  default     = ""
}

variable "elb_real_servers" {
  description = "List of real servers for load balancer"
  type = list(object({
    ip_address = string
    port       = number
    weight     = number
    enabled    = bool
  }))
  default = [
    {
      ip_address = "192.168.1.11"
      port       = 80
      weight     = 100
      enabled    = true
    },
    {
      ip_address = "192.168.1.12"
      port       = 80
      weight     = 100
      enabled    = true
    }
  ]
}