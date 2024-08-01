resource "azurerm_mssql_server" "sql_server" {
  name                         = "sqlserver-${var.project}-${var.environment}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = var.password

  tags = var.tags

}

resource "azurerm_mssql_database" "sql_db" {
    name               = "rhy.db"
    server_id          = azurerm_mssql_server.sql_server.id
    sku_name           = "S0"

    tags = var.tags

}

resource "azurerm_private_endpoint" "sql_private_endpoint" {
  name                = "sql-private-endpoint-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.subnetdb.id

  private_service_connection {
    name                           = "sql-private-ec-${var.project}-${var.environment}"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  tags = var.tags
}

resource "azurerm_private_dns_zone" "private_dns_zone" {
  name                = "private.dbserver.database.windows.net"
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags
}

resource "azurerm_private_dns_a_record" "private_dns_a_record" {
  name                = "sqlserver-record-${var.project}-${var.environment}"
  zone_name           = azurerm_private_dns_zone.private_dns_zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.sql_private_endpoint.private_service_connection[0].private_ip_address]

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  name                = "vnetlink-${var.project}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone.name
  virtual_network_id  = azurerm_virtual_network.vnet.id

  tags = var.tags
}

resource "azurerm_sql_firewall_rule" "allow_my_ip" {
  name                = "allow_my_ip"
  resource_group_name = azurerm_mssql_server.sql_server.resource_group_name
  server_name         = azurerm_mssql_server.sql_server.name
  start_ip_address    = "201.190.16.157"
  end_ip_address      = "201.190.16.157"
}
