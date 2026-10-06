terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

locals {
  prefix = "tf"
}

module "nginx" {
  source        = "./modules/nginx"
  for_each      = var.sites
  name          = "${local.prefix}-${each.key}"
  external_port = each.value
}
