locals {
  tags = merge(var.tags, { ManagedByTerraform = "True" })
}

###########
# Namespace
###########

resource "azurerm_eventhub_namespace" "default" {
  name                          = var.name_sufix_append ? "${var.eventhub_namespace.name}-evhns" : var.eventhub_namespace.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = "Standard"
  capacity                      = var.eventhub_namespace.capacity
  dedicated_cluster_id          = var.eventhub_namespace.dedicated_cluster_id
  auto_inflate_enabled          = var.eventhub_namespace.auto_inflate_enabled
  maximum_throughput_units      = var.eventhub_namespace.auto_inflate_enabled ? var.eventhub_namespace.maximum_throughput_units : null
  zone_redundant                = var.eventhub_namespace.zone_redundant
  local_authentication_enabled  = var.eventhub_namespace.local_authentication_enabled
  public_network_access_enabled = try(var.network_rules.public_network_access_enabled, false)
  minimum_tls_version           = var.eventhub_namespace.minimum_tls_version
  tags                          = local.tags

  dynamic "identity" {
    for_each = var.eventhub_namespace.identity == null ? [] : [var.eventhub_namespace.identity]
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "network_rulesets" {
    for_each = var.network_rules == null ? [] : [var.network_rules]
    content {
      default_action                 = network_rulesets.value.default_action
      public_network_access_enabled  = var.network_rules.public_network_access_enabled
      trusted_service_access_enabled = network_rulesets.value.trusted_service_access_enabled

      dynamic "virtual_network_rule" {
        for_each = var.network_rules.subnet_ids == null ? [] : var.network_rules.subnet_ids
        content {
          subnet_id                                       = virtual_network_rule.value
          ignore_missing_virtual_network_service_endpoint = false
        }
      }

      dynamic "ip_rule" {
        for_each = var.network_rules.allowed_ips == null ? [] : var.network_rules.allowed_ips
        content {
          ip_mask = ip_rule.value
          action  = "Allow"
        }
      }
    }
  }
}

###########
# Cluster
###########

###########
# Eventhub
###########

resource "azurerm_eventhub" "default" {
  for_each            = var.eventhubs == null ? {} : { for key, value in var.eventhubs : value.name => value }
  name                = var.name_sufix_append ? "${each.value.name}-evh" : each.value.name
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_eventhub_namespace.default.name
  partition_count     = each.value.partition_count
  message_retention   = each.value.message_retention
  status              = each.value.status

  dynamic "capture_description" {
    for_each = each.value.capture_descriptioncapture_description == null ? [] : [each.value.capture_descriptioncapture_description]

    content {
      enabled             = true
      encoding            = capture_descriptioncapture_description.value.encoding
      interval_in_seconds = capture_descriptioncapture_description.value.interval_in_seconds
      size_limit_in_bytes = capture_descriptioncapture_description.value.size_limit_in_bytes
      skip_empty_archives = capture_descriptioncapture_description.value.skip_empty_archives

      destination {
        name                = capture_descriptioncapture_description.value.destination.name
        archive_name_format = capture_descriptioncapture_description.value.destination.archive_name_format
        blob_container_name = capture_descriptioncapture_description.value.destination.blob_container_name
        storage_account_id  = capture_descriptioncapture_description.value.destination.storage_account_id
      }
    }
  }
}

#######
# Create private endpoint
#######

module "private-endpoint" {
  for_each            = var.private_endpoint == null ? [] : toset(["namespace"])
  source              = "jsathler/private-endpoint/azurerm"
  version             = "0.0.1"
  location            = var.location
  resource_group_name = var.resource_group_name
  name_sufix_append   = var.name_sufix_append
  tags                = local.tags

  private_endpoint = {
    name                           = var.private_endpoint.name
    subnet_id                      = var.private_endpoint.subnet_id
    private_connection_resource_id = azurerm_eventhub_namespace.default.id
    subresource_name               = "namespace"
    application_security_group_ids = var.private_endpoint.application_security_group_ids
    private_dns_zone_id            = var.private_endpoint.private_dns_zone_id
  }
}
