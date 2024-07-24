<!-- BEGIN_TF_DOCS -->
# Azure Eventhub Terraform module

Terraform module which creates Azure Eventhub resources on Azure.

Supported Azure services:

* [Azure Eventhub](https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-about)
* [Azure Eventhub Namespace](https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-features#namespace)
* [Azure Eventhub Consumer Groups](https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-features#consumer-groups)
* [Azure Eventhub SAS Authorization](https://learn.microsoft.com/en-us/azure/event-hubs/authorize-access-shared-access-signature)
* [Azure Eventhub RBAC Authorization](https://learn.microsoft.com/en-us/azure/event-hubs/authorize-access-azure-active-directory)
* [Azure Private Endpoint](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.6 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.70.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.70.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_eventhub.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub) | resource |
| [azurerm_eventhub_authorization_rule.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_authorization_rule) | resource |
| [azurerm_eventhub_consumer_group.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_consumer_group) | resource |
| [azurerm_eventhub_namespace.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace) | resource |
| [azurerm_eventhub_namespace_authorization_rule.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace_authorization_rule) | resource |
| [azurerm_role_assignment.eventhub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.namespace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eventhubs"></a> [eventhubs](#input\_eventhubs) | n/a | <pre>list(object({<br>    name              = string<br>    partition_count   = optional(number, 1)<br>    message_retention = optional(number, 3)<br>    status            = optional(string, "Active")<br><br>    capture_description = optional(object({<br>      encoding            = optional(string, "Avro")<br>      interval_in_seconds = optional(number, 300)<br>      size_limit_in_bytes = optional(number, 314572800)<br>      skip_empty_archives = optional(bool, false)<br>      destination = object({<br>        name                = optional(string, "EventHubArchive.AzureBlockBlob")<br>        archive_name_format = string<br>        blob_container_name = optional(string, "eventhub")<br>        storage_account_id  = string<br>      })<br>    }), null)<br><br>    consumer_groups = optional(list(object({<br>      name          = string<br>      user_metadata = optional(string, null)<br>    })), null)<br><br>    sas_key_auth = optional(list(object({<br>      name   = string<br>      listen = optional(bool, false)<br>      send   = optional(bool, false)<br>      manage = optional(bool, false)<br>    })), null)<br><br>    rbac_auth = optional(list(object({<br>      object_id = string<br>      sender    = optional(bool, false)<br>      receiver  = optional(bool, false)<br>      owner     = optional(bool, false)<br>    })), null)<br>  }))</pre> | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The region where the Data Factory will be created. This parameter is required | `string` | `"northeurope"` | no |
| <a name="input_name_sufix_append"></a> [name\_sufix\_append](#input\_name\_sufix\_append) | Define if all resources names should be appended with sufixes according to https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations. | `bool` | `true` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | n/a | <pre>object({<br>    name                         = string<br>    sku                          = optional(string, "Standard")<br>    capacity                     = optional(number, 1)<br>    auto_inflate_enabled         = optional(bool, false)<br>    dedicated_cluster_id         = optional(string, null)<br>    maximum_throughput_units     = optional(number, 40)<br>    zone_redundant               = optional(bool, true)<br>    local_authentication_enabled = optional(bool, true)<br>    minimum_tls_version          = optional(string, "1.2")<br><br>    identity = optional(object({<br>      type         = optional(string, "SystemAssigned")<br>      identity_ids = optional(list(string), null)<br>    }), null)<br><br>    sas_key_auth = optional(list(object({<br>      name   = string<br>      listen = optional(bool, false)<br>      send   = optional(bool, false)<br>      manage = optional(bool, false)<br>    })), null)<br><br>    rbac_auth = optional(list(object({<br>      object_id = string<br>      sender    = optional(bool, false)<br>      receiver  = optional(bool, false)<br>      owner     = optional(bool, false)<br>    })), null)<br>  })</pre> | n/a | yes |
| <a name="input_network_rules"></a> [network\_rules](#input\_network\_rules) | n/a | <pre>object({<br>    public_network_access_enabled  = optional(bool, false)<br>    default_action                 = optional(string, "Deny")<br>    trusted_service_access_enabled = optional(bool, false)<br>    subnet_ids                     = optional(list(string), null)<br>    allowed_ips                    = optional(list(string), null)<br>  })</pre> | `{}` | no |
| <a name="input_private_endpoint"></a> [private\_endpoint](#input\_private\_endpoint) | n/a | <pre>object({<br>    name                           = string<br>    subnet_id                      = string<br>    application_security_group_ids = optional(list(string))<br>    private_dns_zone_id            = string<br>  })</pre> | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which the resources will be created. This parameter is required | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to resources. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eventhub_authorization"></a> [eventhub\_authorization](#output\_eventhub\_authorization) | Evenhub authorization keys and connection strings |
| <a name="output_eventhub_consumer_group_ids"></a> [eventhub\_consumer\_group\_ids](#output\_eventhub\_consumer\_group\_ids) | Evenhub consumer group ids |
| <a name="output_eventhub_ids"></a> [eventhub\_ids](#output\_eventhub\_ids) | Evenhub IDs |
| <a name="output_eventhub_partition_ids"></a> [eventhub\_partition\_ids](#output\_eventhub\_partition\_ids) | Evenhub partition IDs |
| <a name="output_namespace_authorization"></a> [namespace\_authorization](#output\_namespace\_authorization) | Evenhub namespace authorization keys and connection strings |
| <a name="output_namespace_id"></a> [namespace\_id](#output\_namespace\_id) | Evenhub namespace ID |
| <a name="output_namespace_name"></a> [namespace\_name](#output\_namespace\_name) | Evenhub namespace Name |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | Private endpoint address |

## Examples
```hcl
module "eventhub" {
  source              = "jsathler/eventhub/azurerm"
  resource_group_name = azurerm_resource_group.default.name

  namespace = {
    name                     = local.prefix
    auto_inflate_enabled     = true
    maximum_throughput_units = 3

    sas_key_auth = [
      { name = "app1", send = true },
      { name = "app2", manage = true }
    ]

    rbac_auth = [{ object_id = data.azurerm_client_config.default.object_id, sender = true }]
  }

  network_rules = {
    public_network_access_enabled = true
  }

  eventhubs = [
    {
      name = "${local.prefix}-1"
      sas_key_auth = [
        { name = "app3", send = true, listen = true },
        { name = "app4", manage = true },
        { name = "app5", listen = true }
      ]
      rbac_auth = [{ object_id = data.azurerm_client_config.default.object_id, owner = true }]
    },
    {
      name            = "${local.prefix}-2"
      partition_count = 2
      consumer_groups = [{ name = "group1" }, { name = "group2" }]
      rbac_auth       = [{ object_id = data.azurerm_client_config.default.object_id, receiver = true }]
    }
  ]
}
```
More examples in ./examples folder
<!-- END_TF_DOCS -->