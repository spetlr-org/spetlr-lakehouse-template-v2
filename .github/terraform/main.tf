resource "azurerm_resource_group" "rg" {
  name = local.resource_group_name
  location = var.location  # Change this as needed
  tags = {
    creator = var.creator_tag
    system = var.system_tag
    service = var.service_tag
  }
}

resource "azurerm_storage_account" "storage_account" {
  name                     = local.resource_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    creator = var.creator_tag
    system = var.system_tag
    service = var.service_tag
  }
}