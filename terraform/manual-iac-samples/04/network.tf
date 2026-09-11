locals {
  vpn_router_gateway        = cidrhost(var.private_network_cidr, 1)
  vpn_router_network_prefix = tonumber(split("/", var.private_network_cidr)[1])
  vpn_range_start           = cidrhost(var.private_network_cidr, var.vpn_ip_range_start)
  vpn_range_end             = cidrhost(var.private_network_cidr, var.vpn_ip_range_end)
}

resource "sakura_vswitch" "private" {
  name        = "${var.prefix}-private-switch"
  description = "Private network switch for server communication"
}

resource "sakura_vpn_router" "main" {
  name        = "${var.prefix}-vpn-router"
  description = "VPN Router as Internet Gateway with WireGuard support"
  plan        = var.vpn_router_plan

  # public_network_interface {
  #   upstream = "shared"
  # }

  private_network_interface = [{
    index        = 1
    vswitch_id   = sakura_vswitch.private.id
    ip_addresses = [local.vpn_router_gateway]
    netmask      = local.vpn_router_network_prefix
  }]

  # Firewall configuration commented out due to API changes
  # firewall {
  #   direction = "send"
  #   expression {
  #     protocol = "tcp"
  #     dest_port = "22"
  #     action = "allow"
  #   }
  # }

  l2tp = {
    pre_shared_secret_wo = var.vpn_pre_shared_secret
    pre_shared_secret_wo_version = 1
    range_start       = local.vpn_range_start
    range_stop        = local.vpn_range_end
  }

  user = [{
    name                = var.vpn_username
    password_wo         = var.vpn_password
    password_wo_version = 1
  }]

  # WireGuard configuration
  wire_guard = var.wireguard_enabled ? {
    ip_address = var.wireguard_server_ip
    peer = [for peer in var.wireguard_peers : {
      name       = peer.name
      ip_address = peer.ip_address
      public_key = peer.public_key
    }]
  } : null
}

# Packet filter for servers - allow only private network traffic
# resource "sakura_packet_filter" "server_filter" {
#   name        = "${var.prefix}-server-filter"
#   description = "Packet filter for servers - private network only"
# }