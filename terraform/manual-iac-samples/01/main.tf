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
  alias = "primary"
  zone  = var.primary_region
}

provider "sakura" {
  alias = "secondary"
  zone  = var.secondary_region
}


# Dynamic archive selection based on OS type
data "sakura_archive" "selected_os_primary" {
  provider = sakura.primary
  os_type  = var.archive_name_filter == "" ? (var.archive_ostype != "" ? var.archive_ostype : var.os_type) : null
  name     = var.archive_name_filter != "" ? var.archive_name_filter : null
}

data "sakura_archive" "selected_os_secondary" {
  provider = sakura.secondary
  os_type  = var.archive_name_filter == "" ? (var.archive_ostype != "" ? var.archive_ostype : var.os_type) : null
  name     = var.archive_name_filter != "" ? var.archive_name_filter : null
}

