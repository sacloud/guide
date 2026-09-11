locals {
  web_server_gateway        = cidrhost(var.private_network_cidr, 1)
  web_server_network_prefix = tonumber(split("/", var.private_network_cidr)[1])
  database_ip               = cidrhost(var.private_network_cidr, 21)
}

resource "sakura_disk" "web_disk" {
  count = var.web_server_count

  name              = "${var.prefix}-web-disk-${format("%02d", count.index + 1)}"
  source_archive_id = data.sakura_archive.web_os.id
  size              = var.web_server_disk_size
  plan              = var.web_server_disk_plan
  connector         = "virtio"
}

resource "sakura_server" "web_server" {
  count = var.web_server_count

  name        = "${var.prefix}-web-server-${format("%02d", count.index + 1)}"
  disks       = [sakura_disk.web_disk[count.index].id]
  core        = var.web_server_core
  memory      = var.web_server_memory
  description = "Secure Web Server ${format("%02d", count.index + 1)}"

  network_interface = [{
    upstream = "shared"
    # packet_filter_id = sakura_packet_filter.web_filter.id
    }, {
    upstream        = sakura_vswitch.private.id
    user_ip_address = cidrhost(var.private_network_cidr, count.index + 11)
  }]

  disk_edit_parameter = {
    hostname            = "${var.prefix}-web-${format("%02d", count.index + 1)}"
    password_wo         = var.server_password
    password_wo_version = 1
    disable_pw_auth     = false
  }
}

resource "sakura_database" "main" {
  name                = "${var.prefix}-database"
  description         = "Database appliance - private network only"
  plan                = var.db_plan
  username            = var.db_username
  password_wo         = var.db_password
  password_wo_version = 1

  network_interface = {
    vswitch_id = sakura_vswitch.private.id
    ip_address = local.database_ip
    netmask    = local.web_server_network_prefix
    gateway    = local.web_server_gateway
    # packet_filter_id = sakura_packet_filter.database_filter.id
  }
}