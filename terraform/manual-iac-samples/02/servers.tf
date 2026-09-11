resource "sakura_server" "initial" {
  name        = "${var.prefix}-initial"
  core        = var.server_core
  memory      = var.server_memory
  description = "Initial server for auto scale template"

  disks = [sakura_disk.initial.id]

  network_interface = [{
    upstream = "shared"
  }]

  disk_edit_parameter = {
    hostname            = "${var.prefix}-initial"
    password_wo         = var.server_password
    password_wo_version = 1
    disable_pw_auth     = false
  }
}

data "sakura_archive" "ubuntu" {
  os_type = "ubuntu"
}

resource "sakura_disk" "initial" {
  name        = "${var.prefix}-initial-disk"
  size        = var.server_disk_size
  plan        = var.server_disk_plan
  connector   = "virtio"
  description = "Initial server disk for auto scale template"

  source_archive_id = var.initial_server_archive_id != "" ? var.initial_server_archive_id : data.sakura_archive.ubuntu.id
  source_disk_id    = var.initial_server_disk_id != "" ? var.initial_server_disk_id : null
}