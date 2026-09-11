locals {
  server_gateway         = cidrhost(var.private_network_cidr, 1)
  server_network_prefix  = tonumber(split("/", var.private_network_cidr)[1])
  nfs_server_ip_internal = cidrhost(var.private_network_cidr, 21)
}

resource "sakura_disk" "server_disk" {
  count = var.server_count

  name              = "${var.prefix}-server-disk-${format("%02d", count.index + 1)}"
  source_archive_id = data.sakura_archive.server_os.id
  size              = var.server_disk_size
  plan              = var.server_disk_plan
  connector         = "virtio"
}

resource "sakura_server" "server" {
  count = var.server_count

  name        = "${var.prefix}-server-${format("%02d", count.index + 1)}"
  disks       = [sakura_disk.server_disk[count.index].id]
  core        = var.server_core
  memory      = var.server_memory
  description = "File Server ${format("%02d", count.index + 1)} with NFS and Samba"

  # Only private network interface - no direct internet access
  network_interface = [{
    upstream        = sakura_vswitch.private.id
    user_ip_address = cidrhost(var.private_network_cidr, count.index + 11)
    # packet_filter_id = sakura_packet_filter.server_filter.id
  }]

  disk_edit_parameter = {
    hostname            = "${var.prefix}-server-${format("%02d", count.index + 1)}"
    password_wo         = var.server_password
    password_wo_version = 1
    disable_pw_auth     = false


    # Cloud-init configuration for NFS and Samba setup
    # note {
    #   id      = 1
    #   api_key_id = ""
    #   variables = {
    #     startup_script = local.cloud_init_config
    #   }
    # }
  }
}

resource "sakura_nfs" "main" {
  name        = "${var.prefix}-nfs"
  description = "Network File Storage for shared data"
  plan        = "ssd"  # or "hdd"
  size        = "100"  # size depends on your plan and zone

  network_interface = {
    vswitch_id = sakura_vswitch.private.id
    ip_address = local.nfs_server_ip_internal
    netmask    = local.server_network_prefix
    gateway    = local.server_gateway
  }
}
