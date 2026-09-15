terraform {
  required_version = ">= 1.0"
  required_providers {
    sakura = {
      source  = "sacloud/sakura"
      version = "~> 3.0"
    }
  }
}

provider "sakura" {
  zone = var.zone
}

data "sakura_archive" "server_os" {
  os_type = var.server_os_type
}

# Cloud-init configuration for NFS mount and Samba server
locals {
  cloud_init_config = base64encode(templatefile("${path.module}/cloud-init.yaml.tpl", {
    nfs_server_ip       = var.nfs_server_ip != "" ? var.nfs_server_ip : cidrhost(var.private_network_cidr, 21)
    nfs_export_path     = var.nfs_export_path
    nfs_mount_point     = var.nfs_mount_point
    samba_workgroup     = var.samba_workgroup
    samba_server_string = var.samba_server_string
  }))
}