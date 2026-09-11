resource "sakura_vswitch" "switch_primary" {
  provider    = sakura.primary
  name        = "${var.prefix}-switch-${var.primary_region}"
  description = "Private network switch for primary region ${var.primary_region} (${local.primary_subnet})"
}

resource "sakura_vswitch" "switch_secondary" {
  provider    = sakura.secondary
  name        = "${var.prefix}-switch-${var.secondary_region}"
  description = "Private network switch for secondary region ${var.secondary_region} (${local.secondary_subnet})"
}


resource "sakura_bridge" "bridge" {
  provider    = sakura.primary
  name        = "${var.prefix}-bridge"
  description = "Bridge connection between ${var.primary_region} and ${var.secondary_region}"
}

resource "sakura_gslb" "main" {
  provider    = sakura.primary
  name        = "${var.prefix}-gslb"
  description = "Global Server Load Balancing"

  health_check = {
    protocol = "http"
    #    host_header = var.domain_name
    path       = "/"
    delay_loop = 10
    status     = "200"
  }

  server = [{
    ip_address = sakura_server.web_primary.ip_address
    weight     = 1
    enabled    = true
  },{
    ip_address = sakura_server.web_secondary.ip_address
    weight     = 1
    enabled    = true
  }]
}