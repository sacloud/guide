resource "sakura_vswitch" "monitoring_switch" {
  provider    = sakura.monitoring
  name        = "${var.prefix}-monitoring-switch"
  bridge_id   = sakura_bridge.inter_region.id
  description = "Monitoring zone switch"
}

resource "sakura_vswitch" "business_switch" {
  provider    = sakura.business
  name        = "${var.prefix}-business-switch"
  bridge_id   = sakura_bridge.inter_region.id
  description = "Business operations zone switch"
}

resource "sakura_bridge" "inter_region" {
  provider    = sakura.monitoring
  name        = "${var.prefix}-bridge"
  description = "Bridge connection between monitoring and business zones"
}

# VPC Router moved to monitoring zone
resource "sakura_vpn_router" "monitoring_router" {
  provider    = sakura.monitoring
  name        = "${var.prefix}-monitoring-vpc-router"
  description = "VPC Router for monitoring zone VPN"
  plan        = "standard"

  # public_network_interface {
  #   upstream = "shared"
  # }

  private_network_interface = [{
    index        = 1
    vswitch_id   = sakura_vswitch.monitoring_switch.id
    ip_addresses = ["192.168.0.1"]
    netmask      = 24
  }]

  l2tp = {
    pre_shared_secret_wo = var.vpn_pre_shared_secret
    pre_shared_secret_wo_version = 1
    range_start       = "192.168.0.240"
    range_stop        = "192.168.0.249"
  }

  user = [{
    name                = var.vpn_username
    password_wo         = var.vpn_password
    password_wo_version = 1
  }]
}

resource "sakura_internet" "monitoring_router_extra" {
  provider    = sakura.monitoring
  name        = "${var.prefix}-monitoring-router-extra"
  netmask     = 28
  band_width  = 100
  enable_ipv6 = false
  description = "Additional IPv4 block for monitoring zone"
}