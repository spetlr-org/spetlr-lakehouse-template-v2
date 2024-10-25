data "azurerm_key_vault" "key_vault" {
  name                = local.resource_name
  resource_group_name = local.resource_group_name
}