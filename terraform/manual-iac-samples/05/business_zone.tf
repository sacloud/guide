# Business Operations Zone (Tokyo Region)

# UTM Server - Sophos Firewall as Internet Gateway for Business Zone
resource "sakura_disk" "utm_disk" {
  provider          = sakura.business
  name              = "${var.prefix}-utm-disk"
  source_archive_id = data.sakura_archive.sophos_business.id
  size              = 100
  plan              = "ssd"
  connector         = "virtio"
}

resource "sakura_server" "utm_server" {
  provider    = sakura.business
  name        = "${var.prefix}-utm-server"
  disks       = [sakura_disk.utm_disk.id]
  core        = 2
  memory      = 4
  description = "Sophos UTM Server - Internet Gateway"

  # Public internet connection
  network_interface = [{
    upstream = "shared"
    }, {
    upstream        = sakura_vswitch.business_switch.id
    user_ip_address = "192.168.1.1"
  }]

  disk_edit_parameter = {
    hostname            = "${var.prefix}-utm"
    password_wo         = var.server_password
    password_wo_version = 1
    disable_pw_auth     = false

  }
}

# Authentication Management Server - Private network only
resource "sakura_disk" "auth_disk" {
  provider          = sakura.business
  name              = "${var.prefix}-auth-disk"
  source_archive_id = data.sakura_archive.windows_business.id
  size              = 100
  plan              = "ssd"
  connector         = "virtio"
}

resource "sakura_server" "auth_server" {
  provider    = sakura.business
  name        = "${var.prefix}-auth-server"
  disks       = [sakura_disk.auth_disk.id]
  core        = 1
  memory      = 4
  description = "Authentication Management Server"

  # Only private network - no direct internet access
  network_interface = [{
    upstream        = sakura_vswitch.business_switch.id
    user_ip_address = "192.168.1.12"
  }]

  disk_edit_parameter = {
    hostname            = "${var.prefix}-auth"
    password_wo         = var.server_password
    password_wo_version = 1
    disable_pw_auth     = false
  }
}

# Business Operations Server - Private network only
resource "sakura_disk" "business_disk" {
  provider          = sakura.business
  name              = "${var.prefix}-business-disk"
  source_archive_id = data.sakura_archive.windows_business.id
  size              = 100
  plan              = "ssd"
  connector         = "virtio"
}

resource "sakura_server" "business_server" {
  provider    = sakura.business
  name        = "${var.prefix}-business-server"
  disks       = [sakura_disk.business_disk.id]
  core        = 1
  memory      = 4
  description = "Business Operations Server"

  # Only private network - no direct internet access
  network_interface = [{
    upstream        = sakura_vswitch.business_switch.id
    user_ip_address = "192.168.1.13"
  }]

  disk_edit_parameter = {
    hostname            = "${var.prefix}-business"
    password_wo         = var.server_password
    password_wo_version = 1
    disable_pw_auth     = false
  }
}

# Database Appliance - Private network only
resource "sakura_database" "business_db" {
  provider            = sakura.business
  name                = "${var.prefix}-business-database"
  description         = "Business Database Appliance"
  plan                = "90g"
  username            = var.db_username
  password_wo         = var.db_password
  password_wo_version = 1

  network_interface = {
    vswitch_id = sakura_vswitch.business_switch.id
    ip_address = "192.168.1.21"
    netmask    = 24
    gateway    = "192.168.1.1" # UTM server as gateway
  }
}