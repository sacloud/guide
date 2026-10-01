# Master Database in primary region
resource "sakura_database" "master" {
  provider            = sakura.primary
  name                = "${var.prefix}-db-master-${var.primary_region}"
  description         = "Master Database in primary region (${var.primary_region})"
  plan                = var.db_plan
  username            = var.db_username
  password_wo         = var.db_password
  password_wo_version = 1

  network_interface = {
    vswitch_id = sakura_vswitch.switch_primary.id
    ip_address = cidrhost(local.primary_subnet, 50)
    netmask    = split("/", local.primary_subnet)[1]
    gateway    = cidrhost(local.primary_subnet, 1)
  }

  depends_on = [sakura_vswitch.switch_primary]
}

# Slave Database in secondary region
resource "sakura_database" "slave" {
  provider            = sakura.secondary
  name                = "${var.prefix}-db-slave-${var.secondary_region}"
  description         = "Slave Database in secondary region (${var.secondary_region})"
  plan                = var.db_plan
  username            = var.db_username
  password_wo         = var.db_password
  password_wo_version = 1

  network_interface = {
    vswitch_id = sakura_vswitch.switch_secondary.id
    ip_address = cidrhost(local.secondary_subnet, 50)
    netmask    = split("/", local.secondary_subnet)[1]
    gateway    = cidrhost(local.secondary_subnet, 1)
  }

  depends_on = [sakura_vswitch.switch_secondary, sakura_database.master]
}