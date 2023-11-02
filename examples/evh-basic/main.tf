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

module "eventhub" {
  source              = "../../"
  resource_group_name = azurerm_resource_group.default.name

  eventhub_namespace = {
    name                     = local.prefix
    auto_inflate_enabled     = true
    maximum_throughput_units = 3

    sas_key_auth = [
      { name = "app1", send = true },
      { name = "app2", manage = true }
    ]
  }

  network_rules = {
    public_network_access_enabled = true
  }

  eventhubs = [
    {
      name = "${local.prefix}-1"
      sas_key_auth = [
        { name = "app3", send = true },
        { name = "app4", manage = true },
        { name = "app5", listen = true }
      ]
    },
    {
      name = "${local.prefix}-2"
      #partition_count = 2
    }
  ]
}

output "eventhub" {
  value = module.eventhub
}
