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

variable "namespace" {
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

  nullable = false

  validation {
    condition     = can(index(["Basic", "Standard", "Premium"], var.namespace.sku) >= 0)
    error_message = "Valid values are: Basic, Standard and Premium"
  }

  validation {
    condition     = var.namespace.maximum_throughput_units >= 1 && var.namespace.maximum_throughput_units <= 40
    error_message = "namespace.maximum_throughput_units should be between 1 and 40"
  }

  validation {
    condition     = can(index(["1.0", "1.1", "1.2"], var.namespace.minimum_tls_version) >= 0)
    error_message = "Valid values are: 1.0, 1.1 and 1.2"
  }

  validation {
    condition = var.namespace.rbac_auth == null ? true : alltrue([for rbac in var.namespace.rbac_auth :
      (rbac.sender && rbac.receiver == false && rbac.owner == false) || (rbac.sender == false && rbac.receiver && rbac.owner == false) || (rbac.sender == false && rbac.receiver == false && rbac.owner)
    ])
    error_message = "sender, receiver or owner are mutual exclusive in namespace.rbac_auth."
  }
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

  validation {
    condition     = can(index(["Allow", "Deny"], var.network_rules.default_action) >= 0)
    error_message = "Valid values for network_rules.default_action are: Allow and Deny"
  }
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
        archive_name_format = string
        blob_container_name = optional(string, "eventhub")
        storage_account_id  = string
      })
    }), null)

    consumer_groups = optional(list(object({
      name          = string
      user_metadata = optional(string, null)
    })), null)

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

  validation {
    condition     = var.eventhubs == null ? true : alltrue([for eventhub in var.eventhubs : can(index(["Active", "Disabled", "SendDisabled"], eventhub.status) >= 0)])
    error_message = "Allowed values for eventhubs.status are Active, Disabled and SendDisabled"
  }

  validation {
    condition     = var.eventhubs == null ? true : alltrue([for eventhub in var.eventhubs : eventhub.capture_description == null ? true : can(index(["Avro", "AvroDeflate"], eventhub.capture_description.encoding) >= 0)])
    error_message = "Allowed values for eventhubs.status are Avro and AvroDeflate"
  }

  validation {
    condition = var.eventhubs == null ? true : alltrue([for eventhub in var.eventhubs : alltrue([
      for rbac in eventhub.rbac_auth :
      (rbac.sender && rbac.receiver == false && rbac.owner == false) || (rbac.sender == false && rbac.receiver && rbac.owner == false) || (rbac.sender == false && rbac.receiver == false && rbac.owner)
    ]) if eventhub.rbac_auth != null])
    error_message = "sender, receiver or owner are mutual exclusive in eventhubs.rbac_auth."
  }
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
