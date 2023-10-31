locals {
  prefix = "${basename(path.cwd)}-${random_string.default.result}"
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

module "eventhub" {
  source              = "../../"
  resource_group_name = azurerm_resource_group.default.name

  eventhub_namespace = {
    name = local.prefix
    #public_network_access_enabled = false
  }

  # network_rules = {
  #   #trusted_service_access_enabled = true 
  #   allowed_ips = [chomp(data.http.myip.response_body)]
  # }

  # eventhub = {
  #   name           = local.prefix
  #   namespace_name = null
  # }
}

output "eventhub" {
  value = module.eventhub
}
