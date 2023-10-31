output "id" {
  value = azurerm_eventhub_namespace.default.id
}

output "name" {
  value = azurerm_eventhub_namespace.default.name
}

output "eventhub_ids" {
  value = { for key, value in azurerm_eventhub.default : value.name => value.id }
}

output "eventhub_partition_ids" {
  value = { for key, value in azurerm_eventhub.default : value.name => value.partition_ids }
}
