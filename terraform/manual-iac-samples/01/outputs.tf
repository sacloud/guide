output "web_server_primary_global_ip" {
  description = "Global IP address of Web Server in Primary Region"
  value       = sakura_server.web_primary.ip_address
}

output "web_server_secondary_global_ip" {
  description = "Global IP address of Web Server in Secondary Region"
  value       = sakura_server.web_secondary.ip_address
}

output "web_server_primary_private_ip" {
  description = "Private IP address of Web Server in Primary Region"
  value       = cidrhost(local.primary_subnet, 11)
}

output "web_server_secondary_private_ip" {
  description = "Private IP address of Web Server in Secondary Region"
  value       = cidrhost(local.secondary_subnet, 11)
}

output "gslb_fqdn" {
  description = "GSLB FQDN for global load balancing"
  value       = sakura_gslb.main.fqdn
}

# Database outputs
output "master_database_ip" {
  description = "Private IP address of Master Database"
  value       = cidrhost(local.primary_subnet, 50)
}

output "slave_database_ip" {
  description = "Private IP address of Slave Database"
  value       = cidrhost(local.secondary_subnet, 50)
}

# Region and network configuration outputs
output "primary_region" {
  description = "Primary region"
  value       = var.primary_region
}

output "secondary_region" {
  description = "Secondary region"
  value       = var.secondary_region
}

output "primary_subnet_cidr" {
  description = "Primary region subnet CIDR"
  value       = local.primary_subnet
}

output "secondary_subnet_cidr" {
  description = "Secondary region subnet CIDR"
  value       = local.secondary_subnet
}

output "selected_os_type" {
  description = "Selected operating system type"
  value       = var.os_type
}

