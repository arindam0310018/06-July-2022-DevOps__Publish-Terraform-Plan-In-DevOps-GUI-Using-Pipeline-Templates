# Azure Resource Group:-
resource "azurerm_resource_group" "rg" {
  name     = var.rg-name
  location = var.rg-location
}

## Azure log Analytics Workspace:-

resource "azurerm_log_analytics_workspace" "loga" {
  name                = var.loga-name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.loga-sku 
  retention_in_days   = var.loga-retention

  depends_on          = [azurerm_resource_group.rg]
}
