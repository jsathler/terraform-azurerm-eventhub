locals {
  prefix = basename(path.cwd)
  #prefix = "${basename(path.cwd)}-${random_string.default.result}"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "default" {
  name     = "${local.prefix}-rg"
  location = "northeurope"
}

resource "random_string" "default" {
  length    = 6
  min_lower = 6
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "azurerm_application_security_group" "default" {
  name                = "${local.prefix}-asg"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
}

module "vnet" {
  source              = "jsathler/network/azurerm"
  version             = "0.0.2"
  name                = local.prefix
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  address_space       = ["10.0.0.0/16"]

  subnets = {
    default = {
      address_prefixes   = ["10.0.0.0/24"]
      nsg_create_default = false
    }
  }
}

module "private-zone" {
  source              = "jsathler/dns-zone/azurerm"
  version             = "0.0.1"
  resource_group_name = azurerm_resource_group.default.name
  zones = {
    "privatelink.servicebus.windows.net" = {
      private = true
      vnets = {
        "${local.prefix}-vnet" = { id = module.vnet.vnet_id }
      }
    }
  }
}

module "eventhub" {
  source              = "../../"
  resource_group_name = azurerm_resource_group.default.name

  eventhub_namespace = {
    name = local.prefix
  }

  eventhubs = [
    {
      name = "${local.prefix}-1"
    }
  ]

  private_endpoint = {
    name                           = "${module.eventhub.name}-namespace"
    subnet_id                      = module.vnet.subnet_ids.default-snet
    application_security_group_ids = [azurerm_application_security_group.default.id]
    private_dns_zone_id            = module.private-zone.private_zone_ids["privatelink.servicebus.windows.net"]
  }
}

output "eventhub" {
  value = module.eventhub
}
