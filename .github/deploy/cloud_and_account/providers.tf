terraform {
  required_providers {
    azurerm   = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0"
    }
    databricks = {
      source = "databricks/databricks"
    }
  }
  backend "azurerm" {
      resource_group_name  = "Terraform-State-Stoarge"
      storage_account_name = "spetlrlhv2tfstate"
      container_name       = "tfstate"
      key                  = "terraform_cloud_and_account.tfstate"
  }
}

provider "azurerm" {
  features {}
}

provider "databricks" {
  alias      = "account"
  host       = "https://accounts.azuredatabricks.net"
  account_id = module.global_variables.db_account_id
}

provider "databricks" {
  alias               = "workspace"
  host                = azurerm_key_vault_secret.db_ws_url.value
  azure_client_id     = data.azuread_service_principal.db_meta_spn.client_id
  azure_client_secret = azuread_service_principal_password.db_meta_spn_password.value
  azure_tenant_id     = data.azurerm_client_config.current.tenant_id
}