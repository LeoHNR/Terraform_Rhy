resource "azurerm_storage_account" "storage_account" {
  name                     = "storage${var.project}${var.environment}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
}

resource "azurerm_storage_container" "blob_container" {
  name                  = "db-rhythmnest"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}

resource "azurerm_private_endpoint" "blob_private_endpoint" {
  name                = "storage-private-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.subnetapp.id

  private_service_connection {
    name                           = "storage-private-${var.project}-${var.environment}"
    private_connection_resource_id = azurerm_storage_account.storage_account.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
  tags = var.tags
}

resource "azurerm_private_dns_zone" "sa_private_dns_zone" {
  name                = "privatelink.storage.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags
}

resource "azurerm_private_dns_a_record" "sa_private_dns_a_record" {
  name                = "storage-record-${var.project}-${var.environment}"
  zone_name           = azurerm_private_dns_zone.sa_private_dns_zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.blob_private_endpoint.private_service_connection[0].private_ip_address]

}

resource "azurerm_private_dns_zone_virtual_network_link" "sa_vnet_link" {
  name                = "sa-vnetlink-${var.project}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.sa_private_dns_zone.name
  virtual_network_id  = azurerm_virtual_network.vnet.id

}