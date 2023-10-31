module "private-endpoint" {
  source              = "jsathler/private-endpoint/azurerm"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  private_endpoint = {
    name                           = "${azurerm_storage_account.default.name}-blob"
    subnet_id                      = module.vnet.subnet_ids.default-snet
    private_connection_resource_id = azurerm_storage_account.default.id
    subresource_name               = "blob"

    application_security_group_ids = [azurerm_application_security_group.default.id]
    private_dns_zone_id            = module.private-zone.private_zone_ids["privatelink.blob.core.windows.net"]
  }
}
