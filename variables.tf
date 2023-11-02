variable "location" {
  description = "The region where the Data Factory will be created. This parameter is required"
  type        = string
  default     = "northeurope"
  nullable    = false
}

variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created. This parameter is required"
  type        = string
  nullable    = false
}
variable "tags" {
  description = "Tags to be applied to resources."
  type        = map(string)
  default     = null
}

variable "name_sufix_append" {
  description = "Define if all resources names should be appended with sufixes according to https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations."
  type        = bool
  default     = true
  nullable    = false
}

variable "eventhub_namespace" {
  type = object({
    name                         = string
    sku                          = optional(string, "Standard")
    capacity                     = optional(number, 1)
    auto_inflate_enabled         = optional(bool, false)
    dedicated_cluster_id         = optional(string, null)
    maximum_throughput_units     = optional(number, 40)
    zone_redundant               = optional(bool, true)
    local_authentication_enabled = optional(bool, true)
    minimum_tls_version          = optional(string, "1.2")

    identity = optional(object({
      type         = optional(string, "SystemAssigned")
      identity_ids = optional(list(string), null)
    }), null)

    sas_key_auth = optional(list(object({
      name   = string
      listen = optional(bool, false)
      send   = optional(bool, false)
      manage = optional(bool, false)
    })), null)

    rbac_auth = optional(list(object({
      object_id = string
      sender    = optional(bool, false)
      receiver  = optional(bool, false)
      owner     = optional(bool, false)
    })), null)
  })
}

variable "network_rules" {
  type = object({
    public_network_access_enabled  = optional(bool, false)
    default_action                 = optional(string, "Deny")
    trusted_service_access_enabled = optional(bool, false)
    subnet_ids                     = optional(list(string), null)
    allowed_ips                    = optional(list(string), null)
  })

  default  = {}
  nullable = false
}

variable "eventhubs" {
  type = list(object({
    name              = string
    partition_count   = optional(number, 1)
    message_retention = optional(number, 3)
    status            = optional(string, "Active")

    capture_description = optional(object({
      encoding            = optional(string, "Avro")
      interval_in_seconds = optional(number, 300)
      size_limit_in_bytes = optional(number, 314572800)
      skip_empty_archives = optional(bool, false)
      destination = object({
        name                = optional(string, "EventHubArchive.AzureBlockBlob")
        archive_name_format = optional(string, "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}")
        blob_container_name = optional(string, "eventhub")
        storage_account_id  = string
      })
    }), null)

    sas_key_auth = optional(list(object({
      name   = string
      listen = optional(bool, false)
      send   = optional(bool, false)
      manage = optional(bool, false)
    })), null)

    rbac_auth = optional(list(object({
      object_id = string
      sender    = optional(bool, false)
      receiver  = optional(bool, false)
      owner     = optional(bool, false)
    })), null)
  }))

  default = null
}

variable "private_endpoint" {
  type = object({
    name                           = string
    subnet_id                      = string
    application_security_group_ids = optional(list(string))
    private_dns_zone_id            = string
  })

  default = null
}
