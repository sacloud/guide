variable "prefix" {
  description = "Resource name prefix"
  type        = string
  default     = "example-08"
}

variable "monitoring_zone" {
  description = "Zone for monitoring resources"
  type        = string
}

variable "business_zone" {
  description = "Zone for business operations resources"
  type        = string
}

variable "server_password" {
  description = "Password for server root user"
  type        = string
  sensitive   = true
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