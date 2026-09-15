output "initial_server_ip" {
  description = "IP address of the initial server"
  value       = sakura_server.initial.ip_address
}

output "initial_server_disk_id" {
  description = "Disk ID of the initial server (can be used for auto scale cloning)"
  value       = sakura_disk.initial.id
}

# output "load_balancer_ip" {
#   description = "IP address of Enhanced Load Balancer"
#   value       = sakura_dsr_lb.main.network_interface[0].ip_addresses[0]
# }

output "autoscale_group_id" {
  description = "Auto Scale group ID"
  value       = sakura_auto_scale.web_servers.id
}

