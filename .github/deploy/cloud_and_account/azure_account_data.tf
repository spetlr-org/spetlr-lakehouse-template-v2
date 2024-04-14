# Required data fields for azure cloud

data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "current" {
}

data "azuread_service_principal" "cicd_spn" {
  display_name = var.cicdSpnName
}

data "azuread_client_config" "current" {}