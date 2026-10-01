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

data "sakura_archive" "web_os" {
  os_type = var.web_server_os_type
}