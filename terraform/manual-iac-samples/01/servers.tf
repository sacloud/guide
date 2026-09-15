resource "sakura_disk" "web_disk_primary" {
  provider          = sakura.primary
  name              = "${var.prefix}-web-disk-${var.primary_region}"
  source_archive_id = data.sakura_archive.selected_os_primary.id
  size              = var.server_disk_size
  plan              = var.server_disk_plan
  connector         = "virtio"
}

resource "sakura_server" "web_primary" {
  provider    = sakura.primary
  name        = "${var.prefix}-web-server-${var.primary_region}"
  disks       = [sakura_disk.web_disk_primary.id]
  core        = var.server_core
  memory      = var.server_memory
  description = "Web Server in Primary Region (${var.primary_region})"

  network_interface = [{
    upstream = "shared"
  },{
    upstream        = sakura_vswitch.switch_primary.id
    user_ip_address = cidrhost(local.primary_subnet, 11)
  }]

  disk_edit_parameter = {
    hostname            = "${var.prefix}-web-${var.primary_region}"
    password_wo         = var.server_password
    password_wo_version = 1
    disable_pw_auth     = contains(["windows2019", "windows2022", "windows2025"], var.os_type) ? true : false
  }
}

resource "sakura_disk" "web_disk_secondary" {
  provider          = sakura.secondary
  name              = "${var.prefix}-web-disk-${var.secondary_region}"
  source_archive_id = data.sakura_archive.selected_os_secondary.id
  size              = var.server_disk_size
  plan              = var.server_disk_plan
  connector         = "virtio"
}

resource "sakura_server" "web_secondary" {
  provider    = sakura.secondary
  name        = "${var.prefix}-web-server-${var.secondary_region}"
  disks       = [sakura_disk.web_disk_secondary.id]
  core        = var.server_core
  memory      = var.server_memory
  description = "Web Server in Secondary Region (${var.secondary_region})"

  network_interface = [{
    upstream = "shared"
  },{
    upstream        = sakura_vswitch.switch_secondary.id
    user_ip_address = cidrhost(local.secondary_subnet, 11)
  }]

  disk_edit_parameter = {
    hostname            = "${var.prefix}-web-${var.secondary_region}"
    password_wo         = var.server_password
    password_wo_version = 1
    disable_pw_auth     = contains(["windows2019", "windows2022", "windows2025"], var.os_type) ? true : false
  }
}