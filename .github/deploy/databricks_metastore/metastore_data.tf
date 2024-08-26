# Required data fields for azure cloud
data "azurerm_subscription" "primary" {
}

data "azuread_service_principal" "cicd_spn" {
  display_name = module.global_variables.cicdSpnName
}