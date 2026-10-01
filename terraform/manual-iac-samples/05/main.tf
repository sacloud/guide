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
  alias = "monitoring"
  zone  = var.monitoring_zone
}

provider "sakura" {
  alias = "business"
  zone  = var.business_zone
}

data "sakura_archive" "windows_monitoring" {
  provider = sakura.monitoring
  os_type  = "ubuntu2404"
}

data "sakura_archive" "windows_business" {
  provider = sakura.business
  os_type  = "ubuntu2404"
}

data "sakura_archive" "sophos_business" {
  provider = sakura.business
  os_type  = "ubuntu2404"
}