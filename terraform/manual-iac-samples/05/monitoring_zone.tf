# Monitoring Zone (Ishikari Region)

resource "sakura_disk" "monitoring_disk" {
  provider          = sakura.monitoring
  name              = "${var.prefix}-monitoring-disk"
  source_archive_id = data.sakura_archive.windows_monitoring.id
  size              = 100
  plan              = "ssd"
  connector         = "virtio"
}

resource "sakura_server" "monitoring_server" {
  provider    = sakura.monitoring
  name        = "${var.prefix}-monitoring-server"
  disks       = [sakura_disk.monitoring_disk.id]
  core        = 1
  memory      = 4
  description = "Windows Monitoring Server"

  network_interface = [{
    upstream        = sakura_vswitch.monitoring_switch.id
    user_ip_address = "192.168.0.11"
  }]

  disk_edit_parameter = {
    hostname            = "${var.prefix}-monitoring"
    password_wo         = var.server_password
    password_wo_version = 1
    disable_pw_auth     = false

  }
}