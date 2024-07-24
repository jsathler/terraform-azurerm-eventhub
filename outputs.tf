output "namespace_id" {
  description = "Evenhub namespace ID"
  value       = azurerm_eventhub_namespace.default.id
}

output "namespace_name" {
  description = "Evenhub namespace Name"
  value       = azurerm_eventhub_namespace.default.name
}

output "namespace_authorization" {
  description = "Evenhub namespace authorization keys and connection strings"
  value = try([for key, value in azurerm_eventhub_namespace_authorization_rule.default : {
    name                        = value.name
    id                          = value.id
    primary_connection_string   = value.primary_connection_string
    primary_key                 = value.primary_key
    secondary_connection_string = value.secondary_connection_string
    secondary_key               = value.secondary_key
    }
  ], null)
}

output "eventhub_ids" {
  description = "Evenhub IDs"
  value       = try({ for key, value in azurerm_eventhub.default : value.name => value.id }, null)
}

output "eventhub_partition_ids" {
  description = "Evenhub partition IDs"
  value       = try({ for key, value in azurerm_eventhub.default : value.name => value.partition_ids }, null)
}

output "eventhub_authorization" {
  description = "Evenhub authorization keys and connection strings"
  value = try([for key, value in azurerm_eventhub_authorization_rule.default : {
    name                        = value.name
    id                          = value.id
    primary_connection_string   = value.primary_connection_string
    primary_key                 = value.primary_key
    secondary_connection_string = value.secondary_connection_string
    secondary_key               = value.secondary_key
    }
  ], null)
}

output "eventhub_consumer_group_ids" {
  description = "Evenhub consumer group ids"
  value = try([for key, value in azurerm_eventhub_consumer_group.default : {
    name          = key
    eventhub_name = split("/", value.id)[10]
    id            = value.id
    }
  ], null)
}

output "private_ip_address" {
  description = "Private endpoint address"
  value       = module.private-endpoint["namespace"].private_ip_address
}
