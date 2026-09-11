# Monitoring Zone Outputs
output "monitoring_server_global_ip" {
  description = "Global IP address of Monitoring Server"
  value       = sakura_server.monitoring_server.ip_address
}

output "monitoring_server_private_ip" {
  description = "Private IP address of Monitoring Server"
  value       = "192.168.0.11"
}

# Business Zone Outputs
output "utm_server_global_ip" {
  description = "Global IP address of UTM Server"
  value       = sakura_server.utm_server.ip_address
}

output "utm_server_private_ip" {
  description = "Private IP address of UTM Server"
  value       = "192.168.1.11"
}

output "auth_server_private_ip" {
  description = "Private IP address of Authentication Server"
  value       = "192.168.1.12"
}

output "business_server_private_ip" {
  description = "Private IP address of Business Operations Server"
  value       = "192.168.1.13"
}

output "business_database_private_ip" {
  description = "Private IP address of Business Database"
  value       = "192.168.1.21"
}

output "vpc_router_global_ip" {
  description = "Global IP address of VPC Router (in monitoring zone)"
  value       = sakura_vpn_router.monitoring_router.public_ip
}

output "vpn_l2tp_range" {
  description = "L2TP VPN IP range (monitoring zone)"
  value       = "192.168.0.240-192.168.0.249"
}

