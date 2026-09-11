output "web_server_global_ips" {
  description = "Global IP addresses of Web Servers"
  value       = sakura_server.web_server[*].ip_address
}

output "web_server_private_ips" {
  description = "Private IP addresses of Web Servers"
  value       = [for i in range(var.web_server_count) : cidrhost(var.private_network_cidr, i + 11)]
}

output "vpc_router_global_ip" {
  description = "Global IP address of VPC Router"
  value       = sakura_vpn_router.main.public_ip
}

output "vpc_router_private_ip" {
  description = "Private IP address of VPC Router"
  value       = cidrhost(var.private_network_cidr, 1)
}

output "database_private_ip" {
  description = "Private IP address of Database"
  value       = cidrhost(var.private_network_cidr, 21)
}

# output "database_fqdn" {
#   description = "Database FQDN"
#   value       = sakura_database.main.fqdn
# }

output "vpn_l2tp_range" {
  description = "L2TP VPN IP range"
  value       = "${cidrhost(var.private_network_cidr, var.vpn_ip_range_start)}-${cidrhost(var.private_network_cidr, var.vpn_ip_range_end)}"
}

output "private_network_cidr" {
  description = "Private network CIDR"
  value       = var.private_network_cidr
}

output "connection_info" {
  description = "Connection information"
  value = {
    web_servers = [
      for i in range(var.web_server_count) : {
        name          = "${var.prefix}-web-server-${format("%02d", i + 1)}"
        public_ip     = sakura_server.web_server[i].ip_address
        private_ip    = cidrhost(var.private_network_cidr, i + 11)
        ssh_command   = "ssh root@${sakura_server.web_server[i].ip_address}"
        allowed_ports = "80, 443 (from anywhere), all (from private network)"
      }
    ]
    database = {
      # fqdn       = sakura_database.main.fqdn
      private_ip = cidrhost(var.private_network_cidr, 21)
      port       = 3306
      username   = var.db_username
      access     = "Private network only (${var.private_network_cidr})"
    }
    vpn = {
      l2tp = {
        server_ip = sakura_vpn_router.main.public_ip
        username  = var.vpn_username
        ip_range  = "${cidrhost(var.private_network_cidr, var.vpn_ip_range_start)}-${cidrhost(var.private_network_cidr, var.vpn_ip_range_end)}"
      }
      wireguard = var.wireguard_enabled ? {
        server_ip      = sakura_vpn_router.main.public_ip
        server_port    = var.wireguard_port
        server_network = var.wireguard_server_ip
        peers          = var.wireguard_peers
      } : null
    }
    admin_access = {
      allowed_networks = var.admin_source_networks
      services         = "SSH (port 22), WireGuard (port ${var.wireguard_port})"
    }
  }
}

