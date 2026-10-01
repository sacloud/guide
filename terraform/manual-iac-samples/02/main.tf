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

