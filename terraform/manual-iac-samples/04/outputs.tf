output "vpc_router_global_ip" {
  description = "Global IP address of VPC Router"
  value       = sakura_vpn_router.main.public_ip
}

output "vpc_router_private_ip" {
  description = "Private IP address of VPC Router (Gateway)"
  value       = cidrhost(var.private_network_cidr, 1)
}

output "server_private_ips" {
  description = "Private IP addresses of servers"
  value       = [for i in range(var.server_count) : cidrhost(var.private_network_cidr, i + 11)]
}

output "nfs_server_ip" {
  description = "NFS server IP address"
  value       = cidrhost(var.private_network_cidr, 21)
}

output "nfs_mount_point" {
  description = "NFS mount point on servers"
  value       = var.nfs_mount_point
}

output "samba_share_path" {
  description = "Samba share path (accessible via SMB)"
  value       = "//${cidrhost(var.private_network_cidr, 11)}/shared"
}

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
    servers = [
      for i in range(var.server_count) : {
        name        = "${var.prefix}-server-${format("%02d", i + 1)}"
        private_ip  = cidrhost(var.private_network_cidr, i + 11)
        description = "File server with NFS mount and Samba share"
        samba_share = "//${cidrhost(var.private_network_cidr, i + 11)}/shared"
        access_note = "No direct internet access - use VPC router as gateway"
      }
    ]
    nfs = {
      server_ip   = cidrhost(var.private_network_cidr, 21)
      export_path = var.nfs_export_path
      mount_point = var.nfs_mount_point
    }
    vpc_router = {
      public_ip  = sakura_vpn_router.main.public_ip
      private_ip = cidrhost(var.private_network_cidr, 1)
      role       = "Internet Gateway"
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

